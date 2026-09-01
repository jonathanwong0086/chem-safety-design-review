# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-01

### Added

#### 核心方法论
- 三层证据架构 (L1 WeKnora API → L2 本地规范库全文检索 → L3 内置锚点卡)，支持断网自动降级
- M1–M7 强制执行工序 (全文落盘/计算留痕/法规时效/程序要件/跨文种联动/评审标尺/问题映射)
- 十步工作流：预处理落盘 → 文种定性 → 证据探测 → 章节完整性 → 危险辨识+设施映射 → 设施符合性 → 计算复核 → 数据闭环 → 意见闭环 → A/B/C 输出
- R1–R6 修订稿/意见回复复核规则 (回应具体化/禁空话/答须对题/附件实证/全文联动/改后重扫)
- 9 条专篇专有核查清单 (高频缺陷模式)
- 中试专篇特有要点 (小试总结/放大论证/机械化换人/依托设施前置条件)
- 诊断红线 6 条 (两文种同错/空表识别/模板残留/几何可行性/证据自省)

#### 参考文件体系
- `references/regulation-index.md`: 150 本标准索引 (化工 36/建筑消防 37/电力管道 27/给排水暖通 4/综合基础 37/设备材料 9)，分 6 大专业，含 doc_id/版本年/名称/检索关键词
- `references/checklist-completeness.md`: AQ 3066-2025 + 39号导则并轨章节完整性要件表，齐备/缺项/不适用三态判据，4.1–4.12 设施类逐章
- `references/standard-anchors.md`: 10 类设施标准锚点库 (防火间距/气体检测/供配电/SIS-SIL/防雷防静电/消防/事故水/外部防护距离/储罐/特种设备)，含适用标准/检索关键词/高频错误/内置锚点值。GBT50493 气体检测器布点距离等真实条款值已从标准原文提取并标 `[原文核校]`
- `references/calc-cards.md`: 7 张计算复核公式卡 (事故水池 GBT50483-6.6/消防水量/气体探测器布点/氮气仪表风/储量几何上限/重大危险源 GB18218/外部防护距离 GBT37243)
- `references/output-templates.md`: 12 套输出模板 (项目画像卡/章节完整性表/危险-设施映射矩阵/设施符合性矩阵/关键计算独立复核表/数据一致性问题清单/意见落实闭环核查表/问题映射表/法规时效核查留痕表/程序要件核查表/A/B/C 分级缺陷清单/通过性三档结论)

#### 脚本与工具
- `scripts/weknora_probe.sh`: 证据层探测 + 三层检索封装，导出 `EVIDENCE_LEVEL`，提供 `chem_probe`/`chem_search`/`wk_api`/`wk_search`/`wk_hybrid` 函数，支持 source 复用

#### 标准依据
- 主轴标准: AQ 3066-2025 (2026-07-01 实施) / 安监总厅管三〔2013〕39号 (历史主依据并轨对照)
- 核心计算: GBT50483-2019 (事故水)、GB50974 (消防水)、GBT50493-2019 (气体检测)、GB18218 (重大危险源)、GBT37243-2019 (外部防护距离)
- 设施符合性: GB51283/GB50160 (防火标准行业属性匹配)、GB55037/GB55036 (强制性通用规范)、AQT3033-2022 (安全设计管理/SIL 定级)、应急〔2022〕52号 (首次工业化)

### 设计特性
- **WeKnora 兼容性协议**: 优先委托 weknora skill 完成检索 (职责分离)，weknora skill 不可用时用内置 `wk_api` 直连兜底
- **可配置参数**: `WEKNORA_BASE_URL`/`WEKNORA_API_KEY`/`WEKNORA_KB_IDS` (L1)，`CHEM_STD_LIB` (L2)，均不写死，缺省自动降级并提示
- **证据可追溯**: L1 → `knowledge_title#chunk_index`，L2 → `文件路径:行号`，L3 → `[需复核,来源:内置锚点卡]`
- **L3 强制复核声明**: 证据等级为 L3 时，诊断报告结论章必须显著声明所有标准数值须上会前复核现行原文
- **M3 法规时效核查**: 诊断当天对专篇引用的每本标准文号做现行有效性复核，输出时效核查留痕表
- **M6 评审标尺事前声明**: 概况章声明评审标尺/否决项阈值/证据等级，结论严格度须与 A 类问题自洽

### 文档
- `README.md`: 完整使用说明/快速开始/环境配置/标准依据/缺陷分级/红线
- `CHANGELOG.md`: 版本记录
- `LICENSE`: MIT 许可证

---

## [Unreleased]

### Planned
- 真实专篇端到端测试案例库
- 典型 A 类缺陷模式案例集 (精细化工错用石油化工标准/甲基肼 J1-J2 矛盾/乙腈临界量放大 115 倍等基准案例)
- 自动化脚本: pandoc 批量落盘/表格全量导出/图片提取
- 多版本修改对比工具脚本 (问题映射表自动生成)

[1.0.0]: https://github.com/your-org/chem-safety-design-review/releases/tag/v1.0.0
[Unreleased]: https://github.com/your-org/chem-safety-design-review/compare/v1.0.0...HEAD
