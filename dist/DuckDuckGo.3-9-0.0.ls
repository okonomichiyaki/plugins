import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
var DuckDuckGo = { ...PluginBase, ...{
    niceName: 'DuckDuckGo',
    languages: {},
    description: 'The duckduckgo search engine.',
    version: '3.9.0',
    match: /.*/,

    homophones: {
        'search': 'duck',
    },

    authors: 'Aparajita Fishman',

    commands: [{
            name: 'Search',
            description: "Do a duckduckgo search.",
            global: true,
            match: 'duck *',
            fn: async (transcript, searchQuery) => {
                chrome.tabs.create({
                    url: `https://duckduckgo.com/?q=${searchQuery}`,
                    active: true
                });
            }
        }
    ]
}
};

export default DuckDuckGo;LS-SPLITallPlugins.DuckDuckGo = (() => { /// <reference types="lipsurf-types/extension"/>
var DuckDuckGo = { ...PluginBase, ...{
    commands: {
        "Search": {}
    }
}
};

return DuckDuckGo;
 })()LS-SPLITallPlugins.DuckDuckGo = (() => { /// <reference types="lipsurf-types/extension"/>
var DuckDuckGo = { ...PluginBase, ...{
    commands: {
        "Search": {}
    }
}
};

return DuckDuckGo;
 })()