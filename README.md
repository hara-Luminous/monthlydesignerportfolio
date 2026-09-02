# 月別ポートフォリオ / GitHub Pages 用

このフォルダは新しい月別ポートフォリオ専用です。
既存ページの `portfolio_works` とは分離し、新ページは `monthly_portfolio_works` を使用します。
画像保存先も既存の `portfolio` ではなく `monthly-portfolio` を使用します。

## 今回すでに完了していること
Supabase SQL Editor で新ページ専用テーブル・RLS・Storage・Realtime の設定を実行済みなら、`supabase_setup.sql` は再実行不要です。

## GitHub に置くファイル
リポジトリの一番上に次を置いてください。

- `index.html`
- `config.js`
- `.nojekyll`
- `assets/`
- `README.md`
- `supabase_setup.sql`（保管用。実行済みなら再実行不要）

`index.html` は必ずリポジトリ直下に置きます。

## config.js
前のポートフォリオと同じ Supabase プロジェクトを使うため、前ページで使っている Project URL と anon key を `config.js` に設定できます。

```js
window.PORTFOLIO_SUPABASE = {
  url: 'https://xxxxxxxx.supabase.co',
  anonKey: 'xxxxxxxx'
};
```

`service_role` キーは絶対に GitHub に置かないでください。

## 管理画面
公開URLの末尾に `#admin` を付けると管理画面を開けます。
例: `https://example.github.io/repository/#admin`

前ページで `portfolio_admin: true` を設定済みのSupabase Authユーザーは、その管理者設定をこの新ページでも利用できます。

## 新ページのデータ保存先
- テーブル: `public.monthly_portfolio_works`
- Storage: `monthly-portfolio`
- 制作月: `work_month`（1〜12）
- テイストカテゴリ: `category`（かわいい、高級感、ネオン等）

月とカテゴリは別項目なので、「9月 × 高級感」のような絞り込みができます。
