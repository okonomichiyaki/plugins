import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';// dist/tmp/Bunpro/Bunpro.js
var matchedAnswer = "", previousLanguage, particles = { もう: "も", わ: "は" };
function fuzzyParticle(transcript) {
  let maybe = particles[transcript];
  return maybe === null ? transcript : maybe;
}
function notEmpty(value) {
  return value != null;
}
function getAnswers() {
  return Array.from(document.querySelectorAll("#answer_in_kana")).map((answer) => answer.getAttribute("data-answer")).filter(notEmpty);
}
function matchAnswer({ preTs, normTs }) {
  let transcript = normTs.toLowerCase(), answers = getAnswers();
  console.log("[Bunpro.matchAnswer] t=%s,a=%o", transcript, answers);
  for (var i = 0; i < answers.length; i++) {
    let hiragana = answers[i];
    if (hiragana === transcript || hiragana === fuzzyParticle(transcript))
      return console.log("[Bunpro.matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
  }
  matchedAnswer = "";
}
function inputAnswer({ preTs, normTs }) {
  let transcript = normTs;
  if (matchedAnswer.length < 1) {
    console.log("[Bunpro.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
    return;
  }
  let studyAreaInput = document.getElementById("study-answer-input");
  studyAreaInput !== null ? (studyAreaInput.value = matchedAnswer, clickNext()) : console.log("[Bunpro.inputAnswer] studyAreaInput was null");
}
function markWrong() {
  matchedAnswer = "あああ", inputAnswer({ preTs: "", normTs: matchedAnswer });
}
function clickElement(selector) {
  let element = document.querySelector(selector);
  element !== null ? element.click() : console.log("[Bunpro.clickElement] %s was null", selector);
}
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
  console.log("[Bunpro.enterBunproContext]"), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.enterContext(["Bunpro"]), PluginBase.util.setLanguage("ja");
}
function exitBunproContext() {
  console.log("[Bunpro.exitBunproContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage);
}
function locationChangeHandler() {
  console.log("[Bunpro.locationChangeHandler] href=%s", document.location.href), document.location.href.match(/.*bunpro.jp\/(learn|study|cram)$/) ? enterBunproContext() : exitBunproContext();
}
var Bunpro_default = { ...PluginBase, languages: {}, niceName: "Bunpro", description: "", match: /.*bunpro.jp.*/, apiVersion: 2, version: "0.0.4", init: () => {
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
  window.removeEventListener("locationchange", locationChangeHandler), exitBunproContext();
}, contexts: { Bunpro: { commands: ["LipSurf.Change Language to Japanese", "LipSurf.Normal Mode", "LipSurf.Turn off LipSurf", "Answer", "Hint", "Next", "Wrong", "Info"] } }, commands: [{ name: "Answer", description: "Submit an answer for a Bunpro review", match: { description: "[answer]", fn: (transcript) => {
  if (document.location.href.match(/.*www.bunpro.jp\/(learn|study|cram)$/))
    return matchAnswer(transcript);
} }, normal: !1, pageFn: inputAnswer }, { name: "Hint", description: "Toggle the translated hint", match: "hint", normal: !1, pageFn: clickHint }, { name: "Next", description: "Go to the next card", match: "next", normal: !1, pageFn: clickNext }, { name: "Wrong", description: "Mark a card wrong", match: "wrong", normal: !1, pageFn: markWrong }, { name: "Info", description: "Show grammar info", match: "info", normal: !1, pageFn: clickShowGrammar }] };
Bunpro_default.languages.ja = { niceName: "Bunpro", description: "Bunpro", commands: { Answer: { name: "答え (answer)", match: { description: "[Bunproの答え]", fn: matchAnswer } }, Hint: { name: "暗示 (hint)", match: ["ひんと", "あんじ"] }, Next: { name: "次へ (next)", match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"] }, Wrong: { name: "バツ (wrong)", match: ["だめ", "ばつ"] }, Info: { name: "情報 (info)", match: ["じょうほう"] } } };
var dumby_default = Bunpro_default;
export {
  dumby_default as default
};
LS-SPLIT// dist/tmp/Bunpro/Bunpro.js
allPlugins.Bunpro = (() => {
  var matchedAnswer = "", previousLanguage, particles = { もう: "も", わ: "は" };
  function fuzzyParticle(transcript) {
    let maybe = particles[transcript];
    return maybe === null ? transcript : maybe;
  }
  function notEmpty(value) {
    return value != null;
  }
  function getAnswers() {
    return Array.from(document.querySelectorAll("#answer_in_kana")).map((answer) => answer.getAttribute("data-answer")).filter(notEmpty);
  }
  function matchAnswer({ preTs, normTs }) {
    let transcript = normTs.toLowerCase(), answers = getAnswers();
    console.log("[Bunpro.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript))
        return console.log("[Bunpro.matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[Bunpro.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let studyAreaInput = document.getElementById("study-answer-input");
    studyAreaInput !== null ? (studyAreaInput.value = matchedAnswer, clickNext()) : console.log("[Bunpro.inputAnswer] studyAreaInput was null");
  }
  function markWrong() {
    matchedAnswer = "あああ", inputAnswer({ preTs: "", normTs: matchedAnswer });
  }
  function clickElement(selector) {
    let element = document.querySelector(selector);
    element !== null ? element.click() : console.log("[Bunpro.clickElement] %s was null", selector);
  }
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
    console.log("[Bunpro.enterBunproContext]"), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.enterContext(["Bunpro"]), PluginBase.util.setLanguage("ja");
  }
  function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage);
  }
  function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s", document.location.href), document.location.href.match(/.*bunpro.jp\/(learn|study|cram)$/) ? enterBunproContext() : exitBunproContext();
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
    window.removeEventListener("locationchange", locationChangeHandler), exitBunproContext();
  }, commands: { Answer: { match: { en: (transcript) => {
    if (document.location.href.match(/.*www.bunpro.jp\/(learn|study|cram)$/))
      return matchAnswer(transcript);
  }, ja: function({ preTs, normTs }) {
    let transcript = normTs.toLowerCase(), answers = getAnswers();
    console.log("[Bunpro.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript))
        return console.log("[Bunpro.matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  } }, pageFn: function({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[Bunpro.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let studyAreaInput = document.getElementById("study-answer-input");
    studyAreaInput !== null ? (studyAreaInput.value = matchedAnswer, clickNext()) : console.log("[Bunpro.inputAnswer] studyAreaInput was null");
  } }, Hint: { pageFn: function() {
    clickElement("#show-english-hint");
  } }, Next: { pageFn: function() {
    clickElement("#submit-study-answer");
  } }, Wrong: { pageFn: function() {
    matchedAnswer = "あああ", inputAnswer({ preTs: "", normTs: matchedAnswer });
  } }, Info: { pageFn: function() {
    clickElement("#show-grammar");
  } } } };
})();
LS-SPLIT// dist/tmp/Bunpro/Bunpro.js
allPlugins.Bunpro = (() => {
  var matchedAnswer = "", previousLanguage, particles = { もう: "も", わ: "は" };
  function fuzzyParticle(transcript) {
    let maybe = particles[transcript];
    return maybe === null ? transcript : maybe;
  }
  function notEmpty(value) {
    return value != null;
  }
  function getAnswers() {
    return Array.from(document.querySelectorAll("#answer_in_kana")).map((answer) => answer.getAttribute("data-answer")).filter(notEmpty);
  }
  function matchAnswer({ preTs, normTs }) {
    let transcript = normTs.toLowerCase(), answers = getAnswers();
    console.log("[Bunpro.matchAnswer] t=%s,a=%o", transcript, answers);
    for (var i = 0; i < answers.length; i++) {
      let hiragana = answers[i];
      if (hiragana === transcript || hiragana === fuzzyParticle(transcript))
        return console.log("[Bunpro.matchAnswer] a=%s h=%s t=%s", answers[i], hiragana, transcript), matchedAnswer = answers[i], [0, transcript.length, [answers[i]]];
    }
    matchedAnswer = "";
  }
  function inputAnswer({ preTs, normTs }) {
    let transcript = normTs;
    if (matchedAnswer.length < 1) {
      console.log("[Bunpro.inputAnswer] matched transcript but matchedAnswer=%s? transcript=%s", matchedAnswer, transcript);
      return;
    }
    let studyAreaInput = document.getElementById("study-answer-input");
    studyAreaInput !== null ? (studyAreaInput.value = matchedAnswer, clickNext()) : console.log("[Bunpro.inputAnswer] studyAreaInput was null");
  }
  function markWrong() {
    matchedAnswer = "あああ", inputAnswer({ preTs: "", normTs: matchedAnswer });
  }
  function clickElement(selector) {
    let element = document.querySelector(selector);
    element !== null ? element.click() : console.log("[Bunpro.clickElement] %s was null", selector);
  }
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
    console.log("[Bunpro.enterBunproContext]"), previousLanguage = PluginBase.util.getLanguage(), PluginBase.util.enterContext(["Bunpro"]), PluginBase.util.setLanguage("ja");
  }
  function exitBunproContext() {
    console.log("[Bunpro.exitBunproContext]"), PluginBase.util.enterContext(["Normal"]), previousLanguage !== null && PluginBase.util.setLanguage(previousLanguage);
  }
  function locationChangeHandler() {
    console.log("[Bunpro.locationChangeHandler] href=%s", document.location.href), document.location.href.match(/.*bunpro.jp\/(learn|study|cram)$/) ? enterBunproContext() : exitBunproContext();
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
    window.removeEventListener("locationchange", locationChangeHandler), exitBunproContext();
  }, commands: {} };
})();
