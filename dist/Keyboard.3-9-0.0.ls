import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
function backendPressKey(codes) {
    // force into array
    const codesArr = [].concat(codes);
    chrome.runtime.sendMessage({ type: 'pressKeys', payload: { codes: codesArr, nonChar: true } });
}
function pressKey(key, code = 0) {
    backendPressKey(code);
    return true;
    // const activeEle = document.activeElement;
    // console.log(activeEle);
    // if (activeEle) {
    //     const code = key.charCodeAt(0);
    //     const evtDeets = {
    //         bubbles: true,
    //         cancelable: true,
    //         key,
    //         code: key,
    //         location: 0,
    //         // @ts-ignore
    //         keyCode: code,
    //         // deprecated, but we include it
    //         which: code,
    //     }
    //     activeEle.dispatchEvent(new KeyboardEvent("keydown", evtDeets));
    //     activeEle.dispatchEvent(new KeyboardEvent("keyup", evtDeets));
    //     activeEle.dispatchEvent(new KeyboardEvent("keypress", evtDeets));
    //     return true;
    // }
    // return false;
}
var Keyboard = { ...PluginBase, ...{
    niceName: 'Keyboard',
    languages: {},
    description: 'For pressing individual keyboard buttons with your voice.',
    version: '3.9.0',
    match: /.*/,
    authors: "Miko",

    homophones: {
        // causes issues with "press tab"
        // 'preston': 'press down',
        'pressed': 'press',
    },

    commands: [
        {
            name: 'Press Tab',
            description: 'Equivalent of hitting the tab key.',
            match: 'press tab',
            pageFn: () => {
                if (!pressKey("Tab", 9))
                    ;
            }
        },
        {
            name: 'Press Enter',
            description: 'Equivalent of hitting the enter key.',
            match: 'press enter',
            pageFn: () => {
                if (!pressKey("Enter", 13))
                    ;
            }
        },
        {
            name: 'Press Down',
            description: 'Equivalent of hitting the down arrow key.',
            match: 'press down',
            pageFn: () => {
                // gmail down arrow needs forcus when selecting recipient
                if (!pressKey("ArrowDown", 40))
                    // not sure of the use case for this
                    ;
            }
        },
        {
            name: 'Press Up',
            description: 'Equivalent of hitting the up arrow key.',
            match: 'press up',
            pageFn: () => {
                if (!pressKey("ArrowUp", 38))
                    ;
            }
        },
        {
            name: 'Press Left',
            description: 'Equivalent of hitting the left arrow key.',
            match: 'press left',
            pageFn: () => {
                if (!pressKey("ArrowLeft", 37))
                    ;
            }
        },
        {
            name: 'Press Right',
            description: 'Equivalent of hitting the right arrow key.',
            match: 'press right',
            pageFn: () => {
                if (!pressKey("ArrowRight", 39))
                    ;
            }
        },
    ]
} };

/// <reference types="lipsurf-types/extension"/>
Keyboard.languages.ja = {
    niceName: 'キーボード',
    description: 'キーボードのキーを個別に声で押せます。',
    authors: "Hiroki Yamazaki, Miko",
    commands: {
        'Press Tab': {
            name: 'Tabを押す',
            description: 'Tabキーを押すのと同じ動作をします。',
            match: 'たぶをおす',
        },
        'Press Enter': {
            name: 'Enterを押す',
            description: 'Enterキーを押すのと同じ動作をします。',
            match: 'えんたーをおす',
        },
        'Press Down': {
            name: '↓を押す',
            description: '↓キーを押すのと同じ動作をします。',
            match: 'したをおす',
        },
        'Press Up': {
            name: '↑を押す',
            description: '↑キーを押すのと同じ動作をします。',
            match: 'うえをおす',
        },
        'Press Left': {
            name: '←を押す',
            description: '←キーを押すのと同じ動作をします。',
            match: 'ひだりをおす',
        },
        'Press Right': {
            name: '→を押す',
            description: '→キーを押すのと同じ動作をします。',
            match: 'みぎをおす',
        },
    },
};

export default Keyboard;
export { backendPressKey };LS-SPLITallPlugins.Keyboard = (() => { /// <reference types="lipsurf-types/extension"/>
function backendPressKey(codes) {
    // force into array
    const codesArr = [].concat(codes);
    chrome.runtime.sendMessage({ type: 'pressKeys', payload: { codes: codesArr, nonChar: true } });
}
function pressKey(key, code = 0) {
    backendPressKey(code);
    return true;
    // const activeEle = document.activeElement;
    // console.log(activeEle);
    // if (activeEle) {
    //     const code = key.charCodeAt(0);
    //     const evtDeets = {
    //         bubbles: true,
    //         cancelable: true,
    //         key,
    //         code: key,
    //         location: 0,
    //         // @ts-ignore
    //         keyCode: code,
    //         // deprecated, but we include it
    //         which: code,
    //     }
    //     activeEle.dispatchEvent(new KeyboardEvent("keydown", evtDeets));
    //     activeEle.dispatchEvent(new KeyboardEvent("keyup", evtDeets));
    //     activeEle.dispatchEvent(new KeyboardEvent("keypress", evtDeets));
    //     return true;
    // }
    // return false;
}
var Keyboard = { ...PluginBase, ...{
    commands: {
        "Press Tab": {
            pageFn: () => {
                if (!pressKey("Tab", 9))
                    ;
            }
        },

        "Press Enter": {
            pageFn: () => {
                if (!pressKey("Enter", 13))
                    ;
            }
        },

        "Press Down": {
            pageFn: () => {
                // gmail down arrow needs forcus when selecting recipient
                if (!pressKey("ArrowDown", 40))
                    // not sure of the use case for this
                    ;
            }
        },

        "Press Up": {
            pageFn: () => {
                if (!pressKey("ArrowUp", 38))
                    ;
            }
        },

        "Press Left": {
            pageFn: () => {
                if (!pressKey("ArrowLeft", 37))
                    ;
            }
        },

        "Press Right": {
            pageFn: () => {
                if (!pressKey("ArrowRight", 39))
                    ;
            }
        }
    }
} };

return Keyboard;
 })()LS-SPLIT