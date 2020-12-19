/// <reference types="lipsurf-types/extension"/>
import Kitsun from "./Kitsun";
import { matchAnswer } from "./Kitsun";

Kitsun.languages!.ja = {
    niceName: "Kitsun",
    description: "Kitsun",
    commands: {
        "Answer": {
            name: "答え (answer)",
            match: {
                description: "[Kitsunの答え]",
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
