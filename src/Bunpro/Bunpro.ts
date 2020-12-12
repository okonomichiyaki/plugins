// lipsurf-plugins/src/Bunpro/Bunpro.ts
/// <reference types="lipsurf-types/extension"/>

declare const PluginBase: IPluginBase;

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string = "";

const particles: { [key: string]: string } = {
    "もう":"も",
}

function fuzzyParticle(transcript: string): string {
    const maybe = particles[transcript]
    if (maybe === null) {
        return transcript;
    } else {
        return maybe
    }
}

function getAnswers() {
    return Array.from(document.querySelectorAll('.examples .japanese-example-sentence strong'))
        .map((x) => { return x.innerHTML });
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    transcript = transcript.toLowerCase();
    const answers = getAnswers();
    console.log("[matchAnswer] t="+transcript);
    for (var i = 0; i < answers.length; i++) {
        const hiragana = answers[i];//katakanaToHiragana(answers[i]);
        if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
            console.log("[matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript);
            matchedAnswer = answers[i];
            return [0, transcript.length, [answers[i]]];
        }
    }
    matchedAnswer = "";
    return undefined;
}

function inputAnswer(transcript: string) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
        (studyAreaInput as HTMLInputElement).value = matchedAnswer;
        clickNext();
    } else {
        console.log("[inputAnswer] studyAreaInput was null");
    }
}

function markWrong() {
    matchedAnswer = "あああ";
    inputAnswer(matchedAnswer);
}

function clickElement(selector: string) {
    const element = document.querySelector(selector) as HTMLElement;
    if (element !== null) {
        element.click();
    } else {
        console.log("[clickNext] %s was null", selector)
    }
}

// alternates
// #study-page > section.grammar-point.review-grammar-point > header > div.alternate-grammar
// or 'a'

// undo
// #study-page > section.grammar-point.review-grammar-point > div.study-input-bar > div.col-xs-2.col-sm-1.undo-button.tooltip.tooltipstered
// or backspace

function clickNext() {
    clickElement("#submit-study-answer");
}

function clickHint() {
    clickElement("#show-english-hint");
}

function enterBunproContext() {
    console.log("[enterBunproContext]");
    PluginBase.util.enterContext(["Bunpro"]);
    PluginBase.util.setLanguage("ja");
}

function exitBunproContext() {
    console.log("[exitBunproContext]");
    PluginBase.util.enterContext(["default"]);
    PluginBase.util.setLanguage("en");
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Bunpro",
    description: "",
    // Can't match on the paths because the app dynamically changes the URL?
    match: /.*www.bunpro.jp.*/,
    version: "0.0.1",
    init: enterBunproContext,
    destroy: exitBunproContext,
    contexts: {
        "Bunpro": {
            commands: [
                "Answer",
                "Hint",
                "Next",
                "Wrong"
            ]
        }
    },

    commands: [
        {
            name: "Answer",
            description: "Submit an answer for a Bunpro review",
            match: {
                description: "[answer]",
                fn: (transcript) => {
                    if (document.location.href.match(/.*www.bunpro.jp\/(learn|study|cram)$/)) {
                        return matchAnswer(transcript);
                    }
                }
            },
            normal: false,
            pageFn: inputAnswer
        }, {
            name: "Hint",
            description: "Toggle the translated hint",
            match: "hint",
            normal: false,
            pageFn: clickHint
        }, {
            name: "Next",
            description: "Go to the next card",
            match: "next",
            normal: false,
            pageFn: clickNext
        }, {
            name: "Wrong",
            description: "Mark a card wrong",
            match: "wrong",
            normal: false,
            pageFn: markWrong
        }
    ]
}};