# Finance Dashboard - Google OAuth 版

## 部署步驟
1. 將本 ZIP 解壓後推到 GitHub。
2. Netlify 連接 GitHub repository。
3. Netlify Environment variables 設定：
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
4. Supabase Authentication > Providers 啟用 Google。
5. Google Cloud OAuth Client 的 Authorized redirect URI 設定：
   - `https://你的-supabase-project.supabase.co/auth/v1/callback`
6. Supabase Authentication > URL Configuration：
   - Site URL：`https://你的-netlify-site.netlify.app`
   - Redirect URLs 加入：`https://你的-netlify-site.netlify.app/*`
7. 重新部署 Netlify。

## 注意
本版前端改為 `signInWithOAuth({ provider: 'google' })`，不再使用 Email/密碼登入。
Google OAuth 只處理身份驗證；角色仍可由 `finance_profiles` 或 Supabase user metadata 控制。
