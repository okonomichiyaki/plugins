/// <reference types="lipsurf-types/extension"/>
import KaniWani from "./KaniWani";
import { matchAnswer } from "./KaniWani";

KaniWani.languages!.ja = {
    niceName: "KaniWani",
    description: "KaniWani",
    commands: {
        "Answer": {
            name: "答え (answer)",
            match: {
                description: "[KaniWaniの答え]",
                fn: matchAnswer
            }
        },
        "Next": {
            name: "次へ (next)",
            match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"]
        },
        "Wrong": {
            name: "バツ (wrong)",
            match: ["だめ", "ばつ"],
        }
    }
};
