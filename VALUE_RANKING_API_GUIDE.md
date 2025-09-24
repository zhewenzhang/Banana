# 价值排行榜 API 配置指南

## 概述
价值排行榜功能已集成 Discogs API，可以获取真实的高价值唱片数据。本指南将帮助您正确配置 API 以获取准确的内容。

## 前置要求
1. 有效的 Discogs 账户
2. Discogs API Token
3. 网络连接权限

## 配置步骤

### 1. 获取 Discogs API Token
1. 访问 [Discogs 开发者页面](https://www.discogs.com/settings/developers)
2. 登录您的 Discogs 账户
3. 点击 "Create an App" 或 "Generate new token"
4. 填写应用信息：
   - **App Name**: 您的应用名称（如 "Banana Music App"）
   - **Description**: 应用描述
   - **Website**: 可选，填写您的网站
5. 复制生成的 Token

### 2. 配置 API Token

#### 方法一：修改配置文件
1. 打开 `entry/src/main/ets/common/ApiConfig.ets`
2. 找到 `DISCOGS_TOKEN` 常量
3. 将您的 Token 替换默认值：
```typescript
export const DISCOGS_TOKEN: string = 'YOUR_ACTUAL_TOKEN_HERE';
```

#### 方法二：运行时配置
在应用启动时调用：
```typescript
import { ApiConfig } from '../common/ApiConfig';
ApiConfig.setDiscogsToken('YOUR_ACTUAL_TOKEN_HERE');
```

### 3. 验证配置
1. 重新编译并运行应用
2. 进入 TimeMachine 页面
3. 点击 "切换到API数据" 按钮
4. 观察是否成功加载真实数据

## 功能特性

### 数据获取策略
价值排行榜使用多重搜索策略获取高价值唱片：

1. **稀有流派搜索**：搜索 Jazz、Blues、Soul、Funk 等稀有流派
2. **年代筛选**：重点关注 1950-1980 年代的经典唱片
3. **格式筛选**：优先 Vinyl 格式
4. **排序优化**：按拥有量降序排列，筛选稀有度高的唱片
5. **去重处理**：自动移除重复条目
6. **价值估算**：基于发行年份、稀有度等因素估算价值

### 数据源切换
- **API 数据**：实时从 Discogs 获取真实唱片信息
- **模拟数据**：当 API 不可用时自动切换到本地模拟数据
- **手动切换**：用户可通过界面按钮手动切换数据源

### 错误处理
- 自动检测 API Token 配置状态
- 网络错误时自动降级到模拟数据
- 详细的错误信息提示
- 重试机制

## 注意事项

### API 限制
- Discogs API 有速率限制（每分钟 60 次请求）
- 建议合理控制请求频率
- 避免频繁刷新数据

### 安全性
- 不要在代码中硬编码 Token
- 考虑使用环境变量或安全存储
- 定期更新 Token

### 网络权限
确保应用具有网络访问权限：
```json
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET"
    }
  ]
}
```

## 故障排除

### 常见问题

#### 1. 无法获取数据
- 检查网络连接
- 验证 API Token 是否正确
- 查看控制台日志错误信息

#### 2. 数据加载缓慢
- Discogs API 响应可能较慢
- 考虑添加加载指示器
- 检查网络状况

#### 3. Token 无效
- 确认 Token 未过期
- 重新生成新的 Token
- 检查 Token 格式是否正确

### 调试方法
1. 启用详细日志输出
2. 使用网络抓包工具检查 API 请求
3. 测试 API Token 在浏览器中的有效性

## 技术实现

### 核心组件
- **DiscogsService**: API 服务封装
- **ApiConfig**: 配置管理
- **TimeMachine**: 价值排行榜界面组件

### 数据流程
1. 用户进入价值排行榜页面
2. 检查 API Token 配置
3. 发起多个并发搜索请求
4. 合并和去重搜索结果
5. 计算估值并排序
6. 渲染到界面

### API 端点使用
- **搜索端点**: `/database/search`
- **参数**: `q`, `type`, `format`, `decade`, `sort`, `sort_order`
- **认证**: Bearer Token

## 更新日志
- **v1.0**: 初始版本，支持基本的价值排行榜功能
- **v1.1**: 添加多重搜索策略和去重逻辑
- **v1.2**: 优化错误处理和数据源切换

## 支持
如遇问题，请检查：
1. API Token 配置是否正确
2. 网络连接是否正常
3. 应用权限是否充足
4. Discogs API 服务状态

---
*最后更新：2024年1月*