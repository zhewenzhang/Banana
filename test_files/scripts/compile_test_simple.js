const fs = require('fs');
const path = require('path');

// 检查Index.ets文件的语法问题
function checkIndexFile() {
  const filePath = path.join(__dirname, '../../entry/src/main/ets/pages/Index.ets');
  
  if (!fs.existsSync(filePath)) {
    console.log('❌ Index.ets文件不存在');
    return false;
  }
  
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  
  console.log('🔍 检查Index.ets文件语法...');
  
  // 检查大括号匹配
  let braceCount = 0;
  let hasError = false;
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;
    
    // 计算大括号
    const openBraces = (line.match(/\{/g) || []).length;
    const closeBraces = (line.match(/\}/g) || []).length;
    braceCount += openBraces - closeBraces;
    
    // 检查LengthMetrics使用
    if (line.includes('LengthMetrics') && !line.includes('//')) {
      console.log(`⚠️  第${lineNum}行可能存在LengthMetrics使用问题: ${line.trim()}`);
      hasError = true;
    }
    
    // 只检查Flex组件的space属性数字赋值问题
    if (line.includes('Flex(') && line.includes('space:') && line.includes('{') && /:\s*\d+/.test(line)) {
      console.log(`⚠️  第${lineNum}行Flex组件space属性使用数字可能有问题: ${line.trim()}`);
      hasError = true;
    }
    
    // 检查对象字面量类型标注
    if (line.includes('.map(') && !line.includes('):') && line.includes('=> ({')) {
      console.log(`⚠️  第${lineNum}行map函数可能缺少类型标注: ${line.trim()}`);
      hasError = true;
    }
  }
  
  // 检查大括号平衡
  if (braceCount !== 0) {
    console.log(`❌ 大括号不匹配，差值: ${braceCount}`);
    hasError = true;
  }
  
  // 检查文件结构完整性
  if (!content.includes('@Entry') || !content.includes('@Component') || !content.includes('build()')) {
    console.log('❌ 文件结构不完整，缺少必要的装饰器或build方法');
    hasError = true;
  }
  
  if (!hasError) {
    console.log('✅ 语法检查通过，未发现明显问题');
    return true;
  } else {
    console.log('❌ 发现语法问题，需要修复');
    return false;
  }
}

// 运行检查
const result = checkIndexFile();
process.exit(result ? 0 : 1);