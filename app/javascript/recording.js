document.addEventListener('DOMContentLoaded', () => {
  // --- 録音関連の状態を保持する変数 ---
  let mediaRecorder; // MediaRecorderAPIのインスタンス
  let audioChunks = []; // 録音中に溜めていくデータ
  let recording = false; // 録音中のフラグ
  let startTime; // 録音開始時刻
  let timerInterval; // タイマーのID
  let audioBlob; // 録音できた後の音声ファイル
  let recordingDuration = 0; // 録音時間

    // --- UI要素取得 ---
  const recordingInterface = document.getElementById('recordingInterface');
  const waveContainer = document.getElementById('waveContainer');
  const waveBars = document.getElementById('waveBars');
  const recordBtn = document.getElementById('recordBtn');
  const saveBtn = document.getElementById('saveBtn');
  const timer = document.getElementById('timer');
  const status = document.getElementById('status');
  const audioPlayerContainer = document.getElementById('audioPlayerContainer');
  const audioPlayer = document.getElementById('audioPlayer');

  // --- 波形アニメーションのバーを生成 ---
  function createWaveBars() { // createWaveBars という関数を定義する。「波形バーを生成する処理」
    waveBars.innerHTML = ''; // 新しく作り直すために、すでにwaveBars内にある HTML（古いバー）をすべて削除
    waveContainer.classList.remove('empty', 'completed'); // 録音開始するから、waveContainer要素からemptyとcompletedクラスを外す。
    for (let i = 0; i < 9; i++) { // 0から8までのループを回して、合計9本のバーを生成する。
      const bar = document.createElement('div'); // 新しい <div> 要素を作る。
      bar.className = 'wave-bar'; // CSSで高さが上下するアニメーション用の棒になるクラスをつける
      waveBars.appendChild(bar); // 生成したバーをwaveBarsの中に追加していく。
    }
  }
  // --- 波形バーを非表示にして「録音完了」状態にする ---
  function hideWaveBars() { // 波形エリアの中身を空にする処理。
    waveBars.innerHTML = ''; //録音中に動かしていた「9本のバー」を消すことで、録音終了後に波形アニメーションが残らないようにしている。
    waveContainer.classList.remove('empty'); // 録音完了時には「もう空ではない（録音データがある）」ので削除
    waveContainer.classList.add('completed'); // completed クラスを付けて「録音が終了した」状態とする
  }

   // --- 波形エリアごと隠す ---
  function hideWaveArea () { // 
    if (!waveContainer) return; //waveContainerが存在しない場合にエラーにならないようにガード処理
    waveContainer.style.display = ''; // 一度displayを空文字にリセットして、前の状態をクリア
    waveContainer.classList.remove('empty'); // 「録音前の空状態」を表すemptyクラスを外す エリアを非表示にするので「空状態」というUI表現は不要
    waveContainer.style.display = 'none'; // 録音完了後には波形アニメーションエリア自体を消して、再生UIや保存ボタンを見せたい
  }

  // --- 波形エリアを「録音前の空」状態で表示する ---
  function showWaveContainer() {
    if (!waveContainer) return; // waveContainerが存在しない場合にエラーを避けるガード処理
    waveContainer.style.display = ''; // displayを空文字に戻し、非表示（display:none）から再表示す。録音開始前に波形エリアを「見える状態」に復帰
    waveContainer.classList.remove('completed'); // completed ラスは「録音完了」状態で、「録音を開始する直前」なので、完了状態から外す必要がある
    waveContainer.classList.add('empty'); // 「まだ録音が始まっていない、空っぽの状態」
    waveBars.innerHTML = ''; // 波形エリア内部を空にする。createWaveBars() を呼ぶときに新しく作られる前提。
  }
  
  // --- タイマー開始 ---
  function startTimer() {
    startTime = Date.now(); // Date.now()で録音開始時点のミリ秒タイムスタンプを保存 後で経過時間を算出する基準
    timerInterval = setInterval(() => { // setInterval を使い 1秒ごとに処理を繰り返す 
      const elapsed = Math.floor((Date.now() - startTime) / 1000); // Date.now() - startTimeで現在までの経過時間（ミリ秒）を計算 /1000で秒単位に変換、Math.floorで切り捨て
      const minutes = Math.floor(elapsed / 60); // 秒数を「分」と「秒」に分けて表示する
      const seconds = elapsed % 60;
      timer.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`; // 分・秒を常に2桁表示（00:00形式） にするためpadStart(2, '0')を利用
    }, 1000); // 更新間隔は 1000ms（1秒）ごと 録音中にリアルタイムで時間表示
  }

   // --- タイマー停止 ---
  function stopTimer() {
    clearInterval(timerInterval); // clearIntervalでsetIntervalを停止 timerIntervalを保持しておいたのは、録音終了後にタイマーが無駄に動き続けないようにするため
  }

  // --- ステータスメッセージを表示 ---
  function updateStatus(message, type = 'info') { // 使っているひとに操作状況を即座にフィードバック
    status.textContent = message;
    status.className = `alert alert-${type} text-center status-alert`; // Bootstrap alert-*を使って色で表現
  }

  // --- 録音開始処理 ---
  async function startRecording() { // 関数をasyncで定義しているのは、中でawaitを使うため
    try { // navigator.mediaDevices.getUserMediaはPromiseを返す非同期処理 → awaitで待てるようにしている。安全にエラーを拾ってUIで通知するために try/catch を利用。
      // マイクアクセスを要求
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true }); // ブラウザAPIでマイクにアクセス。ユーザーが許可しなければ例外。{ audio: true }を指定しているので、映像カメラではなく「音声マイク」のみを要求。awaitは、非同期処理が完了するまで待ち、返ってきたMediaStreamを変数streamに代入。
      mediaRecorder = new MediaRecorder(stream); // MediaStreamを録音できるインターフェース。streamを引数に渡すことで「このマイク入力を録音対象にする」という指定。mediaRecorderを関数外のスコープに代入しているのは、録音停止処理や他の関数から参照できるようにする。
      audioChunks = []; // データはondataavailableイベントでかけらとして届く。一時的にここで初期化。毎回録音するたびにリセットする。録音開始時点で空にする。

        // 録音開始時
      mediaRecorder.onstart = e => { // MediaRecorderのイベントハンドラ。
        startTime = Date.now(); // 録音開始時点の「UNIX時間（ミリ秒）」を取得して記録 後で「経過時間」を計算するため
        startTimer(); // 別に用意してある関数を呼び、UIのタイマー表示を開始。setIntervalで1秒ごとに残り時間を計算し、timerDOMに表示する仕組み。
      }
      
       // 録音データを受け取るたびに追加
      mediaRecorder.ondataavailable = e => { // MediaRecorderが録音中に「データのかけら（チャンク）」を生成するたびに発火
        audioChunks.push(e.data); // 小さな BlobをaudioChunks配列に順番に追加。録音停止時に new Blob(audioChunks, { type: 'audio/webm' })でまとめて1つの音声ファイルにする。
      };

      // 録音停止時
      mediaRecorder.onstop = () => { // 録音の終了後、データの後処理や UI の切り替えをここで行う
        // 録音時間を計算
        recordingDuration = Math.round((Date.now() - startTime) / 1000); // 開始時刻 startTime との差をミリ秒で計算
        recording = false; // グローバル状態フラグをfalseにして「録音中ではない」ことを明示
        if (recordingInterface) recordingInterface.classList.remove('recording'); // 録音中につけていたCSSクラスrecordingを外す。
        recordBtn.classList.remove('recording');

       // UIを「録音停止」状態に戻す
        const icon = recordBtn.querySelector('i');
        const text = recordBtn.querySelector('.btn-text');
        if (icon && text) { // icon&&textのチェックでnullエラー防止
          icon.className = 'bi bi-mic-fill fs-1';
          text.textContent = '録音開始';
        }

       // 音声ファイルを生成し、プレイヤーにセット
        audioBlob = new Blob(audioChunks, { type: 'audio/webm' }); // MediaRecorderは録音データを小さなチャンク（分割データ） として逐次audioChunksに溜める // Chromeなどはaudio/webmが標準でサポート
        const audioUrl = URL.createObjectURL(audioBlob); // メモリ上のblobに対して一時的なオブジェクトURLを発行
        if (audioPlayer) { //audioPlayer が存在する場合にのみ設定
          audioPlayer.src = audioUrl; // 録音したデータをユーザーが再生できる。
          audioPlayer.controls = true; // 再生・停止などのUIをブラウザ組み込みで利用可能になる。
        }
        if (audioPlayerContainer) {
          audioPlayerContainer.style.display = 'block';
        }

        // 保存ボタンを表示
        if (saveBtn) {
          saveBtn.style.display = 'inline-block';
          saveBtn.classList.add('show');
        }
        // ステータス更新 & UIリセット
        updateStatus("録音完了。内容を確認してください。", 'success');
        hideWaveBars();
        hideWaveArea ();
        stopTimer();
      };

      // 録音開始
      mediaRecorder.start();
      recording = true;

      // UIを「録音中」に変更
      if (recordingInterface) recordingInterface.classList.add('recording');
      recordBtn.classList.add('recording');
      const icon = recordBtn.querySelector('i');
      const text = recordBtn.querySelector('.btn-text');
      if (icon && text) {
        icon.className = 'bi bi-stop-fill fs-1';
        text.textContent = "録音停止";
      }

      updateStatus("録音中...", 'warning');
      createWaveBars();

      if (timer) timer.textContent = '00:00';
      createWaveBars();

      if (waveContainer) {
        waveContainer.style.display = '';
      }

      if (audioPlayerContainer) {
        audioPlayerContainer.style.display = 'none';
      }
      
      if (saveBtn) {
        saveBtn.style.display = 'none';
        saveBtn.classList.remove('show');
      }

    } catch (error) {
      console.error("録音エラー：", error);
      updateStatus("マイクアクセスが拒否されました。", 'danger');
    }
  }
  // --- 録音停止処理 ---
  function stopRecording() { // 録音中かを判定しつつ安全に停止させるために分離
    if (mediaRecorder && recording) { // 未初期化や非録音時の例外を防ぐ
      mediaRecorder.stop(); // MediaRecorderを停止 録音の完了処理（Blob化・UI更新）をイベントで一元化
      mediaRecorder.stream.getTracks().forEach(track => track.stop()); // マイク解放.  使用中のオーディオトラックをすべて止める
    }
  }
  // --- 録音データをActiveStorageに送信 ---
  function saveToActiveStorage() { // UI/録音処理と送信処理を責務分離して可読性を保つ
    if (!audioBlob) { // Blob未生成なら保存中止
      updateStatus("保存するファイルがありません。", 'danger'); // サーバへ無効データを送るのを未然に防止
      return;
    }

    if (audioBlob.size > 2 * 1024 * 1024) { // 2MB超なら保存中止
      updateStatus("ファイルサイズが2MBを超えています。", 'danger'); // 許容サイズに合わせる
      return;
    }

    // Railsに送るフォームデータを準備
    const formData = new FormData(); // FormDataを作り、音声と録音秒数を詰める
    formData.append('audio', audioBlob, 'recording.webm'); // ActiveStorage/コントローラでファイルとメタ情報を同時受信する
    formData.append('duration', recordingDuration); // ActiveStorage/コントローラでファイルとメタ情報を同時受信する

    // ボタンを「保存中」表示に変更
    saveBtn.disabled = true; // 二重送信防止と処理中フィードバックでUXを向上させるために保存中はボタン無効化＆文言変更、ステータス表示
    const originalHTML = saveBtn.innerHTML;
    saveBtn.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>保存中...';
    updateStatus("保存中...", 'info');

    // CSRFトークンを取得して送信
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content; // RailsのCSRF保護を満たしつつ、ビュー側指定のURLに送る
    const postUrl = saveBtn.dataset.url;

    fetch(postUrl, { // Fetchで非同期POST ページ遷移なしでファイルアップロードを行う
      method: 'POST',
      headers: { 'X-CSRF-Token': csrfToken },
      body: formData
    })
    .then(response => response.json()) // 以降の分岐で構造化データを扱うためにJSONとしてレスポンスをパース。
    .then(data => { // バックエンドの結果に従って次アクション（遷移/エラーメッセージ）を分岐するため
      if (data.status === 'OK' || data.success) {
        updateStatus("保存完了", 'success');
        window.location.href =  data.redirect_url; // 成功なら完了表示→サーバ指示のURLへ遷移
      } else {
        throw new Error(data.errors ? data.errors.join(', ') : '保存に失敗しました'); // 失敗ならエラー発生
      }
    })
    .catch(error => { // 通信失敗や例外を捕捉するためにPromiseのcatchを利用
      console.error("保存エラー", error); // 原因を調べられるようにログを残す
      // updateStatus(`保存エラー：${error.message}`, 'danger'); // 利用者に失敗したことを即時に知らせる
      
      saveBtn.disabled = false; // 失敗した場合でもユーザーが再度保存できるようにする
      saveBtn.innerHTML = originalHTML; // 処理中インジケータを消して通常状態に復帰させる
    });
  }
    // --- 初期状態のUIをセット ---
  function initializeInterface() {
    const path = window.location.pathname;
    if (/^\/visits\/\d+\/recording\/new$/.test(path)) { // 正規表現を入れてみる
      if (saveBtn) saveBtn.style.display = 'none';
      if (timer) timer.textContent = '00:00';
      if (waveContainer) {
        waveBars.innerHTML = '';
        waveContainer.classList.remove('completed');
        waveContainer.classList.add('empty');
        waveContainer.style.display = '';
      }
      updateStatus("録音ボタンを押して開始して下さい。", 'info');
    }
  }

  // イベントリスナー
  if (recordBtn) { // null参照エラーを防ぐ
    recordBtn.addEventListener('click', (e) => { // 録音開始・停止をトグル操作で行う
      e.preventDefault(); // ボタンが <form> 内にある場合のページ遷移を防ぐ
      if (!recording) { // 1つのボタンで録音/停止を切り替えるUI仕様にする
        startRecording();
      } else {
        stopRecording();
      }
    });
  }

  if (saveBtn) { // null参照エラー防止
    saveBtn.addEventListener('click', (e) => { // 録音済みデータを保存できるようにする
      e.preventDefault(); // フォーム送信やページリロードを避ける
      if (recording) { // 録音中に保存ボタンが押されたら警告を表示して中断 録音が完了していない音声は保存できない
        updateStatus("録音を停止してから保存してください。", 'warning');
        return;
      }
      saveToActiveStorage(); // 保存処理を実行 録音停止済みならファイルをサーバに送れるため
    });
  }

  // 初期化
      initializeInterface(); // ページロード直後に「録音前」の状態を整える
});
