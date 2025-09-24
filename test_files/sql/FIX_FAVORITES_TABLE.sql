-- 修复 favorites 表的列名和 RLS 策略问题
-- 解决 PostgreSQL 列名大小写和安全策略问题

-- 1. 删除现有表（如果需要重新创建）
-- DROP TABLE IF EXISTS favorites;

-- 2. 或者重命名现有列以匹配驼峰命名
ALTER TABLE favorites RENAME COLUMN recordid TO "recordId";
ALTER TABLE favorites RENAME COLUMN recordtitle TO "recordTitle";
ALTER TABLE favorites RENAME COLUMN recordartist TO "recordArtist";
ALTER TABLE favorites RENAME COLUMN recordimage TO "recordImage";
ALTER TABLE favorites RENAME COLUMN recordyear TO "recordYear";
ALTER TABLE favorites RENAME COLUMN recordgenres TO "recordGenres";
ALTER TABLE favorites RENAME COLUMN recordformats TO "recordFormats";
ALTER TABLE favorites RENAME COLUMN favoritetime TO "favoriteTime";
ALTER TABLE favorites RENAME COLUMN userid TO "userId";

-- 3. 检查并修复 RLS 策略
-- 首先删除现有策略
DROP POLICY IF EXISTS "Users can view own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can insert own favorites" ON favorites;
DROP POLICY IF EXISTS "Users can delete own favorites" ON favorites;

-- 重新创建正确的 RLS 策略
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = "userId");

CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = "userId");

CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = "userId");

-- 4. 确保 RLS 已启用
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- 5. 重新创建索引（使用正确的列名）
DROP INDEX IF EXISTS idx_favorites_user_id;
DROP INDEX IF EXISTS idx_favorites_record_id;
DROP INDEX IF EXISTS idx_favorites_user_record;

CREATE INDEX idx_favorites_user_id ON favorites("userId");
CREATE INDEX idx_favorites_record_id ON favorites("recordId");
CREATE INDEX idx_favorites_user_record ON favorites("userId", "recordId");

-- 6. 验证表结构
-- 查看表结构以确认列名正确
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'favorites';

-- 7. 测试 RLS 策略
-- 以下查询应该返回空结果（因为没有认证用户）
-- SELECT * FROM favorites;

-- 8. 插入测试数据（需要认证用户）
-- 注意：这需要在有认证用户的情况下执行
-- INSERT INTO favorites ("userId", "recordId", "recordTitle", "recordArtist", "recordImage", "recordYear", "recordGenres", "recordFormats")
-- VALUES 
--   (auth.uid(), 'test-123', 'Test Album', 'Test Artist', 'https://example.com/test.jpg', 2023, 'Rock', 'Vinyl');

-- 完成修复