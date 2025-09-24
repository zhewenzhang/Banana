-- 创建收藏表 (favorites)
-- 根据 FavoriteService.ets 中的 CreateFavoriteRecord 接口设计

CREATE TABLE favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  userId UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  recordId TEXT NOT NULL,
  recordTitle TEXT NOT NULL,
  recordArtist TEXT NOT NULL,
  recordImage TEXT,
  recordYear INTEGER,
  recordGenres TEXT,
  recordFormats TEXT,
  favoriteTime TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- 确保同一用户不能重复收藏同一唱片
  UNIQUE(userId, recordId)
);

-- 设置行级安全 (RLS)
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- 创建安全策略：用户只能查看自己的收藏
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = userId);

-- 创建安全策略：用户只能添加自己的收藏
CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = userId);

-- 创建安全策略：用户只能删除自己的收藏
CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = userId);

-- 创建索引以提高查询性能
CREATE INDEX idx_favorites_user_id ON favorites(userId);
CREATE INDEX idx_favorites_record_id ON favorites(recordId);
CREATE INDEX idx_favorites_user_record ON favorites(userId, recordId);

-- 插入测试数据（可选）
-- INSERT INTO favorites (userId, recordId, recordTitle, recordArtist, recordImage, recordYear, recordGenres, recordFormats)
-- VALUES 
--   ('your-user-id-here', '123456', 'Test Album', 'Test Artist', 'https://example.com/image.jpg', 2023, 'Rock', 'Vinyl');