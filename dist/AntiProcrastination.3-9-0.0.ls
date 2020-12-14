import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
const OPEN_X_FOR_Y_TIME_REGX = /\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/;
const OPEN_REGX = /\bopen\b/;
var AntiProcrastination = { ...PluginBase, ...{
    niceName: 'Anti-procrastination',
    languages: {},
    description: 'Tools for curbing procrastination.',
    match: /.*/,
    version: '3.9.0',
    authors: 'Miko',

    commands: [
        {
            name: 'Self Destructing Tab',
            description: 'Open a new tab with x website for y time. Useful for limiting the time-sucking power of sites like facebook, reddit, twitter etc.',
            global: true,
            match: {
                description: 'open [website name] for [n] [seconds/minutes/hours]',
                fn: (transcript) => {
                    const match = transcript.match(OPEN_X_FOR_Y_TIME_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (OPEN_REGX.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                }
            },
            // delay is needed to get more accurate site name
            delay: 600,
            fn: async (transcript, fullMatch, siteStr, secondsStr, unit) => {
                let seconds = Number(secondsStr);
                if (unit.startsWith('minute'))
                    seconds *= 60;
                else if (unit.startsWith('hour'))
                    seconds *= 3600;
                if (~siteStr.indexOf('hacker news'))
                    siteStr = 'news.ycombinator';
                else if (siteStr === 'reddit' || siteStr === 'ready')
                    // faster than the redirect
                    siteStr = 'old.reddit.com';
                let site = `https://${siteStr.replace(/\s+/g, '').replace("'", '').replace('.com', '').replace('dot com', '')}.com`;
                let id = chrome.tabs.create({
                    url: site,
                    active: true,
                }, (tab) => {
                    setTimeout(() => {
                        chrome.tabs.remove(tab.id);
                    }, seconds * 1000);
                });
            }
        }
    ]
} };

/// <reference types="lipsurf-types/extension"/>
AntiProcrastination.languages.ru = {
    niceName: 'Анти-прокрастинатор',
    authors: 'Hanna',
    commands: {
        'Self Destructing Tab': {
            name: 'Самозакрывающаяся вкладка',
            description: 'Открывает новую вкладку только на заданное время. Удобно для ограничения пользования сайтами-времяубийцами вроде facebook, reddit, twitter etc.',
            match: {
                description: 'Скажите "открыть [название сайта] на x секунд/минут/часов"',
                fn: (transcript) => {
                    let match = transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        match[3] = match[3].startsWith('минут') ? 'minute' : match[3].startsWith('час') ? 'hour' : 'second';
                        return [match.index, endPos, match];
                    }
                    else if (/\bоткрыть\b/.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                }
            },
            // delay is needed to get more accurate site name
            delay: 600,
        },
    }
};

export default AntiProcrastination;LS-SPLITallPlugins.AntiProcrastination = (() => { /// <reference types="lipsurf-types/extension"/>
const OPEN_X_FOR_Y_TIME_REGX = /\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/;
const OPEN_REGX = /\bopen\b/;
var AntiProcrastination = { ...PluginBase, ...{
    commands: {
        "Self Destructing Tab": {
            match: {
                en: (transcript) => {
                    const match = transcript.match(OPEN_X_FOR_Y_TIME_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (OPEN_REGX.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                },

                ru: (transcript) => {
                    let match = transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        match[3] = match[3].startsWith('минут') ? 'minute' : match[3].startsWith('час') ? 'hour' : 'second';
                        return [match.index, endPos, match];
                    }
                    else if (/\bоткрыть\b/.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                }
            }
        }
    }
} };

return AntiProcrastination;
 })()LS-SPLITallPlugins.AntiProcrastination = (() => { /// <reference types="lipsurf-types/extension"/>
const OPEN_X_FOR_Y_TIME_REGX = /\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/;
const OPEN_REGX = /\bopen\b/;
var AntiProcrastination = { ...PluginBase, ...{
    commands: {
        "Self Destructing Tab": {
            match: {
                en: (transcript) => {
                    const match = transcript.match(OPEN_X_FOR_Y_TIME_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (OPEN_REGX.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                },

                ru: (transcript) => {
                    let match = transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        match[3] = match[3].startsWith('минут') ? 'minute' : match[3].startsWith('час') ? 'hour' : 'second';
                        return [match.index, endPos, match];
                    }
                    else if (/\bоткрыть\b/.test(transcript)) {
                        // ideally it would be smarter than just testing (open) but that functionality 
                        // should be built into the recognizer
                        return false;
                    }
                }
            }
        }
    }
} };

return AntiProcrastination;
 })()