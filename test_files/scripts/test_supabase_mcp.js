/**
 * Supabase MCP 连接测试脚本
 * 用于诊断 MCP error -32603: fetch failed 问题
 */

const https = require('https');
const { URL } = require('url');

// Supabase 配置
const SUPABASE_URL = 'https://uwvlduprxppwdkjkvwby.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dmxkdXByeHBwd2Rramt2d2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5NDYxMTMsImV4cCI6MjA2NTUyMjExM30.IT_7wL-0Buf1iyGKI1cw2PY0GtlKFljFiNOVYBvA_o0';

// 测试函数
async function testSupabaseConnection() {
  console.log('🔍 开始 Supabase MCP 连接诊断...\n');
  
  // 测试 1: 基础连接测试
  console.log('1️⃣ 测试基础连接...');
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      console.log('✅ 基础连接成功');
      console.log(`   状态码: ${response.status}`);
      console.log(`   状态文本: ${response.statusText}`);
    } else {
      console.log('❌ 基础连接失败');
      console.log(`   状态码: ${response.status}`);
      console.log(`   状态文本: ${response.statusText}`);
    }
  } catch (error) {
    console.log('❌ 基础连接异常');
    console.log(`   错误类型: ${error.name}`);
    console.log(`   错误信息: ${error.message}`);
    
    // 详细错误分析
    if (error.code) {
      console.log(`   错误代码: ${error.code}`);
    }
    if (error.cause) {
      console.log(`   错误原因: ${error.cause}`);
    }
  }
  
  console.log('');
  
  // 测试 2: 认证端点测试
  console.log('2️⃣ 测试认证端点...');
  try {
    const response = await fetch(`${SUPABASE_URL}/auth/v1/settings`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      console.log('✅ 认证端点连接成功');
      const data = await response.json();
      console.log(`   返回数据长度: ${JSON.stringify(data).length} 字符`);
    } else {
      console.log('❌ 认证端点连接失败');
      console.log(`   状态码: ${response.status}`);
    }
  } catch (error) {
    console.log('❌ 认证端点连接异常');
    console.log(`   错误信息: ${error.message}`);
  }
  
  console.log('');
  
  // 测试 3: 网络延迟测试
  console.log('3️⃣ 测试网络延迟...');
  const startTime = Date.now();
  try {
    const response = await fetch(`${SUPABASE_URL}/rest/v1/`, {
      method: 'HEAD',
      headers: {
        'apikey': SUPABASE_ANON_KEY
      }
    });
    
    const endTime = Date.now();
    const latency = endTime - startTime;
    
    console.log(`✅ 网络延迟: ${latency}ms`);
    
    if (latency > 5000) {
      console.log('⚠️  网络延迟较高，可能导致 MCP 超时');
    } else if (latency > 2000) {
      console.log('⚠️  网络延迟偏高');
    } else {
      console.log('✅ 网络延迟正常');
    }
  } catch (error) {
    console.log('❌ 网络延迟测试失败');
    console.log(`   错误信息: ${error.message}`);
  }
  
  console.log('');
  
  // 测试 4: DNS 解析测试
  console.log('4️⃣ 测试 DNS 解析...');
  try {
    const url = new URL(SUPABASE_URL);
    console.log(`✅ URL 解析成功`);
    console.log(`   主机名: ${url.hostname}`);
    console.log(`   协议: ${url.protocol}`);
    console.log(`   端口: ${url.port || '默认'}`);
  } catch (error) {
    console.log('❌ URL 解析失败');
    console.log(`   错误信息: ${error.message}`);
  }
  
  console.log('');
  
  // 测试 5: 模拟 MCP 请求
  console.log('5️⃣ 模拟 MCP 风格请求...');
  try {
    // 模拟一个可能导致 MCP 错误的请求
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10秒超时
    
    const response = await fetch(`${SUPABASE_URL}/rest/v1/favorites`, {
      method: 'GET',
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      signal: controller.signal
    });
    
    clearTimeout(timeoutId);
    
    console.log(`✅ MCP 风格请求完成`);
    console.log(`   状态码: ${response.status}`);
    
    if (response.status === 404) {
      console.log('ℹ️  返回 404 - 这是正常的，因为 favorites 表可能不存在');
    }
    
  } catch (error) {
    console.log('❌ MCP 风格请求失败');
    console.log(`   错误类型: ${error.name}`);
    console.log(`   错误信息: ${error.message}`);
    
    if (error.name === 'AbortError') {
      console.log('⚠️  请求超时 - 这可能是 MCP fetch failed 的原因');
    }
  }
  
  console.log('\n🏁 诊断完成');
  
  // 总结和建议
  console.log('\n📋 诊断总结和建议:');
  console.log('1. 如果基础连接失败，检查网络连接和防火墙设置');
  console.log('2. 如果网络延迟过高，考虑网络优化或使用代理');
  console.log('3. 如果出现超时错误，增加 MCP 客户端的超时设置');
  console.log('4. 确保 Supabase 项目状态正常，没有被暂停或删除');
  console.log('5. 检查 API 密钥是否正确且未过期');
}

// 运行测试
async function main() {
  // Node.js 环境需要 fetch polyfill
  if (typeof fetch === 'undefined') {
    try {
      const { default: fetch } = await import('node-fetch');
      global.fetch = fetch;
      console.log('✅ 已加载 node-fetch');
    } catch (error) {
      console.log('❌ 无法加载 node-fetch，请运行: npm install node-fetch');
      process.exit(1);
    }
  }
  
  await testSupabaseConnection();
}

main().catch(console.error);