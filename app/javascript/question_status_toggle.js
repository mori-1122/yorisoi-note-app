document.addEventListener('turbo:load', () => {
  document.addEventListener("ajax:success", function (event) {
    const [data, _status, xhr] = event.detail;

    // selectionIDを取得
    const target = event.target.closest(".question-item");
    if (!target) return;

    const asked = data.asked; // サーバーから返された新しい状態
    const btn = target.querySelector(".toggle-btn");
    const questionText = target.querySelector(".question-text");

    if (!btn || !questionText) return;

    // ボタンの見た目を変える
    if (asked) {
      btn.classList.remove("pending");
      btn.classList.add("asked");
      btn.innerHTML = '未質問に戻す <i class="bi bi-check-circle-fill me-1"></i>';
      questionText.classList.add("asked");
    } else {
      btn.classList.remove("btn-success", "asked");
      btn.classList.add("btn-warning", "pending");
      btn.innerHTML = '質問済みにする <i class="bi bi-clock-fill me-1"></i>';
      questionText.classList.remove("asked");
    }
  });

  document.addEventListener("ajax:error", function (event) {
    alert("状態の更新に失敗しました。");
  });

  // フラッシュメッセージ
  function showFlashMessage(message, type) {
    const flashElement = document.createElement('div');

    // 既存のflash-messageクラスを使用
    let flashClass = 'flash-message';
    switch(type) {
      case 'success':
        flashClass += ' flash-success';
        break;
      case 'error':
        flashClass += ' flash-alert';
        break;
      case 'notice':
        flashClass += ' flash-notice';
        break;
      default:
        flashClass += ' flash-notice';
    }

    flashElement.className = flashClass;
    flashElement.textContent = message;

    document.body.appendChild(flashElement);

    setTimeout(() => {
      if (flashElement.parentNode) {
        flashElement.remove();
      }
    }, 8000);
  }
});
