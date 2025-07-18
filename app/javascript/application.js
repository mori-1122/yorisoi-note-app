window.onload = function () {
window.onload = () => { //DOMが完全に読み込まれてから安全に初期化
  window.selectedQuestionIds = [];
  window.searchInProgress = false;

  initSidebar();
  initFilterUI();
  initQuestionSelection();
};

      const isHidden =
        filterCollapse.style.display === "none" || filterCollapse.style.display === "";
      filterCollapse.style.display = isHidden ? "block" : "none";

      const icon = filterToggle.querySelector("i");
      if (icon) {
        icon.className = isHidden
          ? "bi bi-chevron-double-up"
          : "bi bi-chevron-double-down";

// フィルターUI初期化（開閉・変更イベント）
function initFilterUI() {
  const filterForm = document.getElementById('filter-form');
  if (!filterForm) return;

  const dept = document.getElementById('departmentFilter');
  const cat = document.getElementById('categoryFilter');
  const keyword = document.getElementById('keywordInput');
  const toggle = document.getElementById('filterToggle');
  const collapse = document.getElementById('filterCollapse');

  // visit_id 保存
  window.currentVisitId = document.querySelector('input[name="visit_id"]')?.value;

  // 開閉トグル
  toggle?.addEventListener('click', e => {
    e.preventDefault();
    const hidden = !collapse || collapse.style.display === 'none';
    collapse.style.display = hidden ? 'block' : 'none';
    toggle.querySelector('i').className = hidden ? 'bi bi-chevron-double-up' : 'bi bi-chevron-double-down';
  });

  dept?.addEventListener('change', () => {
    updateCategories(dept.value);
    setTimeout(submitSearch, 300);
  });

  cat?.addEventListener('change', submitSearch);

  keyword?.addEventListener('input', debounce(submitSearch, 800));

  filterForm.addEventListener('submit', e => {
    e.preventDefault();
    submitSearch();
  });
}
// カテゴリ更新
function updateCategories(departmentId) {
  const cat = document.getElementById('categoryFilter');
  if (!cat) return;

// Ajaxでカテゴリを取得するためのfetch実装
  fetch(`/questions/search?department_id=${departmentId}&action_type=categories&format=json`, {
    headers: defaultHeaders()
  })
    .then(res => res.ok ? res.json() : Promise.reject(res.statusText))
    .then(categories => {
      cat.innerHTML = '<option value="">全て</option>';
      categories.forEach(c => {
        cat.insertAdjacentHTML('beforeend', `<option value="${c.id}">${c.name}</option>`);
      });
    })
    .catch(err => console.error('カテゴリ取得失敗:', err));
}
// Ajax検索
function submitSearch() {
  if (window.searchInProgress) return;
  window.searchInProgress = true;

  const form = document.getElementById('filter-form');
  if (!form) return;

  const formData = new FormData(form);
  formData.set('visit_id', window.currentVisitId);

  window.selectedQuestionIds = Array.from(
    document.querySelectorAll('input[name="visit[question_ids][]"]:checked')
  ).map(cb => cb.value);

  fetch(`${form.action}.js?${new URLSearchParams(formData)}`, {
    headers: defaultHeaders('js')
  })
    .then(res => res.text())
    .then(code => {
      eval(code);
      restoreSelections();
    })
    .catch(err => console.error('検索失敗:', err))
    .finally(() => { window.searchInProgress = false; });
}
      }
    };
  }

  // サイドメニュー開閉処理
  const menuToggle = document.getElementById("menuToggle");
  const sidebar = document.getElementById("sidebarMenu");

  if (menuToggle && sidebar) {
    menuToggle.addEventListener("click", function (e) {
      e.preventDefault();
      document.body.classList.toggle("open");
      console.log("動いた");
    });
  }
};
