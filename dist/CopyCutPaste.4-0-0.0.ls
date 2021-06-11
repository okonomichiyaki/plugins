import PluginBase from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/plugin-base.js';import ExtensionUtil from 'chrome-extension://lnnmjmalakahagblkkcnjkoaihlfglon/dist/modules/extension-util.js';function u(e){return new Promise(t=>{chrome.permissions.contains({permissions:[e]},s=>{s?t(!0):chrome.permissions.request({permissions:[e]},i=>{t(i)})})})}var a={...PluginBase,languages:{},niceName:"Copy, Cut and Paste",description:"Permissions must be granted with the mouse the first time this plugin is used.",version:"4.0.0",match:/.*/,homophones:{coffee:"copy",poppee:"copy",pissed:"paste",taste:"paste"},authors:"Miko",commands:[{name:"Copy",description:"Copies the selected text to the clipboard.",match:"copy",fn:async()=>{await u("clipboardWrite")},pageFn:async()=>{document.execCommand("copy")}},{name:"Cut",description:"Cut the selected text to the clipboard.",match:"cut",fn:async()=>{await u("clipboardWrite")},pageFn:async()=>{document.execCommand("cut")}},{name:"Paste",description:"Paste the item in the clipboard.",match:"paste",fn:async()=>{await u("clipboardRead")},pageFn:async()=>{document.execCommand("paste")}}]};a.languages.ja={niceName:"コピー, 切り取り, 貼り付け",description:"このプラグインの使用前にマウスで権限を与える必要があります。",authors:"Hiroki Yamazaki, Miko",commands:{Copy:{name:"コピー",description:"選択されたテキストをクリップボードにコピーします。",match:"こぴー"},Cut:{name:"切り取り",description:"選択されたテキストをクリップボードに切り取ります。",match:["かっと","きりとり"]},Paste:{name:"貼り付け",description:"クリップボードの内容を貼り付けます。",match:["はりつけ","ぺーすと"]}}};var n=a;export{n as default};
LS-SPLITallPlugins.CopyCutPaste=(()=>{function m(e){return new Promise(n=>{chrome.permissions.contains({permissions:[e]},s=>{s?n(!0):chrome.permissions.request({permissions:[e]},o=>{n(o)})})})}return{...PluginBase,commands:{Copy:{pageFn:async()=>{document.execCommand("copy")}},Cut:{pageFn:async()=>{document.execCommand("cut")}},Paste:{pageFn:async()=>{document.execCommand("paste")}}}}})();
LS-SPLIT