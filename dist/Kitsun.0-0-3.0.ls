import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';function isPrefecturesDeck() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return false;
    }
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === null) {
        return false;
    }
    if (placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/)) {
        return true;
    }
    return false;
}
/**
 * converts a prefecture name in kanji to romaji
 * todo: support submitting answers with suffix? 県,都,府
 */
function prefectureToRomaji(ja) {
    const maybe = prefectures[ja];
    if (maybe === null || maybe === undefined) {
        return ja;
    }
    else {
        return maybe.toLowerCase();
    }
}
const prefectures = {
    "とうほく": "Tohoku",
    "かんさい": "Kansai",
    "かんとう": "Kanto",
    "ちゅうぶ": "Chubu",
    "ちゅうごく": "Chugoku",
    "しこく": "Shikoku",
    "きゅうしゅう": "Kyushu",
    "あいち": "Aichi",
    "あきた": "Akita",
    "あおもり": "Aomori",
    "ちば": "Chiba",
    "えひめ": "Ehime",
    "ふくい": "Fukui",
    "ふくおか": "Fukuoka",
    "ふくしま": "Fukushima",
    "ぎふ": "Gifu",
    "ぐんま": "Gunma",
    "ひろしま": "Hiroshima",
    "ほっかいどう": "Hokkaido",
    "ひょうご": "Hyogo",
    "いばらき": "Ibaraki",
    "いしかわ": "Ishikawa",
    "いわて": "Iwate",
    "かがわ": "Kagawa",
    "かごしま": "Kagoshima",
    "かながわ": "Kanagawa",
    "こうち": "Kochi",
    "くまもと": "Kumamoto",
    "きょうと": "Kyoto",
    "みえ": "Mie",
    "みやぎ": "Miyagi",
    "みやざき": "Miyazaki",
    "ながの": "Nagano",
    "ながさき": "Nagasaki",
    "なら": "Nara",
    "にいがた": "Niigata",
    "おおいた": "Oita",
    "おかやま": "Okayama",
    "おきなわ": "Okinawa",
    "おおさか": "Osaka",
    "さが": "Saga",
    "さいたま": "Saitama",
    "しが": "Shiga",
    "しまね": "Shimane",
    "しずおか": "Shizuoka",
    "とちぎ": "Tochigi",
    "とくしま": "Tokushima",
    "とうきょう": "Tokyo",
    "とっとり": "Tottori",
    "とやま": "Toyama",
    "わかやま": "Wakayama",
    "やまがた": "Yamagata",
    "やまぐち": "Yamaguchi",
    "やまなし": "Yamanashi",
    "愛知": "Aichi",
    "秋田": "Akita",
    "青森": "Aomori",
    "千葉": "Chiba",
    "愛媛": "Ehime",
    "福井": "Fukui",
    "福岡": "Fukuoka",
    "福島": "Fukushima",
    "岐阜": "Gifu",
    "群馬": "Gunma",
    "広島": "Hiroshima",
    "北海道": "Hokkaido",
    "兵庫": "Hyogo",
    "茨城": "Ibaraki",
    "石川": "Ishikawa",
    "岩手": "Iwate",
    "香川": "Kagawa",
    "鹿児島": "Kagoshima",
    "神奈川": "Kanagawa",
    "高知": "Kochi",
    "熊本": "Kumamoto",
    "京都": "Kyoto",
    "三重": "Mie",
    "宮城": "Miyagi",
    "宮崎": "Miyazaki",
    "長野": "Nagano",
    "長崎": "Nagasaki",
    "奈良": "Nara",
    "新潟": "Niigata",
    "大分": "Oita",
    "岡山": "Okayama",
    "沖縄": "Okinawa",
    "大阪": "Osaka",
    "佐賀": "Saga",
    "埼玉": "Saitama",
    "滋賀": "Shiga",
    "島根": "Shimane",
    "静岡": "Shizuoka",
    "栃木": "Tochigi",
    "徳島": "Tokushima",
    "東京": "Tokyo",
    "鳥取": "Tottori",
    "富山": "Toyama",
    "和歌山": "Wakayama",
    "山形": "Yamagata",
    "山口": "Yamaguchi",
    "山梨": "Yamanashi"
};

// lipsurf-plugins/src/Kitsun/Kitsun.ts
const activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/;
var FlashCardState;
(function (FlashCardState) {
    FlashCardState[FlashCardState["Flipping"] = 1] = "Flipping";
    FlashCardState[FlashCardState["Flipped"] = 2] = "Flipped";
})(FlashCardState || (FlashCardState = {}));
let currentState = FlashCardState.Flipping;
let previousLanguage = PluginBase.util.getLanguage();
let observer = null;
// converts katakana characters in the string to hiragana. will be a no-op if no katakana
function katakanaToHiragana(s) {
    const lower = "゠".codePointAt(0);
    const upper = "ヿ".codePointAt(0);
    const diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map(c => {
        const point = c.codePointAt(0);
        if (point >= lower && point <= upper) {
            return String.fromCodePoint(point - diff);
        }
        else {
            return c;
        }
    }).join("");
}
function punctuationToSpace(s) {
    return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/, " ");
}
/**
 * extracts list of answers from comma separated string,also cleans up individual answers: trim spaces, remove parentheticals
 * also returns extra copies of answers, replacing any punctuation with spaces
 * e.g. transcript for "what age?" will not include "?" but for "one's regards" it will include "'" so try both
 */
function transformAnswers(raw) {
    const results = [];
    const noParens = raw.replace(/\(.*\)/, "");
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
    var results = [];
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
// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer = "";
function markWrong() {
    const language = PluginBase.util.getLanguage();
    const incorrect = language === "en-US" ? "wrong" : "あああ";
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        typeans.value = incorrect;
        clickNext();
    }
}
function matchAnswer(transcript) {
    const answers = getAnswers();
    transcript = transcript.toLowerCase();
    console.log("[matchAnswer] t=" + transcript);
    for (var i = 0; i < answers.length; i++) {
        const answer = katakanaToHiragana(answers[i]);
        // special case: current language is Japanese and answer is romaji, then maybe prefectures deck
        // so convert possible prefecture name to romaji and check that too
        const prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
        if (answer === transcript || prefectureMatch) {
            console.log("[matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript);
            matchedAnswer = answers[i];
            return [0, transcript.length, [answers[i]]];
        }
    }
    matchedAnswer = "";
    return undefined;
}
function clickNext() {
    const nextans = document.getElementById("nextans");
    const nextButtons = document.querySelectorAll('.kitButton.flip_btn.kitButton__primary');
    if (nextans !== null) {
        nextans.click();
    }
    else if (nextButtons.length > 0) {
        nextButtons.item(0).click();
    }
    else {
        console.log("[clickNext] failed to find next button");
    }
}
function inputAnswer(transcript) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        typeans.value = matchedAnswer;
        clickNext();
    }
    else {
        console.log("[inputAnswer] typeans was null");
    }
}
/**
 * attempts to get the language for 10k listening cards based on .quest element(s)
 */
function getLanguageFromQuest() {
    const quests = document.getElementsByClassName("quest");
    for (var i = 0; i < quests.length; i++) {
        const quest = quests[i];
        const trimmed = quest.innerHTML.trim();
        if (trimmed === "Vocabulary Meaning") {
            return "en";
        }
        else if (trimmed === "Vocabulary Reading") {
            return "ja";
        }
    }
    return null;
}
/**
 * attempts to get the language for 10k, basic user deck based on #typeans element
 */
function getLanguageFromTypeans() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return null;
    }
    // first look for a placeholder in the typeans:
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning") {
        return "en";
    }
    else if (placeholder === "Japanese" || placeholder === "Reading") {
        return "ja";
    }
    else {
        // then look for a language attribute on typeans:
        const lang = typeans.getAttribute("lang");
        if (lang === null || (lang !== "ja" && lang !== "en")) {
            return null;
        }
        return lang;
    }
}
function setLanguage() {
    if (isPrefecturesDeck()) {
        console.log("[setLanguage] set to Japanese for prefectures deck");
        PluginBase.util.setLanguage("ja");
        return true;
    }
    var lang = getLanguageFromTypeans();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on typeans (10k/user deck)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    lang = getLanguageFromQuest();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on quest (10k)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    console.log("[setLanguage] failed to set language!");
    return false;
}
/**
 * Watches the page for changes to flip between languages for different cards
 */
function mutationCallback(mutations, observer) {
    if (currentState === FlashCardState.Flipping && document.location.href.match(activePages)) {
        if (setLanguage()) {
            currentState = FlashCardState.Flipped;
        }
    }
}
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
    observer.observe(mainContainer, config);
}
function locationChangeHandler() {
    if (document.location.href.match(activePages)) {
        enterKitsunContext();
    }
    else if (PluginBase.util.getContext().includes("Kitsun Review")) {
        exitKitsunContext();
    }
}
var Kitsun = { ...PluginBase, ...{
    niceName: "Kitsun",
    languages: {},
    description: "",
    match: /^https:\/\/kitsun\.io\/.*$/,
    version: "0.0.3",

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
    })(history.replaceState);`;
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
} };

/// <reference types="lipsurf-types/extension"/>
Kitsun.languages.ja = {
    niceName: "Kitsun",
    description: "Kitsun",
    commands: {
        "Answer": {
            name: "答え (answer)",
            match: {
                description: "[Kitsunの答え]",
                fn: matchAnswer
            }
        },
        "Next": {
            name: "次へ (next)",
            match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"]
        },
        "Wrong": {
            name: "バツ (wrong)",
            match: ["だめ", "ばつ"],
        }
    }
};

export default Kitsun;
export { markWrong, matchAnswer };LS-SPLITallPlugins.Kitsun = (() => { function isPrefecturesDeck() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return false;
    }
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === null) {
        return false;
    }
    if (placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/)) {
        return true;
    }
    return false;
}
/**
 * converts a prefecture name in kanji to romaji
 * todo: support submitting answers with suffix? 県,都,府
 */
function prefectureToRomaji(ja) {
    const maybe = prefectures[ja];
    if (maybe === null || maybe === undefined) {
        return ja;
    }
    else {
        return maybe.toLowerCase();
    }
}
const prefectures = {
    "とうほく": "Tohoku",
    "かんさい": "Kansai",
    "かんとう": "Kanto",
    "ちゅうぶ": "Chubu",
    "ちゅうごく": "Chugoku",
    "しこく": "Shikoku",
    "きゅうしゅう": "Kyushu",
    "あいち": "Aichi",
    "あきた": "Akita",
    "あおもり": "Aomori",
    "ちば": "Chiba",
    "えひめ": "Ehime",
    "ふくい": "Fukui",
    "ふくおか": "Fukuoka",
    "ふくしま": "Fukushima",
    "ぎふ": "Gifu",
    "ぐんま": "Gunma",
    "ひろしま": "Hiroshima",
    "ほっかいどう": "Hokkaido",
    "ひょうご": "Hyogo",
    "いばらき": "Ibaraki",
    "いしかわ": "Ishikawa",
    "いわて": "Iwate",
    "かがわ": "Kagawa",
    "かごしま": "Kagoshima",
    "かながわ": "Kanagawa",
    "こうち": "Kochi",
    "くまもと": "Kumamoto",
    "きょうと": "Kyoto",
    "みえ": "Mie",
    "みやぎ": "Miyagi",
    "みやざき": "Miyazaki",
    "ながの": "Nagano",
    "ながさき": "Nagasaki",
    "なら": "Nara",
    "にいがた": "Niigata",
    "おおいた": "Oita",
    "おかやま": "Okayama",
    "おきなわ": "Okinawa",
    "おおさか": "Osaka",
    "さが": "Saga",
    "さいたま": "Saitama",
    "しが": "Shiga",
    "しまね": "Shimane",
    "しずおか": "Shizuoka",
    "とちぎ": "Tochigi",
    "とくしま": "Tokushima",
    "とうきょう": "Tokyo",
    "とっとり": "Tottori",
    "とやま": "Toyama",
    "わかやま": "Wakayama",
    "やまがた": "Yamagata",
    "やまぐち": "Yamaguchi",
    "やまなし": "Yamanashi",
    "愛知": "Aichi",
    "秋田": "Akita",
    "青森": "Aomori",
    "千葉": "Chiba",
    "愛媛": "Ehime",
    "福井": "Fukui",
    "福岡": "Fukuoka",
    "福島": "Fukushima",
    "岐阜": "Gifu",
    "群馬": "Gunma",
    "広島": "Hiroshima",
    "北海道": "Hokkaido",
    "兵庫": "Hyogo",
    "茨城": "Ibaraki",
    "石川": "Ishikawa",
    "岩手": "Iwate",
    "香川": "Kagawa",
    "鹿児島": "Kagoshima",
    "神奈川": "Kanagawa",
    "高知": "Kochi",
    "熊本": "Kumamoto",
    "京都": "Kyoto",
    "三重": "Mie",
    "宮城": "Miyagi",
    "宮崎": "Miyazaki",
    "長野": "Nagano",
    "長崎": "Nagasaki",
    "奈良": "Nara",
    "新潟": "Niigata",
    "大分": "Oita",
    "岡山": "Okayama",
    "沖縄": "Okinawa",
    "大阪": "Osaka",
    "佐賀": "Saga",
    "埼玉": "Saitama",
    "滋賀": "Shiga",
    "島根": "Shimane",
    "静岡": "Shizuoka",
    "栃木": "Tochigi",
    "徳島": "Tokushima",
    "東京": "Tokyo",
    "鳥取": "Tottori",
    "富山": "Toyama",
    "和歌山": "Wakayama",
    "山形": "Yamagata",
    "山口": "Yamaguchi",
    "山梨": "Yamanashi"
};

// lipsurf-plugins/src/Kitsun/Kitsun.ts
const activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/;
var FlashCardState;
(function (FlashCardState) {
    FlashCardState[FlashCardState["Flipping"] = 1] = "Flipping";
    FlashCardState[FlashCardState["Flipped"] = 2] = "Flipped";
})(FlashCardState || (FlashCardState = {}));
let currentState = FlashCardState.Flipping;
let previousLanguage = PluginBase.util.getLanguage();
let observer = null;
// converts katakana characters in the string to hiragana. will be a no-op if no katakana
function katakanaToHiragana(s) {
    const lower = "゠".codePointAt(0);
    const upper = "ヿ".codePointAt(0);
    const diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map(c => {
        const point = c.codePointAt(0);
        if (point >= lower && point <= upper) {
            return String.fromCodePoint(point - diff);
        }
        else {
            return c;
        }
    }).join("");
}
function punctuationToSpace(s) {
    return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/, " ");
}
/**
 * extracts list of answers from comma separated string,also cleans up individual answers: trim spaces, remove parentheticals
 * also returns extra copies of answers, replacing any punctuation with spaces
 * e.g. transcript for "what age?" will not include "?" but for "one's regards" it will include "'" so try both
 */
function transformAnswers(raw) {
    const results = [];
    const noParens = raw.replace(/\(.*\)/, "");
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
    var results = [];
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
// stores the actual answer we matched so it can be inputted by pageFn (inputAnswer)
var matchedAnswer = "";
function markWrong() {
    const language = PluginBase.util.getLanguage();
    const incorrect = language === "en-US" ? "wrong" : "あああ";
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        typeans.value = incorrect;
        clickNext();
    }
}
function matchAnswer(transcript) {
    const answers = getAnswers();
    transcript = transcript.toLowerCase();
    console.log("[matchAnswer] t=" + transcript);
    for (var i = 0; i < answers.length; i++) {
        const answer = katakanaToHiragana(answers[i]);
        // special case: current language is Japanese and answer is romaji, then maybe prefectures deck
        // so convert possible prefecture name to romaji and check that too
        const prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
        if (answer === transcript || prefectureMatch) {
            console.log("[matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript);
            matchedAnswer = answers[i];
            return [0, transcript.length, [answers[i]]];
        }
    }
    matchedAnswer = "";
    return undefined;
}
function clickNext() {
    const nextans = document.getElementById("nextans");
    const nextButtons = document.querySelectorAll('.kitButton.flip_btn.kitButton__primary');
    if (nextans !== null) {
        nextans.click();
    }
    else if (nextButtons.length > 0) {
        nextButtons.item(0).click();
    }
    else {
        console.log("[clickNext] failed to find next button");
    }
}
function inputAnswer(transcript) {
    // assumes that we matched a correct answer, so input the stored matched answer:
    if (matchedAnswer.length < 1) {
        console.log("[inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
        return;
    }
    const typeans = document.getElementById("typeans");
    if (typeans !== null) {
        typeans.value = matchedAnswer;
        clickNext();
    }
    else {
        console.log("[inputAnswer] typeans was null");
    }
}
/**
 * attempts to get the language for 10k listening cards based on .quest element(s)
 */
function getLanguageFromQuest() {
    const quests = document.getElementsByClassName("quest");
    for (var i = 0; i < quests.length; i++) {
        const quest = quests[i];
        const trimmed = quest.innerHTML.trim();
        if (trimmed === "Vocabulary Meaning") {
            return "en";
        }
        else if (trimmed === "Vocabulary Reading") {
            return "ja";
        }
    }
    return null;
}
/**
 * attempts to get the language for 10k, basic user deck based on #typeans element
 */
function getLanguageFromTypeans() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return null;
    }
    // first look for a placeholder in the typeans:
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning") {
        return "en";
    }
    else if (placeholder === "Japanese" || placeholder === "Reading") {
        return "ja";
    }
    else {
        // then look for a language attribute on typeans:
        const lang = typeans.getAttribute("lang");
        if (lang === null || (lang !== "ja" && lang !== "en")) {
            return null;
        }
        return lang;
    }
}
function setLanguage() {
    if (isPrefecturesDeck()) {
        console.log("[setLanguage] set to Japanese for prefectures deck");
        PluginBase.util.setLanguage("ja");
        return true;
    }
    var lang = getLanguageFromTypeans();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on typeans (10k/user deck)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    lang = getLanguageFromQuest();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on quest (10k)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    console.log("[setLanguage] failed to set language!");
    return false;
}
/**
 * Watches the page for changes to flip between languages for different cards
 */
function mutationCallback(mutations, observer) {
    if (currentState === FlashCardState.Flipping && document.location.href.match(activePages)) {
        if (setLanguage()) {
            currentState = FlashCardState.Flipped;
        }
    }
}
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
    observer.observe(mainContainer, config);
}
function locationChangeHandler() {
    if (document.location.href.match(activePages)) {
        enterKitsunContext();
    }
    else if (PluginBase.util.getContext().includes("Kitsun Review")) {
        exitKitsunContext();
    }
}
var Kitsun = { ...PluginBase, ...{
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
    })(history.replaceState);`;
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

    commands: {
        "Answer": {
            match: {
                en: matchAnswer,
                ja: matchAnswer
            },

            normal: false,
            pageFn: inputAnswer
        },

        "Next": {
            normal: false,

            pageFn: () => {
                currentState = FlashCardState.Flipping;
                clickNext();
            }
        },

        "Wrong": {
            normal: false,
            pageFn: markWrong
        }
    }
} };

return Kitsun;
 })()LS-SPLITallPlugins.Kitsun = (() => { function isPrefecturesDeck() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return false;
    }
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === null) {
        return false;
    }
    if (placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/)) {
        return true;
    }
    return false;
}

// lipsurf-plugins/src/Kitsun/Kitsun.ts
const activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/;
var FlashCardState;
(function (FlashCardState) {
    FlashCardState[FlashCardState["Flipping"] = 1] = "Flipping";
    FlashCardState[FlashCardState["Flipped"] = 2] = "Flipped";
})(FlashCardState || (FlashCardState = {}));
let currentState = FlashCardState.Flipping;
let previousLanguage = PluginBase.util.getLanguage();
let observer = null;
/**
 * attempts to get the language for 10k listening cards based on .quest element(s)
 */
function getLanguageFromQuest() {
    const quests = document.getElementsByClassName("quest");
    for (var i = 0; i < quests.length; i++) {
        const quest = quests[i];
        const trimmed = quest.innerHTML.trim();
        if (trimmed === "Vocabulary Meaning") {
            return "en";
        }
        else if (trimmed === "Vocabulary Reading") {
            return "ja";
        }
    }
    return null;
}
/**
 * attempts to get the language for 10k, basic user deck based on #typeans element
 */
function getLanguageFromTypeans() {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return null;
    }
    // first look for a placeholder in the typeans:
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning") {
        return "en";
    }
    else if (placeholder === "Japanese" || placeholder === "Reading") {
        return "ja";
    }
    else {
        // then look for a language attribute on typeans:
        const lang = typeans.getAttribute("lang");
        if (lang === null || (lang !== "ja" && lang !== "en")) {
            return null;
        }
        return lang;
    }
}
function setLanguage() {
    if (isPrefecturesDeck()) {
        console.log("[setLanguage] set to Japanese for prefectures deck");
        PluginBase.util.setLanguage("ja");
        return true;
    }
    var lang = getLanguageFromTypeans();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on typeans (10k/user deck)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    lang = getLanguageFromQuest();
    if (lang !== null) {
        console.log("[setLanguage] set to %s based on quest (10k)", lang);
        PluginBase.util.setLanguage(lang);
        return true;
    }
    console.log("[setLanguage] failed to set language!");
    return false;
}
/**
 * Watches the page for changes to flip between languages for different cards
 */
function mutationCallback(mutations, observer) {
    if (currentState === FlashCardState.Flipping && document.location.href.match(activePages)) {
        if (setLanguage()) {
            currentState = FlashCardState.Flipped;
        }
    }
}
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
    observer.observe(mainContainer, config);
}
function locationChangeHandler() {
    if (document.location.href.match(activePages)) {
        enterKitsunContext();
    }
    else if (PluginBase.util.getContext().includes("Kitsun Review")) {
        exitKitsunContext();
    }
}
var Kitsun = { ...PluginBase, ...{
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
    })(history.replaceState);`;
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

    commands: {}
} };

return Kitsun;
 })()