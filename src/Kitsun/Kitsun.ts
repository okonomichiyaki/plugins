// lipsurf-plugins/src/Kitsun/Kitsun.ts
/// <reference types="lipsurf-types/extension"/>
import { prefectureToRomaji, isPrefecturesDeck } from "./prefectures";

declare const PluginBase: IPluginBase;

const activePages: RegExp = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/;
const FlashCardState: { Flipping: string, Flipped: string } = {
    "Flipping":"Flipping",
    "Flipped":"Flipped"
};

let currentState: string;
let previousLanguage: LanguageCode;
let observer: MutationObserver | null;

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string;

// converts katakana characters in the string to hiragana. will be a no-op if no katakana
function katakanaToHiragana(s: string): string {
    const lower = "゠".codePointAt(0)!;
    const upper = "ヿ".codePointAt(0)!;
    const diff = "ア".codePointAt(0)! - "あ".codePointAt(0)!
    return s.split("").map(c => {
        const point = c.codePointAt(0)!;
        if (point >= lower && point <= upper) {
            return String.fromCodePoint(point - diff);
        } else {
            return c;
        }
    }).join("");
}

function punctuationToSpace(s: string): string {
    return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/," ");
}

/**
 * extracts list of answers from comma separated string,also cleans up individual answers: trim spaces, remove parentheticals
 * also returns extra copies of answers, replacing any punctuation with spaces
 * e.g. transcript for "what age?" will not include "?" but for "one's regards" it will include "'" so try both
 */
function transformAnswers(raw: string): string[] {
    const results: string[] = []
    const noZeroWith = raw.replace(/[\u200B-\u200D\uFEFF]/g, '');
    const noParens = noZeroWith.replace(/\(.*\)/,"");
    const answers = noParens.split(",")
        .map(a => a.trim().toLowerCase())
        .filter(a => a.length != 0);
    for (var i = 0; i < answers.length; i++) {
        const answer = answers[i];
        results.push(answer);
        const noPunct = punctuationToSpace(answer);
        if (noPunct !== answer) {
            results.push(answer);
        }
    }
    return results;
}

function getAnswers() {
    // first try to get the answer from typeans property:
    var results: string[] = [];
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        const answers = typeans.getAttribute("answer");
        if (answers !== null) {
            results = results.concat(transformAnswers(answers));
        }
    }
    // then try to get answers from combinedans property:
    const combinedans = document.getElementById("combinedans");
    if (combinedans !== null) {
        const answers = combinedans.innerHTML;
        if (answers !== null) {
            results = results.concat(transformAnswers(answers));
        }
    }
    return results;
}

export function markWrong() {
    const language = PluginBase.util.getLanguage();
    const incorrect = language === "en-US" ? "wrong" : "あああ";
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        (typeans as HTMLInputElement).value = incorrect;
        clickNext();
    }
}

function compareAnswer(answer: string, transcript: string) {
    if (answer===transcript) {
        return true;
    }
    // check if the transcript is just the answer multiple times because the user's trying to get the engine to recognize
    if (transcript.replace(new RegExp(answer,"g"), "").length===0) {
        return true;
    }
    return false;
}

export function matchAnswer({preTs, normTs}: TsData): [number, number, any[]?]|undefined|false {
    const answers = getAnswers();
    let transcript = normTs.toLowerCase();
    console.log("[Kitsun.matchAnswer] t=%s, a=%o",transcript,answers);
    for (var i = 0; i < answers.length; i++) {
        const answer = katakanaToHiragana(answers[i]);
        // special case: current language is Japanese and answer is romaji, then maybe prefectures deck
        // so convert possible prefecture name to romaji and check that too
        const prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript)
        if (compareAnswer(answer, transcript) || prefectureMatch) {
            console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript);
            matchedAnswer = answers[i];
            return [0, transcript.length, [answers[i]]];
        }
    }
    matchedAnswer = "";
    return undefined;
}

function clickNext() {
    const quizButtons=document.querySelectorAll('body > div.swal2-container.swal2-center.swal2-fade.swal2-shown > div > div.swal2-buttonswrapper > button.swal2-confirm.swal2-styled');
    if (quizButtons.length > 0) {
        (quizButtons.item(0) as HTMLElement).click();
        return;
    }
    const nextans = document.getElementById("nextans");
    const nextButtons = document.querySelectorAll('.kitButton.flip_btn.kitButton__primary')
    if (nextans !== null) {
        nextans.click();
    } else if (nextButtons.length > 0) {
        (nextButtons.item(0) as HTMLElement).click();
    } else {
        console.log("[Kitsun.clickNext] failed to find next button")
    }
}

function inputAnswer({preTs, normTs}: TsData) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[Kitsun.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, normTs);
        return;
    }
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        (typeans as HTMLInputElement).value = matchedAnswer;
        clickNext();
    } else {
        console.log("[Kitsun.inputAnswer] typeans was null");
    }
}


/**
 * attempts to get the language for 10k listening cards based on .quest element(s)
 */
function getLanguageFromQuest(): "en" | "ja" | null {
    const quests = document.getElementsByClassName("quest");
    var found = false;
    for (var i = 0; i < quests.length; i++) {
        const quest = quests[i];
        const trimmed = quest.innerHTML.trim();
        if (trimmed === "Vocabulary Meaning") {
            return "en";
        } else if (trimmed === "Vocabulary Reading") {
            return "ja";
        }
    }
    return null;
}

/**
 * attempts to get the language for 10k, basic user deck based on #typeans element
 */
function getLanguageFromTypeans(): "en" | "ja" | null {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return null;
    }
   // first look for a placeholder in the typeans:
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning") {
        return "en";
    } else if (placeholder === "Japanese" || placeholder === "Reading") {
        return "ja";
    } else {
        // then look for a language attribute on typeans:
        const lang = typeans.getAttribute("lang");
        if (lang === null || (lang !== "ja" && lang !== "en")) {
            return null;
        }
        return lang;
    }
}

function setLanguage(): boolean {
    if (isPrefecturesDeck()) {
        console.log("[Kitsun.setLanguage] set to Japanese for prefectures deck");
        PluginBase.util.setLanguage("ja");
        return true;
    }
    var lang = getLanguageFromTypeans();
    if (lang !== null) {
        console.log("[Kitsun.setLanguage] set to %s based on typeans (10k/user deck)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    lang = getLanguageFromQuest();
    if (lang !== null) {
        console.log("[Kitsun.setLanguage] set to %s based on quest (10k)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }

    console.log("[Kitsun.setLanguage] failed to set language!");
    return false;
}

/**
 * Watches the page for changes to flip between languages for different cards
 */
function mutationCallback(mutations, observer) {
    console.log("[Kitsun.mutationCallback] " + FlashCardState[currentState]);
    if (currentState === FlashCardState.Flipping && document.location.href.match(activePages)) {
        if (setLanguage()) {
            currentState = FlashCardState.Flipped
        }
    }
}

function exitKitsunContext() {
    console.log("[Kitsun.exitKitsunContext]");
    PluginBase.util.enterContext(["Normal"]);
    if (previousLanguage !== null) {
        PluginBase.util.setLanguage(previousLanguage);
    }
    if (observer !== null) {
        observer.disconnect();
    }
}

function enterKitsunContext() {
    console.log("[Kitsun.enterKitsunContext]");
    currentState = FlashCardState.Flipping;
    PluginBase.util.enterContext(["Kitsun Review"]);
    previousLanguage = PluginBase.util.getLanguage();

    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Create an observer instance linked to the callback function
    observer = new MutationObserver(mutationCallback);

    // Start observing the target node for configured mutations
    const mainContainer = document.getElementsByClassName("main-container")[0];
    observer!.observe(mainContainer, config);
    
    // Trigger callback to check the language initially
    mutationCallback(null, null);
}

function locationChangeHandler() {
    if (document.location.href.match(activePages)) {
        enterKitsunContext();
    } else if (PluginBase.util.getContext().includes("Kitsun Review")) {
        exitKitsunContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Kitsun",
    description: "",
    match: /^https:\/\/kitsun\.io\/.*$/,
    apiVersion: 2,
    version: "0.0.4",
    init: () => {
        currentState = FlashCardState.Flipping;
        previousLanguage = PluginBase.util.getLanguage();
        const src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`
        var head = document.getElementsByTagName("head")[0];         
        var script = document.createElement('script');
        script.type = 'text/javascript';
        script.innerHTML = src;
        head.appendChild(script);
        window.addEventListener('locationchange', locationChangeHandler);
        locationChangeHandler();
    },
    destroy: () => {
        window.removeEventListener('locationchange', locationChangeHandler);
        exitKitsunContext();
    },
    contexts: {
        "Kitsun Review": {
            commands: [
                "Change Language to Japanese",
                "LipSurf.Normal Mode",
                "LipSurf.Turn off LipSurf",
                "Answer",
                "Next",
                "Wrong"
            ]
        }
    },
    commands: [
        {
            name: "Answer",
            description: "Submit an English answer for a Kitsun review",
            match: {
                description: "[English answer]",
                fn: matchAnswer
            },
            context: "Kitsun Review",
            normal: false,
            pageFn: inputAnswer
        }, {
            name: "Next",
            description: "Go to the next item in a Kitsun review",
            match: "next",
            context: "Kitsun Review",
            normal: false,
            pageFn: () => {
                currentState = FlashCardState.Flipping;
                clickNext();
            }
        }, {
            name: "Wrong",
            description: "Mark a card wrong",
            match: "wrong",
            context: "Kitsun Review",
            normal: false,
            pageFn: markWrong
        }
]
}};
