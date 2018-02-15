const customArgumentsToken = Symbol("__ES6-PROMISIFY--CUSTOM-ARGUMENTS__");
var activated = false;
const LABEL_FADE_TIME = 2000;
const SCROLL_DISTANCE = 550;
const SCROLL_TIME = 450;
var $previewCmdBox;
var $helpBox;
var lblTimeout;
var helpBoxOpen = false;
var commandsLoaded = false;
var $lastExpanded;
var commands = {};
let msgTracker = {};
async function getFrameHtml(id) {
    return await $.get(chrome.extension.getURL(`views/${id}.html`));
}
function scrollToAnimated($ele) {
    $("html, body").animate({ scrollTop: $ele.offset().top }, SCROLL_TIME);
}
async function attachOverlay(id) {
    var $iframe = $(`<iframe class="nhm-iframe" id="nhm-${id}"></iframe>`);
    $iframe.appendTo(document.body).contents().find('body').append(await getFrameHtml(id));
    return $iframe;
}
function isInView($ele) {
    var docViewTop = $(window).scrollTop();
    var docViewBottom = docViewTop + $(window).height();
    var elemTop = $ele.offset().top;
    return ((elemTop <= docViewBottom) && (elemTop >= docViewTop));
}
function sendMsgToBeacon(msg) {
    return retrialAndError(new Promise((resolve, reject) => {
        console.log(`send msg to beacon msg: ${JSON.stringify(msg)}`);
        chrome.runtime.sendMessage({ bubbleDown: msg }, function (resp) {
            if (resp) {
                return resolve(resp);
            }
            else {
                return reject();
            }
        });
    }), null, 2000, 2);
}
window.addEventListener('message', function (evt) {
    let msg = evt.data;
    let id = msg.id;
    if (msg.isTop) {
        msgTracker[id].cb(msg.data);
        delete msgTracker[id];
    }
}, false);
function queryAllFrames(tagName, attrs) {
    return new Promise((resolve, reject) => {
        let msgName = 'get_send';
        let frames = $('iframe');
        let id = +new Date();
        msgTracker[id] = {
            cb: function (res) {
                resolve(res);
            }
        };
        window.postMessage({ id: id, name: msgName, data: { tagName, attrs } }, window.location.href);
    });
}
function postToAllFrames({ id, selector, fnNames }) {
    let msgName = 'post_send';
    let frames = $('iframe');
    fnNames = typeof fnNames === "object" ? fnNames : [fnNames];
    let msg = { id: +new Date(), name: msgName, data: { id, selector, fnNames } };
    window.postMessage(msg, window.location.href);
    frames.each((i, frame) => {
        try {
            if (!frame.src.startsWith('http://') && !frame.src.startsWith('https://')) {
                return;
            }
        }
        catch (e) { }
        frame.contentWindow.postMessage(msg, frame.src);
    });
}
function retrialAndError(f, f_check, delay, times) {
    return new Promise((resolve, reject) => {
        if (times > 0) {
            let res = Promise.resolve(f);
            res.then((res0) => {
                if (!f_check && res0) {
                    resolve();
                }
                else {
                    setTimeout(function () {
                        if (f_check) {
                            let res = f_check();
                            if (!res) {
                                return retrialAndError(f, f_check, delay, times - 1);
                            }
                            else {
                                return resolve(res);
                            }
                        }
                        else {
                            return retrialAndError(f, f_check, delay, times - 1);
                        }
                    }, delay);
                }
            });
        }
        else {
            return resolve();
        }
    });
}
function toggleActivated(_activated = true, quiet = false) {
    if (!_activated && activated) {
        activated = false;
        try {
            $previewCmdBox.remove();
        }
        catch (e) { }
        try {
            $helpBox.remove();
        }
        catch (e) { }
    }
    else if (_activated && !activated) {
        activated = true;
        if (!commandsLoaded) {
            chrome.runtime.sendMessage('loadPlugins');
            commandsLoaded = true;
        }
        retrialAndError(async function () {
            await promisify($(document).ready)();
            if (activated) {
                $previewCmdBox = await attachOverlay('preview-cmd-box');
            }
            if (!quiet) {
                showLiveText("Ready");
            }
            $(`#siteTable>div.thing .expando-button`).click(function (e) {
                $lastExpanded = $(e.currentTarget);
            });
        }, function () {
            if ($previewCmdBox) {
                return document.body.contains($previewCmdBox[0]);
            }
        }, LABEL_FADE_TIME / 5, 5);
        retrialAndError(async function () {
            await promisify($(document).ready)();
            if (activated) {
                console.log("opening");
                $helpBox = await attachOverlay('help-box');
                helpBoxOpen = true;
            }
        }, function () {
            return !helpBoxOpen || document.body.contains($helpBox[0]);
        }, 500, 25);
    }
}
async function showLiveText(text, isSuccess = false, isUnsure = false, hold = false, isError = false) {
    if (typeof $previewCmdBox === 'undefined' || !document.body.contains($previewCmdBox[0])) {
        $previewCmdBox = await attachOverlay('preview-cmd-box');
    }
    console.log(`showLiveText ${text} ${isSuccess} ${isUnsure}`);
    let $previewCmdLbl = $previewCmdBox.contents().find('.preview-cmd');
    clearTimeout(lblTimeout);
    $previewCmdLbl.toggleClass('success', isSuccess);
    $previewCmdLbl.toggleClass('unsure', isUnsure);
    $previewCmdLbl.toggleClass('error', isError);
    $previewCmdLbl.text(text);
    $previewCmdLbl.toggleClass('visible', true);
    lblTimeout = setTimeout(function () {
        $('iframe.nhm-iframe#nhm-preview-cmd-box').contents().find('.preview-cmd').toggleClass('visible', false);
    }, hold ? LABEL_FADE_TIME * 3 : LABEL_FADE_TIME);
}
chrome.runtime.onMessage.addListener(function (msg) {
    if (typeof msg.cmdName !== 'undefined') {
        commands[msg.cmdPluginName][msg.cmdName].apply(null, msg.cmdArgs);
    }
    else if (typeof msg.liveText !== 'undefined') {
        showLiveText(msg.liveText.text, msg.liveText.isSuccess);
    }
    else if (typeof msg.toggleActivated !== "undefined") {
        toggleActivated(msg.toggleActivated);
    }
});
document.addEventListener("webkitfullscreenchange", function (event) {
    console.log(`rnh-cs removing fullscreen ${document.webkitIsFullScreen}`);
    toggleFullScreen(false);
});
document.addEventListener("webkitvisibilitychange", function (event) {
    console.log(`hidden: ${document.hidden}`);
    if (!document.hidden) {
        checkActivatedStatus();
    }
});
function checkActivatedStatus() {
    chrome.storage.local.get('activated', function (activatedObj) {
        if (typeof (activatedObj) == 'object' && activatedObj.activated) {
            toggleActivated(true, true);
        }
    });
}
function promisify(original, withError = false) {
    if (typeof original !== "function") {
        throw new TypeError("Argument to promisify must be a function");
    }
    const argumentNames = original[customArgumentsToken];
    if (typeof Promise !== "function") {
        throw new Error("No Promise implementation found; do you need a polyfill?");
    }
    return function (...args) {
        return new Promise((resolve, reject) => {
            args.push(function callback() {
                let values = [];
                for (var i = withError ? 1 : 0; i < arguments.length; i++) {
                    values.push(arguments[i]);
                }
                if (withError && arguments[0]) {
                    return reject(arguments[0]);
                }
                if (values.length === 1 || !argumentNames) {
                    return resolve(values[0]);
                }
                let o;
                values.forEach((value, index) => {
                    const name = argumentNames[index];
                    if (name) {
                        o[name] = value;
                    }
                });
                resolve(o);
            });
            original.call(this, ...args);
        });
    };
}
checkActivatedStatus();
console.log("rnh-cs loaded");
