import "@hotwired/turbo-rails";
import "filter";
import "question_status_toggle";

// カレンダー初期化関数
window.initCalendar = function() {
    const el = document.getElementById("calendar");
    
    if (!el) {
        return;
    }
    
    if (typeof FullCalendar === "undefined") {
        return;}

    // 既存のカレンダーインスタンスがあれば破棄
    if (window.calendarInstance) {
        window.calendarInstance.destroy();
        window.calendarInstance = null;
    }

    try {
        // 新しいカレンダーを作成
        window.calendarInstance = new FullCalendar.Calendar(el, {
            initialView: "dayGridMonth",
            locale: "ja",
            dateClick: function(info) {
                const clickDate = info.dateStr;
                
                // 新しい訪問作成ページに遷移
                window.location.href = `/visits/new?date=${clickDate}`;
                
                // Fetch APIでAjaxリクエストを送る
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
        
    } catch (error) {
        console.error("カレンダー初期化エラー:", error);
    }
};

// サイドバーの開閉 トグルボタン（#menuToggle）とサイドバー領域（#sidebarMenu）を明示的に監視
window.initSidebar = () => {
    const banner = document.querySelector('.login-user-banner');

    // ここを関数の中に移す
    banner?.addEventListener('click', e => {
        const menuToggle = document.getElementById('menuToggle');
        if (!menuToggle) {
            return;
        }

        const target = e.target.closest('#menuToggle');
        if (!target) return;

        e.preventDefault();
        document.body.classList.toggle('open');
    });

    document.addEventListener('click', e => {
        const sidebar = document.getElementById('sidebarMenu');
        const menuToggle = document.getElementById('menuToggle');
        if (!sidebar || !menuToggle) return;

        const isOpen = document.body.classList.contains('open');
        const isOutside = !sidebar.contains(e.target) && !menuToggle.contains(e.target);
        if (isOpen && isOutside) {
            document.body.classList.remove('open');
        }
    });
};

// チェック復元
window.restoreSelections = () => {
    setTimeout(() => {
        window.selectedQuestionIds.forEach(id => {
            const cb = document.querySelector(`input[name="visit[question_ids][]"][value="${id}"]`);
            if (cb) {
                cb.checked = true;
                window.updateDisplay(cb);
            }
        });
        window.updateCounter();
        window.updateButton();
    }, 100);
};

// 質問選択のイベント初期化
window.initQuestionSelection = () => {
    window.updateCounter();
    window.updateButton();

    document.addEventListener('change', e => {
        if (e.target.matches('input[name="visit[question_ids][]"]')) {
            window.updateCounter();
            window.updateButton();
            window.updateDisplay(e.target);
        }
    });

    document.addEventListener('click', e => {
        const li = e.target.closest('li');
        if (li && !e.target.matches('input[type="checkbox"]')) {
            const cb = li.querySelector('input[type="checkbox"]');
            if (cb) {
                cb.checked = !cb.checked;
                cb.dispatchEvent(new Event('change', { bubbles: true }));
            }
        }
    });

    document.getElementById('questionForm')?.addEventListener('submit', e => {
        const checked = document.querySelectorAll('input[name="visit[question_ids][]"]:checked');
        if (checked.length === 0) {
            e.preventDefault();
            alert("質問を一つ以上選択してください");
        }
    });
};

// 表示更新
window.updateCounter = () => {
    const count = document.querySelectorAll('input[name="visit[question_ids][]"]:checked').length;
    const counter = document.getElementById('selectedCounter');
    const span = document.getElementById('selectedCount');
    if (counter && span) {
        span.textContent = count;
        counter.style.display = count > 0 ? 'block' : 'none';
    }
};

window.updateButton = () => {
    const count = document.querySelectorAll('input[name="visit[question_ids][]"]:checked').length;
    const btn = document.querySelector('#show-question-btn');
    if (btn) {
        btn.disabled = count === 0;
        btn.innerHTML = count === 0
            ? '<i class="bi bi-list-check"></i> 質問を選択してください'
            : `<i class="bi bi-list-check"></i> 選んだ質問のリストをみる (${count}件)`;
    }
};

window.updateDisplay = (cb) => {
    cb.closest('li')?.classList.toggle('selected', cb.checked);
};

// Turbo遷移前のクリーンアップ
document.addEventListener("turbo:before-render", () => {
    // カレンダーインスタンスを破棄
    if (window.calendarInstance) {
        window.calendarInstance.destroy();
        window.calendarInstance = null;
    }
    
    // サイドバーの状態をリセット
    document.body.classList.remove('open');
});

// Turbo読み込み後の初期化
document.addEventListener("turbo:load", () => {
    window.selectedQuestionIds = [];
    
    setTimeout(() => {
        requestAnimationFrame(() => {
            window.initSidebar();
            
            // initFilterUIが存在するかチェックしてから実行
            if (typeof window.initFilterUI === 'function') {
                window.initFilterUI();
            } else {
                console.warn('initFilterUI関数が見つかりません');
            }
            
            window.initQuestionSelection();
            window.restoreSelections();
            
            // カレンダー初期化
            window.initCalendar();
        });
    }, 0);
});
