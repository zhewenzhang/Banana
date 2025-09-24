/**
 * 测试唱片点击跳转的参数传递和数据映射
 * 验证首页点击唱片后，详情页是否显示正确的唱片信息
 */

console.log('=== 唱片点击跳转参数传递测试 ===\n');

// 模拟首页的唱片数据（来自MusicApiService的FALLBACK_RECORDS）
const homePageRecords = [
  {
    id: '249504',
    title: 'After Hours',
    artist: 'The Weeknd',
    image: 'https://i.scdn.co/image/ab67616d0000b273ef6f049cce6fcc59a6e52233',
    year: 2020
  },
  {
    id: '9823525',
    title: '÷ (Divide)',
    artist: 'Ed Sheeran',
    image: 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96',
    year: 2017
  },
  {
    id: '4262072',
    title: 'A Night At The Opera',
    artist: 'Queen',
    image: 'https://i.scdn.co/image/ab67616d0000b273ce4f1737bc8a646c8c4bd25a',
    year: 1975
  },
  {
    id: '1218307',
    title: 'Hotel California',
    artist: 'Eagles',
    image: 'https://i.scdn.co/image/ab67616d0000b2734637341b9f507521afa9a778',
    year: 1976
  }
];

// 模拟详情页的数据映射（来自RecordDetail.ets的mockDataMap）
const detailPageMapping = {
  '249504': {
    title: 'After Hours',
    artist: 'The Weeknd',
    year: '2020',
    genres: ['Pop', 'Synthwave'],
    image: 'https://i.scdn.co/image/ab67616d0000b273ef6f049cce6fcc59a6e52233'
  },
  '9823525': {
    title: '÷ (Divide)',
    artist: 'Ed Sheeran',
    year: '2017',
    genres: ['Pop', 'Folk'],
    image: 'https://i.scdn.co/image/ab67616d0000b273ba5db46f4b838ef6027e6f96'
  },
  '4262072': {
    title: 'A Night At The Opera',
    artist: 'Queen',
    year: '1975',
    genres: ['Rock', 'Progressive Rock'],
    image: 'https://i.scdn.co/image/ab67616d0000b273ce4f1737bc8a646c8c4bd25a'
  },
  '1218307': {
    title: 'Hotel California',
    artist: 'Eagles',
    year: '1976',
    genres: ['Rock', 'Country Rock'],
    image: 'https://i.scdn.co/image/ab67616d0000b2734637341b9f507521afa9a778'
  }
};

console.log('1. 参数传递流程测试:');
console.log('   首页 onRecordClick 方法传递的参数:');
console.log('   - recordId: record.id (string类型)');
console.log('   - recordName: record.title');
console.log('   - artistName: record.artist');
console.log('   - imageUrl: record.image');
console.log('');

console.log('2. 详情页参数接收测试:');
console.log('   RecordDetail.aboutToAppear() 方法:');
console.log('   - 获取 router.getParams()');
console.log('   - 提取 params.recordId as string');
console.log('   - 调用 loadRecordDetail()');
console.log('');

console.log('3. 数据映射一致性检查:');
let allMatched = true;
homePageRecords.forEach((homeRecord, index) => {
  const detailData = detailPageMapping[homeRecord.id];
  
  console.log(`   ${index + 1}. 唱片ID: ${homeRecord.id}`);
  console.log(`      首页显示: ${homeRecord.title} - ${homeRecord.artist}`);
  
  if (detailData) {
    console.log(`      详情页映射: ${detailData.title} - ${detailData.artist}`);
    
    // 检查标题和艺术家是否匹配
    const titleMatch = homeRecord.title === detailData.title;
    const artistMatch = homeRecord.artist === detailData.artist;
    
    if (titleMatch && artistMatch) {
      console.log(`      ✅ 匹配正确`);
    } else {
      console.log(`      ❌ 匹配错误:`);
      if (!titleMatch) console.log(`         - 标题不匹配: "${homeRecord.title}" vs "${detailData.title}"`);
      if (!artistMatch) console.log(`         - 艺术家不匹配: "${homeRecord.artist}" vs "${detailData.artist}"`);
      allMatched = false;
    }
  } else {
    console.log(`      ❌ 详情页缺少ID "${homeRecord.id}" 的映射数据`);
    allMatched = false;
  }
  console.log('');
});

console.log('4. 潜在问题分析:');
if (allMatched) {
  console.log('   ✅ 数据映射完全一致，理论上应该显示正确的唱片信息');
  console.log('');
  console.log('   如果仍然显示错误的内容，可能的原因:');
  console.log('   1. 参数传递过程中类型转换问题');
  console.log('   2. loadRecordDetail() 方法中的API调用逻辑');
  console.log('   3. loadMockDetail() 方法中的默认值逻辑');
  console.log('   4. UI渲染时的数据绑定问题');
} else {
  console.log('   ❌ 发现数据映射不一致的问题');
  console.log('   建议检查并修复上述不匹配的数据');
}
console.log('');

console.log('5. 调试建议:');
console.log('   1. 在 onRecordClick 方法中添加 console.log 输出传递的参数');
console.log('   2. 在 RecordDetail.aboutToAppear 中添加 console.log 输出接收的参数');
console.log('   3. 在 loadMockDetail 方法中添加 console.log 输出选择的数据');
console.log('   4. 检查 recordId 的类型是否在传递过程中发生变化');
console.log('');

console.log('6. 测试流程模拟:');
homePageRecords.forEach((record, index) => {
  console.log(`   测试 ${index + 1}: 点击 "${record.title}"`);
  console.log(`   → 传递参数: recordId="${record.id}"`);
  console.log(`   → 详情页接收: this.recordId="${record.id}"`);
  console.log(`   → 数据映射: mockDataMap["${record.id}"]`);
  
  const expectedData = detailPageMapping[record.id];
  if (expectedData) {
    console.log(`   → 期望显示: ${expectedData.title} - ${expectedData.artist}`);
  }
  console.log('');
});

console.log('✅ 测试完成！请根据上述分析结果进行调试。');