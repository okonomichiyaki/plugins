import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';// dist/tmp/KaniWani/KaniWani.js
var kaniwaniDotCom = /^https:\/\/kaniwani.com\/.*$/, activePages = /^https:\/\/kaniwani.com\/(lessons|reviews)\/session$/, previousLanguage;
function katakanaToHiragana(s) {
  let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
  return s.split("").map((c) => {
    let point = c.codePointAt(0);
    return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
  }).join("");
}
function getAnswers() {
  let hidden = document.querySelectorAll("div[data-ruby]");
  if (hidden === null || hidden.length === 0)
    return console.log("[KaniWani.getAnswer] failed to find hidden div"), [];
  let answer = hidden[0].getAttribute("data-ruby");
  if (answer === null)
    return console.log("[KaniWani.getAnswer] found hidden div, but no data ruby"), [];
  let parts = answer.split(" ");
  return [{ answer: parts[0], kana: parts[1] }];
}
var matchedAnswer = "";
function markWrong() {
  console.log("[KaniWani.markWrong]");
  let answer = document.getElementById("answer");
  answer !== null && (answer.value = "あああ", clickNext()), window.setTimeout(() => {
    let info = document.querySelectorAll("#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.rsmiak-0.fjUYuW > button:nth-child(2)");
    console.log("info=%o", info), info.length > 0 && (console.log("clicked info=%o", info), info[0].click());
  }, 100);
}
function matchAnswer({ preTs, normTs }) {
  let answers = getAnswers(), transcript = normTs.toLowerCase();
  console.log("[KaniWani.matchAnswer] t=%s,a=%o", transcript, answers);
  for (var i = 0; i < answers.length; i++) {
    let answer = katakanaToHiragana(answers[i].kana);
    if (answer === transcript)
      return console.log("[KaniWani.matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i].answer, [0, transcript.length, [answers[i].kana]];
  }
  matchedAnswer = "";
}
function clickNext() {
  console.log("[KaniWani.clickNext]");
  let nextButtons = document.querySelectorAll('button[title="Submit answer"]');
  nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[KaniWani.clickNext] failed to find next button");
}
function inputAnswer({ preTs, normTs }) {
  let transcript = normTs;
  if (matchedAnswer.length < 1) {
    console.log("[KaniWani.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
    return;
  }
  let answer = document.getElementById("answer");
  answer !== null ? (answer.value = matchedAnswer, clickNext()) : console.log("[KaniWani.inputAnswer] answer was null");
}
function exitKaniWaniContext() {
  console.log("[KaniWani.exitKaniWaniContext]"), PluginBase.util.enterContext(["Normal"]), PluginBase.util.setLanguage(previousLanguage);
}
function enterKaniWaniContext() {
  console.log("[KaniWani.enterKaniWaniContext]"), PluginBase.util.enterContext(["KaniWani Review"]), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.setLanguage("ja");
}
function locationChangeHandler() {
  document.location.href.match(activePages) ? enterKaniWaniContext() : PluginBase.util.getContext().includes("KaniWani Review") && exitKaniWaniContext();
}
var KaniWani_default = { ...PluginBase, languages: {}, niceName: "KaniWani", description: "", match: kaniwaniDotCom, version: "0.0.2", apiVersion: 2, init: () => {
  previousLanguage = PluginBase.util.getLanguage();
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
  window.removeEventListener("locationchange", locationChangeHandler), exitKaniWaniContext();
}, contexts: { "KaniWani Review": { commands: ["LipSurf.Change Language to Japanese", "LipSurf.Normal Mode", "LipSurf.Turn off LipSurf", "Answer", "Next", "Wrong"] } }, commands: [{ name: "Answer", description: "Submit an English answer for a KaniWani review", match: { description: "[English answer]", fn: matchAnswer }, context: "KaniWani Review", normal: !1, pageFn: inputAnswer }, { name: "Next", description: "Go to the next item in a KaniWani review", match: "next", context: "KaniWani Review", normal: !1, pageFn: clickNext }, { name: "Wrong", description: "Mark a card wrong", match: "wrong", context: "KaniWani Review", normal: !1, pageFn: markWrong }] };
KaniWani_default.languages.ja = { niceName: "KaniWani", description: "KaniWani", commands: { Answer: { name: "答え (answer)", match: { description: "[KaniWaniの答え]", fn: matchAnswer } }, Next: { name: "次へ (next)", match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, Wrong: { name: "バツ (wrong)", match: ["だめ", "ばつ"] } } };
var dumby_default = KaniWani_default;
export {
  dumby_default as default
};
LS-SPLIT// dist/tmp/KaniWani/KaniWani.js
allPlugins.KaniWani = (() => {
  var kaniwaniDotCom = /^https:\/\/kaniwani.com\/.*$/, activePages = /^https:\/\/kaniwani.com\/(lessons|reviews)\/session$/, previousLanguage;
  function katakanaToHiragana(s) {
    let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map((c) => {
      let point = c.codePointAt(0);
      return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
    }).join("");
  }
  function getAnswers() {
    let hidden = document.querySelectorAll("div[data-ruby]");
    if (hidden === null || hidden.length === 0)
      return console.log("[KaniWani.getAnswer] failed to find hidden div"), [];
    let answer = hidden[0].getAttribute("data-ruby");
    if (answer === null)
      return console.log("[KaniWani.getAnswer] found hidden div, but no data ruby"), [];
    let parts = answer.split(" ");
    return [{ answer: parts[0], kana: parts[1] }];
  }
  var matchedAnswer = "";
  function markWrong() {
    console.log("[KaniWani.markWrong]");
    let answer = document.getElementById("answer");
    answer !== null && (answer.value = "あああ", clickNext()), window.setTimeout(() => {
      let info = document.querySelectorAll("#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.rsmiak-0.fjUYuW > button:nth-child(2)");
      console.log("info=%o", info), info.length > 0 && (console.log("clicked info=%o", info), info[0].click());
    }, 100);
  }
  function matchAnswer({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[KaniWani.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i].kana);
      if (answer === transcript)
        return console.log("[KaniWani.matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i].answer, [0, transcript.length, [answers[i].kana]];
    }
    matchedAnswer = "";
  }
  function clickNext() {
    console.log("[KaniWani.clickNext]");
    let nextButtons = document.querySelectorAll('button[title="Submit answer"]');
    nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[KaniWani.clickNext] failed to find next button");
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[KaniWani.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let answer = document.getElementById("answer");
    answer !== null ? (answer.value = matchedAnswer, clickNext()) : console.log("[KaniWani.inputAnswer] answer was null");
  }
  function exitKaniWaniContext() {
    console.log("[KaniWani.exitKaniWaniContext]"), PluginBase.util.enterContext(["Normal"]), PluginBase.util.setLanguage(previousLanguage);
  }
  function enterKaniWaniContext() {
    console.log("[KaniWani.enterKaniWaniContext]"), PluginBase.util.enterContext(["KaniWani Review"]), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.setLanguage("ja");
  }
  function locationChangeHandler() {
    document.location.href.match(activePages) ? enterKaniWaniContext() : PluginBase.util.getContext().includes("KaniWani Review") && exitKaniWaniContext();
  }
  return { ...PluginBase, init: () => {
    previousLanguage = PluginBase.util.getLanguage();
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
    window.removeEventListener("locationchange", locationChangeHandler), exitKaniWaniContext();
  }, commands: { Answer: { match: { en: function({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[KaniWani.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i].kana);
      if (answer === transcript)
        return console.log("[KaniWani.matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i].answer, [0, transcript.length, [answers[i].kana]];
    }
    matchedAnswer = "";
  }, ja: function({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[KaniWani.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i].kana);
      if (answer === transcript)
        return console.log("[KaniWani.matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i].answer, [0, transcript.length, [answers[i].kana]];
    }
    matchedAnswer = "";
  } }, pageFn: function({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[KaniWani.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let answer = document.getElementById("answer");
    answer !== null ? (answer.value = matchedAnswer, clickNext()) : console.log("[KaniWani.inputAnswer] answer was null");
  } }, Next: { pageFn: function() {
    console.log("[KaniWani.clickNext]");
    let nextButtons = document.querySelectorAll('button[title="Submit answer"]');
    nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[KaniWani.clickNext] failed to find next button");
  } }, Wrong: { pageFn: function() {
    console.log("[KaniWani.markWrong]");
    let answer = document.getElementById("answer");
    answer !== null && (answer.value = "あああ", clickNext()), window.setTimeout(() => {
      let info = document.querySelectorAll("#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.rsmiak-0.fjUYuW > button:nth-child(2)");
      console.log("info=%o", info), info.length > 0 && (console.log("clicked info=%o", info), info[0].click());
    }, 100);
  } } } };
})();
LS-SPLIT// dist/tmp/KaniWani/KaniWani.js
allPlugins.KaniWani = (() => {
  var kaniwaniDotCom = /^https:\/\/kaniwani.com\/.*$/, activePages = /^https:\/\/kaniwani.com\/(lessons|reviews)\/session$/, previousLanguage;
  function katakanaToHiragana(s) {
    let lower = "゠".codePointAt(0), upper = "ヿ".codePointAt(0), diff = "ア".codePointAt(0) - "あ".codePointAt(0);
    return s.split("").map((c) => {
      let point = c.codePointAt(0);
      return point >= lower && point <= upper ? String.fromCodePoint(point - diff) : c;
    }).join("");
  }
  function getAnswers() {
    let hidden = document.querySelectorAll("div[data-ruby]");
    if (hidden === null || hidden.length === 0)
      return console.log("[KaniWani.getAnswer] failed to find hidden div"), [];
    let answer = hidden[0].getAttribute("data-ruby");
    if (answer === null)
      return console.log("[KaniWani.getAnswer] found hidden div, but no data ruby"), [];
    let parts = answer.split(" ");
    return [{ answer: parts[0], kana: parts[1] }];
  }
  var matchedAnswer = "";
  function markWrong() {
    console.log("[KaniWani.markWrong]");
    let answer = document.getElementById("answer");
    answer !== null && (answer.value = "あああ", clickNext()), window.setTimeout(() => {
      let info = document.querySelectorAll("#app > div > main > div > div > div > section.sc-1y6l0g0-1.cvbtyw > div.rsmiak-0.fjUYuW > button:nth-child(2)");
      console.log("info=%o", info), info.length > 0 && (console.log("clicked info=%o", info), info[0].click());
    }, 100);
  }
  function matchAnswer({ preTs, normTs }) {
    let answers = getAnswers(), transcript = normTs.toLowerCase();
    console.log("[KaniWani.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let answer = katakanaToHiragana(answers[i].kana);
      if (answer === transcript)
        return console.log("[KaniWani.matchAnswer] a=%o h=%s t=%s", answers[i], answer, transcript), matchedAnswer = answers[i].answer, [0, transcript.length, [answers[i].kana]];
    }
    matchedAnswer = "";
  }
  function clickNext() {
    console.log("[KaniWani.clickNext]");
    let nextButtons = document.querySelectorAll('button[title="Submit answer"]');
    nextButtons.length > 0 ? nextButtons.item(0).click() : console.log("[KaniWani.clickNext] failed to find next button");
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[KaniWani.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let answer = document.getElementById("answer");
    answer !== null ? (answer.value = matchedAnswer, clickNext()) : console.log("[KaniWani.inputAnswer] answer was null");
  }
  function exitKaniWaniContext() {
    console.log("[KaniWani.exitKaniWaniContext]"), PluginBase.util.enterContext(["Normal"]), PluginBase.util.setLanguage(previousLanguage);
  }
  function enterKaniWaniContext() {
    console.log("[KaniWani.enterKaniWaniContext]"), PluginBase.util.enterContext(["KaniWani Review"]), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.setLanguage("ja");
  }
  function locationChangeHandler() {
    document.location.href.match(activePages) ? enterKaniWaniContext() : PluginBase.util.getContext().includes("KaniWani Review") && exitKaniWaniContext();
  }
  return { ...PluginBase, init: () => {
    previousLanguage = PluginBase.util.getLanguage();
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
    window.removeEventListener("locationchange", locationChangeHandler), exitKaniWaniContext();
  }, commands: {} };
})();
