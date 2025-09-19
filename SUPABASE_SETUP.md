# Supabase 數據庫設置指南

## 概述

本應用已集成 Supabase 作為後端數據庫和用戶認證服務。按照以下步驟完成配置。

## 1. 創建 Supabase 項目

1. **訪問 Supabase**
   - 打開 https://supabase.com
   - 註冊或登錄您的賬戶

2. **創建新項目**
   - 點擊 "New Project"
   - 填寫項目信息：
     - Name: `Banana Record App`
     - Database Password: 設置一個強密碼
     - Region: 選擇離您最近的區域

3. **等待項目初始化**
   - 項目創建需要幾分鐘時間
   - 完成後會顯示項目儀表板

## 2. 獲取項目配置信息

在項目儀表板中：

1. **獲取 URL 和 Key**
   - 點擊左側菜單的 "Settings" → "API"
   - 複製以下信息：
     - Project URL (類似: `https://xxxxx.supabase.co`)
     - anon public key (類似: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## 3. 配置應用

1. **修改配置文件**
   - 打開 `entry/src/main/ets/common/SupabaseConfig.ets`
   - 將獲取的信息填入：

```typescript
public static readonly SUPABASE_URL = 'https://your-project.supabase.co';
public static readonly SUPABASE_ANON_KEY = 'your-anon-key-here';
```

## 4. 設置數據庫表結構

在 Supabase 儀表板中：

1. **進入 SQL Editor**
   - 點擊左側菜單的 "SQL Editor"
   - 點擊 "New query"

2. **創建用戶資料表**
   執行以下 SQL：

```sql
-- 創建用戶資料表
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  username TEXT UNIQUE,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  records_count INTEGER DEFAULT 0,
  followers_count INTEGER DEFAULT 0,
  following_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  PRIMARY KEY (id)
);

-- 設置 RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 創建策略：用戶可以查看所有資料
CREATE POLICY "Public profiles are viewable by everyone." ON profiles
  FOR SELECT USING (true);

-- 創建策略：用戶只能更新自己的資料
CREATE POLICY "Users can update own profile." ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- 創建策略：用戶可以插入自己的資料
CREATE POLICY "Users can insert their own profile." ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- 創建觸發器：自動創建用戶資料
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, display_name)
  VALUES (new.id, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'display_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

3. **創建唱片收藏表（可選）**
   如果需要存儲用戶的唱片收藏：

```sql
-- 創建唱片收藏表
CREATE TABLE user_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  discogs_id TEXT NOT NULL,
  title TEXT NOT NULL,
  artist TEXT NOT NULL,
  year INTEGER,
  genre TEXT,
  cover_image TEXT,
  added_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  UNIQUE(user_id, discogs_id)
);

-- 設置 RLS
ALTER TABLE user_records ENABLE ROW LEVEL SECURITY;

-- 創建策略
CREATE POLICY "Users can view own records." ON user_records
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own records." ON user_records
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own records." ON user_records
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own records." ON user_records
  FOR DELETE USING (auth.uid() = user_id);
```

## 5. 測試配置

1. **重新編譯應用**
2. **測試註冊功能**
   - 使用有效的郵箱地址註冊
   - 檢查是否收到確認郵件
3. **測試登錄功能**
   - 使用註冊的郵箱和密碼登錄

## 6. 故障排除

### 常見問題

1. **配置錯誤**
   - 檢查 URL 和 Key 是否正確複製
   - 確保沒有多餘的空格或字符

2. **網絡問題**
   - 確保設備有網絡連接
   - 檢查防火牆設置

3. **認證失敗**
   - 檢查郵箱格式是否正確
   - 確保密碼符合要求（至少6位）

4. **數據庫錯誤**
   - 檢查表結構是否正確創建
   - 確認 RLS 策略已正確設置

### 查看日誌

在應用中查看控制台輸出，會顯示詳細的錯誤信息。

## 7. 安全注意事項

1. **保護密鑰**
   - 不要將真實的 API 密鑰提交到公共代碼庫
   - 考慮使用環境變量或配置文件

2. **RLS 策略**
   - 確保正確設置行級安全策略
   - 定期檢查數據訪問權限

3. **郵箱驗證**
   - 在生產環境中啟用郵箱驗證
   - 設置適當的重定向 URL

## 8. 當前功能狀態

- ✅ Supabase 配置框架已就緒
- ✅ 用戶認證服務已實現
- ✅ 登錄/註冊 UI 已集成
- ⚠️ 需要配置 Supabase 項目信息
- ⚠️ 需要創建數據庫表結構
- ✅ 有模擬數據作為後備方案

配置完成後，應用將支持真實的用戶註冊、登錄和資料管理功能。