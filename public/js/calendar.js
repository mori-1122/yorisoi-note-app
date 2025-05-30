document.addEventListener("DOMContentLoaded", function () { //HTMLの読み込み後、関数を実行
    const el = document.getElementById("calendar"); //idのcalendar要素をelに代入
    if ( !el || typeof FullCalendar === "undefined") { //elがない時、フルカレンダーがない時
        return; //処理を中断
    }

    const calendar = new FullCalendar.Calendar(el, {
        initialView: "dayGridMonth", //月表示
        locale: "ja" //日本語
    });
    calendar.render(); //描画
})

