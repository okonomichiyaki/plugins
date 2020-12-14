import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';/// <reference types="lipsurf-types/extension"/>
var PeriodFix = { ...PluginBase, ...{
    niceName: 'Period Fix',
    languages: {},
    description: 'Some recognizers do not put a period but literally write "period" (something to do with region or Chrome OS perhaps). This is a workaround for that.',
    version: '3.9.0',
    match: /.*/,
    authors: 'Miko Borys',

    replacements: [
        {
            pattern: / ?period/,
            replacement: '.',
            context: 'Dictate',
        },
    ],

    commands: []
}
};

export default PeriodFix;LS-SPLITLS-SPLIT