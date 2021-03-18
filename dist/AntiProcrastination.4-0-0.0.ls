import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';const OPEN_X_FOR_Y_TIME_REGX=/\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/,OPEN_REGX=/\bopen\b/;var AntiProcrastination={...PluginBase,niceName:"Anti-procrastination",languages:{},description:"Tools for curbing procrastination.",match:/.*/,version:"4.0.0",authors:"Miko",commands:[{name:"Self Destructing Tab",description:"Open a new tab with x website for y time. Useful for limiting the time-sucking power of sites like facebook, reddit, twitter etc.",global:!0,match:{description:"open [website name] for [n] [seconds/minutes/hours]",fn:transcript=>{const match=transcript.match(OPEN_X_FOR_Y_TIME_REGX);if(match){const endPos=match.index+match[0].length;return [match.index,endPos,match]}if(OPEN_REGX.test(transcript))return !1}},delay:600,fn:async(transcript,fullMatch,siteStr,secondsStr,unit)=>{let seconds=Number(secondsStr);unit.startsWith("minute")?seconds*=60:unit.startsWith("hour")&&(seconds*=3600),~siteStr.indexOf("hacker news")?siteStr="news.ycombinator":"reddit"!==siteStr&&"ready"!==siteStr||(siteStr="old.reddit.com");let site=`https://${siteStr.replace(/\s+/g,"").replace("'","").replace(".com","").replace("dot com","")}.com`;chrome.tabs.create({url:site,active:!0},tab=>{setTimeout(()=>{chrome.tabs.remove(tab.id);},1e3*seconds);});}}]};AntiProcrastination.languages.ru={niceName:"Анти-прокрастинатор",authors:"Hanna",commands:{"Self Destructing Tab":{name:"Самозакрывающаяся вкладка",description:"Открывает новую вкладку только на заданное время. Удобно для ограничения пользования сайтами-времяубийцами вроде facebook, reddit, twitter etc.",match:{description:'Скажите "открыть [название сайта] на x секунд/минут/часов"',fn:transcript=>{let match=transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);if(match){const endPos=match.index+match[0].length;return match[3]=match[3].startsWith("минут")?"minute":match[3].startsWith("час")?"hour":"second",[match.index,endPos,match]}if(/\bоткрыть\b/.test(transcript))return !1}},delay:600}}};

export default AntiProcrastination;LS-SPLITallPlugins.AntiProcrastination = (() => { const OPEN_X_FOR_Y_TIME_REGX=/\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/,OPEN_REGX=/\bopen\b/;var AntiProcrastination={...PluginBase,commands:{"Self Destructing Tab":{match:{en:transcript=>{const match=transcript.match(OPEN_X_FOR_Y_TIME_REGX);if(match){const endPos=match.index+match[0].length;return [match.index,endPos,match]}if(OPEN_REGX.test(transcript))return !1},ru:transcript=>{let match=transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);if(match){const endPos=match.index+match[0].length;return match[3]=match[3].startsWith("минут")?"minute":match[3].startsWith("час")?"hour":"second",[match.index,endPos,match]}if(/\bоткрыть\b/.test(transcript))return !1}}}}};

return AntiProcrastination;
 })()LS-SPLITallPlugins.AntiProcrastination = (() => { const OPEN_X_FOR_Y_TIME_REGX=/\bopen (.*) for (\d+) (seconds|minutes?|hours?)\b/,OPEN_REGX=/\bopen\b/;var AntiProcrastination={...PluginBase,commands:{"Self Destructing Tab":{match:{en:transcript=>{const match=transcript.match(OPEN_X_FOR_Y_TIME_REGX);if(match){const endPos=match.index+match[0].length;return [match.index,endPos,match]}if(OPEN_REGX.test(transcript))return !1},ru:transcript=>{let match=transcript.match(/\bоткрыть (.*) на (\d+) (секунд(?:у|ы)?|минут(?:у|ы)?|час(?:а|ов)?)\b/);if(match){const endPos=match.index+match[0].length;return match[3]=match[3].startsWith("минут")?"minute":match[3].startsWith("час")?"hour":"second",[match.index,endPos,match]}if(/\bоткрыть\b/.test(transcript))return !1}}}}};

return AntiProcrastination;
 })()