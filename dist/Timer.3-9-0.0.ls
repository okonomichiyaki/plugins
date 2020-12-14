import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
const SET_TIMER_REGX = /\bset (?:(.*) )?timer (?:for )?(\d+) (seconds|minutes?|hours?)(?:(?: and)? (?:(?:(\d+) (seconds|minutes?))|(?:(?:a (?:(half)|(quarter))))))?\b/;
const PARTIAL_SET_TIMER_REGX = /\bset\b(.* )?(timer)?\b/;
var Timer = { ...PluginBase, ...{
    niceName: 'Timer',
    languages: {},
    description: 'Tools for setting timers.',
    version: '3.9.0',
    match: /.*/,
    authors: 'Miko',

    commands: [
        {
            name: 'Set Timer',
            description: 'Shows a notification and speaks "timer elapsed" (audio) after the specified duration.',
            global: true,
            match: {
                // does not handle decimals
                description: 'set [timer name (optional)] timer for [n] [seconds/minutes/hours]',
                fn: (transcript) => {
                    let match = transcript.match(SET_TIMER_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (PARTIAL_SET_TIMER_REGX.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                }
            },
            fn: async (transcript, fullMatch, timerName, quantity, unit, quantity2, unit2, half, quarter) => {
                let seconds = Number(quantity);
                if (unit.startsWith('minute'))
                    seconds *= 60;
                else if (unit.startsWith('hour'))
                    seconds *= 3600;
                let seconds2 = Number(quantity2);
                if (!isNaN(seconds2) && seconds2) {
                    if (unit2.startsWith('minute'))
                        seconds2 *= 60;
                    seconds += seconds2;
                }
                if (half)
                    if (unit.startsWith('minute'))
                        seconds += 30;
                    else
                        seconds += 1800;
                else if (quarter)
                    if (unit.startsWith('minute'))
                        seconds += 15;
                    else
                        seconds += 900;
                console.log(`total seconds ${seconds}`);
                setTimeout(() => {
                    let title = `${(timerName ? timerName : '')} timer elapsed.`.trimLeft();
                    title = title[0].toUpperCase() + title.slice(1, title.length);
                    chrome.notifications.create({
                        type: 'basic',
                        title,
                        message: `"${transcript}"`,
                        iconUrl: 'assets/icon-timer-48.png',
                        requireInteraction: true
                    });
                    chrome.tts.speak(title);
                }, seconds * 1000);
            }
        }
    ]
}
};

/// <reference types="lipsurf-types/extension"/>
Timer.languages.ru = {
    niceName: "Таймер",
    description: "Поиск в Google",
    authors: "Hanna",
    commands: {
        "Set Timer": {
            name: 'Установить таймер',
            description: 'Показывает уведомление и говорит "Таймер установлен" после того, как назван промежуток времени.',
            match: {
                // does not handle decimals
                description: 'Скажите "Установить таймер [имя таймера (не обязательно)] на x секунд/минут/часов"',
                fn: (transcript) => {
                    const match = transcript.match(/\bустановить (?:(.*) )?таймер (?:на )?(полчаса|полтора часа|(\d+) ?(секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)(?:(?: и)? (?:(?:(\d+) (секунд(?:у|ы)?|минут(?:у|ы)?))))?)\b/);
                    if (match) {
                        let quarter = null;
                        let timerName = match[1];
                        let half = match[2] && match[2].startsWith('пол') ? 'half' : null;
                        let quantity = match[3];
                        let unit = match[4] ? match[4].startsWith('секунд') ? 'second' : match[4].startsWith('минут') ? 'minute' : 'hour' : '';
                        let quantity2 = match[5];
                        let unit2 = match[6] ? match[6].startsWith('секунд') ? 'second' : match[6].startsWith('минут') ? 'minute' : 'hour' : '';
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, [match[0], timerName, quantity, unit, quantity2, unit2, half, quarter]];
                    }
                    else if (/\bустановить (?:(.*) )?(?:таймер)? (?:на )?/.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                }
            },
        },
    }
};

export default Timer;LS-SPLITallPlugins.Timer = (() => { /// <reference types="lipsurf-types/extension"/>
const SET_TIMER_REGX = /\bset (?:(.*) )?timer (?:for )?(\d+) (seconds|minutes?|hours?)(?:(?: and)? (?:(?:(\d+) (seconds|minutes?))|(?:(?:a (?:(half)|(quarter))))))?\b/;
const PARTIAL_SET_TIMER_REGX = /\bset\b(.* )?(timer)?\b/;
var Timer = { ...PluginBase, ...{
    commands: {
        "Set Timer": {
            match: {
                en: (transcript) => {
                    let match = transcript.match(SET_TIMER_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (PARTIAL_SET_TIMER_REGX.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                },

                ru: (transcript) => {
                    const match = transcript.match(/\bустановить (?:(.*) )?таймер (?:на )?(полчаса|полтора часа|(\d+) ?(секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)(?:(?: и)? (?:(?:(\d+) (секунд(?:у|ы)?|минут(?:у|ы)?))))?)\b/);
                    if (match) {
                        let quarter = null;
                        let timerName = match[1];
                        let half = match[2] && match[2].startsWith('пол') ? 'half' : null;
                        let quantity = match[3];
                        let unit = match[4] ? match[4].startsWith('секунд') ? 'second' : match[4].startsWith('минут') ? 'minute' : 'hour' : '';
                        let quantity2 = match[5];
                        let unit2 = match[6] ? match[6].startsWith('секунд') ? 'second' : match[6].startsWith('минут') ? 'minute' : 'hour' : '';
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, [match[0], timerName, quantity, unit, quantity2, unit2, half, quarter]];
                    }
                    else if (/\bустановить (?:(.*) )?(?:таймер)? (?:на )?/.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                }
            }
        }
    }
}
};

return Timer;
 })()LS-SPLITallPlugins.Timer = (() => { /// <reference types="lipsurf-types/extension"/>
const SET_TIMER_REGX = /\bset (?:(.*) )?timer (?:for )?(\d+) (seconds|minutes?|hours?)(?:(?: and)? (?:(?:(\d+) (seconds|minutes?))|(?:(?:a (?:(half)|(quarter))))))?\b/;
const PARTIAL_SET_TIMER_REGX = /\bset\b(.* )?(timer)?\b/;
var Timer = { ...PluginBase, ...{
    commands: {
        "Set Timer": {
            match: {
                en: (transcript) => {
                    let match = transcript.match(SET_TIMER_REGX);
                    if (match) {
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, match];
                    }
                    else if (PARTIAL_SET_TIMER_REGX.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                },

                ru: (transcript) => {
                    const match = transcript.match(/\bустановить (?:(.*) )?таймер (?:на )?(полчаса|полтора часа|(\d+) ?(секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)(?:(?: и)? (?:(?:(\d+) (секунд(?:у|ы)?|минут(?:у|ы)?))))?)\b/);
                    if (match) {
                        let quarter = null;
                        let timerName = match[1];
                        let half = match[2] && match[2].startsWith('пол') ? 'half' : null;
                        let quantity = match[3];
                        let unit = match[4] ? match[4].startsWith('секунд') ? 'second' : match[4].startsWith('минут') ? 'minute' : 'hour' : '';
                        let quantity2 = match[5];
                        let unit2 = match[6] ? match[6].startsWith('секунд') ? 'second' : match[6].startsWith('минут') ? 'minute' : 'hour' : '';
                        const endPos = match.index + match[0].length;
                        return [match.index, endPos, [match[0], timerName, quantity, unit, quantity2, unit2, half, quarter]];
                    }
                    else if (/\bустановить (?:(.*) )?(?:таймер)? (?:на )?/.test(transcript)) {
                        // ideally it would be smarter. Smartness should be built into the recognizer
                        return false;
                    }
                }
            }
        }
    }
}
};

return Timer;
 })()