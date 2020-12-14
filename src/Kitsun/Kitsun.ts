// lipsurf-plugins/src/Kitsun/Kitsun.ts
/// <reference types="lipsurf-types/extension"/>

declare const PluginBase: IPluginBase;

enum FlashCardState {
    Flipping = 1,
    Flipped
}

let currentState: FlashCardState = FlashCardState.Flipping
let previousLanguage: LanguageCode = PluginBase.util.getLanguage();
let observer: MutationObserver | null = null;

// converts katakana characters in the string to hiragana. will be a no-op if no katakana
function katakanaToHiragana(s: string) {
    // not sure why but these unicode characters get garbled after being loaded into LS, so hardcoded the codepoint values
    const lower = 12448; //"゠".codePointAt(0)!;
    const upper = 12543; //"ヿ".codePointAt(0)!;
    const diff = 96;//"ア".codePointAt(0)! - "あ".codePointAt(0)!
    return s.split("").map(c => {
        const point = c.codePointAt(0)!;
        if (point >= lower && point <= upper) {
            return String.fromCodePoint(point - diff);
        } else {
            return c;
        }
    }).join("");
}

/**
 * extracts list of answers from comma separated string
 * also cleans up individual answers: trim spaces, remove parentheticals
 */
function splitAnswers(answers: string) {
    const cleaned = answers.replace(/\(.*\)/,"");
    return cleaned.split(",")
        .map(a => a.trim().toLowerCase())
        .filter(a => a.length != 0);
}

function getAnswers() {
    // first try to get the answer from typeans property:
    var results: string[] = [];
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        const answers = typeans.getAttribute("answer");
        if (answers !== null) {
            results = results.concat(splitAnswers(answers));
        }
    }
    // then try to get answers from combinedans property:
    const combinedans = document.getElementById("combinedans");
    if (combinedans !== null) {
        const answers = combinedans.innerHTML;
        if (answers !== null) {
            results = results.concat(splitAnswers(answers));
        }
    }
    return results;
}

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string = "";

export function markWrong() {
    const language = PluginBase.util.getLanguage();
    const incorrect = language === "en-US" ? "wrong" : "\u3060\u3081";
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        (typeans as HTMLInputElement).value = incorrect;
        clickNext();
    }
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    const answers = getAnswers();
    console.log("[matchAnswer] t="+transcript);
    for (var i = 0; i < answers.length; i++) {
        const hiragana = katakanaToHiragana(answers[i]);
        if (hiragana === transcript.toLowerCase()) {
            console.log("[matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript);
            matchedAnswer = answers[i];
            return [0, transcript.length, [answers[i]]];
        }
    }
    matchedAnswer = "";
    return undefined;
}

function clickNext() {
    const nextans = document.getElementById("nextans");
    if (nextans !== null) {
        nextans.click();
    } else {
        console.log("[clickNext] nextans was null")
    }
}

function inputAnswer(transcript: string) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        (typeans as HTMLInputElement).value = matchedAnswer;
        clickNext();
    } else {
        console.log("[inputAnswer] typeans was null");
    }
}

function setEnglish() {
    console.log("[setLanguage] setting to English");
    PluginBase.util.setLanguage("en");
}

function setJapanese() {
    console.log("[setLanguage] setting to Japanese");
    PluginBase.util.setLanguage("ja");
}

/**
 * sets the language in LipSurf for 10K deck
 */
function setLanguageFromQuest() {
    const quests = document.getElementsByClassName("quest");
    var found = false;
    for (var i = 0; i < quests.length; i++) {
        const quest = quests[i];
        const trimmed = quest.innerHTML.trim();
        if (trimmed === "Vocabulary Meaning") {
            setEnglish();
            found = true;
        } else if (trimmed === "Vocabulary Reading") {
            setJapanese();
            found = true;
        }
    }
    if (!found) {
        console.log("[setLanguageFromQuest] failed to find quest");
    }
    return found;
}

function setLanguageFromTypeans() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return false;
    }
    // first look for a placeholder in the typeans:
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning") {
        setEnglish();
        return true;
    } else if (placeholder === "Japanese" || placeholder === "Reading") {
        setJapanese();
        return true;
    } else {
        // then look for a language attribute on typeans:
        const lang = typeans.getAttribute("lang");
        if (lang === "ja") {
            setJapanese();
            return true;
        } else if (lang === "en") {
            setEnglish();
            return true;
        }
    }
    return false;
}

function setLanguage(): boolean {
    if (setLanguageFromTypeans() || setLanguageFromQuest()) {
        console.log("[setLanguage] successfully set language!");
        return true;
    } else {
        console.log("[setLanguage] failed to set language!");
        return false;
    }
}

/**
 * Watches the page for changes to flip between languages for different cards
 */
function mutationCallback(mutations, observer) {
    if (currentState === FlashCardState.Flipping &&
        document.location.href.match(/^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons)$/)) {
        if (setLanguage()) {
            currentState = FlashCardState.Flipped
        }
    }
};

function exitKitsunContext() {
    console.log("[exitKitsunContext]");
    PluginBase.util.enterContext(["Normal"]);
    PluginBase.util.setLanguage(previousLanguage);
    if (observer !== null) {
        observer.disconnect();
    }
}

function enterKitsunContext() {
    console.log("[enterKitsunContext]");
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
}

function locationChangeHandler() {
    if (document.location.href.match(/^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons)$/)) {
        enterKitsunContext();
    } else if (PluginBase.util.getContext().includes("Kitsun Review")) {
        exitKitsunContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Kitsun",
    description: "",
    match: /^https:\/\/kitsun\.io\/.*$/,
    version: "0.0.2",
    init: () => {
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
    },
    destroy: () => {
        window.removeEventListener('locationchange', locationChangeHandler);
        exitKitsunContext();
    },
    contexts: {
        "Kitsun Review": {
            commands: [
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
