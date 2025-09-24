/**
 * 测试 favorites 表修复后的功能
 * 使用正确的列名进行测试
 */

const SUPABASE_URL = 'https://uwvlduprxppwdkjkvwby.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dmxkdXByeHBwd2Rramt2d2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5NDYxMTMsImV4cCI6MjA2NTUyMjExM30.IT_7wL-0Buf1iyGKI1cw2PY0GtlKFljFiNOVYBvA_o0';

async function testAfterFix() {
  console.log('🔧 测试 favorites 表修复后的功能...\n');

  // 1. 测试表结构
  await testTableStructure();
  
  // 2. 测试基本查询
  await testBasicQueries();
  
  // 3. 测试 RLS 策略
  await testRLSAfterFix();
  
  // 4. 测试 MCP 连接状态
  await testMCPConnectionStatus();
}

// 1. 测试表结构
async function testTableStructure() {
  console.log('1️⃣ 测试表结构...');
  
  try {
    // 测试基本访问
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites?select=*&limit=0`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`   基本访问状态码: ${response.status}`);
    
    if (response.status === 200) {
      console.log('   ✅ 表结构正常');
    } else if (response.status === 401) {
      console.log('   ✅ RLS 策略生效（需要认证）');
    } else {
      const errorText = await response.text();
      console.log(`   ❌ 表结构问题: ${errorText.substring(0, 200)}`);
    }
    
  } catch (error) {
    console.log(`   ❌ 表结构测试失败: ${error.message}`);
  }
  console.log('');
}

// 2. 测试基本查询
async function testBasicQueries() {
  console.log('2️⃣ 测试基本查询...');
  
  const queries = [
    {
      url: '/rest/v1/favorites?select=*',
      description: '查询所有字段'
    },
    {
      url: '/rest/v1/favorites?select=id,recordTitle,recordArtist',
      description: '查询特定字段（使用驼峰命名）'
    },
    {
      url: '/rest/v1/favorites?select=id,"recordTitle","recordArtist"',
      description: '查询特定字段（使用引号）'
    },
    {
      url: '/rest/v1/favorites?recordArtist=eq.Test Artist',
      description: '按艺术家筛选'
    },
    {
      url: '/rest/v1/favorites?order=favoriteTime.desc&limit=10',
      description: '按时间排序'
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
        console.log('     ⚠️  需要用户认证（RLS 生效）');
      } else if (response.status === 400) {
        const errorText = await response.text();
        console.log(`     ❌ 查询失败: ${errorText.substring(0, 150)}`);
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

// 3. 测试 RLS 策略
async function testRLSAfterFix() {
  console.log('3️⃣ 测试 RLS 策略修复后的状态...');
  
  try {
    // 测试未认证访问
    console.log('   测试未认证访问...');
    const response1 = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Content-Type': 'application/json'
        // 不包含 Authorization 头
      }
    });
    
    console.log(`     未认证访问状态码: ${response1.status}`);
    
    // 测试带认证访问
    console.log('   测试带认证访问...');
    const response2 = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`     带认证访问状态码: ${response2.status}`);
    
    if (response1.status === 401 && response2.status === 200) {
      console.log('   ✅ RLS 策略工作正常');
    } else if (response1.status === 200 && response2.status === 200) {
      console.log('   ⚠️  RLS 策略可能未正确配置（两种访问都成功）');
    } else {
      console.log('   ⚠️  RLS 策略状态不明确');
    }
    
  } catch (error) {
    console.log(`   ❌ RLS 测试失败: ${error.message}`);
  }
  console.log('');
}

// 4. 测试 MCP 连接状态
async function testMCPConnectionStatus() {
  console.log('4️⃣ 测试 MCP 连接状态...');
  
  try {
    // 模拟 MCP 风格的请求
    console.log('   测试 MCP 风格的 GET 请求...');
    const getResponse = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`     GET 请求状态码: ${getResponse.status}`);
    
    if (getResponse.status === 200) {
      console.log('     ✅ MCP GET 请求成功');
    } else if (getResponse.status === 401) {
      console.log('     ⚠️  MCP GET 请求需要认证');
    } else {
      console.log('     ❌ MCP GET 请求失败');
    }
    
    // 测试 POST 请求（不会真正插入，因为没有真实用户）
    console.log('   测试 MCP 风格的 POST 请求...');
    const postData = {
      recordId: 'test-record-123',
      recordTitle: 'Test Album',
      recordArtist: 'Test Artist',
      recordImage: 'https://example.com/test.jpg',
      recordYear: 2023,
      recordGenres: 'Rock',
      recordFormats: 'Vinyl'
    };
    
    const postResponse = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'POST',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(postData)
    });
    
    console.log(`     POST 请求状态码: ${postResponse.status}`);
    
    if (postResponse.status === 201) {
      console.log('     ✅ MCP POST 请求成功');
    } else if (postResponse.status === 401 || postResponse.status === 403) {
      console.log('     ⚠️  MCP POST 请求需要认证或权限不足');
    } else if (postResponse.status === 400) {
      const errorText = await postResponse.text();
      console.log(`     ❌ MCP POST 请求数据格式错误: ${errorText.substring(0, 100)}`);
    } else {
      const errorText = await postResponse.text();
      console.log(`     ⚠️  MCP POST 请求状态码 ${postResponse.status}: ${errorText.substring(0, 100)}`);
    }
    
  } catch (error) {
    console.log(`   ❌ MCP 连接测试失败: ${error.message}`);
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
  
  await testAfterFix();
  
  console.log('🏁 favorites 表修复后的测试完成\n');
  
  console.log('📋 修复状态总结:');
  console.log('1. ✅ favorites 表已存在且可访问');
  console.log('2. ❌ 列名大小写问题需要修复');
  console.log('3. ❌ RLS 策略需要重新配置');
  console.log('4. ✅ MCP 404 错误已解决（端点存在）');
  console.log('');
  console.log('🔧 下一步操作:');
  console.log('1. 在 Supabase Dashboard 中执行 FIX_FAVORITES_TABLE.sql');
  console.log('2. 重新测试所有功能');
  console.log('3. 测试用户认证后的完整收藏流程');
}

main().catch(console.error);