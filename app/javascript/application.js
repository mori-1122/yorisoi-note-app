import "filter";

// サイドバーの開閉 トグルボタン（#menuToggle）とサイドバー領域（#sidebarMenu）を明示的に監視
function initSidebar() {
  const menuToggle = document.getElementById('menuToggle');
  const sidebar = document.getElementById('sidebarMenu');

//クリックイベントに対してdocument.body.classList.toggle('open')で状態を切り替える
  menuToggle?.addEventListener('click', e => {
    e.preventDefault();
    document.body.classList.toggle('open');
  });

  document.addEventListener('click', e => { 
    if (document.body.classList.contains('open') &&
        !sidebar?.contains(e.target) &&
        !menuToggle.contains(e.target)) {
      document.body.classList.remove('open');
    }
  });
}
// チェック復元
function restoreSelections() {
  setTimeout(() => {
    window.selectedQuestionIds.forEach(id => {
      const cb = document.querySelector(`input[name="visit[question_ids][]"][value="${id}"]`);
      if (cb) {
        cb.checked = true;
        updateDisplay(cb);
      }
    });
    updateCounter();
    updateButton();
  }, 100);
}

// 質問選択のイベント初期化
function initQuestionSelection() {
  updateCounter();
  updateButton();

  document.addEventListener('change', e => {
    if (e.target.matches('input[name="visit[question_ids][]"]')) {
      updateCounter();
      updateButton();
      updateDisplay(e.target);
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
}

// 表示更新
function updateCounter() {
  const count = document.querySelectorAll('input[name="visit[question_ids][]"]:checked').length;
  const counter = document.getElementById('selectedCounter');
  const span = document.getElementById('selectedCount');
  if (counter && span) {
    span.textContent = count;
    counter.style.display = count > 0 ? 'block' : 'none';
  }
}

function updateButton() {
  const count = document.querySelectorAll('input[name="visit[question_ids][]"]:checked').length;
  const btn = document.querySelector('#show-question-btn');
  if (btn) {
    btn.disabled = count === 0;
    btn.innerHTML = count === 0
      ? '<i class="bi bi-list-check"></i> 質問を選択してください'
      : `<i class="bi bi-list-check"></i> 選んだ質問のリストをみる (${count}件)`;
  }
}

function updateDisplay(cb) {
  cb.closest('li')?.classList.toggle('selected', cb.checked);
}

document.addEventListener("DOMContentLoaded", () => {
  window.selectedQuestionIds = [];
  window.searchInProgress = false;

  initSidebar();
  restoreSelections();
  initQuestionSelection();
});
