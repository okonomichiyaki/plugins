/// <reference types="lipsurf-types/extension"/>
import Bunpro from "./Bunpro";
import { matchAnswer } from "./Bunpro";

Bunpro.languages!.ja = {
    niceName: "Bunpro",
    description: "Bunpro",
    commands: {
        "Answer": {
            name: "答え (answer)",
            match: {
                description: "[Bunproの答え]",
                fn: matchAnswer
            }
        },
        "Hint": {
            name: "暗示 (hint)",
            match: ["ひんと", "あんじ"]
        },
        "Next": {
            name: "次へ (next)",
            match: ["つぎ", "ねくすと", "ていしゅつ", "すすむ", "ちぇっく"]
        },
        "Wrong": {
            name: "バツ (wrong)",
            match: ["だめ", "ばつ"]
        },
        "Info": {
            name: "情報 (info)",
            match: ["じょうほう"]
        },
    }
};
