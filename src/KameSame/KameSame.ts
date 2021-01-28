// lipsurf-plugins/src/KameSame/KameSame.ts
/// <reference types="lipsurf-types/extension"/>

import {vocabulary} from './WaniKaniData'
declare const PluginBase: IPluginBase;

const kamesameDotCom = /^https:\/\/www.kamesame.com\/.*$/
const appReviewsStudy = /^https:\/\/www.kamesame.com\/app\/reviews\/study\/.*$/

enum FlashCardState {
    Flipping = 1,
    Flipped
}
let currentState: FlashCardState = FlashCardState.Flipping
let previousLanguage: LanguageCode = PluginBase.util.getLanguage();
let observer: MutationObserver | null = null;

/**
 * get alternative english prompts
 */
function getAlternatives(): string[] {
    let alternatives = document.querySelector("#study > div.synonyms > div");
    if (alternatives!==null) {
        return alternatives.innerHTML.split('•').map(s => {
            return s.trim();
        });
    }
    return [];
}

/**
 * get english prompt words
 */
function getWords(): string[] {
    let words = getAlternatives();
    var meaning=document.querySelector("#study > div.meaning > svg > text");
    if (meaning!==null) {
        let word = meaning.innerHTML;
        words.push(word);
    } else {
        console.log("[KameSame.getWords] meaning was null")
    }
    return words;
}

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string = "";

export function markWrong() {
    (document.getElementsByClassName("action fail")[0] as HTMLElement).click();
}

function clickNext() {
    currentState = FlashCardState.Flipping;
    (document.getElementsByClassName("emoji right")[0] as HTMLElement).click();
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    let words = getWords();
    let answers=words.reduce((acc: string[], word: string) => { // flat map
        let readingsMaybe = vocabulary[word];
        return readingsMaybe === undefined ? acc : acc.concat(readingsMaybe);
    }, []);
    console.log("[KameSame.matchAnswer] t=%s,w=%o,a=%o",transcript,words,answers);
    if (answers.includes(transcript)) {
        // Because there are many vocabulary (e.g. 文字, 得体) with the same english word, need to save the transcript
        matchedAnswer = transcript;
        return [0, transcript.length, [vocabulary[words[0]]]];
    }
    matchedAnswer = "";
    return undefined;
}

function inputAnswer(transcript: string) {
    if (matchedAnswer.length < 1) {
        console.log("[KameSame.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const input = document.querySelector("#study > div.input-area > input");
    if (input !== null) {
        (input as HTMLInputElement).value = matchedAnswer;
        clickNext();
    } else {
        console.log("[KameSame.inputAnswer] input was null");
    }
}

// need this any more ?
function mutationCallback(mutations, observer) {
    if (currentState === FlashCardState.Flipping && document.location.href.match(appReviewsStudy)) {
        currentState = FlashCardState.Flipped
    }
}

function exitKameSameContext() {
    console.log("[KameSame.exitKameSameContext]");
    PluginBase.util.enterContext(["Normal"]);
    PluginBase.util.setLanguage(previousLanguage);
    if (observer !== null) {
        observer.disconnect();
    }
}

function enterKameSameContext() {
    console.log("[KameSame.enterKameSameContext]");
    currentState = FlashCardState.Flipping;
    PluginBase.util.enterContext(["KameSame Review"]);
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.setLanguage("ja");

    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Create an observer instance linked to the callback function
    observer = new MutationObserver(mutationCallback);

    // Start observing the target node for configured mutations
    const mainContainer = document.body;//getElementsByClassName("kamesame")[0];
    observer!.observe(mainContainer, config);
}

/**
 * Watches for URL change, to detect the start of a review session
 */
function locationChangeHandler() {
    if (document.location.href.match(appReviewsStudy)) {
        enterKameSameContext();
    } else if (PluginBase.util.getContext().includes("KameSame Review")) {
        exitKameSameContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "KameSame",
    description: "",
    match: kamesameDotCom,
    version: "0.0.1",
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
        locationChangeHandler();
    },
    destroy: () => {
        window.removeEventListener('locationchange', locationChangeHandler);
        exitKameSameContext();
    },
    contexts: {
        "KameSame Review": {
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
            description: "",
            match: {
                description: "[English answer]",
                fn: matchAnswer
            },
            context: "KameSame Review",
            normal: false,
            pageFn: inputAnswer
        }, {
            name: "Next",
            description: "Go to the next item in a KameSame review",
            match: "next",
            context: "KameSame Review",
            normal: false,
            pageFn: () => {
                currentState = FlashCardState.Flipping;
                clickNext();
            }
        }, {
            name: "Wrong",
            description: "Mark a card wrong",
            match: "wrong",
            context: "KameSame Review",
            normal: false,
            pageFn: markWrong
        }
]
}};
