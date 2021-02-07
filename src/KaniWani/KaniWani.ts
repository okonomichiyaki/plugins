// lipsurf-plugins/src/KaniWani/KaniWani.ts
/// <reference types="lipsurf-types/extension"/>

declare const PluginBase: IPluginBase;

const kaniwaniDotCom = /^https:\/\/kaniwani.com\/.*$/;
const activePages = /^https:\/\/kaniwani.com\/(lessons|reviews)\/session$/;

enum FlashCardState {
    WaitingForAnswer = 0,
    CheckedAnswer
}

let currentState: FlashCardState;

interface KaniWaniAnswer {
    answer: string,
    kana: string
}

let previousLanguage: LanguageCode = PluginBase.util.getLanguage();

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

function getAnswers(): KaniWaniAnswer[] {
    let hidden=document.querySelector("#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.g04mrt-0.gqVjQO > div > div");
    if (hidden===null){
        console.log("[getAnswer] failed to find hidden div");
        return [];
    }
    let answer = hidden.getAttribute("data-ruby")
    if (answer===null){
        console.log("[getAnswer] found hidden div, but no data ruby");
        return [];
    }
    let parts = answer.split(' ');
    return [{answer: parts[0], kana: parts[1]}];
}

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string = "";

export function markWrong() {
    console.log("[markWrong]");
    const answer = document.getElementById("answer");
    if (answer !== null) {
        (answer as HTMLInputElement).value = "あああ";
        clickNext();
    }
    currentState = FlashCardState.CheckedAnswer;
    window.setTimeout(() => {
        // expand info card automatically:
        let info = document.querySelectorAll('#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.rsmiak-0.fjUYuW > button:nth-child(2)');
        console.log("info=%o", info);
        if (info.length > 0) {
            console.log("clicked info=%o", info);
            (info[0] as HTMLElement).click();
        }
    }, 100);
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    const answers = getAnswers();
    transcript = transcript.toLowerCase();
    console.log("[matchAnswer] t=%s,a=%o",transcript,answers);
    if (currentState !== FlashCardState.WaitingForAnswer) {
        matchedAnswer = "";
        console.log("[matchAnswer] ignoring");
        return undefined;
    }
    for (var i = 0; i < answers.length; i++) {
        const answer = katakanaToHiragana(answers[i].kana);
        if (answer === transcript ){
            console.log("[matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript);
            matchedAnswer = answers[i].answer;
            return [0, transcript.length, [answers[i].kana]];
        }
    }
    matchedAnswer = "";
    return undefined;
}

function clickNext() {
    let reviewSelector = '#app > div > main > div > div > div > section.sc-1y6l0g0-0.kzMdza > form > div > button > div > span';
    let lessonSelector = '#app > div > main > div > div > div > section.sc-1y6l0g0-0.dXcQgo > form > div > button > div > span';
    let selector = document.location.href.includes('reviews') ? reviewSelector : lessonSelector;
    const nextButtons = document.querySelectorAll(selector);
    if (nextButtons.length > 0) {
        (nextButtons.item(0) as HTMLElement).click();
    } else {
        console.log("[clickNext] failed to find next button")
    }
}

function inputAnswer(transcript: string) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const answer = document.getElementById("answer");
    if (answer !== null) {
        (answer as HTMLInputElement).value = matchedAnswer;
        clickNext();
        currentState = FlashCardState.CheckedAnswer;
    } else {
        console.log("[inputAnswer] answer was null");
    }
}

function exitKaniWaniContext() {
    console.log("[exitKaniWaniContext]");
    PluginBase.util.enterContext(["Normal"]);
    PluginBase.util.setLanguage(previousLanguage);
}

function enterKaniWaniContext() {
    console.log("[enterKaniWaniContext]");
    PluginBase.util.enterContext(["KaniWani Review"]);
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.setLanguage('ja');
    currentState = FlashCardState.WaitingForAnswer;
}

function locationChangeHandler() {
    if (document.location.href.match(activePages)) {
        enterKaniWaniContext();
    } else if (PluginBase.util.getContext().includes("KaniWani Review")) {
        exitKaniWaniContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "KaniWani",
    description: "",
    match: kaniwaniDotCom,
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
        exitKaniWaniContext();
    },
    contexts: {
        "KaniWani Review": {
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
            description: "Submit an English answer for a KaniWani review",
            match: {
                description: "[English answer]",
                fn: matchAnswer
            },
            context: "KaniWani Review",
            normal: false,
            pageFn: inputAnswer
        }, {
            name: "Next",
            description: "Go to the next item in a KaniWani review",
            match: "next",
            context: "KaniWani Review",
            normal: false,
            pageFn: () => {
                clickNext();
                currentState = FlashCardState.WaitingForAnswer;
            }
        }, {
            name: "Wrong",
            description: "Mark a card wrong",
            match: "wrong",
            context: "KaniWani Review",
            normal: false,
            pageFn: markWrong
        }
]
}};
