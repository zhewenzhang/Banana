# Banana 唱片应用 API 配置指南

## 为什么需要配置 API？

目前你的搜索功能使用的是模拟数据，要获取真实的唱片信息，需要配置 Discogs API。

## 如何获取 Discogs API Token

1. **访问 Discogs 开发者页面**
   - 打开浏览器访问：https://www.discogs.com/settings/developers
   - 如果没有账号，需要先注册 Discogs 账号

2. **创建应用**
   - 点击 "Create an App" 按钮
   - 填写应用信息：
     - App Name: `Banana Record App`
     - Description: `个人唱片收藏管理应用`
     - Website: 可以填写 `http://localhost` 或留空

3. **获取 Token**
   - 创建应用后，会生成一个 Personal Access Token
   - 复制这个 Token（类似：`abcdef123456789...`）

## 如何配置 API Token

### 方法1：直接修改配置文件（推荐）

1. 打开文件：`entry/src/main/ets/common/ApiConfig.ets`

2. 找到这一行：
   ```typescript
   private static DISCOGS_TOKEN = ''; // 在这里填入你的Discogs API Token
   ```

3. 将你的 Token 填入引号中：
   ```typescript
   private static DISCOGS_TOKEN = 'your_token_here'; // 替换为你的实际Token
   ```

### 方法2：运行时设置（可选）

如果你想在应用运行时动态设置Token，可以在任何页面调用：
```typescript
import { ApiConfig } from '../common/ApiConfig';

// 设置Token
ApiConfig.setDiscogsToken('your_token_here');
```

## 验证配置

配置完成后：

1. **重新编译应用**
2. **进行搜索测试**
   - 在搜索框输入歌手名或专辑名
   - 如果配置正确，会显示真实的搜索结果
   - 如果配置错误，会继续显示模拟数据

## 注意事项

- **保护你的 Token**：不要将包含真实Token的代码提交到公共代码仓库
- **API限制**：Discogs API 有请求频率限制，正常使用不会超限
- **网络权限**：确保应用有网络访问权限

## 故障排除

如果搜索仍然不工作：

1. **检查网络连接**
2. **查看控制台日志**：会显示具体的错误信息
3. **验证Token有效性**：在 Discogs 开发者页面确认Token状态
4. **检查应用权限**：确保应用有网络访问权限

## 当前状态

- ✅ API配置框架已就绪
- ⚠️ 需要用户配置 Discogs API Token
- ✅ 有模拟数据作为后备方案
- ✅ 错误处理和日志记录已完善