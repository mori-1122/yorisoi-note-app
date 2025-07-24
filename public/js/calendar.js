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

            // 新しい訪問作成ページに遷移
            window.location.href = `/visits/new?date=${clickDate}`;

            // Fetch APIでAjaxリクエストを送る（jQuery $.ajax の代替）
            fetch("/visits/by_date?" + new URLSearchParams({ date: clickDate }), {
                method: "GET",
                headers: {
                    "Accept": "text/html",
                    "X-Requested-With": "XMLHttpRequest"
                }
            })
            .then(response => {
                if (response.ok) {
                    return response.text();
                } else {
                    throw new Error("予定の取得に失敗しました");
                }
            })
            .then(data => {
                // #schedule-list要素の中身を書き換える（取得した予定のHTMLで）
                const scheduleList = document.getElementById("schedule-list");
                if (scheduleList) {
                    scheduleList.innerHTML = data;
                }
            })
            .catch(error => {
                console.error("Ajax error:", error);
                const scheduleList = document.getElementById("schedule-list");
                if (scheduleList) {
                    scheduleList.innerHTML = "<p class='flash-error text-center'>予定の取得ができません。</p>";
                }
            });
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
