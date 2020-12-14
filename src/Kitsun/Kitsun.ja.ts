/// <reference types="lipsurf-types/extension"/>
import Kitsun from "./Kitsun";
import { matchAnswer } from "./Kitsun";

Kitsun.languages!.ja = {
    niceName: "Kitsun",
    description: "Kitsun",
    commands: {
        "Answer": {
            name: "Answer (Japanese)",
            match: {
                description: "[Japanese answer]",
                fn: matchAnswer
            }
        },
        "Next": {
            name: "Next (Japanese)",
            match: "\u3064\u304E",
        },
        "Wrong": {
            name: "Wrong (Japanese)",
            match: "\u3060\u3081"
        }
    }
};