# Supabase MCP 连接状态诊断报告

## 🔍 问题描述
用户遇到 **MCP error -32603: fetch failed** 错误，需要诊断 Supabase MCP 连接状态。

## 📊 测试结果总结

### ✅ 正常工作的部分
1. **基础 Supabase 连接** - 完全正常
   - REST API 端点响应正常 (状态码: 200)
   - 认证端点工作正常
   - API 密钥有效且未过期

2. **网络连接稳定性** - 优秀
   - 连接成功率: **100%** (5/5 次测试)
   - 平均响应时间: **343ms**
   - 所有超时测试均通过 (1s-30s)

3. **认证机制** - 正常
   - API 密钥认证成功
   - Bearer Token 格式正确
   - 权限验证正常

### ⚠️ 发现的问题
1. **数据库表缺失**
   - `favorites` 表不存在 (返回 404)
   - 这解释了为什么收藏功能失败

2. **MCP 专用端点缺失**
   - `/rest/v1/rpc/mcp_handler` - 404
   - `/functions/v1/mcp` - 404
   - 没有找到 MCP 专用的处理端点

## 🤔 MCP 错误原因分析

基于详细测试，**MCP error -32603: fetch failed** 的可能原因：

### 1. **MCP 客户端配置问题** (最可能)
- MCP 客户端可能使用了错误的端点 URL
- 请求格式不符合 Supabase API 规范
- 超时设置过短（虽然我们的测试显示网络很稳定）

### 2. **缺少 MCP 专用处理逻辑**
- Supabase 项目中没有配置 MCP 专用的 Edge Functions
- 没有创建处理 JSON-RPC 请求的 RPC 函数
- MCP 客户端期望的端点不存在

### 3. **请求格式不匹配**
- MCP 使用 JSON-RPC 2.0 格式
- Supabase REST API 使用标准 REST 格式
- 两者之间需要适配层

## 💡 解决方案建议

### 立即可执行的解决方案

#### 1. **创建 favorites 表**
```sql
-- 执行已准备好的 SQL 脚本
-- 文件: CREATE_FAVORITES_TABLE.sql
```

#### 2. **检查 MCP 客户端配置**
确保 MCP 客户端使用正确的配置：
```json
{
  "supabase": {
    "url": "https://uwvlduprxppwdkjkvwby.supabase.co",
    "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "timeout": 30000
  }
}
```

#### 3. **增加超时设置**
将 MCP 客户端超时设置为至少 30 秒：
```javascript
// MCP 客户端配置
{
  timeout: 30000, // 30 秒
  retries: 3
}
```

### 长期解决方案

#### 1. **创建 MCP 适配器 Edge Function**
在 Supabase 中创建一个 Edge Function 来处理 MCP 请求：

```typescript
// supabase/functions/mcp-handler/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { method, params, id } = await req.json()
  
  // 处理不同的 MCP 方法
  switch (method) {
    case 'supabase/query':
      // 处理查询请求
      break
    case 'supabase/insert':
      // 处理插入请求
      break
    default:
      return new Response(JSON.stringify({
        jsonrpc: '2.0',
        error: { code: -32601, message: 'Method not found' },
        id
      }))
  }
})
```

#### 2. **创建 RPC 函数**
在 Supabase 中创建处理 MCP 请求的 PostgreSQL 函数：

```sql
CREATE OR REPLACE FUNCTION handle_mcp_request(request_data jsonb)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
BEGIN
  -- 处理 MCP JSON-RPC 请求
  -- 返回标准 JSON-RPC 响应
END;
$$;
```

## 📋 下一步行动计划

### 优先级 1 (立即执行)
1. ✅ 在 Supabase Dashboard 中执行 `CREATE_FAVORITES_TABLE.sql`
2. 🔄 检查并调整 MCP 客户端的超时设置
3. 🔄 验证 MCP 客户端使用的端点 URL

### 优先级 2 (短期内完成)
1. 📝 获取 MCP 客户端的详细配置信息
2. 📝 查看 MCP 客户端的完整错误日志
3. 🔧 考虑创建 MCP 适配器 Edge Function

### 优先级 3 (长期优化)
1. 🏗️ 实现完整的 MCP-Supabase 适配层
2. 📊 添加 MCP 请求的监控和日志
3. 🔒 优化 MCP 请求的安全性和性能

## 🎯 结论

**Supabase 本身工作完全正常**，问题主要在于：
1. 缺少 `favorites` 表（已有解决方案）
2. MCP 客户端配置或端点问题
3. 可能需要 MCP-Supabase 适配层

建议先执行优先级 1 的任务，然后根据结果决定是否需要进一步的适配开发。

---
*报告生成时间: ${new Date().toLocaleString('zh-CN')}*
*测试环境: Node.js v22.14.0, Windows PowerShell*