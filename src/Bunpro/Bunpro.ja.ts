/// <reference types="lipsurf-types/extension"/>
import Bunpro from "./Bunpro";
import { matchAnswer } from "./Bunpro";

Bunpro.languages!.ja = {
    niceName: "Bunpro",
    description: "Bunpro",
    commands: {
        "Answer": {
            name: "Answer (Japanese)",
            match: {
                description: "[Japanese answer]",
                fn: matchAnswer
            }
        },
        "Hint": {
            name: "Hint (Japanese)",
            match: "ひんと",
        },
        "Next": {
            name: "Next (Japanese)",
            match: "つぎ",
        },
        "Wrong": {
            name: "Wrong (Japanese)",
            match: "だめ",
        }
    }
};
