
export function isPrefecturesDeck(): boolean {
    const typeans = document.getElementById("typeans");
    if (typeans === null) {
        return false;
    }
    const placeholder = typeans.getAttribute("placeholder");
    if (placeholder === null) {
        return false;
    }
    if (placeholder === "Enter Prefecture Name ..." || placeholder.match(/Click on the.*Prefecture!/)) {
        return true;
    }
    return false;
}

/**
 * converts a prefecture name in kanji to romaji
 * todo: support submitting answers with suffix? 県,都,府
 */
export function prefectureToRomaji(ja: string): string {
    const maybe = prefectures[ja];
    if (maybe === null || maybe === undefined) {
        return ja;
    } else {
        return maybe.toLowerCase();
    }
}

const prefectures: { [key: string]: string } = {
    "とうほく":"Tohoku",
    "かんさい":"Kansai",
    "かんとう":"Kanto",
    "ちゅうぶ":"Chubu",
    "ちゅうごく":"Chugoku",
    "しこく":"Shikoku",
    "きゅうしゅう":"Kyushu",

    "あいち":"Aichi",
    "あきた":"Akita",
    "あおもり":"Aomori",
    "ちば":"Chiba",
    "えひめ":"Ehime",
    "ふくい":"Fukui",
    "ふくおか":"Fukuoka",
    "ふくしま":"Fukushima",
    "ぎふ":"Gifu",
    "ぐんま":"Gunma",
    "ひろしま":"Hiroshima",
    "ほっかいどう":"Hokkaido",
    "ひょうご":"Hyogo",
    "いばらき":"Ibaraki",
    "いしかわ":"Ishikawa",
    "いわて":"Iwate",
    "かがわ":"Kagawa",
    "かごしま":"Kagoshima",
    "かながわ":"Kanagawa",
    "こうち":"Kochi",
    "くまもと":"Kumamoto",
    "きょうと":"Kyoto",
    "みえ":"Mie",
    "みやぎ":"Miyagi",
    "みやざき":"Miyazaki",
    "ながの":"Nagano",
    "ながさき":"Nagasaki",
    "なら":"Nara",
    "にいがた":"Niigata",
    "おおいた":"Oita",
    "おかやま":"Okayama",
    "おきなわ":"Okinawa",
    "おおさか":"Osaka",
    "さが":"Saga",
    "さいたま":"Saitama",
    "しが":"Shiga",
    "しまね":"Shimane",
    "しずおか":"Shizuoka",
    "とちぎ":"Tochigi",
    "とくしま":"Tokushima",
    "とうきょう":"Tokyo",
    "とっとり":"Tottori",
    "とやま":"Toyama",
    "わかやま":"Wakayama",
    "やまがた":"Yamagata",
    "やまぐち":"Yamaguchi",
    "やまなし":"Yamanashi",

    "愛知":"Aichi",
    "秋田":"Akita",
    "青森":"Aomori",
    "千葉":"Chiba",
    "愛媛":"Ehime",
    "福井":"Fukui",
    "福岡":"Fukuoka",
    "福島":"Fukushima",
    "岐阜":"Gifu",
    "群馬":"Gunma",
    "広島":"Hiroshima",
    "北海道":"Hokkaido",
    "兵庫":"Hyogo",
    "茨城":"Ibaraki",
    "石川":"Ishikawa",
    "岩手":"Iwate",
    "香川":"Kagawa",
    "鹿児島":"Kagoshima",
    "神奈川":"Kanagawa",
    "高知":"Kochi",
    "熊本":"Kumamoto",
    "京都":"Kyoto",
    "三重":"Mie",
    "宮城":"Miyagi",
    "宮崎":"Miyazaki",
    "長野":"Nagano",
    "長崎":"Nagasaki",
    "奈良":"Nara",
    "新潟":"Niigata",
    "大分":"Oita",
    "岡山":"Okayama",
    "沖縄":"Okinawa",
    "大阪":"Osaka",
    "佐賀":"Saga",
    "埼玉":"Saitama",
    "滋賀":"Shiga",
    "島根":"Shimane",
    "静岡":"Shizuoka",
    "栃木":"Tochigi",
    "徳島":"Tokushima",
    "東京":"Tokyo",
    "鳥取":"Tottori",
    "富山":"Toyama",
    "和歌山":"Wakayama",
    "山形":"Yamagata",
    "山口":"Yamaguchi",
    "山梨":"Yamanashi"
};
