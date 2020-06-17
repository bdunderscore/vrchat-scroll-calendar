アセット名　VRChatスクロール式イベントカレンダー
バージョン 1.0

アセット制作   bd_
デザイン: ことのし (@color_kotonoshi)

【概要】
このアセットは、カッコウ様が運営するVRChatイベントカレンダー[1]の情報を、VRChat内で表示するアセットです。イベントが多い日の対策として、スクロールできる仕様となっています。

[1] - https://sites.google.com/view/vrchat-event

【導入方法】
StdCalendarもしくはUnlitCalendarをシーンに配置し、位置やサイズを調整してください。
アス比は変えないようにご注意ください。

StdCalendarはStandardシェーダーベースなので影、光源の影響を受けます。
また、CalendarMatStdマテリアルを調整することでいろいろと調節できます。
AlbedoおよびMain MapsのTilingやOffsetをいじると崩壊するのでご注意ください。

UnlitCalendarはUnlitシェーダーベースなので、Unlit系統のワールドなら配置しやすいかもしれません。
明度はある程度CalendarMatのBrightness値で調節できます。

注意：　スポーンのすぐ近く、なおかつ低い位置に配置するとスクロールがうまく作動しない場合があります。
　　　　１メートルぐらいスポーンから離して配置したほうがいいかもしれません。

【明度調整】
このアセットは一部Unlit系統のシェーダーを使っているため、通常の照明や影の影響を受けない場合があります。
明度の調整が必要になった場合は、以下のところを調整してみてください

・【UnlitCalendarを使用する場合】CalendarMatマテリアルのBrightness値
・プレハブ内のScrollbarオブジェクトのNormal Color値（スクロールバーの背景を調整できます）
・プレハブ内のHandleオブジェクトのColor値（スクロールバーのハンドルの色を調整できます）

【利用規約】
Unityプレハブ、ローディング画像はCreative Commons CC0にて著作権を放棄しています。
詳しくはこちらに参照→https://creativecommons.org/publicdomain/zero/1.0/deed.ja
もしくはLICENSE-CC0.txtにて原文があります。

シェーダーコードはファイルによってはCC0もしくはMIT Licenseにて配布しています。
詳しくは該当ファイルのヘッダーを確認してください。

プレハブに設定されているカレンダーテキスチャーURLで配信されている画像は、
このアセットでVRChatワールド内に表示することを許可していますが、改変・再配布は禁止します。

【クレジット】
元々、坪倉輝明様の「VRChatイベントカレンダー」を参考にして作ったアセットです。

イベントカレンダーの情報はカッコウ様（@nest_cuckoo_)のVRChat イベントカレンダーを使用しています。イベントの登録、編集などはこちらに参照してください→https://sites.google.com/view/vrchat-event

デザイン案、配色、そしてリリース時のヘッダー画像はことのし様（@color_kotonoshi）にお願いしました。

スクロール同期はPhasedragonのSynced slidersプレハブを参考にさせていただきました。

シェーダーの制作過程でゆかたゆ様、はこつき様、Ram.Type-0様、PhaxeNor様などがいろいろアドバイスをしてくださいました。ありがとうございます。

クローズアルファーテストで神城葵さまに協力していただきました。

　　　　　　　　　　　　AND YOU　　　　　