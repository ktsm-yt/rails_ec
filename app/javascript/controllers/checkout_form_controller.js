import {Controller} from"@hotwired/stimulus"

export default class extends Controller {
  connect(){
    console.log("Checkout form controller connected")
    this.form = this.element.querySelector('form');

    if (this.form){
      this.form.querySelectorAll('input,select,textarea').forEach(element =>{
        element.addEventListener('input', this.saveDraft.bind(this));

        if (element.type === 'checkbox' || element.type === 'radio'){
          element.addEventListener('change', this.saveDraft.bind(this));
        }
      });
    } else {
      console.error("No form found within the checkout form controller element.");
    }
  }

  saveDraft() {
    console.log("Input changed, saving draft...");

    const data = {};
    new FormData(this.form).forEach((value, key) => {
      const keys = key.replace(/\]/g, '').split(/\[/);
      let current = data
      for(let i = 0; i < keys.length - 1; i++){
        current[keys[i]] = current[keys[i]] || {};
        current = current[keys[i]];
      }
      current[keys[keys.length - 1]] = value;
    });
    console.log("Sending data:", data);

    // Ajaxリクエストを送信
    fetch('/cart/save_checkout_draft', {
      method: 'POST',
      headers: {
        'X-CSRF-Token': this.getCsrfToken(), // CSRFトークンを含める
        'Content-Type': 'application/json', // JSON形式で送信
        'Accept': 'application/json'
      },
      body: JSON.stringify(data) // データをJSON文字列に変換して送信
    })
    .then(response => {
      if (response.ok) {
        console.log("Checkout draft saved successfully.");
      } else {
        console.error("Failed to save checkout draft.", response.statusText);
        // エラーハンドリング（例: ユーザーに通知）
      }
    })
    .catch(error => {
      console.error("Error saving checkout draft:", error);
      // ネットワークエラーなどのハンドリング
    });
  }

  // メタタグからCSRFトークンを取得するヘルパーメソッド
  getCsrfToken() {
    const tokenElement = document.querySelector('meta[name="csrf-token"]');
    return tokenElement ? tokenElement.content : null;
  }

  disconnect() {
    console.log("Checkout form controller disconnected.");
    // イベントリスナーをクリーンアップ（SPAなどで必要になる場合があります）
    if (this.form) {
       this.form.querySelectorAll('input, select, textarea').forEach(element => {
        element.removeEventListener('input', this.saveDraft.bind(this));
         if (element.type === 'checkbox' || element.type === 'radio') {
           element.removeEventListener('change', this.saveDraft.bind(this));
         }
       });
     }
  }
}
