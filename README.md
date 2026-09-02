# PORTFOLIO ARCHIVE - Supabase 共通管理版

この版では、管理画面から追加・編集した作品を **Supabase Database / Storage** に保存します。
そのため、同じサイトを見ている別PC・スマホ・別ブラウザにも共通で反映されます。

## 変更点

- `localStorage` 保存を廃止
- 作品情報 → Supabase Database
- 追加画像 → Supabase Storage
- 管理画面 → Supabase Authでログイン必須
- 公開作品 → 誰でも閲覧可能
- 非公開作品・追加/編集/削除 → 管理者のみ
- Realtime → 他端末にも自動同期

## 1. Supabaseプロジェクトを作成

Supabaseで新しいProjectを作成します。

## 2. SQLを実行

Supabase Dashboard の **SQL Editor** を開き、同梱の `supabase_setup.sql` 全体を貼り付けて実行してください。

これで以下が作成されます。

- `portfolio_works` テーブル
- `portfolio` Storage bucket
- 公開閲覧 / 管理者編集用のRLS policy
- 初期3作品
- Realtime設定

## 3. 管理者アカウントを作成

Supabase Dashboard の Authentication から管理用ユーザーを1人作成します。

その後 `supabase_setup.sql` の一番下にある次のSQLのコメントを外し、メールアドレスを書き換えてSQL Editorで実行してください。

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"portfolio_admin": true}'::jsonb
where email = 'YOUR_ADMIN_EMAIL';
```

`YOUR_ADMIN_EMAIL` を作成した管理者のメールアドレスに変更します。

管理者権限を付けたあと、すでにログインしている場合はいったんログアウトして再ログインしてください。

### セキュリティ上のおすすめ

このサイトには新規登録画面を用意していません。Supabase側でも不要なら一般ユーザーの新規サインアップを無効にして、管理者ユーザーだけをDashboardから作る運用がおすすめです。

## 4. `config.js` を設定

Supabase Dashboard の Project Settings / API で確認できる値を `config.js` に入れます。

```js
window.PORTFOLIO_SUPABASE = {
  url: 'https://xxxxxxxx.supabase.co',
  anonKey: 'xxxxxxxxxxxxxxxx'
};
```

**重要:** `service_role` key は絶対に入れないでください。ブラウザに入れるのは anon / publishable key だけです。

## 5. GitHub Pagesへアップロード

このフォルダの中身をGitHubリポジトリ直下へアップロードします。

```text
.nojekyll
index.html
config.js
supabase_setup.sql
README.md
assets/
```

GitHubの `Settings` → `Pages` で、Branchを `main`、Folderを `/(root)` にして公開します。

## 6. 管理画面の使い方

公開URLの右上にある **管理画面** を押します。

1. 管理者メールアドレス・パスワードでログイン
2. 作品画像を選択
3. 作品名 / カテゴリー / タグ / 備考を入力
4. `保存する`
5. 公開サイトへ反映

追加画像はブラウザで長辺1600pxまで圧縮してからStorageへアップロードします。

## ファイル構成

- `index.html` : 公開サイト + 管理画面
- `config.js` : Supabase接続設定
- `supabase_setup.sql` : DB / Storage / RLS / Realtime 初期設定
- `assets/` : 初期3作品画像
- `.nojekyll` : GitHub Pages用
- `README.md` : この手順

## 補足

`config.js` 未設定の状態では、公開画面は同梱の初期3作品を表示します。
管理画面の共通保存機能はSupabase設定完了後に有効になります。
