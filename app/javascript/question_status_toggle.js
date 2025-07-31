document.addEventListener('turbo:load', () => { //ページがTurboによって読み込まれたタイミングで、以下の処理を実行
  document.addEventListener("ajax:success", function (event) { // Ajaxリクエストが成功した時のイベントを受け取る
    const [data, _status, xhr] = event.detail; // Ajaxのレスポンス（data）を受け取る（Rails側から返されたJSONなど）

    // selectionIDを取得 イベント発生元（ボタンなど）の親にある .question-item要素を探す。なければ何もしない。
    const target = event.target.closest(".question-item");
    if (!target) return;

    const asked = data.asked; // サーバーから返されたデータオブジェクト（data）の中の askedプロパティを取り出し、変数asked に代入する。
    const btn = target.querySelector(".toggle-btn"); // イベント発生元から見て一番近い .question-item要素（＝target）の中にある .toggle-btnクラスの要素（ボタン）を探して btn に格納
    const questionText = target.querySelector(".question-text"); // targetの中にある .question-textクラスの要素（質問テキスト表示部）を探してquestionTextに格納

    if (!btn || !questionText) return; // もしボタンまたはテキスト要素が見つからなかった場合は、それ以上の処理をせず中断

    // ボタンを押した時の見た目を変える
    if (asked) { // もしaskedがtrue（＝質問済みの状態）であれば
      btn.classList.remove("pending"); // ボタンから"pending"クラスを削除する。
      btn.classList.add("asked"); // ボタンに"asked"クラスを追加する。
      btn.innerHTML = '未質問に戻す <i class="bi bi-check-circle-fill me-1"></i>'; // ボタンの中身（HTML）を書き換える。チェックマークアイコン（bi-check-circle-fill）を右に表示
      questionText.classList.add("asked");  // SCSSにより「斜線＋グレー文字」などのスタイルが適用
    } else { // askedがfalse（＝未質問の状態）であれば
      btn.classList.remove("btn-success", "asked"); // ボタンに "btn-warning"と "pending"（未質問状態の独自クラス）を追加
      btn.classList.add("btn-warning", "pending");
      btn.innerHTML = '質問済みにする <i class="bi bi-hand-thumbs-up me-1"></i>';
      questionText.classList.remove("asked");
    }
  });

  document.addEventListener("ajax:error", function (event) {
    alert("状態の更新に失敗しました。");
  });

  // フラッシュメッセージ
  function showFlashMessage(message, type) { // messageとtypeは外部から渡される動的データ。typeに応じてメッセージの見た目を変える実装
    const flashElement = document.createElement('div'); // DOMに新しい <div> 要素を動的に作成。これがフラッシュメッセージになる。document.createElementはDOM標準 API

    // 既存のflash-messageクラスを使用。type に応じて、見た目（背景色など）を切り替えるクラスを追加する。
    let flashClass = 'flash-message';
    switch(type) {
      case 'success': // success: 青系の成功メッセージ
        flashClass += ' flash-success';
        break;
      case 'error': // error:赤系のエラー
        flashClass += ' flash-alert';
        break;
      case 'notice': // notice:通知系のピンク
        flashClass += ' flash-notice';
        break;
      default:
        flashClass += ' flash-notice'; //それ以外→ flash-notice
    }

    // 作成したdivにクラスとメッセージ文字列を設定。
    flashElement.className = flashClass;
    flashElement.textContent = message;

    document.body.appendChild(flashElement); // ページの <body> 要素の最後に、作ったflashElementを追加

    setTimeout(() => { // 8秒後にflashElementをDOMから削除
      if (flashElement.parentNode) {
        flashElement.remove();
      }
    }, 8000); 
  }
});
