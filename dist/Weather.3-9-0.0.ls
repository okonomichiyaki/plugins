import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
const weatherForLang = {
    'en': async (q) => {
        // https://api.accuweather.com/locations/v1/cities/autocomplete?q=chiang%20mai&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value
        // ex resp: [{"Version":1,"Key":"317505","Type":"City","Rank":41,"LocalizedName":"Chiang Mai","Country":{"ID":"TH","LocalizedName":"Thailand"},"AdministrativeArea":{"ID":"50","LocalizedName":"Chiang Mai"}}]
        // https://www.accuweather.com/en/th/chiang-mai/317505/weather-forecast/317505
        const resp = await (await window.fetch(`https://api.accuweather.com/locations/v1/cities/autocomplete?q=${q}&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value`)).json();
        let cityId = resp[0].Key;
        let countryCode = resp[0].Country.ID.toLowerCase();
        let cityName = resp[0].LocalizedName.replace(' ', '-');
        window.location.href = `https://www.accuweather.com/en/${countryCode}/${cityName}/${cityId}/weather-forecast/${cityId}`;
    }
};
function registerWeatherCbForLang(lang, cb) {
    weatherForLang[lang] = cb;
}
var Weather = { ...PluginBase, ...{
    niceName: 'Weather',
    languages: {},
    match: /.*accuweather\.com/,
    version: '3.9.0',

    commands: [{
            name: 'Check the Weather',
            description: 'Check the weather for a given city.',
            // say it on any page (not just accuweather domain)
            global: true,
            match: ['[weather/forecast] [for/in] *'],
            pageFn: async (transcript, q) => {
                const curLang = PluginBase.util.getLanguage();
                const shortenedLang = curLang.substr(0, 2);
                let chosenLang;
                if (curLang in weatherForLang) {
                    chosenLang = curLang;
                }
                else if (shortenedLang in weatherForLang) {
                    chosenLang = shortenedLang;
                }
                else {
                    chosenLang = 'en';
                }
                return weatherForLang[chosenLang](q);
            }
        }]
} };

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ja', (q) => {
    window.location.href = `https://tenki.jp/search/?keyword=${q}`;
});
Weather.languages.ja = {
    niceName: '天気',
    authors: "Hiroki Yamazaki",
    commands: {
        'Check the Weather': {
            name: "天気を調べる",
            description: '任意の都市の天気を調べます。',
            match: ['てんき[/よほう]*'],
        },
    }
};

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ru', (q) => {
    return window.location.href = `https://yandex.ru/pogoda/search?request=${q}`;
});
Weather.languages.ru = {
    niceName: 'Прогноз погоды',
    commands: {
        'Check the Weather': {
            name: "Погода",
            description: 'Узнать прогноз погоды в том или ином городе. Например, "погода минск" (название города не склоняется).',
            match: 'погода *',
        },
    }
};

export default Weather;
export { registerWeatherCbForLang };LS-SPLITallPlugins.Weather = (() => { /// <reference types="lipsurf-types/extension"/>
const weatherForLang = {
    'en': async (q) => {
        // https://api.accuweather.com/locations/v1/cities/autocomplete?q=chiang%20mai&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value
        // ex resp: [{"Version":1,"Key":"317505","Type":"City","Rank":41,"LocalizedName":"Chiang Mai","Country":{"ID":"TH","LocalizedName":"Thailand"},"AdministrativeArea":{"ID":"50","LocalizedName":"Chiang Mai"}}]
        // https://www.accuweather.com/en/th/chiang-mai/317505/weather-forecast/317505
        const resp = await (await window.fetch(`https://api.accuweather.com/locations/v1/cities/autocomplete?q=${q}&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value`)).json();
        let cityId = resp[0].Key;
        let countryCode = resp[0].Country.ID.toLowerCase();
        let cityName = resp[0].LocalizedName.replace(' ', '-');
        window.location.href = `https://www.accuweather.com/en/${countryCode}/${cityName}/${cityId}/weather-forecast/${cityId}`;
    }
};
function registerWeatherCbForLang(lang, cb) {
    weatherForLang[lang] = cb;
}
var Weather = { ...PluginBase, ...{
    commands: {
        "Check the Weather": {
            pageFn: async (transcript, q) => {
                const curLang = PluginBase.util.getLanguage();
                const shortenedLang = curLang.substr(0, 2);
                let chosenLang;
                if (curLang in weatherForLang) {
                    chosenLang = curLang;
                }
                else if (shortenedLang in weatherForLang) {
                    chosenLang = shortenedLang;
                }
                else {
                    chosenLang = 'en';
                }
                return weatherForLang[chosenLang](q);
            }
        }
    }
} };

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ja', (q) => {
    window.location.href = `https://tenki.jp/search/?keyword=${q}`;
});

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ru', (q) => {
    return window.location.href = `https://yandex.ru/pogoda/search?request=${q}`;
});

return Weather;
 })()LS-SPLITallPlugins.Weather = (() => { /// <reference types="lipsurf-types/extension"/>
const weatherForLang = {
    'en': async (q) => {
        // https://api.accuweather.com/locations/v1/cities/autocomplete?q=chiang%20mai&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value
        // ex resp: [{"Version":1,"Key":"317505","Type":"City","Rank":41,"LocalizedName":"Chiang Mai","Country":{"ID":"TH","LocalizedName":"Thailand"},"AdministrativeArea":{"ID":"50","LocalizedName":"Chiang Mai"}}]
        // https://www.accuweather.com/en/th/chiang-mai/317505/weather-forecast/317505
        const resp = await (await window.fetch(`https://api.accuweather.com/locations/v1/cities/autocomplete?q=${q}&apikey=d41dfd5e8a1748d0970cba6637647d96&language=en-us&get_param=value`)).json();
        let cityId = resp[0].Key;
        let countryCode = resp[0].Country.ID.toLowerCase();
        let cityName = resp[0].LocalizedName.replace(' ', '-');
        window.location.href = `https://www.accuweather.com/en/${countryCode}/${cityName}/${cityId}/weather-forecast/${cityId}`;
    }
};
function registerWeatherCbForLang(lang, cb) {
    weatherForLang[lang] = cb;
}
var Weather = { ...PluginBase, ...{
    commands: {
        "Check the Weather": {
            pageFn: async (transcript, q) => {
                const curLang = PluginBase.util.getLanguage();
                const shortenedLang = curLang.substr(0, 2);
                let chosenLang;
                if (curLang in weatherForLang) {
                    chosenLang = curLang;
                }
                else if (shortenedLang in weatherForLang) {
                    chosenLang = shortenedLang;
                }
                else {
                    chosenLang = 'en';
                }
                return weatherForLang[chosenLang](q);
            }
        }
    }
} };

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ja', (q) => {
    window.location.href = `https://tenki.jp/search/?keyword=${q}`;
});

/// <reference types="lipsurf-types/extension"/>
registerWeatherCbForLang('ru', (q) => {
    return window.location.href = `https://yandex.ru/pogoda/search?request=${q}`;
});

return Weather;
 })()