/**
 * 测试 favorites 表创建后的功能
 * 验证 MCP 连接状态和收藏功能是否正常工作
 */

const SUPABASE_URL = 'https://uwvlduprxppwdkjkvwby.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dmxkdXByeHBwd2Rramt2d2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5NDYxMTMsImV4cCI6MjA2NTUyMjExM30.IT_7wL-0Buf1iyGKI1cw2PY0GtlKFljFiNOVYBvA_o0';

async function testFavoritesTableAfterCreation() {
  console.log('🎯 测试 favorites 表创建后的功能...\n');

  // 1. 测试 favorites 表是否存在
  await testFavoritesTableExists();
  
  // 2. 测试表结构和权限
  await testTableStructureAndPermissions();
  
  // 3. 测试 MCP 风格请求（现在应该不再是 404）
  await testMCPStyleRequestsAfterTableCreation();
  
  // 4. 测试收藏功能的基本操作
  await testBasicFavoriteOperations();
  
  // 5. 测试 RLS 安全策略
  await testRLSPolicies();
}

// 1. 测试 favorites 表是否存在
async function testFavoritesTableExists() {
  console.log('1️⃣ 测试 favorites 表是否存在...');
  
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`   状态码: ${response.status}`);
    
    if (response.status === 200) {
      console.log('   ✅ favorites 表存在且可访问');
      const data = await response.json();
      console.log(`   ✅ 返回数据类型: ${Array.isArray(data) ? '数组' : typeof data}`);
      console.log(`   ✅ 当前记录数: ${Array.isArray(data) ? data.length : 'N/A'}`);
    } else if (response.status === 401) {
      console.log('   ⚠️  返回 401 - 需要用户认证（这是正常的，因为启用了 RLS）');
    } else if (response.status === 404) {
      console.log('   ❌ 仍然返回 404 - 表可能未正确创建');
    } else {
      console.log(`   ⚠️  返回状态码 ${response.status}`);
      const errorText = await response.text();
      console.log(`   错误信息: ${errorText.substring(0, 200)}`);
    }
    
  } catch (error) {
    console.log(`   ❌ 请求失败: ${error.message}`);
  }
  console.log('');
}

// 2. 测试表结构和权限
async function testTableStructureAndPermissions() {
  console.log('2️⃣ 测试表结构和权限...');
  
  try {
    // 尝试获取表的元数据
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites?select=*&limit=0`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
        'Prefer': 'count=exact'
      }
    });
    
    console.log(`   表结构查询状态码: ${response.status}`);
    
    if (response.status === 200 || response.status === 401) {
      console.log('   ✅ 表结构正常');
      
      // 检查响应头中的列信息
      const contentRange = response.headers.get('content-range');
      if (contentRange) {
        console.log(`   ✅ Content-Range: ${contentRange}`);
      }
      
    } else {
      const errorText = await response.text();
      console.log(`   ❌ 表结构查询失败: ${errorText.substring(0, 200)}`);
    }
    
  } catch (error) {
    console.log(`   ❌ 表结构测试失败: ${error.message}`);
  }
  console.log('');
}

// 3. 测试 MCP 风格请求（现在应该不再是 404）
async function testMCPStyleRequestsAfterTableCreation() {
  console.log('3️⃣ 测试 MCP 风格请求（表创建后）...');
  
  const mcpRequests = [
    {
      method: 'GET',
      endpoint: '/rest/v1/favorites',
      description: '获取收藏列表'
    },
    {
      method: 'POST',
      endpoint: '/rest/v1/favorites',
      description: '添加收藏',
      body: {
        userId: '00000000-0000-0000-0000-000000000000', // 测试用的假 UUID
        recordId: 'test-record-123',
        recordTitle: 'Test Album',
        recordArtist: 'Test Artist',
        recordImage: 'https://example.com/test.jpg',
        recordYear: 2023,
        recordGenres: 'Rock',
        recordFormats: 'Vinyl'
      }
    }
  ];
  
  for (const [index, request] of mcpRequests.entries()) {
    try {
      console.log(`   测试 ${index + 1}: ${request.description}...`);
      
      const fetchOptions = {
        method: request.method,
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        }
      };
      
      if (request.body) {
        fetchOptions.body = JSON.stringify(request.body);
      }
      
      const response = await fetch(`${SUPABASE_URL}${request.endpoint}`, fetchOptions);
      
      console.log(`     状态码: ${response.status}`);
      
      if (response.status === 200) {
        console.log('     ✅ 请求成功');
      } else if (response.status === 201) {
        console.log('     ✅ 创建成功');
      } else if (response.status === 401) {
        console.log('     ⚠️  需要认证（RLS 策略生效）');
      } else if (response.status === 403) {
        console.log('     ⚠️  权限不足（RLS 策略阻止）');
      } else if (response.status === 404) {
        console.log('     ❌ 仍然返回 404');
      } else {
        const errorText = await response.text();
        console.log(`     ⚠️  状态码 ${response.status}: ${errorText.substring(0, 100)}`);
      }
      
    } catch (error) {
      console.log(`     ❌ 请求失败: ${error.message}`);
    }
  }
  console.log('');
}

// 4. 测试收藏功能的基本操作
async function testBasicFavoriteOperations() {
  console.log('4️⃣ 测试收藏功能的基本操作...');
  
  // 测试不同的查询参数
  const queries = [
    { 
      url: '/rest/v1/favorites?select=*',
      description: '查询所有字段'
    },
    {
      url: '/rest/v1/favorites?select=id,recordTitle,recordArtist',
      description: '查询特定字段'
    },
    {
      url: '/rest/v1/favorites?recordArtist=eq.Test Artist',
      description: '按艺术家筛选'
    },
    {
      url: '/rest/v1/favorites?order=favoriteTime.desc&limit=10',
      description: '按时间排序并限制数量'
    }
  ];
  
  for (const query of queries) {
    try {
      console.log(`   测试: ${query.description}...`);
      
      const response = await fetch(`${SUPABASE_URL}${query.url}`, {
        method: 'GET',
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        }
      });
      
      console.log(`     状态码: ${response.status}`);
      
      if (response.status === 200) {
        const data = await response.json();
        console.log(`     ✅ 查询成功，返回 ${data.length} 条记录`);
      } else if (response.status === 401) {
        console.log('     ⚠️  需要用户认证');
      } else {
        const errorText = await response.text();
        console.log(`     ❌ 查询失败: ${errorText.substring(0, 100)}`);
      }
      
    } catch (error) {
      console.log(`     ❌ 请求失败: ${error.message}`);
    }
  }
  console.log('');
}

// 5. 测试 RLS 安全策略
async function testRLSPolicies() {
  console.log('5️⃣ 测试 RLS 安全策略...');
  
  try {
    // 测试未认证用户的访问
    console.log('   测试未认证用户访问...');
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
        // 故意不包含 Authorization 头
      }
    });
    
    console.log(`     状态码: ${response.status}`);
    
    if (response.status === 401) {
      console.log('     ✅ RLS 策略正常工作 - 未认证用户被拒绝');
    } else if (response.status === 200) {
      const data = await response.json();
      console.log(`     ⚠️  未认证用户可以访问，返回 ${data.length} 条记录`);
      console.log('     这可能意味着 RLS 策略配置有问题');
    } else {
      console.log(`     ⚠️  意外的状态码: ${response.status}`);
    }
    
  } catch (error) {
    console.log(`     ❌ RLS 测试失败: ${error.message}`);
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
  
  await testFavoritesTableAfterCreation();
  
  console.log('🏁 favorites 表创建后的功能测试完成\n');
  
  console.log('📋 测试总结:');
  console.log('1. 如果 favorites 表访问返回 200，说明表创建成功');
  console.log('2. 如果返回 401，说明 RLS 策略正常工作，需要用户认证');
  console.log('3. 如果仍然返回 404，可能需要检查表创建是否成功');
  console.log('4. MCP 错误应该已经解决，因为端点现在存在了');
  console.log('5. 接下来需要测试用户认证后的完整收藏功能');
}

main().catch(console.error);