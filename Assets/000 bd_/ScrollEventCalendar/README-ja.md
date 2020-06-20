[English README](https://github.com/bdunderscore/vrchat-scroll-calendar/blob/trunk/Assets/000%20bd_/ScrollEventCalendar/README-en.md)

アセット: VRChat想定スクロール式イベントカレンダー<br>
バージョン: 1.0

制作: bd_ ([@bd_j][1])<br>
デザイン: Kotonoshi ([@color_kotonoshi][2])

[1]: https://twitter.com/bd_j
[2]: https://twitter.com/color_kotonoshi

# 概要
このアセットは、カッコウ様が運営する[VRChatイベントカレンダー][10]の情報を、VRChat内で表示するアセットです。イベントが多い日の対策として、スクロールできる仕様となっています。

[10]: https://sites.google.com/view/vrchat-event

# ダウンロード

[ダウンロードページ][11]から最新版をダウンロードしてください。

[11]: https://github.com/bdunderscore/vrchat-scroll-calendar/releases

# 導入方法

1. ワールドのどこかにEvent Systemコンポーネントがない場合、一度どこかにUI Canvasを作って削除してください（Event Systemが自動的に追加されます）
2. StdCalendarもしくはUnlitCalendarをシーンに配置し、位置やサイズを調整してください。アス比は変えないようにご注意ください。

StdCalendarはStandardシェーダーベースなので影、光源の影響を受けます。
また、CalendarMatStdマテリアルを調整することでいろいろと調節できます。
AlbedoおよびMain MapsのTilingやOffsetをいじると崩壊するのでご注意ください。

UnlitCalendarはUnlitシェーダーベースなので、Unlit系統のワールドなら配置しやすいかもしれません。
明度はある程度CalendarMatのBrightness値で調節できます。

【注意】スポーンのすぐ近く、なおかつ低い位置に配置するとスクロールがうまく作動しない場合があります。
１メートルぐらいスポーンから離して配置したほうがいいかもしれません。

## 明度調整
このアセットは一部Unlit系統のシェーダーを使っているため、通常の照明や影の影響を受けない場合があります。
明度の調整が必要になった場合は、以下のところを調整してみてください

1. 【UnlitCalendarを使用する場合】CalendarMatマテリアルのBrightness値
2. プレハブ内のScrollbarオブジェクトのNormal Color値（スクロールバーの背景を調整できます）
3. プレハブ内のHandleオブジェクトのColor値（スクロールバーのハンドルの色を調整できます）

# 利用規約
Unityプレハブ、ローディング画像は[Creative Commons CC0][41]にて著作権を放棄しています。
[LICENSE-CC0.txt](LICENSE-CC0.txt)にて原文があります。

シェーダーコードはファイルによってはCC0もしくは[MIT License][42]にて配布しています。
詳しくは該当ファイルのヘッダーを確認してください。

プレハブに設定されているカレンダーテキスチャーURLで配信されている画像は、
このアセットでVRChatワールド内に表示することを許可しますが、改変・再配布は禁止します。
また、このアセットを改変・再配布する場合はURLを変えていただけると助かります。

[41]: https://creativecommons.org/publicdomain/zero/1.0/deed.ja 
[42]: LICENSE-MIT.txt

# クレジット
元々、[坪倉輝明様][59]の「[VRChatイベントカレンダー][60]」を参考にして作ったアセットです。

イベントカレンダーの情報はカッコウ様（[@nest_cuckoo_][51])のVRChat イベントカレンダーを使用しています。イベントの登録、編集などはこちらに参照してください→https://sites.google.com/view/vrchat-event

デザイン案、配色、そしてリリース時のヘッダー画像はことのし様（[@color_kotonoshi][52]）にお願いしました。

スクロール同期は[Phasedragon][53]のSynced slidersプレハブを参考にさせていただきました。

シェーダーの制作過程で[ゆかたゆ様][54]、[はこつき様][55]、[Ram.Type-0様][56]、[PhaxeNor様][57]などがいろいろアドバイスをしてくださいました。ありがとうございます。

クローズアルファーテストで[神城葵様][58]に協力していただきました。

　　　　　　　　　　　　AND YOU

[51]: https://twitter.com/nest_cuckoo_
[52]: https://twitter.com/color_kotonoshi
[53]: https://twitter.com/phasedragoon
[54]: https://twitter.com/yukata_yu
[55]: https://twitter.com/re_hako_moon
[56]: https://twitter.com/Ram_Type64_Mod0
[57]: https://twitter.com/PhaxeNor
[58]: https://twitter.com/aoi3192
[59]: https://twitter.com/kohack_v
[60]: https://booth.pm/ja/items/1223535
