import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
const SpotifyPlayerUrl = 'https://play.spotify.com/';
const SpotifyPlayerUrlMatch = '*://*.spotify.com/*';
const SpotifyPlayerUrlRegexMatch = /.*\.spotify\.com/;
function clickButton(selector) {
    const btn = document.querySelector(selector);
    if (btn)
        btn.click();
}
async function findSpotifyPlayerTabAsync() {
    return new Promise((res) => {
        return chrome.tabs.query({ url: SpotifyPlayerUrlMatch }, (tabs) => {
            res(tabs.length ? tabs[0] : null);
        });
    });
}
async function createSpotifyPlayerTabAsync() {
    return new Promise((res) => {
        return chrome.tabs.create({ url: SpotifyPlayerUrl }, (tab) => {
            return res(tab);
        });
    });
}
async function sendSpotifyControlMessage(control, _tab = null) {
    const tab = _tab || await findSpotifyPlayerTabAsync();
    return new Promise((resolve) => {
        if (tab && tab.id) {
            return chrome.tabs.sendMessage(tab.id, { type: 'postMessage', control }, () => {
                resolve(true);
            });
        }
        resolve(false);
    });
}
var Spotify = {
    ...PluginBase, ...{
    niceName: 'Spotify',
    languages: {},
    description: 'An experimental plugin for spotify.com',
    match: SpotifyPlayerUrlRegexMatch,
    version: '0.0.9',
    authors: 'Ahmed Kamal',

    init: function () {
        if (SpotifyPlayerUrlRegexMatch.test(window.location.origin)) {
            chrome.runtime.onMessage.addListener((msg, _, sendResponse) => {
                if (msg.type === 'postMessage') {
                    switch (msg.control) {
                        case "button[data-testid=\"control-button-play\"]" /* Play */: {
                            clickButton("button[data-testid=\"control-button-play\"]" /* Play */);
                            break;
                        }
                        case "button[data-testid=\"control-button-pause\"]" /* Pause */:
                            clickButton("button[data-testid=\"control-button-pause\"]" /* Pause */);
                            break;
                        case "button[data-testid=\"control-button-skip-forward\"]" /* Next */:
                            clickButton("button[data-testid=\"control-button-skip-forward\"]" /* Next */);
                            break;
                        case "button[data-testid=\"control-button-skip-back\"]" /* Previous */:
                            clickButton("button[data-testid=\"control-button-skip-back\"]" /* Previous */);
                            break;
                        default:
                            break;
                    }
                    sendResponse(null);
                }
            });
        }
    },

    commands: [
        {
            name: 'spotify play',
            description: 'Play the Spotify web player.',
            global: true,
            match: 'spotify play',
            fn: async function () {
                let tab = await findSpotifyPlayerTabAsync();
                if (!tab) {
                    const msg = 'Spotify player seems to be closed, do you want me to open it?';
                    if (prompt(msg, 'yes') === 'yes') {
                        tab = await createSpotifyPlayerTabAsync();
                    }
                }
                await sendSpotifyControlMessage("button[data-testid=\"control-button-play\"]" /* Play */, tab);
            }
        },
        {
            name: 'spotify pause',
            description: 'Pause the Spotify web player.',
            global: true,
            match: 'spotify pause',
            fn: async function () {
                await sendSpotifyControlMessage("button[data-testid=\"control-button-pause\"]" /* Pause */);
            }
        },
        {
            name: 'spotify next',
            description: 'Moves to the next song on the Spotify web player.',
            global: true,
            match: 'spotify next',
            fn: async function () {
                await sendSpotifyControlMessage("button[data-testid=\"control-button-skip-forward\"]" /* Next */);
            }
        },
        {
            name: 'spotify previous',
            description: 'Moves to the previous song on the Spotify web player.',
            global: true,
            match: 'spotify previous',
            fn: async function () {
                await sendSpotifyControlMessage("button[data-testid=\"control-button-skip-back\"]" /* Previous */);
            }
        }
    ]
}
};

export default Spotify;LS-SPLITallPlugins.Spotify = (() => { /// <reference types="lipsurf-types/extension"/>
const SpotifyPlayerUrlRegexMatch = /.*\.spotify\.com/;
function clickButton(selector) {
    const btn = document.querySelector(selector);
    if (btn)
        btn.click();
}
var Spotify = {
    ...PluginBase, ...{
    init: function () {
        if (SpotifyPlayerUrlRegexMatch.test(window.location.origin)) {
            chrome.runtime.onMessage.addListener((msg, _, sendResponse) => {
                if (msg.type === 'postMessage') {
                    switch (msg.control) {
                        case "button[data-testid=\"control-button-play\"]" /* Play */: {
                            clickButton("button[data-testid=\"control-button-play\"]" /* Play */);
                            break;
                        }
                        case "button[data-testid=\"control-button-pause\"]" /* Pause */:
                            clickButton("button[data-testid=\"control-button-pause\"]" /* Pause */);
                            break;
                        case "button[data-testid=\"control-button-skip-forward\"]" /* Next */:
                            clickButton("button[data-testid=\"control-button-skip-forward\"]" /* Next */);
                            break;
                        case "button[data-testid=\"control-button-skip-back\"]" /* Previous */:
                            clickButton("button[data-testid=\"control-button-skip-back\"]" /* Previous */);
                            break;
                        default:
                            break;
                    }
                    sendResponse(null);
                }
            });
        }
    },

    commands: {
        "spotify play": {},
        "spotify pause": {},
        "spotify next": {},
        "spotify previous": {}
    }
}
};

return Spotify;
 })()LS-SPLITallPlugins.Spotify = (() => { /// <reference types="lipsurf-types/extension"/>
const SpotifyPlayerUrlRegexMatch = /.*\.spotify\.com/;
function clickButton(selector) {
    const btn = document.querySelector(selector);
    if (btn)
        btn.click();
}
var Spotify = {
    ...PluginBase, ...{
    init: function () {
        if (SpotifyPlayerUrlRegexMatch.test(window.location.origin)) {
            chrome.runtime.onMessage.addListener((msg, _, sendResponse) => {
                if (msg.type === 'postMessage') {
                    switch (msg.control) {
                        case "button[data-testid=\"control-button-play\"]" /* Play */: {
                            clickButton("button[data-testid=\"control-button-play\"]" /* Play */);
                            break;
                        }
                        case "button[data-testid=\"control-button-pause\"]" /* Pause */:
                            clickButton("button[data-testid=\"control-button-pause\"]" /* Pause */);
                            break;
                        case "button[data-testid=\"control-button-skip-forward\"]" /* Next */:
                            clickButton("button[data-testid=\"control-button-skip-forward\"]" /* Next */);
                            break;
                        case "button[data-testid=\"control-button-skip-back\"]" /* Previous */:
                            clickButton("button[data-testid=\"control-button-skip-back\"]" /* Previous */);
                            break;
                        default:
                            break;
                    }
                    sendResponse(null);
                }
            });
        }
    },

    commands: {
        "spotify play": {},
        "spotify pause": {},
        "spotify next": {},
        "spotify previous": {}
    }
}
};

return Spotify;
 })()