# Release v1.0.0 — 化工安全设施设计专篇评审诊断技能首发

## 🎉 首次发布

对标政府专家上会审查水平的化工建设项目"安全设施设计专篇"专家级评审诊断技能。

## ✨ 核心特性

### 三层证据架构
- **L1**: WeKnora 内网规范库 (向量+关键词混合检索) — 优先
- **L2**: 本地规范库全文检索 (150本标准markdown) — 断网兜底
- **L3**: 内置锚点卡 (高频硬值精选,值标 `[需复核]`) — 最后兜底

**断网/API不可用时自动降级,无需手动切换。**

### M1–M7 强制工序
- M1: 全文落盘可检索 (表格全量,禁止抽查)
- M2: 计算复核留痕台账 (可执行计算)
- M3: 法规时效搜索复核 (诊断当天核每本标准现行有效性)
- M4: 程序要件清单核查
- M5: 跨文种联动 (安评/环评错误沿传排查)
- M6: 评审标尺事前声明
- M7: 问题映射与颗粒度

### 十步工作流 + 9条专有清单 + 6条红线
- 十步: 预处理 → 定性 → 探测 → 完整性 → 辨识+映射 → 符合性 → 计算 → 闭环 → 意见 → 输出
- 9条: 跨文种互锁/评审闭环失信/重大危险源变更/辨识规则/储量多口径/意见子项/法定清单/配伍混存/编辑质量
- 6条红线: 两文种同错≠互证/空表识别/模板残留/几何可行性/辨识分母假设/证据自省

## 📦 包含文件

```
chem-safety-design-review/
├── SKILL.md                          主入口
├── README.md                         完整使用说明
├── CHANGELOG.md                      版本记录
├── LICENSE                           MIT许可证
├── .gitignore                        Git忽略规则
├── scripts/
│   └── weknora_probe.sh              证据探测+检索封装
└── references/
    ├── regulation-index.md           150本标准索引
    ├── checklist-completeness.md     章节完整性 (AQ3066+39号并轨)
    ├── standard-anchors.md           10类设施标准锚点
    ├── calc-cards.md                 7张计算复核公式卡
    └── output-templates.md           12套输出模板
```

## 🚀 快速开始

### 1. 配置证据层 (可选)

```bash
# L1: WeKnora内网规范库 (优先)
export WEKNORA_BASE_URL="https://your-host/api/v1"
export WEKNORA_API_KEY="your-key"
export WEKNORA_KB_IDS="kb-id-1,kb-id-2"

# L2: 本地规范库 (断网兜底)
export CHEM_STD_LIB="/path/to/documents"
```

### 2. 探测并检索

```bash
source scripts/weknora_probe.sh
chem_probe  # 输出: 本次证据等级: L1/L2/L3
chem_search "GBT50493 探测器 水平距离"
```

### 3. 开始诊断
遵循 `SKILL.md` 十步工作流,按需加载 `references/` 各文件。

## 📊 标准依据

- **AQ 3066-2025** (2026-07-01实施) / 安监总厅管三〔2013〕39号
- **150本标准**: 化工36/建筑消防37/电力管道27/给排水暖通4/综合37/设备9
- 核心计算: GBT50483 (事故水) / GB50974 (消防水) / GBT50493 (气体检测) / GB18218 (重大危险源) / GBT37243 (外部防护距离)

## 🔍 A/B/C缺陷分级

| 分级 | 定义 | 典型示例 |
|------|------|----------|
| **A类** (否决性) | 颠覆性错误 | 精细化工错用石油化工标准/辨识计算错误/核心设施缺失/无审查意见书 |
| **B类** (重要) | 影响结论准确性 | 数据闭环断裂/计算偏差/图文不一致 |
| **C类** (一般) | 编辑质量 | 错字/编号/单位缺失/目录空挂 |

## ⚠️ 重要声明

**本技能仅作专篇评审辅助诊断,不替代具有相应资质的注册安全工程师/化工工程师的专业判断。** 诊断结论应由具备执业资格的专业人员复核确认后方可用于正式评审意见。

## 📝 许可证

[MIT License](LICENSE)

## 🙏 致谢

感谢所有为化工安全规范体系建设贡献的专家与从业者。

---

**下载**: [chem-safety-design-review-v1.0.0.zip](https://github.com/your-org/chem-safety-design-review/archive/refs/tags/v1.0.0.zip)

**问题反馈**: [Issues](https://github.com/your-org/chem-safety-design-review/issues)
