import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';// dist/tmp/Kitsun/Kitsun.js
function isPrefecturesDeck() {
  let typeans = document.getElementById("typeans");
  if (typeans === null)
    return !1;
  let placeholder = typeans.getAttribute("placeholder");
  return placeholder === null ? !1 : !!(placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/));
}
function prefectureToRomaji(ja) {
  let maybe = prefectures[ja];
  return maybe == null ? ja : maybe.toLowerCase();
}
var prefectures = { とうほく: "Tohoku", かんさい: "Kansai", かんとう: "Kanto", ちゅうぶ: "Chubu", ちゅうごく: "Chugoku", しこく: "Shikoku", きゅうしゅう: "Kyushu", あいち: "Aichi", あきた: "Akita", あおもり: "Aomori", ちば: "Chiba", えひめ: "Ehime", ふくい: "Fukui", ふくおか: "Fukuoka", ふくしま: "Fukushima", ぎふ: "Gifu", ぐんま: "Gunma", ひろしま: "Hiroshima", ほっかいどう: "Hokkaido", ひょうご: "Hyogo", いばらき: "Ibaraki", いしかわ: "Ishikawa", いわて: "Iwate", かがわ: "Kagawa", かごしま: "Kagoshima", かながわ: "Kanagawa", こうち: "Kochi", くまもと: "Kumamoto", きょうと: "Kyoto", みえ: "Mie", みやぎ: "Miyagi", みやざき: "Miyazaki", ながの: "Nagano", ながさき: "Nagasaki", なら: "Nara", にいがた: "Niigata", おおいた: "Oita", おかやま: "Okayama", おきなわ: "Okinawa", おおさか: "Osaka", さが: "Saga", さいたま: "Saitama", しが: "Shiga", しまね: "Shimane", しずおか: "Shizuoka", とちぎ: "Tochigi", とくしま: "Tokushima", とうきょう: "Tokyo", とっとり: "Tottori", とやま: "Toyama", わかやま: "Wakayama", やまがた: "Yamagata", やまぐち: "Yamaguchi", やまなし: "Yamanashi", 愛知: "Aichi", 秋田: "Akita", 青森: "Aomori", 千葉: "Chiba", 愛媛: "Ehime", 福井: "Fukui", 福岡: "Fukuoka", 福島: "Fukushima", 岐阜: "Gifu", 群馬: "Gunma", 広島: "Hiroshima", 北海道: "Hokkaido", 兵庫: "Hyogo", 茨城: "Ibaraki", 石川: "Ishikawa", 岩手: "Iwate", 香川: "Kagawa", 鹿児島: "Kagoshima", 神奈川: "Kanagawa", 高知: "Kochi", 熊本: "Kumamoto", 京都: "Kyoto", 三重: "Mie", 宮城: "Miyagi", 宮崎: "Miyazaki", 長野: "Nagano", 長崎: "Nagasaki", 奈良: "Nara", 新潟: "Niigata", 大分: "Oita", 岡山: "Okayama", 沖縄: "Okinawa", 大阪: "Osaka", 佐賀: "Saga", 埼玉: "Saitama", 滋賀: "Shiga", 島根: "Shimane", 静岡: "Shizuoka", 栃木: "Tochigi", 徳島: "Tokushima", 東京: "Tokyo", 鳥取: "Tottori", 富山: "Toyama", 和歌山: "Wakayama", 山形: "Yamagata", 山口: "Yamaguchi", 山梨: "Yamanashi" }, activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/, FlashCardState = { Flipping: "Flipping", Flipped: "Flipped" }, currentState, previousLanguage, observer, matchedAnswer;
function katakanaToHiragana(s) {
  let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
  return s.split("").map((c) => {
    let point = c.codePointAt(0);
    return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
  }).join("");
}
function punctuationToSpace(s) {
  return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/, " ");
}
function transformAnswers(raw) {
  let results = [], answers = raw.replace(/[\u200B-\u200D\uFEFF]/g, "").replace(/\(.*\)/, "").split(",").map((a) => a.trim().toLowerCase()).filter((a) => a.length != 0);
  for (var i = 0; i < answers.length; i++) {
    let answer = answers[i];
    results.push(answer), punctuationToSpace(answer) !== answer && results.push(answer);
  }
  return results;
}
function getAnswers() {
  var results = [];
  let typeans = document.getElementById("typeans");
  if (typeans !== null) {
    let answers = typeans.getAttribute("answer");
    answers !== null && (results = results.concat(transformAnswers(answers)));
  }
  let combinedans = document.getElementById("combinedans");
  if (combinedans !== null) {
    let answers = combinedans.innerHTML;
    answers !== null && (results = results.concat(transformAnswers(answers)));
  }
  return results;
}
function markWrong() {
  let incorrect = PluginBase.util.getLanguage() === "en-US" ? "wrong" : "あああ", typeans = document.getElementById("typeans");
  typeans !== null && (typeans.value = incorrect, clickNext());
}
function compareAnswer(answer, transcript) {
  return answer === transcript || transcript.replace(new RegExp(answer, "g"), "").length === 0;
}
function matchAnswer({ preTs, normTs }) {
  let answers = getAnswers(), transcript = normTs.toLowerCase();
  console.log("[Kitsun.matchAnswer] t=%s, a=%o", transcript, answers);
  for (var i = 0; i < answers.length; i++) {
    let answer = katakanaToHiragana(answers[i]), prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
    if (compareAnswer(answer, transcript) || prefectureMatch)
      return console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
  }
  matchedAnswer = "";
}
function clickNext() {
  let quizButtons = document.querySelectorAll("body > div.swal2-container.swal2-center.swal2-fade.swal2-shown > div > div.swal2-buttonswrapper > button.swal2-confirm.swal2-styled");
  if (quizButtons.length > 0) {
    quizButtons.item(0).click();
    return;
  }
  let nextans = document.getElementById("nextans"), nextButtons = document.querySelectorAll(".kitButton.flip_btn.kitButton__primary");
  nextans !== null ? nextans.click() : nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[Kitsun.clickNext] failed to find next button");
}
function inputAnswer({ preTs, normTs }) {
  if (matchedAnswer.length < 1) {
    console.log("[Kitsun.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, normTs);
    return;
  }
  let typeans = document.getElementById("typeans");
  typeans !== null ? (typeans.value = matchedAnswer, clickNext()) : console.log("[Kitsun.inputAnswer] typeans was null");
}
function getLanguageFromQuest() {
  let quests = document.getElementsByClassName("quest");
  for (var found = !1, i = 0; i < quests.length; i++) {
    let trimmed = quests[i].innerHTML.trim();
    if (trimmed === "Vocabulary Meaning")
      return "en";
    if (trimmed === "Vocabulary Reading")
      return "ja";
  }
  return null;
}
function getLanguageFromTypeans() {
  let typeans = document.getElementById("typeans");
  if (typeans === null)
    return null;
  let placeholder = typeans.getAttribute("placeholder");
  if (placeholder === "English" || placeholder === "Meaning")
    return "en";
  if (placeholder === "Japanese" || placeholder === "Reading")
    return "ja";
  {
    let lang = typeans.getAttribute("lang");
    return lang === null || lang !== "ja" && lang !== "en" ? null : lang;
  }
}
function setLanguage() {
  if (isPrefecturesDeck())
    return console.log("[Kitsun.setLanguage] set to Japanese for prefectures deck"), PluginBase.util.setLanguage("ja"), !0;
  var lang = getLanguageFromTypeans();
  return lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on typeans (10k/user deck)", lang), PluginBase.util.setLanguage(lang), !0) : (lang = getLanguageFromQuest(), lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on quest (10k)", lang), PluginBase.util.setLanguage(lang), !0) : (console.log("[Kitsun.setLanguage] failed to set language!"), !1));
}
function mutationCallback(mutations, observer2) {
  console.log("[Kitsun.mutationCallback] " + FlashCardState[currentState]), currentState === FlashCardState.Flipping && document.location.href.match(activePages) && setLanguage() && (currentState = FlashCardState.Flipped);
}
function exitKitsunContext() {
  console.log("[Kitsun.exitKitsunContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage), observer !== null && observer.disconnect();
}
function enterKitsunContext() {
  console.log("[Kitsun.enterKitsunContext]"), currentState = FlashCardState.Flipping, PluginBase.util.enterContext(["Kitsun Review"]), previousLanguage = PluginBase.util.getLanguage();
  let config = { attributes: !0, childList: !0, subtree: !0 };
  observer = new MutationObserver(mutationCallback);
  let mainContainer = document.getElementsByClassName("main-container")[0];
  observer.observe(mainContainer, config), mutationCallback(null, null);
}
function locationChangeHandler() {
  document.location.href.match(activePages) ? enterKitsunContext() : PluginBase.util.getContext().includes("Kitsun Review") && exitKitsunContext();
}
var Kitsun_default = { ...PluginBase, languages: {}, niceName: "Kitsun", description: "", match: /^https:\/\/kitsun\.io\/.*$/, apiVersion: 2, version: "0.0.4", init: () => {
  currentState = FlashCardState.Flipping, previousLanguage = PluginBase.util.getLanguage();
  let src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`;
  var head = document.getElementsByTagName("head")[0], script = document.createElement("script");
  script.type = "text/javascript", script.innerHTML = src, head.appendChild(script), window.addEventListener("locationchange", locationChangeHandler), locationChangeHandler();
}, destroy: () => {
  window.removeEventListener("locationchange", locationChangeHandler), exitKitsunContext();
}, contexts: { "Kitsun Review": { commands: ["Change Language to Japanese", "LipSurf.Normal Mode", "LipSurf.Turn off LipSurf", "Answer", "Next", "Wrong"] } }, commands: [{ name: "Answer", description: "Submit an English answer for a Kitsun review", match: { description: "[English answer]", fn: matchAnswer }, context: "Kitsun Review", normal: !1, pageFn: inputAnswer }, { name: "Next", description: "Go to the next item in a Kitsun review", match: "next", context: "Kitsun Review", normal: !1, pageFn: () => {
  currentState = FlashCardState.Flipping, clickNext();
} }, { name: "Wrong", description: "Mark a card wrong", match: "wrong", context: "Kitsun Review", normal: !1, pageFn: markWrong }] };
Kitsun_default.languages.ja = { niceName: "Kitsun", description: "Kitsun", commands: { Answer: { name: "答え (answer)", match: { description: "[Kitsunの答え]", fn: matchAnswer } }, Next: { name: "次へ (next)", match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, Wrong: { name: "バツ (wrong)", match: ["だめ", "ばつ"] } } };
var dumby_default = Kitsun_default;
export {
  dumby_default as default
};
LS-SPLIT// dist/tmp/Kitsun/Kitsun.js
allPlugins.Kitsun = (() => {
  function isPrefecturesDeck() {
    let typeans = document.getElementById("typeans");
    if (typeans === null)
      return !1;
    let placeholder = typeans.getAttribute("placeholder");
    return placeholder === null ? !1 : !!(placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/));
  }
  function prefectureToRomaji(ja) {
    let maybe = prefectures[ja];
    return maybe == null ? ja : maybe.toLowerCase();
  }
  var prefectures = { とうほく: "Tohoku", かんさい: "Kansai", かんとう: "Kanto", ちゅうぶ: "Chubu", ちゅうごく: "Chugoku", しこく: "Shikoku", きゅうしゅう: "Kyushu", あいち: "Aichi", あきた: "Akita", あおもり: "Aomori", ちば: "Chiba", えひめ: "Ehime", ふくい: "Fukui", ふくおか: "Fukuoka", ふくしま: "Fukushima", ぎふ: "Gifu", ぐんま: "Gunma", ひろしま: "Hiroshima", ほっかいどう: "Hokkaido", ひょうご: "Hyogo", いばらき: "Ibaraki", いしかわ: "Ishikawa", いわて: "Iwate", かがわ: "Kagawa", かごしま: "Kagoshima", かながわ: "Kanagawa", こうち: "Kochi", くまもと: "Kumamoto", きょうと: "Kyoto", みえ: "Mie", みやぎ: "Miyagi", みやざき: "Miyazaki", ながの: "Nagano", ながさき: "Nagasaki", なら: "Nara", にいがた: "Niigata", おおいた: "Oita", おかやま: "Okayama", おきなわ: "Okinawa", おおさか: "Osaka", さが: "Saga", さいたま: "Saitama", しが: "Shiga", しまね: "Shimane", しずおか: "Shizuoka", とちぎ: "Tochigi", とくしま: "Tokushima", とうきょう: "Tokyo", とっとり: "Tottori", とやま: "Toyama", わかやま: "Wakayama", やまがた: "Yamagata", やまぐち: "Yamaguchi", やまなし: "Yamanashi", 愛知: "Aichi", 秋田: "Akita", 青森: "Aomori", 千葉: "Chiba", 愛媛: "Ehime", 福井: "Fukui", 福岡: "Fukuoka", 福島: "Fukushima", 岐阜: "Gifu", 群馬: "Gunma", 広島: "Hiroshima", 北海道: "Hokkaido", 兵庫: "Hyogo", 茨城: "Ibaraki", 石川: "Ishikawa", 岩手: "Iwate", 香川: "Kagawa", 鹿児島: "Kagoshima", 神奈川: "Kanagawa", 高知: "Kochi", 熊本: "Kumamoto", 京都: "Kyoto", 三重: "Mie", 宮城: "Miyagi", 宮崎: "Miyazaki", 長野: "Nagano", 長崎: "Nagasaki", 奈良: "Nara", 新潟: "Niigata", 大分: "Oita", 岡山: "Okayama", 沖縄: "Okinawa", 大阪: "Osaka", 佐賀: "Saga", 埼玉: "Saitama", 滋賀: "Shiga", 島根: "Shimane", 静岡: "Shizuoka", 栃木: "Tochigi", 徳島: "Tokushima", 東京: "Tokyo", 鳥取: "Tottori", 富山: "Toyama", 和歌山: "Wakayama", 山形: "Yamagata", 山口: "Yamaguchi", 山梨: "Yamanashi" }, activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/, FlashCardState = { Flipping: "Flipping", Flipped: "Flipped" }, currentState, previousLanguage, observer, matchedAnswer;
  function katakanaToHiragana(s) {
    let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map((c) => {
      let point = c.codePointAt(0);
      return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
    }).join("");
  }
  function punctuationToSpace(s) {
    return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/, " ");
  }
  function transformAnswers(raw) {
    let results = [], answers = raw.replace(/[\u200B-\u200D\uFEFF]/g, "").replace(/\(.*\)/, "").split(",").map((a) => a.trim().toLowerCase()).filter((a) => a.length != 0);
    for (var i = 0; i < answers.length; i++) {
      let answer = answers[i];
      results.push(answer), punctuationToSpace(answer) !== answer && results.push(answer);
    }
    return results;
  }
  function getAnswers() {
    var results = [];
    let typeans = document.getElementById("typeans");
    if (typeans !== null) {
      let answers = typeans.getAttribute("answer");
      answers !== null && (results = results.concat(transformAnswers(answers)));
    }
    let combinedans = document.getElementById("combinedans");
    if (combinedans !== null) {
      let answers = combinedans.innerHTML;
      answers !== null && (results = results.concat(transformAnswers(answers)));
    }
    return results;
  }
  function markWrong() {
    let incorrect = PluginBase.util.getLanguage() === "en-US" ? "wrong" : "あああ", typeans = document.getElementById("typeans");
    typeans !== null && (typeans.value = incorrect, clickNext());
  }
  function compareAnswer(answer, transcript) {
    return answer === transcript || transcript.replace(new RegExp(answer, "g"), "").length === 0;
  }
  function matchAnswer({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[Kitsun.matchAnswer] t=%s, a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i]), prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
      if (compareAnswer(answer, transcript) || prefectureMatch)
        return console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  }
  function clickNext() {
    let quizButtons = document.querySelectorAll("body > div.swal2-container.swal2-center.swal2-fade.swal2-shown > div > div.swal2-buttonswrapper > button.swal2-confirm.swal2-styled");
    if (quizButtons.length > 0) {
      quizButtons.item(0).click();
      return;
    }
    let nextans = document.getElementById("nextans"), nextButtons = document.querySelectorAll(".kitButton.flip_btn.kitButton__primary");
    nextans !== null ? nextans.click() : nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[Kitsun.clickNext] failed to find next button");
  }
  function inputAnswer({ preTs, normTs }) {
    if (matchedAnswer.length < 1) {
      console.log("[Kitsun.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, normTs);
      return;
    }
    let typeans = document.getElementById("typeans");
    typeans !== null ? (typeans.value = matchedAnswer, clickNext()) : console.log("[Kitsun.inputAnswer] typeans was null");
  }
  function getLanguageFromQuest() {
    let quests = document.getElementsByClassName("quest");
    for (var found = !1, i = 0; i < quests.length; i++) {
      let trimmed = quests[i].innerHTML.trim();
      if (trimmed === "Vocabulary Meaning")
        return "en";
      if (trimmed === "Vocabulary Reading")
        return "ja";
    }
    return null;
  }
  function getLanguageFromTypeans() {
    let typeans = document.getElementById("typeans");
    if (typeans === null)
      return null;
    let placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning")
      return "en";
    if (placeholder === "Japanese" || placeholder === "Reading")
      return "ja";
    {
      let lang = typeans.getAttribute("lang");
      return lang === null || lang !== "ja" && lang !== "en" ? null : lang;
    }
  }
  function setLanguage() {
    if (isPrefecturesDeck())
      return console.log("[Kitsun.setLanguage] set to Japanese for prefectures deck"), PluginBase.util.setLanguage("ja"), !0;
    var lang = getLanguageFromTypeans();
    return lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on typeans (10k/user deck)", lang), PluginBase.util.setLanguage(lang), !0) : (lang = getLanguageFromQuest(), lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on quest (10k)", lang), PluginBase.util.setLanguage(lang), !0) : (console.log("[Kitsun.setLanguage] failed to set language!"), !1));
  }
  function mutationCallback(mutations, observer2) {
    console.log("[Kitsun.mutationCallback] " + FlashCardState[currentState]), currentState === FlashCardState.Flipping && document.location.href.match(activePages) && setLanguage() && (currentState = FlashCardState.Flipped);
  }
  function exitKitsunContext() {
    console.log("[Kitsun.exitKitsunContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage), observer !== null && observer.disconnect();
  }
  function enterKitsunContext() {
    console.log("[Kitsun.enterKitsunContext]"), currentState = FlashCardState.Flipping, PluginBase.util.enterContext(["Kitsun Review"]), previousLanguage = PluginBase.util.getLanguage();
    let config = { attributes: !0, childList: !0, subtree: !0 };
    observer = new MutationObserver(mutationCallback);
    let mainContainer = document.getElementsByClassName("main-container")[0];
    observer.observe(mainContainer, config), mutationCallback(null, null);
  }
  function locationChangeHandler() {
    document.location.href.match(activePages) ? enterKitsunContext() : PluginBase.util.getContext().includes("Kitsun Review") && exitKitsunContext();
  }
  return { ...PluginBase, init: () => {
    currentState = FlashCardState.Flipping, previousLanguage = PluginBase.util.getLanguage();
    let src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`;
    var head = document.getElementsByTagName("head")[0], script = document.createElement("script");
    script.type = "text/javascript", script.innerHTML = src, head.appendChild(script), window.addEventListener("locationchange", locationChangeHandler), locationChangeHandler();
  }, destroy: () => {
    window.removeEventListener("locationchange", locationChangeHandler), exitKitsunContext();
  }, commands: { Answer: { match: { en: function({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[Kitsun.matchAnswer] t=%s, a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i]), prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
      if (compareAnswer(answer, transcript) || prefectureMatch)
        return console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  }, ja: function({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[Kitsun.matchAnswer] t=%s, a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i]), prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
      if (compareAnswer(answer, transcript) || prefectureMatch)
        return console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  } }, pageFn: function({ preTs, normTs }) {
    if (matchedAnswer.length < 1) {
      console.log("[Kitsun.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, normTs);
      return;
    }
    let typeans = document.getElementById("typeans");
    typeans !== null ? (typeans.value = matchedAnswer, clickNext()) : console.log("[Kitsun.inputAnswer] typeans was null");
  } }, Next: { pageFn: () => {
    currentState = FlashCardState.Flipping, clickNext();
  } }, Wrong: { pageFn: function() {
    let incorrect = PluginBase.util.getLanguage() === "en-US" ? "wrong" : "あああ", typeans = document.getElementById("typeans");
    typeans !== null && (typeans.value = incorrect, clickNext());
  } } } };
})();
LS-SPLIT// dist/tmp/Kitsun/Kitsun.js
allPlugins.Kitsun = (() => {
  function isPrefecturesDeck() {
    let typeans = document.getElementById("typeans");
    if (typeans === null)
      return !1;
    let placeholder = typeans.getAttribute("placeholder");
    return placeholder === null ? !1 : !!(placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/));
  }
  function prefectureToRomaji(ja) {
    let maybe = prefectures[ja];
    return maybe == null ? ja : maybe.toLowerCase();
  }
  var prefectures = { とうほく: "Tohoku", かんさい: "Kansai", かんとう: "Kanto", ちゅうぶ: "Chubu", ちゅうごく: "Chugoku", しこく: "Shikoku", きゅうしゅう: "Kyushu", あいち: "Aichi", あきた: "Akita", あおもり: "Aomori", ちば: "Chiba", えひめ: "Ehime", ふくい: "Fukui", ふくおか: "Fukuoka", ふくしま: "Fukushima", ぎふ: "Gifu", ぐんま: "Gunma", ひろしま: "Hiroshima", ほっかいどう: "Hokkaido", ひょうご: "Hyogo", いばらき: "Ibaraki", いしかわ: "Ishikawa", いわて: "Iwate", かがわ: "Kagawa", かごしま: "Kagoshima", かながわ: "Kanagawa", こうち: "Kochi", くまもと: "Kumamoto", きょうと: "Kyoto", みえ: "Mie", みやぎ: "Miyagi", みやざき: "Miyazaki", ながの: "Nagano", ながさき: "Nagasaki", なら: "Nara", にいがた: "Niigata", おおいた: "Oita", おかやま: "Okayama", おきなわ: "Okinawa", おおさか: "Osaka", さが: "Saga", さいたま: "Saitama", しが: "Shiga", しまね: "Shimane", しずおか: "Shizuoka", とちぎ: "Tochigi", とくしま: "Tokushima", とうきょう: "Tokyo", とっとり: "Tottori", とやま: "Toyama", わかやま: "Wakayama", やまがた: "Yamagata", やまぐち: "Yamaguchi", やまなし: "Yamanashi", 愛知: "Aichi", 秋田: "Akita", 青森: "Aomori", 千葉: "Chiba", 愛媛: "Ehime", 福井: "Fukui", 福岡: "Fukuoka", 福島: "Fukushima", 岐阜: "Gifu", 群馬: "Gunma", 広島: "Hiroshima", 北海道: "Hokkaido", 兵庫: "Hyogo", 茨城: "Ibaraki", 石川: "Ishikawa", 岩手: "Iwate", 香川: "Kagawa", 鹿児島: "Kagoshima", 神奈川: "Kanagawa", 高知: "Kochi", 熊本: "Kumamoto", 京都: "Kyoto", 三重: "Mie", 宮城: "Miyagi", 宮崎: "Miyazaki", 長野: "Nagano", 長崎: "Nagasaki", 奈良: "Nara", 新潟: "Niigata", 大分: "Oita", 岡山: "Okayama", 沖縄: "Okinawa", 大阪: "Osaka", 佐賀: "Saga", 埼玉: "Saitama", 滋賀: "Shiga", 島根: "Shimane", 静岡: "Shizuoka", 栃木: "Tochigi", 徳島: "Tokushima", 東京: "Tokyo", 鳥取: "Tottori", 富山: "Toyama", 和歌山: "Wakayama", 山形: "Yamagata", 山口: "Yamaguchi", 山梨: "Yamanashi" }, activePages = /^https:\/\/kitsun\.io\/deck\/.*\/(reviews|lessons|selfstudy)$/, FlashCardState = { Flipping: "Flipping", Flipped: "Flipped" }, currentState, previousLanguage, observer, matchedAnswer;
  function katakanaToHiragana(s) {
    let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map((c) => {
      let point = c.codePointAt(0);
      return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
    }).join("");
  }
  function punctuationToSpace(s) {
    return s.replace(/[!"#$%&'()*+,-./:;<=>?@\[\\\]^_`{|}~"]/, " ");
  }
  function transformAnswers(raw) {
    let results = [], answers = raw.replace(/[\u200B-\u200D\uFEFF]/g, "").replace(/\(.*\)/, "").split(",").map((a) => a.trim().toLowerCase()).filter((a) => a.length != 0);
    for (var i = 0; i < answers.length; i++) {
      let answer = answers[i];
      results.push(answer), punctuationToSpace(answer) !== answer && results.push(answer);
    }
    return results;
  }
  function getAnswers() {
    var results = [];
    let typeans = document.getElementById("typeans");
    if (typeans !== null) {
      let answers = typeans.getAttribute("answer");
      answers !== null && (results = results.concat(transformAnswers(answers)));
    }
    let combinedans = document.getElementById("combinedans");
    if (combinedans !== null) {
      let answers = combinedans.innerHTML;
      answers !== null && (results = results.concat(transformAnswers(answers)));
    }
    return results;
  }
  function markWrong() {
    let incorrect = PluginBase.util.getLanguage() === "en-US" ? "wrong" : "あああ", typeans = document.getElementById("typeans");
    typeans !== null && (typeans.value = incorrect, clickNext());
  }
  function compareAnswer(answer, transcript) {
    return answer === transcript || transcript.replace(new RegExp(answer, "g"), "").length === 0;
  }
  function matchAnswer({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[Kitsun.matchAnswer] t=%s, a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i]), prefectureMatch = PluginBase.util.getLanguage() === "ja" && answers[i].match(/[a-zA-Z]+/) && answer === prefectureToRomaji(transcript);
      if (compareAnswer(answer, transcript) || prefectureMatch)
        return console.log("[Kitsun.matchAnswer] a=%s h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  }
  function clickNext() {
    let quizButtons = document.querySelectorAll("body > div.swal2-container.swal2-center.swal2-fade.swal2-shown > div > div.swal2-buttonswrapper > button.swal2-confirm.swal2-styled");
    if (quizButtons.length > 0) {
      quizButtons.item(0).click();
      return;
    }
    let nextans = document.getElementById("nextans"), nextButtons = document.querySelectorAll(".kitButton.flip_btn.kitButton__primary");
    nextans !== null ? nextans.click() : nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[Kitsun.clickNext] failed to find next button");
  }
  function inputAnswer({ preTs, normTs }) {
    if (matchedAnswer.length < 1) {
      console.log("[Kitsun.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, normTs);
      return;
    }
    let typeans = document.getElementById("typeans");
    typeans !== null ? (typeans.value = matchedAnswer, clickNext()) : console.log("[Kitsun.inputAnswer] typeans was null");
  }
  function getLanguageFromQuest() {
    let quests = document.getElementsByClassName("quest");
    for (var found = !1, i = 0; i < quests.length; i++) {
      let trimmed = quests[i].innerHTML.trim();
      if (trimmed === "Vocabulary Meaning")
        return "en";
      if (trimmed === "Vocabulary Reading")
        return "ja";
    }
    return null;
  }
  function getLanguageFromTypeans() {
    let typeans = document.getElementById("typeans");
    if (typeans === null)
      return null;
    let placeholder = typeans.getAttribute("placeholder");
    if (placeholder === "English" || placeholder === "Meaning")
      return "en";
    if (placeholder === "Japanese" || placeholder === "Reading")
      return "ja";
    {
      let lang = typeans.getAttribute("lang");
      return lang === null || lang !== "ja" && lang !== "en" ? null : lang;
    }
  }
  function setLanguage() {
    if (isPrefecturesDeck())
      return console.log("[Kitsun.setLanguage] set to Japanese for prefectures deck"), PluginBase.util.setLanguage("ja"), !0;
    var lang = getLanguageFromTypeans();
    return lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on typeans (10k/user deck)", lang), PluginBase.util.setLanguage(lang), !0) : (lang = getLanguageFromQuest(), lang !== null ? (console.log("[Kitsun.setLanguage] set to %s based on quest (10k)", lang), PluginBase.util.setLanguage(lang), !0) : (console.log("[Kitsun.setLanguage] failed to set language!"), !1));
  }
  function mutationCallback(mutations, observer2) {
    console.log("[Kitsun.mutationCallback] " + FlashCardState[currentState]), currentState === FlashCardState.Flipping && document.location.href.match(activePages) && setLanguage() && (currentState = FlashCardState.Flipped);
  }
  function exitKitsunContext() {
    console.log("[Kitsun.exitKitsunContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage), observer !== null && observer.disconnect();
  }
  function enterKitsunContext() {
    console.log("[Kitsun.enterKitsunContext]"), currentState = FlashCardState.Flipping, PluginBase.util.enterContext(["Kitsun Review"]), previousLanguage = PluginBase.util.getLanguage();
    let config = { attributes: !0, childList: !0, subtree: !0 };
    observer = new MutationObserver(mutationCallback);
    let mainContainer = document.getElementsByClassName("main-container")[0];
    observer.observe(mainContainer, config), mutationCallback(null, null);
  }
  function locationChangeHandler() {
    document.location.href.match(activePages) ? enterKitsunContext() : PluginBase.util.getContext().includes("Kitsun Review") && exitKitsunContext();
  }
  return { ...PluginBase, init: () => {
    currentState = FlashCardState.Flipping, previousLanguage = PluginBase.util.getLanguage();
    let src = `history.pushState = ( f => function pushState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.pushState);
        history.replaceState = ( f => function replaceState(){
            var ret = f.apply(this, arguments);
            window.dispatchEvent(new Event('locationchange'));
            return ret;
        })(history.replaceState);`;
    var head = document.getElementsByTagName("head")[0], script = document.createElement("script");
    script.type = "text/javascript", script.innerHTML = src, head.appendChild(script), window.addEventListener("locationchange", locationChangeHandler), locationChangeHandler();
  }, destroy: () => {
    window.removeEventListener("locationchange", locationChangeHandler), exitKitsunContext();
  }, commands: {} };
})();
