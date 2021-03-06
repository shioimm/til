#use "q08_05.ml"

let global_information_list = [
  {name="代々木上原"; kana="よよぎうえはら"; roman="yoyogiuehara"; route="千代田線"};
  {name="代々木公園"; kana="よよぎこうえん"; roman="yoyogikouen"; route="千代田線"};
  {name="明治神宮前"; kana="めいじじんぐうまえ"; roman="meijijinguumae"; route="千代田線"};
  {name="表参道"; kana="おもてさんどう"; roman="omotesandou"; route="千代田線"};
  {name="乃木坂"; kana="のぎざか"; roman="nogizaka"; route="千代田線"};
  {name="赤坂"; kana="あかさか"; roman="akasaka"; route="千代田線"};
  {name="国会議事堂前"; kana="こっかいぎじどうまえ"; roman="kokkaigijidoumae"; route="千代田線"};
  {name="霞ヶ関"; kana="かすみがせき"; roman="kasumigaseki"; route="千代田線"};
  {name="日比谷"; kana="ひびや"; roman="hibiya"; route="千代田線"};
  {name="二重橋前"; kana="にじゅうばしまえ"; roman="nijuubasimae"; route="千代田線"};
  {name="大手町"; kana="おおてまち"; roman="otemachi"; route="千代田線"};
  {name="新御茶ノ水"; kana="しんおちゃのみず"; roman="shin-ochanomizu"; route="千代田線"};
  {name="湯島"; kana="ゆしま"; roman="yushima"; route="千代田線"};
  {name="根津"; kana="ねづ"; roman="nedu"; route="千代田線"};
  {name="千駄木"; kana="せんだぎ"; roman="sendagi"; route="千代田線"};
  {name="西日暮里"; kana="にしにっぽり"; roman="nishinippori"; route="千代田線"};
  {name="町屋"; kana="まちや"; roman="machiya"; route="千代田線"};
  {name="北千住"; kana="きたせんじゅ"; roman="kitasenjyu"; route="千代田線"};
  {name="綾瀬"; kana="あやせ"; roman="ayase"; route="千代田線"};
  {name="北綾瀬"; kana="きたあやせ"; roman="kitaayase"; route="千代田線"};
  {name="浅草"; kana="あさくさ"; roman="asakusa"; route="銀座線"};
  {name="田原町"; kana="たわらまち"; roman="tawaramachi"; route="銀座線"};
  {name="稲荷町"; kana="いなりちょう"; roman="inaricho"; route="銀座線"};
  {name="上野"; kana="うえの"; roman="ueno"; route="銀座線"};
  {name="上野広小路"; kana="うえのひろこうじ"; roman="uenohirokoji"; route="銀座線"};
  {name="末広町"; kana="すえひろちょう"; roman="suehirocho"; route="銀座線"};
  {name="神田"; kana="かんだ"; roman="kanda"; route="銀座線"};
  {name="三越前"; kana="みつこしまえ"; roman="mitsukoshimae"; route="銀座線"};
  {name="日本橋"; kana="にほんばし"; roman="nihonbashi"; route="銀座線"};
  {name="京橋"; kana="きょうばし"; roman="kyobashi"; route="銀座線"};
  {name="銀座"; kana="ぎんざ"; roman="ginza"; route="銀座線"};
  {name="新橋"; kana="しんばし"; roman="shinbashi"; route="銀座線"};
  {name="虎ノ門"; kana="とらのもん"; roman="toranomon"; route="銀座線"};
  {name="溜池山王"; kana="ためいけさんのう"; roman="tameikesannou"; route="銀座線"};
  {name="赤坂見附"; kana="あかさかみつけ"; roman="akasakamitsuke"; route="銀座線"};
  {name="青山一丁目"; kana="あおやまいっちょうめ"; roman="aoyamaicchome"; route="銀座線"};
  {name="外苑前"; kana="がいえんまえ"; roman="gaienmae"; route="銀座線"};
  {name="表参道"; kana="おもてさんどう"; roman="omotesando"; route="銀座線"};
  {name="渋谷"; kana="しぶや"; roman="shibuya"; route="銀座線"};
  {name="渋谷"; kana="しぶや"; roman="shibuya"; route="半蔵門線"};
  {name="表参道"; kana="おもてさんどう"; roman="omotesandou"; route="半蔵門線"};
  {name="青山一丁目"; kana="あおやまいっちょうめ"; roman="aoyama-itchome"; route="半蔵門線"};
  {name="永田町"; kana="ながたちょう"; roman="nagatacho"; route="半蔵門線"};
  {name="半蔵門"; kana="はんぞうもん"; roman="hanzomon"; route="半蔵門線"};
  {name="九段下"; kana="くだんした"; roman="kudanshita"; route="半蔵門線"};
  {name="神保町"; kana="じんぼうちょう"; roman="jinbocho"; route="半蔵門線"};
  {name="大手町"; kana="おおてまち"; roman="otemachi"; route="半蔵門線"};
  {name="三越前"; kana="みつこしまえ"; roman="mitsukoshimae"; route="半蔵門線"};
  {name="水天宮前"; kana="すいてんぐうまえ"; roman="suitengumae"; route="半蔵門線"};
  {name="清澄白河"; kana="きよすみしらかわ"; roman="kiyosumi-shirakawa"; route="半蔵門線"};
  {name="住吉"; kana="すみよし"; roman="sumiyoshi"; route="半蔵門線"};
  {name="錦糸町"; kana="きんしちょう"; roman="kinshicho"; route="半蔵門線"};
  {name="押上"; kana="おしあげ"; roman="oshiage"; route="半蔵門線"};
  {name="中目黒"; kana="なかめぐろ"; roman="nakameguro"; route="日比谷線"};
  {name="恵比寿"; kana="えびす"; roman="ebisu"; route="日比谷線"};
  {name="広尾"; kana="ひろお"; roman="hiro"; route="日比谷線"};
  {name="六本木"; kana="ろっぽんぎ"; roman="roppongi"; route="日比谷線"};
  {name="神谷町"; kana="かみやちょう"; roman="kamiyacho"; route="日比谷線"};
  {name="霞ヶ関"; kana="かすみがせき"; roman="kasumigaseki"; route="日比谷線"};
  {name="日比谷"; kana="ひびや"; roman="hibiya"; route="日比谷線"};
  {name="銀座"; kana="ぎんざ"; roman="ginza"; route="日比谷線"};
  {name="東銀座"; kana="ひがしぎんざ"; roman="higashiginza"; route="日比谷線"};
  {name="築地"; kana="つきじ"; roman="tsukiji"; route="日比谷線"};
  {name="八丁堀"; kana="はっちょうぼり"; roman="hacchobori"; route="日比谷線"};
  {name="茅場町"; kana="かやばちょう"; roman="kayabacho"; route="日比谷線"};
  {name="人形町"; kana="にんぎょうちょう"; roman="ningyomachi"; route="日比谷線"};
  {name="小伝馬町"; kana="こでんまちょう"; roman="kodemmacho"; route="日比谷線"};
  {name="秋葉原"; kana="あきはばら"; roman="akihabara"; route="日比谷線"};
  {name="仲御徒町"; kana="なかおかちまち"; roman="nakaokachimachi"; route="日比谷線"};
  {name="上野"; kana="うえの"; roman="ueno"; route="日比谷線"};
  {name="入谷"; kana="いりや"; roman="iriya"; route="日比谷線"};
  {name="三ノ輪"; kana="みのわ"; roman="minowa"; route="日比谷線"};
  {name="南千住"; kana="みなみせんじゅ"; roman="minamisenju"; route="日比谷線"};
  {name="北千住"; kana="きたせんじゅ"; roman="kitasenju"; route="日比谷線"};
  {name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
  {name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
  {name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"};
  {name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"};
  {name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
  {name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"};
  {name="淡路町"; kana="あわじちょう"; roman="awajicho"; route="丸ノ内線"};
  {name="大手町"; kana="おおてまち"; roman="otemachi"; route="丸ノ内線"};
  {name="東京"; kana="とうきょう"; roman="tokyo"; route="丸ノ内線"};
  {name="銀座"; kana="ぎんざ"; roman="ginza"; route="丸ノ内線"};
  {name="霞ヶ関"; kana="かすみがせき"; roman="kasumigaseki"; route="丸ノ内線"};
  {name="国会議事堂前"; kana="こっかいぎじどうまえ"; roman="kokkaigijidomae"; route="丸ノ内線"};
  {name="赤坂見附"; kana="あかさかみつけ"; roman="akasakamitsuke"; route="丸ノ内線"};
  {name="四ツ谷"; kana="よつや"; roman="yotsuya"; route="丸ノ内線"};
  {name="四谷三丁目"; kana="よつやさんちょうめ"; roman="yotsuyasanchome"; route="丸ノ内線"};
  {name="新宿御苑前"; kana="しんじゅくぎょえんまえ"; roman="shinjuku-gyoemmae"; route="丸ノ内線"};
  {name="新宿三丁目"; kana="しんじゅくさんちょうめ"; roman="shinjuku-sanchome"; route="丸ノ内線"};
  {name="新宿"; kana="しんじゅく"; roman="shinjuku"; route="丸ノ内線"};
  {name="西新宿"; kana="にししんじゅく"; roman="nishi-shinjuku"; route="丸ノ内線"};
  {name="中野坂上"; kana="なかのさかうえ"; roman="nakano-sakaue"; route="丸ノ内線"};
  {name="新中野"; kana="しんなかの"; roman="shin-nakano"; route="丸ノ内線"};
  {name="東高円寺"; kana="ひがしこうえんじ"; roman="higashi-koenji"; route="丸ノ内線"};
  {name="新高円寺"; kana="しんこうえんじ"; roman="shin-koenji"; route="丸ノ内線"};
  {name="南阿佐ヶ谷"; kana="みなみあさがや"; roman="minami-asagaya"; route="丸ノ内線"};
  {name="荻窪"; kana="おぎくぼ"; roman="ogikubo"; route="丸ノ内線"};
  {name="中野新橋"; kana="なかのしんばし"; roman="nakano-shimbashi"; route="丸ノ内線"};
  {name="中野富士見町"; kana="なかのふじみちょう"; roman="nakano-fujimicho"; route="丸ノ内線"};
  {name="方南町"; kana="ほうなんちょう"; roman="honancho"; route="丸ノ内線"};
  {name="四ツ谷"; kana="よつや"; roman="yotsuya"; route="南北線"};
  {name="永田町"; kana="ながたちょう"; roman="nagatacho"; route="南北線"};
  {name="溜池山王"; kana="ためいけさんのう"; roman="tameikesanno"; route="南北線"};
  {name="六本木一丁目"; kana="ろっぽんぎいっちょうめ"; roman="roppongiitchome"; route="南北線"};
  {name="麻布十番"; kana="あざぶじゅうばん"; roman="azabujuban"; route="南北線"};
  {name="白金高輪"; kana="しろかねたかなわ"; roman="shirokanetakanawa"; route="南北線"};
  {name="白金台"; kana="しろかねだい"; roman="shirokanedai"; route="南北線"};
  {name="目黒"; kana="めぐろ"; roman="meguro"; route="南北線"};
  {name="市ヶ谷"; kana="いちがや"; roman="ichigaya"; route="南北線"};
  {name="飯田橋"; kana="いいだばし"; roman="idabashi"; route="南北線"};
  {name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="南北線"};
  {name="東大前"; kana="とうだいまえ"; roman="todaimae"; route="南北線"};
  {name="本駒込"; kana="ほんこまごめ"; roman="honkomagome"; route="南北線"};
  {name="駒込"; kana="こまごめ"; roman="komagome"; route="南北線"};
  {name="西ヶ原"; kana="にしがはら"; roman="nishigahara"; route="南北線"};
  {name="王子"; kana="おうじ"; roman="oji"; route="南北線"};
  {name="王子神谷"; kana="おうじかみや"; roman="ojikamiya"; route="南北線"};
  {name="志茂"; kana="しも"; roman="shimo"; route="南北線"};
  {name="赤羽岩淵"; kana="あかばねいわぶち"; roman="akabaneiwabuchi"; route="南北線"};
  {name="西船橋"; kana="にしふなばし"; roman="nishi-funabashi"; route="東西線"};
  {name="原木中山"; kana="ばらきなかやま"; roman="baraki-nakayama"; route="東西線"};
  {name="妙典"; kana="みょうでん"; roman="myoden"; route="東西線"};
  {name="行徳"; kana="ぎょうとく"; roman="gyotoku"; route="東西線"};
  {name="南行徳"; kana="みなみぎょうとく"; roman="minami-gyotoku"; route="東西線"};
  {name="浦安"; kana="うらやす"; roman="urayasu"; route="東西線"};
  {name="葛西"; kana="かさい"; roman="kasai"; route="東西線"};
  {name="西葛西"; kana="にしかさい"; roman="nishi-kasai"; route="東西線"};
  {name="南砂町"; kana="みなみすなまち"; roman="minami-sunamachi"; route="東西線"};
  {name="東陽町"; kana="とうようちょう"; roman="touyoucho"; route="東西線"};
  {name="木場"; kana="きば"; roman="kiba"; route="東西線"};
  {name="門前仲町"; kana="もんぜんなかちょう"; roman="monzen-nakacho"; route="東西線"};
  {name="茅場町"; kana="かやばちょう"; roman="kayabacho"; route="東西線"};
  {name="日本橋"; kana="にほんばし"; roman="nihonbashi"; route="東西線"};
  {name="大手町"; kana="おおてまち"; roman="otemachi"; route="東西線"};
  {name="竹橋"; kana="たけばし"; roman="takebashi"; route="東西線"};
  {name="九段下"; kana="くだんした"; roman="kudanshita"; route="東西線"};
  {name="飯田橋"; kana="いいだばし"; roman="iidabashi"; route="東西線"};
  {name="神楽坂"; kana="かぐらざか"; roman="kagurazaka"; route="東西線"};
  {name="早稲田"; kana="わせだ"; roman="waseda"; route="東西線"};
  {name="高田馬場"; kana="たかだのばば"; roman="takadanobaba"; route="東西線"};
  {name="落合"; kana="おちあい"; roman="ochiai"; route="東西線"};
  {name="中野"; kana="なかの"; roman="nakano"; route="東西線"};
  {roman="shinkiba"; kana="しんきば"; name="新木場"; route="有楽町線"};
  {roman="tatsumi"; kana="たつみ"; name="辰巳"; route="有楽町線"};
  {roman="toyosu"; kana="とよす"; name="豊洲"; route="有楽町線"};
  {roman="tsukishima"; kana="つきしま"; name="月島"; route="有楽町線"};
  {roman="shintomityou"; kana="しんとみちょう"; name="新富町"; route="有楽町線"};
  {roman="ginzaittyoume"; kana="ぎんざいっちょうめ"; name="銀座一丁目"; route="有楽町線"};
  {roman="yuurakutyou"; kana="ゆうらくちょう"; name="有楽町"; route="有楽町線"};
  {roman="sakuradamon"; kana="さくらだもん"; name="桜田門"; route="有楽町線"};
  {roman="nagatacho"; kana="ながたちょう"; name="永田町"; route="有楽町線"};
  {roman="koujimachi"; kana="こうじまち"; name="麹町"; route="有楽町線"};
  {roman="ichigaya"; kana="いちがや"; name="市ヶ谷"; route="有楽町線"};
  {roman="iidabashi"; kana="いいだばし"; name="飯田橋"; route="有楽町線"};
  {name="江戸川橋"; kana="えどがわばし"; roman="edogawabasi"; route="有楽町線"};
  {name="護国寺"; kana="ごこくじ"; roman="gokokuji"; route="有楽町線"};
  {name="東池袋"; kana="ひがしいけぶくろ"; roman="higasiikebukuro"; route="有楽町線"};
  {name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="有楽町線"};
  {name="要町"; kana="かなめちょう"; roman="kanametyou"; route="有楽町線"};
  {name="千川"; kana="せんかわ"; roman="senkawa"; route="有楽町線"};
  {name="小竹向原"; kana="こたけむかいはら"; roman="kotakemukaihara"; route="有楽町線"};
  {name="氷川台"; kana="ひかわだい"; roman="hikawadai"; route="有楽町線"};
  {name="平和台"; kana="へいわだい"; roman="heiwadai"; route="有楽町線"};
  {name="営団赤塚"; kana="えいだんあかつか"; roman="eidanakakuka"; route="有楽町線"};
  {name="営団成増"; kana="えいだんなります"; roman="eidannarimasu"; route="有楽町線"};
  {name="和光市"; kana="わこうし"; roman="wakousi"; route="有楽町線"};
]
