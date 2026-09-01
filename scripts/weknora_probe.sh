#!/usr/bin/env bash
# weknora_probe.sh — 证据层探测 + 三层检索封装（步骤3/6/7 复用）
#
# 用法：
#   source scripts/weknora_probe.sh      # 载入函数
#   chem_probe                           # 探测证据等级 → 打印并导出 EVIDENCE_LEVEL
#   chem_search "GBT50493 探测器 水平距离"  # 按当前证据等级自动检索
#
# 可配置环境变量（均不写死，缺省自动降级）：
#   WEKNORA_BASE_URL  WeKnora API 根地址（如 https://host/api/v1）
#   WEKNORA_API_KEY   WeKnora API Key
#   WEKNORA_KB_IDS    知识库 id，逗号分隔（缺省 L1 时先列库让用户选）
#   CHEM_STD_LIB      本地规范库 documents 目录路径（L2 兜底）
#
# 证据可追溯：L1→ knowledge_title#chunk_index；L2→ 文件路径:行号；L3→ [需复核,内置锚点卡]

# ---------- L1：WeKnora 直连 helper（weknora skill 不可用时兜底） ----------
wk_api() {  # method endpoint [json-body]
  curl -s -m 20 -X "$1" "$WEKNORA_BASE_URL/$2" \
    -H "X-API-Key: $WEKNORA_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-Request-ID: $(date +%s)" \
    ${3:+-d "$3"}
}

wk_search() {  # "query" —— 跨库语义检索
  local ids_json
  ids_json=$(echo "$WEKNORA_KB_IDS" | awk -F, '{for(i=1;i<=NF;i++)printf "%s\"%s\"",(i>1?",":""),$i}')
  wk_api POST "knowledge-search" "{\"query\":\"$1\",\"knowledge_base_ids\":[$ids_json]}"
}

wk_hybrid() {  # kb_id "query" [match_count] —— 单库混合检索（GET 带 JSON body）
  wk_api GET "knowledge-bases/$1/hybrid-search" "{\"query_text\":\"$2\",\"match_count\":${3:-5}}"
}

# ---------- 探测：按 L1→L2→L3 顺序确定证据等级 ----------
chem_probe() {
  EVIDENCE_LEVEL=""
  if [ -n "$WEKNORA_BASE_URL" ] && [ -n "$WEKNORA_API_KEY" ]; then
    local probe
    probe=$(curl -s -m 8 -X GET "$WEKNORA_BASE_URL/knowledge-bases" \
      -H "X-API-Key: $WEKNORA_API_KEY" -H "Content-Type: application/json" 2>/dev/null)
    if echo "$probe" | grep -q '"id"'; then EVIDENCE_LEVEL="L1"; fi
  fi
  if [ -z "$EVIDENCE_LEVEL" ] && [ -n "$CHEM_STD_LIB" ] && [ -d "$CHEM_STD_LIB" ]; then
    EVIDENCE_LEVEL="L2"
  fi
  : "${EVIDENCE_LEVEL:=L3}"
  export EVIDENCE_LEVEL
  echo "本次证据等级：$EVIDENCE_LEVEL"
  if [ "$EVIDENCE_LEVEL" = "L1" ] && [ -z "$WEKNORA_KB_IDS" ]; then
    echo "提示：未设 WEKNORA_KB_IDS，先列可用知识库供选择：" >&2
    wk_api GET "knowledge-bases" >&2
  fi
  if [ "$EVIDENCE_LEVEL" = "L3" ]; then
    echo "警告：未接入规范库，将以 L3 内置锚点卡兜底，所有标准数值须上会前复核现行原文。" >&2
  fi
}

# ---------- 统一检索入口：按证据等级路由 ----------
chem_search() {  # "query"
  case "${EVIDENCE_LEVEL:-L3}" in
    L1)
      if [ -n "$WEKNORA_KB_IDS" ]; then wk_search "$1"; else
        echo "WEKNORA_KB_IDS 未配置，无法跨库检索；请先运行 chem_probe 选库。" >&2; return 1; fi
      ;;
    L2)
      # 本地全文检索：命中即给 文件路径:行号（引用出处）
      if command -v rg >/dev/null 2>&1; then
        rg -n --no-heading "$1" "$CHEM_STD_LIB"
      else
        grep -rn "$1" "$CHEM_STD_LIB"
      fi
      ;;
    L3)
      echo "[L3 兜底] 无外部规范库，请查 references/standard-anchors.md 内置锚点卡（值标 [需复核]）。" >&2
      return 2
      ;;
  esac
}
