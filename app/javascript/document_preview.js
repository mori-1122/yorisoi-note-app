document.addEventListener('DOMContentLoaded', () => {
  const fileInput = document.getElementById('document-icon');
  const uploadArea = document.getElementById('upload-area');
  const previewContainer = document.querySelector('.preview-container');
  const previewImage = document.getElementById('preview-image');
  const fileName = document.getElementById('file-name');
  const form = document.getElementById('document-form');

  if (!fileInput || !uploadArea) return; // 必要な要素が存在しない場合は処理を停止

//   クリックするとファイル選択できる
  uploadArea.addEventListener('click', () => fileInput.click());

// ドラッグ&ドロップ
  uploadArea.addEventListener('dragover', (e) => {
    e.preventDefault();
    uploadArea.classList.add('dragover');
  });

  uploadArea.addEventListener('dragleave', () => {
    uploadArea.classList.remove('dragover');
  });

  uploadArea.addEventListener('drop', (e) => {
    e.preventDefault();
    uploadArea.classList.remove('dragover');
    const file = e.dataTransfer.files[0];

  if (file) {
    fileInput.files = e.dataTransfer.files;
    showPreview(file);
  }
});

// ファイルを選んだ
fileInput.addEventListener('change', (e) => {
  const file = e.target.files[0];
  console.log("ファイル選択イベント発火:", file); // ← 追加
  if (file) {
    showPreview(file);
  } else {
    hidePreview();
  }
});

// プレビューを表示する
function showPreview(file) {
    console.log("showPreview呼び出し:", file); // ← 追加
  if (!file.type.startsWith('image/')) {
    alert('画像ファイルを選択してください。');
    return;
  }

  if (file.size > 10 * 1024 * 1024) {
    alert('ファイルのサイズが大きいです。');
    return;
  }

  const reader = new FileReader();
  reader.onload = (e) => {
    if (previewImage && previewContainer) {
      previewImage.src = e.target.result;
      if (fileName) fileName.textContent = file.name;
      previewContainer.style.display = 'block';
    }
  };
  reader.readAsDataURL(file);
}

// プレビューを非表示にする
function hidePreview() {
  if (previewContainer) {
    previewContainer.style.display = 'none';
  }
}

// フォーム送信バリデーション
  if (form) {
    form.addEventListener('submit', (e) => {
      if (!fileInput.files?.length) {
        e.preventDefault();
        alert('画像を選択してください。');
        return;
      }

      const docType = document.querySelector('select[name*="doc_type"]');
      if (docType && !docType.value) {
        e.preventDefault();
        alert('文書の種類を選択してください。');
        return;
      }

      // ダブルクリック防止
      const submitButton = form.querySelector('input[type="submit"]');
      if (submitButton) {
        submitButton.disabled = true;
        submitButton.value = 'アップロード中...';
      }
    });
  }
});
