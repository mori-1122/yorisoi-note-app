window.onload = () => { //DOMがすべて揃ったあとに初期化しないと、存在しない要素を参照してエラーになる危険がある
  window.selectedQuestionIds = [];//質問選択の状態と検索ロックを管理。状態の保持・制御に使う。
  window.searchInProgress = false; //他の関数（submitSearch, restoreSelections）で参照される。
  initSidebar();//3つの関数はページロード時に一度だけ呼び出される初期化関数。
  initFilterUI(); //UIの初期化
  initQuestionSelection(); //visit[question_ids][]による選択項目が使われているため。表示更新やsubmit時の検証で必要
};
// フィルターUI初期化（開閉・変更イベント）
function initFilterUI() {//絞り込みUIのイベントを定義・制御
  const filterForm = document.getElementById('filter-form');
  if (!filterForm) return; //filter-formがなければこのページでは使わないので、他ページのJS干渉を避けるために抜ける。

  const dept = document.getElementById('departmentFilter');//各イベント登録で使うため変数にキャッシュ
  const cat = document.getElementById('categoryFilter');
  const keyword = document.getElementById('keywordInput');
  const toggle = document.getElementById('filterToggle');
  const collapse = document.getElementById('filterCollapse');
 // visit_id 保存
  window.currentVisitId = document.querySelector('input[name="visit_id"]')?.value; //検索時にパラメータとして必要。hiddenフィールドに入ってるvisit_idを取得し、グローバルに保持。

  // 開閉トグル
  toggle?.addEventListener('click', e => { //HTML上に#filterToggle、#filterCollapseが存在。 ?.によって「もしtoggleが存在すれば」だけ処理する
    e.preventDefault();
    const hidden = !collapse || collapse.style.display === 'none';
    collapse.style.display = hidden ? 'block' : 'none'; //閉じていれば表示し、表示されていれば閉じる = トグル動作
    toggle.querySelector('i').className = hidden ? 'bi bi-chevron-double-up' : 'bi bi-chevron-double-down';
  });

  dept?.addEventListener('change', () => { //診療科ごとにカテゴリが変わる仕様（DB設計的に）
    updateCategories(dept.value); //updateCategories()はfetch()で非同期にカテゴリを更新
    setTimeout(submitSearch, 300); //updateCategories()が非同期fetchを使っているため、遅れて検索をかける。非同期処理の順番を調整してる。
  });

  cat?.addEventListener('change', submitSearch); //カテゴリ選択が変わったら即座に検索

  keyword?.addEventListener('input', debounce(submitSearch, 800));  //キーワードはdebounceによって、連続入力を抑制し最後の入力だけ反応するように制御。

  filterForm.addEventListener('submit', e => {
    e.preventDefault();
    submitSearch(); //通常のHTMLフォーム送信を止めて、Ajax経由で処理を行う。
  });
}
// カテゴリ更新
function updateCategories(departmentId) { //fetchURLにaction_type=categoriesを付けてルーティング分岐させている
  const cat = document.getElementById('categoryFilter');
  if (!cat) return;

// Ajaxでカテゴリを取得するためのfetch実装
  fetch(`/questions/search?department_id=${departmentId}&action_type=categories&format=json`, { // 「選択された診療科に対応するカテゴリ一覧を、JSON形式で取得する」リクエスト。${departmentId}：引数で受け取った診療科IDをURLに埋め込んでいる。
    headers: defaultHeaders() // リクエストにヘッダーを追加。
  })
    .then(res => res.ok ? res.json() : Promise.reject(res.statusText)) // res.ok、HTTPステータスコードが200〜299のときtrue成功判定。res.json()成功したらレスポンスをJSONとして解釈。
    .then(categories => {
      cat.innerHTML = '<option value="">全て</option>'; // categories上の.json()によってパースされたカテゴリ配列。
      categories.forEach(c => {
        cat.insertAdjacentHTML('beforeend', `<option value="${c.id}">${c.name}</option>`); // cat.insertAdjacentHTML(...)HTML文字列をセーフに挿入する。beforeend現在の要素の最後の子として追加。
      });
    })
    .catch(err => console.error('カテゴリ取得失敗:', err));
}

// Ajax検索
function submitSearch() {
  if (window.searchInProgress) return; // 連打防止のロック。二重送信を防ぐ。
  window.searchInProgress = true;

  const form = document.getElementById('filter-form'); 
  if (!form) return;

  const formData = new FormData(form); //FormDataはフォーム内の全入力項目を自動的に収集してくれる
  formData.set('visit_id', window.currentVisitId); //visit_id は手動で上書き追加。

  window.selectedQuestionIds = Array.from(//チェックされた質問のIDを収集。
    document.querySelectorAll('input[name="visit[question_ids][]"]:checked') //restoreSelections()のためにグローバル変数として保持
  ).map(cb => cb.value);

  fetch(`${form.action}.js?${new URLSearchParams(formData)}`, { // format.jsを指定したリクエストになる。Railsはこれでsearch.js.erb を返す。
    headers: defaultHeaders('js')
  })
    .then(res => res.text()) // 成功したときだけ、レスポンスを文字列として読み込む（HTMLやJSの本文）
    .then(code => { //.then(code =>eval(code))によって、controller側のsearch.js.erb が実行される。
      eval(code); //受け取ったJSコードを即座に実行
      restoreSelections(); // フィルタ後の状態を復元
    })
    .catch(err => console.error('検索失敗:', err)) // Rubyのrescueにあたる処理　(rescue => eみたいな)。
    .finally(() => { window.searchInProgress = false; }); // rubyのensureに当たる
}
// ヘッダー共通化
function defaultHeaders(type = 'json') { //Ajaxリクエストで使う共通ヘッダーを返す。fetch()のheaders:に渡す。引数typeに'json'または'js'を指定できる.

  return { // サーバーに「どの形式で返してほしいか」を伝える。
    'Accept': type === 'js' ? 'text/javascript' : 'application/json', // type === 'js' のとき → 'text/javascript'。 Rails側でformat.jsに反応（search.js.erb が返る）。それ以外 → 'application/json'
    'X-Requested-With': 'XMLHttpRequest', // 「これはAjaxリクエストですよ」とサーバーに伝えるヘッダー。
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content // CSRF対策用のトークン。Railsはこれが無いと POST/PUT/DELETEを拒否する。
  };
}

// debounce ヘルパー
function debounce(fn, delay) { // 入力イベントなどで、処理を連続で呼ばないように制御するユーティリティ関数。
  let timeout; // timeout は、遅延処理の予約ID（setTimeoutの返り値）を保持する変数。
  return () => { // 実際に返すのは「無名関数」。イベントにこの関数を使う。
    clearTimeout(timeout); // 前回のタイマーをキャンセル（連打されても一旦止める）
    timeout = setTimeout(fn, delay); // 新たに delay（ms）後に fn を実行する予約を入れる。
  };
}
