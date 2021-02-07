// lipsurf-plugins/src/Bunpro/Bunpro.ts
/// <reference types="lipsurf-types/extension"/>

declare const PluginBase: IPluginBase;

const flatMap = (arr, f) => [].concat.apply([], arr.map(f))

// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer: string = "";

// stores the previous language before we started Bunpro context
var previousLanguage: LanguageCode = PluginBase.util.getLanguage();

const particles: { [key: string]: string } = {
    "もう":"も",
    "わ":"は",
}

function fuzzyParticle(transcript: string): string {
    const maybe = particles[transcript]
    if (maybe === null) {
        return transcript;
    } else {
        return maybe
    }
}

function getStrongsFromPrompt(): string[] {
    let strongs = Array.from(document.querySelectorAll("div.study-question-japanese strong"));
    return strongs.map((strong) => (strong as Element).innerHTML);
}

function isKanjiWithFurigana(answer: Element): boolean {
    // are there any <ruby> tags?
    return Array.from(answer.childNodes).filter((child) => {
        return (child as Element).tagName === "RUBY"
    }).length > 0;
}

function getFurigana(answer: Element): string {
    return Array.from(answer.childNodes).map((child) => {
        if (child instanceof Text) {
            return (child as Text).data;
        } else if ((child as Element).tagName === "RUBY") {
            return Array.from((child as Element).querySelectorAll("rt")).map((rt) => rt.innerText).join('');
        }
    }).join('');
}

function isStrong(child: ChildNode): boolean {
    return (child as Element).tagName === "STRONG";
}

function isParticle(child: ChildNode): boolean {
    return child instanceof HTMLSpanElement && child.classList.contains("chui");
}

function getText(component:ChildNode): string {
    if (isKanjiWithFurigana(component as Element)) {
        return getFurigana(component as Element);
    }
    return (component as HTMLElement).innerText;
}

/* extract candidate answers from an example sentence, may include highlighted non-answers */
function getCandidateAnswers(sentence: Element): string[] {
    let candidates:string[] =[]
    let candidate:string | null = null
    let components =Array.from(sentence.childNodes);

    // step over the components of a sentence, joining together adjacent highlights
    for (let i = 0; i < components.length; i++) {
        const component = components[i];
        if (isStrong(component) || isParticle(component)) {
            if (candidate === null) {
                candidate = "";
            }
            candidate = candidate + getText(component);
        } else {
            if (candidate !== null) {
                candidates.push(candidate);
            }
            candidate=null;
        }
    }
    return candidates;
}

function getAnswers(): string[] {
    let promptStrongs = getStrongsFromPrompt();
    let sentences = Array.from(document.querySelectorAll('.examples .japanese-example-sentence'));
    let candidates = flatMap(sentences, getCandidateAnswers);
    
    // From the candidates filter out those that appear in the prompt:
    candidates = candidates.filter(candidate => {
        return !promptStrongs.includes(candidate);
    });

    let counts: Map<string, number> = new Map();
    candidates.forEach(candidate => {
        let value = counts.get(candidate);
        if (value === undefined) {
            counts.set(candidate,1);
        } else {
            counts.set(candidate,value+1);
        }
    });
    // filtering based on frequency in examples a bit too aggressive (eg のわりに)
    return Array.from(counts.keys());/*.filter(candidate => {
        let count=counts.get(candidate)
        return count!==undefined && count/candidates.length > 0.5;
    })*/
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    transcript = transcript.toLowerCase();
    const answers = getAnswers();
    console.log("[Bunpro.matchAnswer] t=%s,a=%o",transcript, answers);
    for (var i = 0; i < answers.length; i++) {
        const hiragana = answers[i];//katakanaToHiragana(answers[i]);
        if (hiragana === transcript || hiragana === fuzzyParticle(transcript)) {
            console.log("[Bunpro.matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript);
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
        console.log("[Bunpro.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const studyAreaInput = document.getElementById("study-answer-input");
    if (studyAreaInput !== null) {
        (studyAreaInput as HTMLInputElement).value = matchedAnswer;
        clickNext();
    } else {
        console.log("[Bunpro.inputAnswer] studyAreaInput was null");
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
        console.log("[Bunpro.clickElement] %s was null", selector)
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

function clickShowGrammar() {
    clickElement("#show-grammar");
}

function enterBunproContext() {
    console.log("[Bunpro.enterBunproContext]");
    previousLanguage = PluginBase.util.getLanguage();
    PluginBase.util.enterContext(["Bunpro"]);
    PluginBase.util.setLanguage("ja");
}

function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]");
    PluginBase.util.enterContext(["Normal"]);
    PluginBase.util.setLanguage(previousLanguage);
}

function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s",document.location.href);
    if (document.location.href.match(/.*bunpro.jp\/(learn|study|cram)$/)) {
        enterBunproContext();
    } else {
        exitBunproContext();
    }
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Bunpro",
    description: "",
    match: /.*bunpro.jp.*/,
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
        locationChangeHandler();
    },
    destroy: () => {
        window.removeEventListener('locationchange', locationChangeHandler);
        exitBunproContext();
    },
    contexts: {
        "Bunpro": {
            commands: [
                "LipSurf.Change Language to Japanese",
                "LipSurf.Normal Mode",
                "LipSurf.Turn off LipSurf",
                "Answer",
                "Hint",
                "Next",
                "Wrong",
                "Info"
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
        }, {
            name: "Info",
            description: "Show grammar info",
            match: "info",
            normal: false,
            pageFn: clickShowGrammar
        }
    ]
}};
