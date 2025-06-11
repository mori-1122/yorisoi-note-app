$(function () { //ページの読み込みが完了したとき中の処理を実行する
    const el = document.getElementById("calendar"); //elが見つからなかった、fullcalendarが読み込まれない場合
    if (!el || typeof FullCalendar === "undefined") {
        return; //処理終了
    }

    const calendar = new FullCalendar.Calendar(el, { //新しいカレンダーを作成
        initialView: "dayGridMonth", //月表示
        locale: "ja", //日本語
        dateClick: function(info) { //日付をクリックしたときに呼ばれる関数
          const clickDate = info.dateStr //文字列が入り
          window.location.href = `/visits/new?date=${clickDate}`;
          console.log("クリックされた日付:", clickDate); //出力

    $.ajax({ //clickDateをパラメータとして/visits/by_dateにGETリクエストを送る
        url: "/visits/by_date", //railsのコントローラーに送る
        type: "GET", //getリクエスト
        data: { date: clickDate },
        dataType: "html",
        success: function (data) {
          $("#schedule-list").html(data); //サーバーからのレスポンスが成功したら#schedule-list要素の中身を書き換える（取得した予定のHTMLで）
        },
        error: function () {
          $("#schedule-list").html("<p class='flash-error text-center'>予定の取得ができません。</p>");
        }
      });
    }
  });
  calendar.render();
});
