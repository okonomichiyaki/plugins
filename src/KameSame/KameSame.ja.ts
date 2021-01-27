/// <reference types="lipsurf-types/extension"/>
import KameSame from "./KameSame";
import { matchAnswer } from "./KameSame";

KameSame.languages!.ja = {
    niceName: "KameSame",
    description: "KameSame",
    commands: {
        "Answer": {
            name: "答え (answer)",
            match: {
                description: "[KameSameの答え]",
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
