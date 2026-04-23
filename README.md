# Finance Dashboard - GitHub + Netlify + Supabase

這份版本已改成：

- 前端可直接放到 GitHub
- 使用 Netlify 靜態部署
- 使用 Supabase Auth 做登入
- 資料改為 Supabase 多資料表結構
  - `finance_transactions`：一筆費用一列
  - `finance_budgets`：一筆預算一列
  - `finance_app_configs`：品牌設定
  - `finance_profiles`：角色 / 部門 / 品牌權限

## 部署步驟

### 1. 建立 Supabase
1. 到 Supabase 建立專案
2. 在 SQL Editor 執行 `supabase/schema.sql`
3. 在 Authentication > Users 建立使用者
4. 建議在 `user_metadata` 或 `finance_profiles` 設定：
   - `role`: `admin` / `supervisor` / `operator` / `viewer`
   - `allowedBrands`: `["wiseedge","revovision"]`

### 2. 建立 GitHub Repo
把本資料夾全部上傳到 GitHub。

### 3. 連接 Netlify
1. 在 Netlify 匯入 GitHub 專案
2. Build command 留空
3. Publish directory 設為 `.`
4. Functions directory 已在 `netlify.toml` 設好

### 4. 設定 Netlify 環境變數
在 Netlify Site configuration > Environment variables 新增：

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 5. 重新部署
重新 deploy 後，前端會從 `/.netlify/functions/app-config` 讀取環境變數。

## 資料設計

### finance_transactions
每一筆費用記錄都會獨立存成一列，前端仍保留原本畫面與流程。

### finance_budgets
每一筆預算獨立一列。

### finance_app_configs
品牌層級設定，例如費用名稱、分類樹、支付方式、幣種、收款人。

### finance_profiles
用來補足 Auth 帳號的角色與權限。若 `user_metadata` 已有完整資料，可不一定要寫入這張表。

## 建議
正式上線前，請先用一個測試站驗證：
- 登入 / 登出
- 不同角色權限
- Wise Edge / Revovision 切換
- 新增 / 編輯 / 刪除費用
- 預算建立與同步
- PDF 匯出

