let UNIQUE_ATTR_NAME = 'data-rnh290318-id';
console.log(`beacon 1 ${window.location}`);
var playing = false;
let waitingSubFrames = {};
function makeId() {
    var text = "";
    var possible = "abcdefghijklmnopqrstuvwxyz";
    for (var i = 0; i < 15; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    return text;
}
window.addEventListener("message", function (evt) {
    console.log(evt.origin);
    let { data, source, origin } = evt;
    let msg = data;
    let msgParts = (msg.name && typeof (msg.name) === 'string') ? msg.name.split('_') : [null];
    let msgType = msgParts[msgParts.length - 1];
    if (msgType === 'recv') {
        if (msgParts[0] === 'get') {
            let tracker = waitingSubFrames[msg.id];
            let index = tracker.pending.indexOf(msg.frameId);
            if (~index) {
                tracker.pending.splice(index, 1);
                tracker.res.push(msg.data);
                if (tracker.pending.length == 0) {
                    let isTop = top === window;
                    parent.postMessage({
                        isTop: isTop,
                        id: msg.id,
                        name: msg.name,
                        frameId: waitingSubFrames[msg.id].sender,
                        data: isTop ? tracker.res : [].concat.apply([], tracker.res)
                    }, '*');
                }
            }
        }
    }
    else {
        if (msgType && msg.id) {
            if (msgParts[0] === 'post') {
                let selStr, selEle, frames;
                if (msg.data.id) {
                    selStr = `[${UNIQUE_ATTR_NAME}="${msg.data.id}"]`;
                }
                else {
                    selStr = msg.data.selector;
                }
                selEle = document.querySelector(selStr);
                frames = document.getElementsByTagName('iframe');
                if (selEle) {
                    for (let fnName of msg.data.fnNames) {
                        selEle[fnName]();
                    }
                }
                for (let i = 0; i < frames.length; i++) {
                    try {
                        if (!frames[i].src.startsWith('http://') && !frames[i].src.startsWith('https://')) {
                            continue;
                        }
                    }
                    catch (e) { }
                    frames[i].contentWindow.postMessage(msg, frames[i].src);
                }
            }
            else {
                let selEles = document.getElementsByTagName(msg.data.tagName);
                let tracker = waitingSubFrames[msg.id] = {
                    res: [],
                    sender: msg.frameId,
                    pending: [],
                };
                let frames = document.getElementsByTagName('iframe');
                for (let selEle of selEles) {
                    let id = selEle.getAttribute(UNIQUE_ATTR_NAME);
                    if (!id) {
                        id = makeId();
                        selEle.setAttribute(UNIQUE_ATTR_NAME, id);
                    }
                    tracker.res.push([id]);
                    for (let attr of msg.data.attrs) {
                        let selAttr = selEle;
                        for (let nestedAttr of attr.split('.')) {
                            try {
                                if (nestedAttr.endsWith('()')) {
                                    selAttr = selAttr[nestedAttr.replace('()', '')]();
                                }
                                else {
                                    selAttr = selAttr[nestedAttr];
                                }
                            }
                            catch (e) { }
                        }
                        tracker.res[tracker.res.length - 1].push(selAttr);
                    }
                }
                for (let i = 0; i < frames.length; i++) {
                    let frameId = makeId();
                    try {
                        if (!frames[i].src.startsWith('http://') && !frames[i].src.startsWith('https://')) {
                            continue;
                        }
                    }
                    catch (e) { }
                    tracker.pending.push(frameId);
                    frames[i].contentWindow.postMessage(Object.assign({}, msg, { frameId }), frames[i].src);
                }
                if (tracker.pending.length == 0) {
                    let isTop = top === window;
                    parent.postMessage({
                        isTop: isTop,
                        id: msg.id,
                        name: `${msg.name}_recv`,
                        frameId: msg.frameId,
                        data: isTop ? tracker.res : [].concat.apply([], tracker.res)
                    }, '*');
                }
            }
        }
    }
}, false);
chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    if (request.bubbleDown) {
        let bubbleDown = request.bubbleDown;
        if (typeof (bubbleDown.getVideos) !== 'undefined') {
            sendResponse("yes");
        }
    }
});
document.addEventListener("webkitfullscreenchange", function (event) {
    console.log(`frame-beacon.js rnh-cs removing fullscreen ${document.webkitIsFullScreen}`);
    if (!document.webkitIsFullScreen) {
        chrome.runtime.sendMessage({
            bubbleDown: {
                unFullScreen: null
            }
        });
    }
});
