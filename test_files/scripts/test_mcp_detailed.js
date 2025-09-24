/**
 * Supabase MCP 详细连接状态检查脚本
 * 专门用于诊断 MCP error -32603: fetch failed 问题
 */

const SUPABASE_URL = 'https://uwvlduprxppwdkjkvwby.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dmxkdXByeHBwd2Rramt2d2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5NDYxMTMsImV4cCI6MjA2NTUyMjExM30.IT_7wL-0Buf1iyGKI1cw2PY0GtlKFljFiNOVYBvA_o0';

// 模拟不同的 MCP 请求场景
async function testMCPScenarios() {
  console.log('🔍 开始详细 MCP 连接状态检查...\n');

  // 1. 测试标准 REST API 调用
  await testStandardRestAPI();
  
  // 2. 测试带认证的请求
  await testAuthenticatedRequest();
  
  // 3. 测试不同的超时设置
  await testTimeoutScenarios();
  
  // 4. 测试错误的端点
  await testInvalidEndpoints();
  
  // 5. 测试网络连接稳定性
  await testConnectionStability();
  
  // 6. 测试 MCP 风格的 JSON-RPC 请求
  await testMCPStyleRequests();
}

// 1. 测试标准 REST API 调用
async function testStandardRestAPI() {
  console.log('1️⃣ 测试标准 REST API 调用...');
  
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`   ✅ 状态码: ${response.status}`);
    console.log(`   ✅ 状态文本: ${response.statusText}`);
    console.log(`   ✅ 响应头数量: ${response.headers.size || 'N/A'}`);
    
  } catch (error) {
    console.log(`   ❌ REST API 调用失败: ${error.message}`);
    console.log(`   ❌ 错误类型: ${error.name}`);
  }
  console.log('');
}

// 2. 测试带认证的请求
async function testAuthenticatedRequest() {
  console.log('2️⃣ 测试带认证的请求...');
  
  try {
    // 尝试访问需要认证的端点
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`   ✅ 认证请求状态码: ${response.status}`);
    
    if (response.status === 404) {
      console.log('   ℹ️  返回 404 - favorites 表不存在（这是预期的）');
    } else if (response.status === 401) {
      console.log('   ⚠️  返回 401 - 认证失败');
    } else if (response.status === 200) {
      console.log('   ✅ 认证成功');
    }
    
  } catch (error) {
    console.log(`   ❌ 认证请求失败: ${error.message}`);
  }
  console.log('');
}

// 3. 测试不同的超时设置
async function testTimeoutScenarios() {
  console.log('3️⃣ 测试不同的超时设置...');
  
  const timeouts = [1000, 5000, 10000, 30000]; // 1s, 5s, 10s, 30s
  
  for (const timeout of timeouts) {
    try {
      console.log(`   测试 ${timeout}ms 超时...`);
      
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);
      
      const startTime = Date.now();
      const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY
        },
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      const duration = Date.now() - startTime;
      
      console.log(`   ✅ ${timeout}ms 超时测试成功，实际耗时: ${duration}ms`);
      
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log(`   ⚠️  ${timeout}ms 超时测试 - 请求被中止`);
      } else {
        console.log(`   ❌ ${timeout}ms 超时测试失败: ${error.message}`);
      }
    }
  }
  console.log('');
}

// 4. 测试错误的端点
async function testInvalidEndpoints() {
  console.log('4️⃣ 测试错误的端点...');
  
  const invalidEndpoints = [
    '/rest/v1/nonexistent',
    '/auth/v1/invalid',
    '/storage/v1/missing'
  ];
  
  for (const endpoint of invalidEndpoints) {
    try {
      const response = await fetch(`${SUPABASE_URL}${endpoint}`, {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY
        }
      });
      
      console.log(`   ${endpoint}: 状态码 ${response.status}`);
      
    } catch (error) {
      console.log(`   ❌ ${endpoint}: ${error.message}`);
    }
  }
  console.log('');
}

// 5. 测试网络连接稳定性
async function testConnectionStability() {
  console.log('5️⃣ 测试网络连接稳定性...');
  
  const testCount = 5;
  let successCount = 0;
  let totalTime = 0;
  
  for (let i = 1; i <= testCount; i++) {
    try {
      const startTime = Date.now();
      const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY
        }
      });
      
      const duration = Date.now() - startTime;
      totalTime += duration;
      
      if (response.ok) {
        successCount++;
        console.log(`   ✅ 测试 ${i}/${testCount}: 成功 (${duration}ms)`);
      } else {
        console.log(`   ⚠️  测试 ${i}/${testCount}: 状态码 ${response.status} (${duration}ms)`);
      }
      
    } catch (error) {
      console.log(`   ❌ 测试 ${i}/${testCount}: ${error.message}`);
    }
    
    // 间隔 500ms
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  
  const avgTime = totalTime / testCount;
  const successRate = (successCount / testCount) * 100;
  
  console.log(`   📊 成功率: ${successRate}% (${successCount}/${testCount})`);
  console.log(`   📊 平均响应时间: ${avgTime.toFixed(0)}ms`);
  console.log('');
}

// 6. 测试 MCP 风格的 JSON-RPC 请求
async function testMCPStyleRequests() {
  console.log('6️⃣ 测试 MCP 风格的 JSON-RPC 请求...');
  
  // 模拟 MCP JSON-RPC 请求格式
  const mcpRequests = [
    {
      jsonrpc: '2.0',
      method: 'supabase/query',
      params: {
        table: 'favorites',
        operation: 'select'
      },
      id: 1
    },
    {
      jsonrpc: '2.0',
      method: 'supabase/insert',
      params: {
        table: 'favorites',
        data: { user_id: 'test', record_id: 'test' }
      },
      id: 2
    }
  ];
  
  for (const [index, request] of mcpRequests.entries()) {
    try {
      console.log(`   测试 MCP 请求 ${index + 1}...`);
      
      // 尝试发送到不同的可能端点
      const endpoints = [
        '/rest/v1/rpc/mcp_handler',
        '/functions/v1/mcp',
        '/rest/v1/favorites'
      ];
      
      for (const endpoint of endpoints) {
        try {
          const response = await fetch(`${SUPABASE_URL}${endpoint}`, {
            method: 'POST',
            headers: {
              'apikey': SUPABASE_ANON_KEY,
              'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify(request)
          });
          
          console.log(`     ${endpoint}: 状态码 ${response.status}`);
          
          if (response.status !== 404) {
            const responseText = await response.text();
            console.log(`     响应长度: ${responseText.length} 字符`);
          }
          
        } catch (error) {
          console.log(`     ❌ ${endpoint}: ${error.message}`);
        }
      }
      
    } catch (error) {
      console.log(`   ❌ MCP 请求 ${index + 1} 失败: ${error.message}`);
    }
  }
  console.log('');
}

// 主函数
async function main() {
  // Node.js 环境需要 fetch polyfill
  if (typeof fetch === 'undefined') {
    try {
      const { default: fetch } = await import('node-fetch');
      global.fetch = fetch;
      console.log('✅ 已加载 node-fetch\n');
    } catch (error) {
      console.log('❌ 无法加载 node-fetch，请运行: npm install node-fetch');
      process.exit(1);
    }
  }
  
  await testMCPScenarios();
  
  console.log('🏁 详细 MCP 连接状态检查完成\n');
  
  console.log('📋 分析建议:');
  console.log('1. 如果所有标准请求都成功，但 MCP 仍然失败，问题可能在 MCP 客户端');
  console.log('2. 如果超时测试显示网络不稳定，考虑增加 MCP 超时设置');
  console.log('3. 如果认证请求失败，检查 API 密钥配置');
  console.log('4. 如果连接稳定性差，可能是网络环境问题');
  console.log('5. MCP 可能需要特定的端点或请求格式');
}

main().catch(console.error);