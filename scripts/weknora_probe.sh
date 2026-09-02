#!/usr/bin/env bash
# weknora_probe.sh — 证据层探测 + 三层检索封装（步骤3/6/7 复用）
#
# 用法（务必在同一个 shell 会话里连续调用）：
#   source scripts/weknora_probe.sh          # 载入函数并自动加载配置文件
#   chem_probe                               # 探测证据等级，打印并导出 EVIDENCE_LEVEL
#   chem_search "GBT50493 探测器 水平距离"     # 按当前证据等级自动检索
#
# 重要：source、chem_probe、chem_search 必须在同一个 shell 会话内先后执行。
#       如果分开在不同命令里跑，导出的 EVIDENCE_LEVEL 不会保留。为防误判，
#       chem_search 在 EVIDENCE_LEVEL 为空时会自动先跑一次 chem_probe。
#
# 配置从哪里来（脚本会主动读取，不依赖 ~/.bashrc）：
#   本技能跑命令用的是非交互 shell，不会读取 ~/.bashrc / ~/.bash_profile。
#   因此凭证请写进配置文件，脚本会按下面顺序查找并加载第一个存在的文件：
#     1. 环境变量 $CHEM_SAFETY_ENV 指向的文件
#     2. ~/.claude/chem-safety.env
#     3. 本脚本所在目录上一级的 chem-safety.env（随技能目录携带）
#   配置文件是普通 shell 片段，示例见文件末尾注释。
#
# 可配置变量（配置文件里 export，缺省则自动降级）：
#   WEKNORA_BASE_URL  WeKnora 接口根地址（如 http://host:8090/api/v1）
#   WEKNORA_API_KEY   WeKnora 接口密钥
#   WEKNORA_KB_IDS    知识库 id，多个用逗号分隔
#   CHEM_STD_LIB      本地规范库 documents 目录路径（L2 断网兜底用）
#
# 证据出处可追溯：L1 给 knowledge_title#chunk_index；L2 给 文件路径:行号；L3 标 [需复核,内置锚点卡]

# ---------- 配置加载：主动读取配置文件，解决非交互 shell 读不到变量的问题 ----------
CHEM_CONFIG_SOURCE=""   # 记录配置从哪来，供 chem_probe 打印排障
_chem_load_config() {
  # 幂等守卫：已经判定过配置来源就不再重复判断。
  # （否则第二次调用时变量已被第一次填上，会被误标成“已有环境变量”，
  #  把“其实是从文件读的”这个事实盖掉，造成排障时的误导。）
  if [ -n "$CHEM_CONFIG_SOURCE" ]; then
    return 0
  fi
  local candidates f
  # 优先级：显式指定 > 用户级 > 技能目录随附
  candidates="$CHEM_SAFETY_ENV
$HOME/.claude/chem-safety.env"
  # 追加“脚本所在目录的上一级/chem-safety.env”
  if [ -n "${BASH_SOURCE:-}" ]; then
    local here
    here=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)
    [ -n "$here" ] && candidates="$candidates
$here/chem-safety.env"
  fi
  # 如果关键变量在首次加载时就已经存在（比如用户在当前会话手动 export 过），
  # 就不覆盖，只标注来源。这个判断只在第一次调用时做，之后被上面的守卫拦住。
  if [ -n "$WEKNORA_BASE_URL" ] && [ -n "$WEKNORA_API_KEY" ]; then
    CHEM_CONFIG_SOURCE="已有环境变量（未加载配置文件）"
    return 0
  fi
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if [ -f "$f" ]; then
      # shellcheck disable=SC1090
      . "$f"
      CHEM_CONFIG_SOURCE="$f"
      return 0
    fi
  done <<EOF
$candidates
EOF
  CHEM_CONFIG_SOURCE="未找到配置文件"
  return 1
}
_chem_load_config

# ---------- L1：WeKnora 接口直连封装 ----------
# 本技能直接调用 WeKnora 接口检索（无需另装独立的 weknora 技能）。
# 如果环境里另外装了 weknora 技能，也可以改用它，但不是必需的。
wk_api() {  # 参数：method endpoint [json-body]
  curl -s -m 20 -X "$1" "$WEKNORA_BASE_URL/$2" \
    -H "X-API-Key: $WEKNORA_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-Request-ID: $(date +%s)" \
    ${3:+-d "$3"}
}

wk_search() {  # 参数："query" —— 跨库语义检索
  local ids_json
  ids_json=$(echo "$WEKNORA_KB_IDS" | awk -F, '{for(i=1;i<=NF;i++)printf "%s\"%s\"",(i>1?",":""),$i}')
  wk_api POST "knowledge-search" "{\"query\":\"$1\",\"knowledge_base_ids\":[$ids_json]}"
}

wk_hybrid() {  # 参数：kb_id "query" [match_count] —— 单库混合检索（GET 带 JSON 体）
  wk_api GET "knowledge-bases/$1/hybrid-search" "{\"query_text\":\"$2\",\"match_count\":${3:-5}}"
}

# ---------- 探测：按 L1 → L2 → L3 顺序确定证据等级 ----------
chem_probe() {
  _chem_load_config   # 每次探测前确保配置已加载（幂等）
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
  echo "配置来源：$CHEM_CONFIG_SOURCE"
  if [ "$EVIDENCE_LEVEL" = "L1" ] && [ -z "$WEKNORA_KB_IDS" ]; then
    echo "提示：未设 WEKNORA_KB_IDS，先列可用知识库供选择：" >&2
    wk_api GET "knowledge-bases" >&2
  fi
  if [ "$EVIDENCE_LEVEL" = "L3" ]; then
    echo "警告：未接入规范库，将以 L3 内置锚点卡兜底，所有标准数值须上会前复核现行原文。" >&2
    echo "      若本应连上 WeKnora，请检查配置文件 ~/.claude/chem-safety.env 是否存在且填对。" >&2
  fi
}

# ---------- 统一检索入口：按证据等级路由 ----------
chem_search() {  # 参数："query"
  # 自愈：如果还没探测过（EVIDENCE_LEVEL 为空），先自动探测一次，避免误掉 L3
  if [ -z "$EVIDENCE_LEVEL" ]; then chem_probe >/dev/null; fi
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

# ---------- 配置文件示例（复制到 ~/.claude/chem-safety.env 后填写）----------
# export WEKNORA_BASE_URL="http://192.168.0.43:8090/api/v1"
# export WEKNORA_API_KEY="sk-你的密钥"
# export WEKNORA_KB_IDS="知识库id1,知识库id2"
# export CHEM_STD_LIB="D:/路径/weknora-input-v3/documents"
