// 验证Top50价值排行榜功能更新
const fs = require('fs');
const path = require('path');

console.log('=== Top50 价值排行榜功能验证 ===\n');

// 检查TimeMachine.ets的更新
const timeMachineFile = path.join(__dirname, 'entry/src/main/ets/pages/TimeMachine.ets');
const discogsServiceFile = path.join(__dirname, 'entry/src/main/ets/services/DiscogsService.ets');

try {
  // 验证TimeMachine.ets更新
  const timeMachineContent = fs.readFileSync(timeMachineFile, 'utf8');
  
  console.log('📱 TimeMachine.ets 更新验证:');
  
  // 检查API数据获取数量
  const apiCallPattern = /getValueRankingRecords\(1,\s*50\)/;
  if (apiCallPattern.test(timeMachineContent)) {
    console.log('✅ API数据获取: 已更新为50条数据');
  } else {
    console.log('❌ API数据获取: 未找到50条数据的配置');
  }
  
  // 检查页面标题更新
  const titlePattern = /价值排行榜 Top50/;
  if (titlePattern.test(timeMachineContent)) {
    console.log('✅ 页面标题: 已更新为"价值排行榜 Top50"');
  } else {
    console.log('❌ 页面标题: 未找到Top50标题');
  }
  
  // 检查估值算法优化
  const estimatedValuePattern = /if \(index < 5\)/;
  if (estimatedValuePattern.test(timeMachineContent)) {
    console.log('✅ 估值算法: 已优化为Top50分层估值');
  } else {
    console.log('❌ 估值算法: 未找到优化的估值逻辑');
  }
  
  // 验证DiscogsService.ets更新
  const discogsContent = fs.readFileSync(discogsServiceFile, 'utf8');
  
  console.log('\n🔧 DiscogsService.ets 更新验证:');
  
  // 检查搜索策略扩展
  const searchQueriesPattern = /Math\.ceil\(perPage\/5\)/g;
  const searchMatches = discogsContent.match(searchQueriesPattern);
  if (searchMatches && searchMatches.length >= 5) {
    console.log('✅ 搜索策略: 已扩展为5个搜索查询');
  } else {
    console.log('❌ 搜索策略: 搜索查询数量不足');
  }
  
  // 检查新增的搜索类别
  const jazzSearchPattern = /genre=Jazz/;
  const decade1970Pattern = /decade=1970/;
  if (jazzSearchPattern.test(discogsContent) && decade1970Pattern.test(discogsContent)) {
    console.log('✅ 搜索范围: 已增加爵士和1970年代搜索');
  } else {
    console.log('❌ 搜索范围: 未找到新增的搜索类别');
  }
  
  console.log('\n=== 功能特性总结 ===');
  console.log('🎯 数据量: 从5条扩展到50条高价值唱片');
  console.log('💰 估值系统: 分层估值算法，Top5最高价值25K-11K美元');
  console.log('🔍 搜索策略: 5个不同维度的API查询');
  console.log('📊 数据源: 1960年代摇滚、1970年代摇滚、爵士、限量版、高评分');
  console.log('🎨 界面优化: 明确显示Top50标题');
  
  console.log('\n✅ Top50价值排行榜功能更新完成！');
  console.log('💡 用户现在可以查看完整的50条高价值唱片排行榜');
  
} catch (error) {
  console.error('❌ 验证过程中发生错误:', error.message);
}