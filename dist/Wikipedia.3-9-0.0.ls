import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
var WikipediaPlugin = { ...PluginBase, ...{
    niceName: 'Wikipedia',
    languages: {},
    description: 'The Wikipedia search engine.',
    version: '3.9.0',
    match: /.*/,

    homophones: {
        'wiki': 'wikipedia',
    },

    authors: 'Aparajita Fishman',

    commands: [{
            name: 'Wikipedia',
            description: "Do a wikipedia search.",
            global: true,
            match: 'wikipedia *',
            fn: async (transcript, searchQuery) => {
                chrome.tabs.create({
                    url: `https://wikipedia.org/w/index.php?search=${encodeURIComponent(searchQuery).replace(/%20/g, '+')}`,
                    active: true
                });
            }
        }
    ]
}
};

/// <reference types="lipsurf-types/extension"/>
WikipediaPlugin.languages.ru = {
    niceName: 'Wikipedia',
    description: 'Поиск по Википедии.',
    authors: 'Hanna',
    homophones: {
        'википедия': 'wikipedia',
    },
    commands: {
        "Wikipedia": {
            name: 'Википедия',
            description: "Выполняет поиск по википедии. Скажите википедия [запрос].",
            match: ['википедия *',],
        }
    },
};

export default WikipediaPlugin;LS-SPLITallPlugins.Wikipedia = (() => { /// <reference types="lipsurf-types/extension"/>
var WikipediaPlugin = { ...PluginBase, ...{
    commands: {
        "Wikipedia": {}
    }
}
};

return WikipediaPlugin;
 })()LS-SPLITallPlugins.Wikipedia = (() => { /// <reference types="lipsurf-types/extension"/>
var WikipediaPlugin = { ...PluginBase, ...{
    commands: {
        "Wikipedia": {}
    }
}
};

return WikipediaPlugin;
 })()