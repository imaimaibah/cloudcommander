//  ========================================================
//  jkl-calendar.js ---- ポップアップカレンダー表示クラス
//  Copyright 2005-2006 Kawasaki Yusuke <u-suke [at] kawa.net>
//  Thanks to 2tak <info [at] code-hour.com>
//  http://www.kawa.net/works/js/jkl/calender.html
//  2005/04/06 - 最初のバージョン
//  2005/04/10 - 外部スタイルシートを使用しない、JKL.Opacity はオプション
//  2006/10/22 - typo修正、spliter/min_date/max_dateプロパティ、×ボタン追加
//  2006/10/23 - prototype.js併用時は、Event.observe()でイベント登録
//  2006/10/24 - max_date 範囲バグ修正
//  2006/10/25 - フォームに初期値があれば、カレンダーの初期値に採用する
//	2006/11/15 - MOM Update 週の初めの曜日を変更できるように修正
//  2006/11/23 - MOM Update 今日日付の文字色を指定できるように修正、あと枠線も描画してみる
//  ========================================================

/***********************************************************
//  （サンプル）ポップアップするカレンダー

  <html>
    <head>
      <script type="text/javascript" src="jkl-calendar.js" charset="Shift_JIS"></script>
      <script>
        var cal1 = new JKL.Calendar("calid","formid","colname");
       </script>
    </head>
    <body>
      <form id="formid" action="">
        <input type="text" name="colname" onClick="cal1.write();" onChange="cal1.getFormValue(); cal1.hide();"><br>
        <div id="calid"></div>
      </form>

	表示開始曜日を選択<br>
	<input type="radio" name="rb_sd" value="0" onChange="changeStartDay(0)" checked>日
	<input type="radio" name="rb_sd" value="1" onChange="changeStartDay(1)">月
	<input type="radio" name="rb_sd" value="2" onChange="changeStartDay(2)">火
	<input type="radio" name="rb_sd" value="3" onChange="changeStartDay(3)">水
	<input type="radio" name="rb_sd" value="4" onChange="changeStartDay(4)">木
	<input type="radio" name="rb_sd" value="5" onChange="changeStartDay(5)">金
	<input type="radio" name="rb_sd" value="6" onChange="changeStartDay(6)">土
	<br>
	<br>
	日付を枠線で<br>
	<input type="radio" name="rb_db" value="1" onChange="changeDrawBorder(true)" checked>区切る
	<input type="radio" name="rb_db" value="0" onChange="changeDrawBorder(false)">区切らない

	<script type="text/javascript">
		function changeStartDay(start_day){
			cal1.start_day = start_day;
		}
		function changeDrawBorder(draw_border){
			cal1.draw_border = draw_border;
		}
	</script>

    </body>
  </html>

 **********************************************************/

// 親クラス

if ( typeof(JKL) == 'undefined' ) JKL = function() {};

// JKL.Calendar コンストラクタの定義

JKL.Calendar = function ( eid, fid, valname ) {
    this.eid = eid;
    this.formid = fid;
    this.valname = valname;
    this.__dispelem = null;  // カレンダー表示欄エレメント
    this.__textelem = null;  // テキスト入力欄エレメント
    this.__opaciobj = null;  // JKL.Opacity オブジェクト
    this.style = new JKL.Calendar.Style();
    return this;
};

// バージョン番号

JKL.Calendar.VERSION = "0.13";

// デフォルトのプロパティ

JKL.Calendar.prototype.spliter = "/";
JKL.Calendar.prototype.date = null;
JKL.Calendar.prototype.min_date = null;
JKL.Calendar.prototype.max_date = null;

// 2006.11.15 MOM 表示開始曜日をプロパティに追加(デフォルトは日曜日=0)
JKL.Calendar.prototype.start_day = 0;

// 2006.11.23 MOM カレンダー内の日付を枠線で区切るかどうかのプロパティ(デフォルトはtrue)
JKL.Calendar.prototype.draw_border = true;

// JKL.Calendar.Style

JKL.Calendar.Style = function() {
    return this;
};

// デフォルトのスタイル

JKL.Calendar.Style.prototype.frame_width        = "150px";      // フレーム横幅
JKL.Calendar.Style.prototype.frame_color        = "#006000";    // フレーム枠の色
JKL.Calendar.Style.prototype.font_size          = "12px";       // 文字サイズ
JKL.Calendar.Style.prototype.day_bgcolor        = "#F0F0F0";    // カレンダーの背景色
JKL.Calendar.Style.prototype.month_color        = "#FFFFFF";    // ○年○月部分の背景色
JKL.Calendar.Style.prototype.month_hover_color  = "#009900";    // マウスオーバー時の≪≫文字色
JKL.Calendar.Style.prototype.month_hover_bgcolor= "#FFFFCC";   // マウスオーバー時の≪≫背景色
JKL.Calendar.Style.prototype.weekday_color      = "#404040";    // 月曜～金曜日セルの文字色
JKL.Calendar.Style.prototype.saturday_color     = "#0040D0";    // 土曜日セルの文字色
JKL.Calendar.Style.prototype.sunday_color       = "#D00000";    // 日曜日セルの文字色
JKL.Calendar.Style.prototype.others_color       = "#999999";    // 他の月の日セルの文字色
JKL.Calendar.Style.prototype.day_hover_bgcolor  = "#FF9933";    // マウスオーバー時の日セルの背景
JKL.Calendar.Style.prototype.cursor             = "pointer";    // マウスオーバー時のカーソル形状

// 2006.11.23 MOM 今日日付の文字色をプロパティに追加
JKL.Calendar.Style.prototype.today_color        = "#00A000";    // 今日日付セルの文字色
// 2006.11.23 MOM 枠線もつけてみる
JKL.Calendar.Style.prototype.today_border_color = "#00A000";    // 今日日付セルの枠線の色
JKL.Calendar.Style.prototype.others_border_color= "#D0D0D0";    // 他の日セルの枠線の色

//  メソッド

JKL.Calendar.Style.prototype.set = function(key,val) { this[key] = val; }
JKL.Calendar.Style.prototype.get = function(key) { return this[key]; }
JKL.Calendar.prototype.setStyle = function(key,val) { this.style.set(key,val); };
JKL.Calendar.prototype.getStyle = function(key) { return this.style.get(key); };

// 日付を初期化する

JKL.Calendar.prototype.initDate = function ( dd ) {
    if ( ! dd ) dd = new Date();
    var year = dd.getFullYear();
    var mon  = dd.getMonth();
    var date = dd.getDate();
    this.date = new Date( year, mon, date );
    this.getFormValue();
    return this.date;
}

// 透明度設定のオブジェクトを返す

JKL.Calendar.prototype.getOpacityObject = function () {
    if ( this.__opaciobj ) return this.__opaciobj;
    var cal = this.getCalendarElement();
    if ( ! JKL.Opacity ) return;
    this.__opaciobj = new JKL.Opacity( cal );
    return this.__opaciobj;
};

// カレンダー表示欄のエレメントを返す

JKL.Calendar.prototype.getCalendarElement = function () {
    if ( this.__dispelem ) return this.__dispelem;
    this.__dispelem = document.getElementById( this.eid )
    return this.__dispelem;
};

// テキスト入力欄のエレメントを返す

JKL.Calendar.prototype.getFormElement = function () {
    if ( this.__textelem ) return this.__textelem;
    var frmelms = document.getElementById( this.formid );
    if ( ! frmelms ) return;
    for( var i=0; i < frmelms.elements.length; i++ ) {
        if ( frmelms.elements[i].name == this.valname ) {
            this.__textelem = frmelms.elements[i];
        }
    }
    return this.__textelem;
};

// オブジェクトに日付を記憶する（YYYY/MM/DD形式で指定する）

JKL.Calendar.prototype.setDateYMD = function (ymd) {
    var splt = ymd.split( this.spliter );
    if ( splt[0]-0 > 0 &&
         splt[1]-0 >= 1 && splt[1]-0 <= 12 &&       // bug fix 2006/03/03 thanks to ucb
         splt[2]-0 >= 1 && splt[2]-0 <= 31 ) {
        if ( ! this.date ) this.initDate();
        this.date.setFullYear( splt[0] );
        this.date.setMonth( splt[1]-1 );
        this.date.setDate( splt[2] );
    } else {
        ymd = "";
    }
    return ymd;
};

// オブジェクトから日付を取り出す（YYYY/MM/DD形式で返る）
// 引数に Date オブジェクトの指定があれば、
// オブジェクトは無視して、引数の日付を使用する（単なるfprint機能）

JKL.Calendar.prototype.getDateYMD = function ( dd ) {
    if ( ! dd ) {
        if ( ! this.date ) this.initDate();
        dd = this.date;
    }
    var mm = "" + (dd.getMonth()+1);
    var aa = "" + dd.getDate();
    if ( mm.length == 1 ) mm = "" + "0" + mm;
    if ( aa.length == 1 ) aa = "" + "0" + aa;
    return dd.getFullYear() + this.spliter + mm + this.spliter + aa;
};

// テキスト入力欄の値を返す（ついでにオブジェクトも更新する）

JKL.Calendar.prototype.getFormValue = function () {
    var form1 = this.getFormElement();
    if ( ! form1 ) return "";
    var date1 = this.setDateYMD( form1.value );
    return date1;
};

// フォーム入力欄に指定した値を書き込む

JKL.Calendar.prototype.setFormValue = function (ymd) {
    if ( ! ymd ) ymd = this.getDateYMD();   // 無指定時はオブジェクトから？
    var form1 = this.getFormElement();
    if ( form1 ) form1.value = ymd;
};

//  カレンダー表示欄を表示する

JKL.Calendar.prototype.show = function () {
    this.getCalendarElement().style.display = "";
};

//  カレンダー表示欄を即座に隠す

JKL.Calendar.prototype.hide = function () {
    this.getCalendarElement().style.display = "none";
};

//  カレンダー表示欄をフェードアウトする

JKL.Calendar.prototype.fadeOut = function (s) {
    if ( JKL.Opacity ) {
        this.getOpacityObject().fadeOut(s);
    } else {
        this.hide();
    }
};

// 月単位で移動する

JKL.Calendar.prototype.moveMonth = function ( mon ) {
    // 前へ移動
    if ( ! this.date ) this.initDate();
    for( ; mon<0; mon++ ) {
        this.date.setDate(1);   // 毎月1日の1日前は必ず前の月
        this.date.setTime( this.date.getTime() - (24*3600*1000) );
    }
    // 後へ移動
    for( ; mon>0; mon-- ) {
        this.date.setDate(1);   // 毎月1日の32日後は必ず次の月
        this.date.setTime( this.date.getTime() + (24*3600*1000)*32 );
    }
    this.date.setDate(1);       // 当月の1日に戻す
    this.write();    // 描画する
};

// イベントを登録する

JKL.Calendar.prototype.addEvent = function ( elem, ev, func ) {
//  prototype.js があれば利用する(IEメモリリーク回避)
    if ( window.Event && Event.observe ) {
        Event.observe( elem, ev, func, false );
    } else {
        elem["on"+ev] = func;
    }
}

// カレンダーを描画する

JKL.Calendar.prototype.write = function () {
    var date = new Date();
    if ( ! this.date ) this.initDate();
    date.setTime( this.date.getTime() );

    var year = date.getFullYear();          // 指定年
    var mon  = date.getMonth();             // 指定月
    var today = date.getDate();             // 指定日
    var form1 = this.getFormElement();

    // 選択可能な日付範囲
    var min;
    if ( this.min_date ) {
        var tmp = new Date( this.min_date.getFullYear(), 
            this.min_date.getMonth(), this.min_date.getDate() );
        min = tmp.getTime();
    }
    var max;
    if ( this.max_date ) {
        var tmp = new Date( this.max_date.getFullYear(), 
            this.max_date.getMonth(), this.max_date.getDate() );
        max = tmp.getTime();
    }

    // 直前の月曜日まで戻す
    date.setDate(1);                        // 1日に戻す
    var wday = date.getDay();               // 曜日 日曜(0)～土曜(6)

// 2006.11.15 MOM 表示開始曜日を可変にしたので、ロジックちょっといじりますよ
    if ( wday != this.start_day ) {
        date.setTime( date.getTime() - (24*3600*1000)*((wday-this.start_day+7)%7) );
    }
/*
    if ( wday != 1 ) {
        if ( wday == 0 ) wday = 7;
        date.setTime( date.getTime() - (24*3600*1000)*(wday-1) );
    }
*/

    // 最大で7日×6週間＝42日分のループ
    var list = new Array();
    for( var i=0; i<42; i++ ) {
        var tmp = new Date();
        tmp.setTime( date.getTime() + (24*3600*1000)*i );
        if ( i && i%7==0 && tmp.getMonth() != mon ) break;
        list[list.length] = tmp;
    }

    // スタイルシートを生成する
    var month_table_style = 'width: 100%; ';
    month_table_style += 'background: '+this.style.frame_color+'; ';
    month_table_style += 'border: 1px solid '+this.style.frame_color+';';

    var week_table_style = 'width: 100%; ';
    week_table_style += 'background: '+this.style.day_bgcolor+'; ';
    week_table_style += 'border-left: 1px solid '+this.style.frame_color+'; ';
    week_table_style += 'border-right: 1px solid '+this.style.frame_color+'; ';

    var days_table_style = 'width: 100%; ';
    days_table_style += 'background: '+this.style.day_bgcolor+'; ';
    days_table_style += 'border: 1px solid '+this.style.frame_color+'; ';

    var month_td_style = "";
    month_td_style += 'font-size: '+this.style.font_size+'; ';
    month_td_style += 'color: '+this.style.month_color+'; ';
    month_td_style += 'padding: 4px 0px 2px 0px; ';
    month_td_style += 'text-align: center; ';
    month_td_style += 'font-weight: bold;';

    var week_td_style = "";
    week_td_style += 'font-size: '+this.style.font_size+'; ';
    week_td_style += 'padding: 2px 0px 2px 0px; ';
    week_td_style += 'font-weight: bold;';
    week_td_style += 'text-align: center;';

    var days_td_style = "";
    days_td_style += 'font-size: '+this.style.font_size+'; ';
    days_td_style += 'padding: 1px; ';
    days_td_style += 'text-align: center; ';
    days_td_style += 'font-weight: bold;';

    var days_unselectable = "font-weight: normal;";

    // HTMLソースを生成する
    var src1 = "";

    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+month_table_style+'"><tr>';
    src1 += '<td id="__'+this.eid+'_btn_prev" title="Pre" style="'+month_td_style+'">≪</td>';
    src1 += '<td style="'+month_td_style+'">&nbsp;</td>';
    src1 += '<td style="'+month_td_style+'">'+(year)+' / '+(mon+1)+'</td>';
    src1 += '<td id="__'+this.eid+'_btn_close" title="Close" style="'+month_td_style+'">X</td>';
    src1 += '<td id="__'+this.eid+'_btn_next" title="Next" style="'+month_td_style+'">≫</td>';
    src1 += "</tr></table>\n";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+week_table_style+'"><tr>';

// 2006.11.15 MOM 表示開始曜日start_dayから順に一週間分表示する
	for(var i = this.start_day; i < this.start_day + 7; i++){
		var _wday = i%7;
		if(_wday == 0){
			 src1 += '<td style="color: '+this.style.sunday_color+'; '+week_td_style+'">Sun</td>';
		}else if(_wday == 6){
			 src1 += '<td style="color: '+this.style.saturday_color+'; '+week_td_style+'">Sat</td>';
		}else{
			 src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">';
			if(_wday == 1)		src1 += 'Mon</td>';
			else if(_wday == 2)	src1 += 'Tue</td>';
			else if(_wday == 3)	src1 += 'Wed</td>';
			else if(_wday == 4)	src1 += 'Thu</td>';
			else if(_wday == 5)	src1 += 'Fri</td>';
		}
	}
/*
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">月</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">火</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">水</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">木</td>';
    src1 += '<td style="color: '+this.style.weekday_color+'; '+week_td_style+'">金</td>';
    src1 += '<td style="color: '+this.style.saturday_color+'; '+week_td_style+'">土</td>';
    src1 += '<td style="color: '+this.style.sunday_color+'; '+week_td_style+'">日</td>';
*/

    src1 += "</tr></table>\n";
    src1 += '<table border="0" cellpadding="0" cellspacing="0" style="'+days_table_style+'">';

    var curutc;
    if ( form1 && form1.value ) {
        var splt = form1.value.split(this.spliter);
        if ( splt[0] > 0 && splt[2] > 0 ) {
            var curdd = new Date( splt[0]-0, splt[1]-1, splt[2]-0 );
            curutc = curdd.getTime();                           // フォーム上の当日
        }
    }

//2006.11.23 MOM 今日日付を取得し、時分秒を切り捨てる
	var realdd = new Date();
	var realutc = (new Date(realdd.getFullYear(),realdd.getMonth(),realdd.getDate())).getTime();

    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        var ww = dd.getDay();
        var mm = dd.getMonth();

        if ( ww == this.start_day ) {
            src1 += "<tr>";                                     // 表示開始曜日の前に行頭
        }
/*
        if ( ww == 1 ) {
            src1 += "<tr>";                                     // 月曜日の前に行頭
        }
*/

        var cc = days_td_style;
        var utc = dd.getTime();

        if ( mon == mm ) {

//2006.11.23 MOM 最初に今日日付かどうかをチェックする
//※当月でない場合にも色変えると選択できそうに見えて紛らわしいので、当月かつ今日日付の場合のみ色を変える
			if ( utc == realutc ){
				cc += "color: "+this.style.today_color+";";     // 今日日付
			} else

			if ( ww == 0 ) {
                cc += "color: "+this.style.sunday_color+";";    // 当月の日曜日
            } else if ( ww == 6 ) {
                cc += "color: "+this.style.saturday_color+";";  // 当月の土曜日
            } else {
                cc += "color: "+this.style.weekday_color+";";   // 当月の平日
            }
        } else {
            cc += "color: "+this.style.others_color+";";        // 前月末と翌月初の日付
        }

//2006.11.23 MOM utcの変数宣言を↑に移動
//      var utc = dd.getTime();
        if (( min && min > utc ) || ( max && max < utc )) {
            cc += days_unselectable;
        }
        if ( utc == curutc ) {                                  // フォーム上の当日
            cc += "background: "+this.style.day_hover_bgcolor+";";
        }

//2006.11.23 MOM 枠線描画を追加
		if ( this.draw_border ){
			if ( mon == mm && utc == realutc ){
				cc += "border:solid 1px "+this.style.today_border_color+";";	// 当月かつ今日日付
			} else {
				cc += "border:solid 1px "+this.style.others_border_color+";";	// その他
			}
		}

        var ss = this.getDateYMD(dd);
        var tt = dd.getDate();

        src1 += '<td style="'+cc+'" title='+ss+' id="__'+this.eid+'_td_'+ss+'">'+tt+'</td>';

        if ( ww == (this.start_day+6)%7 ) {
            src1 += "</tr>\n";                                  // 表示開始曜日の１つ手前で行末
        }
/*
        if ( ww == 7 ) {
            src1 += "</tr>\n";                                  // 土曜日の後に行末
        }
*/
    }
    src1 += "</table>\n";

    // カレンダーを書き換える
    var cal1 = this.getCalendarElement();
    if ( ! cal1 ) return;
    cal1.style.width = this.style.frame_width;
    cal1.style.position = "absolute";
    cal1.innerHTML = src1;

    // イベントを登録する
    var __this = this;
    var get_src = function (ev) {
        ev  = ev || window.event;
        var src = ev.target || ev.srcElement;
        return src;
    };
    var month_onmouseover = function (ev) {
        var src = get_src(ev);
        src.style.color = __this.style.month_hover_color;
        src.style.background = __this.style.month_hover_bgcolor;
    };
    var month_onmouseout = function (ev) {
        var src = get_src(ev);
        src.style.color = __this.style.month_color;
        src.style.background = __this.style.frame_color;
    };
    var day_onmouseover = function (ev) {
        var src = get_src(ev);
        src.style.background = __this.style.day_hover_bgcolor;
    };
    var day_onmouseout = function (ev) {
        var src = get_src(ev);
        src.style.background = __this.style.day_bgcolor;
    };
    var day_onclick = function (ev) {
        var src = get_src(ev);
        var srcday = src.id.substr(src.id.length-10);
        __this.setFormValue( srcday );
        __this.fadeOut( 1.0 );
    };

    // 前の月へボタン
    var tdprev = document.getElementById( "__"+this.eid+"_btn_prev" );
    tdprev.style.cursor = this.style.cursor;
    this.addEvent( tdprev, "mouseover", month_onmouseover );
    this.addEvent( tdprev, "mouseout", month_onmouseout );
    this.addEvent( tdprev, "click", function(){ __this.moveMonth( -1 ); });

    // 閉じるボタン
    var tdclose = document.getElementById( "__"+this.eid+"_btn_close" );
    tdclose.style.cursor = this.style.cursor;
    this.addEvent( tdclose, "mouseover", month_onmouseover );
    this.addEvent( tdclose, "mouseout", month_onmouseout );
    this.addEvent( tdclose, "click", function(){ __this.hide(); });

    // 次の月へボタン
    var tdnext = document.getElementById( "__"+this.eid+"_btn_next" );
    tdnext.style.cursor = this.style.cursor;
    this.addEvent( tdnext, "mouseover", month_onmouseover );
    this.addEvent( tdnext, "mouseout", month_onmouseout );
    this.addEvent( tdnext, "click", function(){ __this.moveMonth( +1 ); });

    // セルごとのイベントを登録する
    for ( var i=0; i<list.length; i++ ) {
        var dd = list[i];
        if ( mon != dd.getMonth() ) continue;       // 今月のセルにのみ設定する

        var utc = dd.getTime();
        if ( min && min > utc ) continue;           // 昔過ぎる
        if ( max && max < utc ) continue;           // 未来過ぎる
        if ( utc == curutc ) continue;              // フォーム上の当日

        var ss = this.getDateYMD(dd);
        var cc = document.getElementById( "__"+this.eid+"_td_"+ss );
        if ( ! cc ) continue;

        cc.style.cursor = this.style.cursor;
        this.addEvent( cc, "mouseover", day_onmouseover );
        this.addEvent( cc, "mouseout", day_onmouseout );
        this.addEvent( cc, "click", day_onclick );
    }

    // 表示する
    this.show();
};

// 旧バージョン互換（typo）
JKL.Calendar.prototype.getCalenderElement = JKL.Calendar.prototype.getCalendarElement;
JKL.Calender = JKL.Calendar;
