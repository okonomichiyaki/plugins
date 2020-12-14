import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
var NewTab = { ...PluginBase, ...{
    niceName: 'New tab',
    languages: {},
    description: 'Create a new empty tab.',
    version: '3.9.0',
    match: /.*/,

    homophones: {
        'open tab': 'new tab',
    },

    authors: 'Aparajita Fishman',

    commands: [{
            name: 'New tab',
            description: "Create a new empty tab.",
            global: true,
            match: 'new tab',
            fn: async () => {
                chrome.tabs.create({
                    active: true,
                });
            }
        }
    ]
} };

export default NewTab;LS-SPLITallPlugins.NewTab = (() => { /// <reference types="lipsurf-types/extension"/>
var NewTab = { ...PluginBase, ...{
    commands: {
        "New tab": {}
    }
} };

return NewTab;
 })()LS-SPLITallPlugins.NewTab = (() => { /// <reference types="lipsurf-types/extension"/>
var NewTab = { ...PluginBase, ...{
    commands: {
        "New tab": {}
    }
} };

return NewTab;
 })()