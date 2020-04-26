// lipsurf-plugins/src/Kitsun/Kitsun.ts
/// <reference types="lipsurf-plugin-types"/>

declare const PluginBase: IPluginBase;

let observer: MutationObserver | null = null;

function splitAnswers(answers: string) {
    return answers.split(",")
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
    console.log("[getAnswers] got " + results.length + " answers");
    return results;
}

export function matchAnswer(transcript: string): [number, number, any[]?]|undefined|false {
    const answers = getAnswers();
    console.log("[matchAnswer] transcript="+transcript);
    if (answers.includes(transcript.toLowerCase())) {
        return [0, transcript.length, [transcript]];
    }
    return undefined;
}

function clickNext() {
    const nextans = document.getElementById("nextans");
    if (nextans !== null) {
        nextans.click();
    } else {
        console.log("[nextItem] nextans was null")
    }
}

function inputAnswer(a: string) {
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        (typeans as HTMLInputElement).value = a;
        clickNext();
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

function findQuest() {
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
        console.log("[findQuest] failed to find quest");
    }
}

function setLanguage() {
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        // first look for a placeholder in the typeans:
        const placeholder = typeans.getAttribute("placeholder");
        if (placeholder === "English" || placeholder === "Meaning") {
            setEnglish();
        } else if (placeholder === "Japanese" || placeholder === "Reading") {
            setJapanese();
        } else {
            // then look for a language attribute on typeans:
            const lang = typeans.getAttribute("lang");
            if (lang !== null && lang === "ja") {
                setJapanese();
            } else if (lang !== null && lang === "en") {
                setEnglish();
            } else {
                // finally look for the "quest" component of the card:
                findQuest();
            }
        }
    } else {
        findQuest();
    }
};

function exitKitsunContext() {
    console.log("[exitKitsunContext]");
    PluginBase.util.enterContext(["default"]);
    if (observer !== null) {
        observer.disconnect();
    }
}

function enterKitsunContext() {
    console.log("[enterKitsunContext!]");
    PluginBase.util.enterContext(["Kitsun Review"]);

    // Options for the observer (which mutations to observe)
    const config = { attributes: true, childList: true, subtree: true };

    // Callback function to execute when mutations are observed
    const callback = function(mutationsList, observer) {
        setLanguage();
    };

    // Create an observer instance linked to the callback function
    observer = new MutationObserver(callback);

    // Start observing the target node for configured mutations
    const mainContainer = document.getElementsByClassName("main-container")[0];
    observer!.observe(mainContainer, config);
}

export default <IPluginBase & IPlugin> {...PluginBase, ...{
    niceName: "Kitsun",
    description: "",
    match: /.*kitsun.*/,
    version: "0.0.1",
    init: enterKitsunContext,
    destroy: exitKitsunContext,
    contexts: {
        "Kitsun Review": {
            commands: [
                "Answer",
                "Next"
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
            pageFn: clickNext
        }
]
}};
