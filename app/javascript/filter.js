window.initFilterUI = function() { //他スクリプトからも呼べるようにする 質問選択画面のフィルターUIを初期化する
  const filterForm = document.getElementById('filter-form'); // document.getElementById()は該当IDが存在しない場合nullを返すため、それを回避
  if (!filterForm) {
    return;
  }

  // それぞれのフィルター項目（診療科・カテゴリ・キーワード）やUI制御要素（開閉トグル）を取得
  const dept = document.getElementById('departmentFilter');
  const cat = document.getElementById('categoryFilter');
  const keyword = document.getElementById('keywordInput');
  const toggle = document.getElementById('filterToggle');
  const collapse = document.getElementById('filterCollapse');

  // 質問検索時に visit_idを含める submitSearchで使われる。?.valueによって該当要素がなければ undefined になるので、nullエラーを防止している。
  window.currentVisitId = document.querySelector('input[name="visit_id"]')?.value;

  // フィルターボックスを開閉するトグル機能の実装
  toggle?.addEventListener('click', e => { //?. により toggle が存在しないページではエラーにならず無視
    e.preventDefault();
    const hidden = !collapse || collapse.style.display === 'none'; // 非表示状態かどうか
    collapse.style.display = hidden ? 'block' : 'none';
    toggle.querySelector('i').className = hidden ? 'bi bi-chevron-double-up' : 'bi bi-chevron-double-down'; //collapse -> フィルターボックス本体。hiddenという真偽値をもとに、displayを'block'か'none'に切り替え
  });

  dept?.addEventListener('change', () => { //診療科に応じてカテゴリを再取得（Ajax）。
    window.updateCategories(dept.value); // updateCategories()はdepartment_idに応じたカテゴリリストを取得・更新
    setTimeout(window.submitSearch, 300); // setTimeout によってカテゴリ描画完了を少し待ってから検索
  });

  cat?.addEventListener('change', window.submitSearch); // カテゴリ変更 → すぐ検索
  keyword?.addEventListener('input', window.debounce(window.submitSearch, 800)); // キーワード入力 → 入力が止まってから 800ms 後に検索（debounce）。debounce()により連続検索を防ぎ、入力完了するまで待つ。

  filterForm.addEventListener('submit', e => { // 通常のHTMLフォーム送信（ページリロード）を防ぎ、Ajaxで処理
    e.preventDefault();
    window.submitSearch();
  });
};

window.updateCategories = function(departmentId) {
  const cat = document.getElementById('categoryFilter'); // カテゴリのセレクトボックス取得。
  if (!cat) return;

  fetch(`/questions/search?department_id=${departmentId}&action_type=categories&format=json`, { ///questions/searchにdepartment_idをクエリとして渡す。action_type=categoriesは、カテゴリのみ返す。
    headers: window.defaultHeaders() //javaScriptのfetchリクエストに共通のヘッダーを渡す
  })
  .then(res => res.ok ? res.json() : Promise.reject(res.statusText)) // res.okがtrue（ステータス 200〜299の成功）なら → .json() を実行
  .then(categories => { // 前の.then()で JSON にパースされたデータ（= categories）がここに渡ってくる。
    cat.innerHTML = '<option value="">すべて</option>'; // セレクトボックス（例: <select id="categoryFilter">）の中身を一旦リセット。最初に「すべて」オプションを追加
    categories.forEach(c => { // カテゴリ一覧をループして、各 <option> 要素を追加
      cat.insertAdjacentHTML('beforeend', `<option value="${c.id}">${c.name}</option>`);
    });
  })
  .catch(error => console.error('カテゴリ取れません')); // .catch()は通信失敗・非200レスポンスなどに対応。
};

window.submitSearch = function() { // 質問リストのAjax検索
  if (window.searchInProgress) return; // 多重送信防止用のフラグ（送信中なら return）
  window.searchInProgress = true;

  const form = document.getElementById('filter-form'); // フォーム内のすべての入力値をAjaxで送信するために、FormDataオブジェクトに値を詰める。明示的にvisit_idを追加しているのは、フォーム内にvisit_idのinput要素がない場合に備えた保険
  if (!form) return;

  const formData = new FormData(form); // FormData は、<form> 要素からすべてのフォームフィールド（input, select, textarea など）を自動的に抽出して key-valueペアにまとめるJavaScriptのAPI
  formData.set('visit_id', window.currentVisitId); // input が無い、もしくは JavaScript の描画順の都合でまだDOMに存在していない時のためにJS側で visit_idを安全に取得
  // JS側で visit_id を安全に取得

  window.selectedQuestionIds = Array.from( // チェックされた質問IDを保持
    document.querySelectorAll('input[name="visit[question_ids][]"]:checked')
  ).map(cb => cb.value);

  fetch(`${form.action}.js?${new URLSearchParams(formData)}`, { // fetch()を使ってAjaxによる.jsリクエストを送信している。明示的に.jsを付けることで、Railsは /questions/search.jsに対してjsを返す。
    headers: window.defaultHeaders('js')
  })
    .then(res => res.text())
    .then(code => { // .then(code => eval(code))で受け取ったJSを即時実行
      eval(code);
      window.restoreSelections(); // restoreSelections()により質問の選択状態を復元。
    })
    .catch(err => console.error('検索失敗:', err))
    .finally(() => { window.searchInProgress = false; }); // .finally()で送信中フラグを解除。
};

// ヘッダー共通化
window.defaultHeaders = function(type = 'json') {
  return {
    'Accept': type === 'js' ? 'text/javascript' : 'application/json', // Accept:text/javascriptによって、Rails側に「JavaScriptが欲しい」と伝える
    'X-Requested-With': 'XMLHttpRequest', // Railsはrequest.xhr?でAjaxとして扱える
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content // X-CSRF-TokenはCSRF対策。Railsのprotect_from_forgeryに必要なトークン
  };
};

// debounce ヘルパー
window.debounce = function(fn, delay) {
  let timeout;
  return () => {
    clearTimeout(timeout);
    timeout = setTimeout(fn, delay);
  };
};
