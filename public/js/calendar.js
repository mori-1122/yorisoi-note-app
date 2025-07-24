// カレンダー初期化関数をwindowにエクスポート
window.initCalendar = function() {
    const el = document.getElementById("calendar");
    
    // 要素が見つからない、またはFullCalendarが読み込まれていない場合
    if (!el || typeof FullCalendar === "undefined") {
        return;
    }

    // 既存のカレンダーインスタンスがあれば破棄
    if (window.calendarInstance) {
        window.calendarInstance.destroy();
        window.calendarInstance = null;
    }

    // 新しいカレンダーを作成
    window.calendarInstance = new FullCalendar.Calendar(el, {
        initialView: "dayGridMonth", // 月表示
        locale: "ja", // 日本語
        dateClick: function(info) {
            const clickDate = info.dateStr; // 文字列が入り

        }
    });

    window.calendarInstance.render();
};

// Turbo対応: turbo:load イベントでカレンダーを初期化
document.addEventListener("turbo:load", function() {
    window.initCalendar();
});

// DOMContentLoaded イベントでも初期化（Turboを使わない場合のため）
document.addEventListener("DOMContentLoaded", function() {
    window.initCalendar();
});
