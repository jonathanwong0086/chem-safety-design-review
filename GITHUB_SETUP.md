# GitHub 私有仓库发布指令

## 一、在 GitHub 创建私有仓库

1. 访问 https://github.com/new
2. 仓库名: `chem-safety-design-review`
3. 描述: `化工安全设施设计专篇评审诊断技能 - 对标政府专家上会审查水平`
4. **设为 Private (私有仓库)**
5. **不要**勾选 "Add a README file" (本地已有)
6. **不要**勾选 "Add .gitignore" (本地已有)
7. **不要**选择 License (本地已有)
8. 点击 "Create repository"

## 二、推送本地仓库到 GitHub

GitHub 创建完成后会显示推送指令,替换 `<your-username>` 为你的 GitHub 用户名:

```bash
cd "D:/ProjectFiles/docs-reviewer/chem-safety-design-review"

# 添加远程仓库 (替换 your-username)
git remote add origin https://github.com/<your-username>/chem-safety-design-review.git

# 或使用 SSH (推荐,需先配置 SSH key)
# git remote add origin git@github.com:<your-username>/chem-safety-design-review.git

# 推送主分支
git push -u origin master

# 推送标签
git push origin v1.0.0
```

## 三、在 GitHub 创建 Release

推送完成后,在 GitHub 仓库页面:

1. 点击右侧 "Releases" → "Create a new release"
2. 选择标签: `v1.0.0`
3. Release title: `v1.0.0 - 化工安全设施设计专篇评审诊断技能首发`
4. 描述框粘贴 `RELEASE_NOTES.md` 全文内容
5. **勾选** "Set as the latest release"
6. **不要**勾选 "Set as a pre-release" (这是正式版)
7. 点击 "Publish release"

## 四、验证发布完整性

发布后检查:

- [ ] README.md 在仓库首页正常渲染,徽章显示正常
- [ ] 文件树结构完整: SKILL.md + references/ + scripts/
- [ ] CHANGELOG.md / CONTRIBUTING.md / LICENSE 可访问
- [ ] Release 页面显示 v1.0.0,附件自动生成 Source code (zip/tar.gz)
- [ ] 标签页 (Tags) 显示 v1.0.0 及注释

## 五、后续维护

### 新增功能或修复问题

```bash
# 创建特性分支
git checkout -b feature/your-feature

# 修改文件后提交
git add .
git commit -m "feat: 描述新增功能"

# 推送分支
git push origin feature/your-feature

# 在 GitHub 创建 Pull Request,合并到 master 后:
git checkout master
git pull origin master
```

### 发布新版本

```bash
# 1. 更新 CHANGELOG.md (将 Unreleased 内容移到新版本号下)
# 2. 提交变更
git add CHANGELOG.md
git commit -m "chore: prepare release v1.1.0"

# 3. 创建新标签
git tag -a v1.1.0 -m "Release v1.1.0 - 版本更新说明"

# 4. 推送
git push origin master
git push origin v1.1.0

# 5. 在 GitHub 创建对应 Release
```

## 六、克隆私有仓库 (团队成员)

团队成员需要:
1. 你在 GitHub 仓库 Settings → Collaborators 添加他们的 GitHub 账号
2. 他们接受邀请后可克隆:

```bash
# HTTPS (每次需输密码或 token)
git clone https://github.com/<your-username>/chem-safety-design-review.git

# SSH (推荐,需配置 SSH key)
git clone git@github.com:<your-username>/chem-safety-design-review.git
```

## 七、GitHub Actions 自动化 (可选)

若需自动化检查 (如 shellcheck 检查 weknora_probe.sh),可添加 `.github/workflows/ci.yml`:

```yaml
name: CI
on: [push, pull_request]
jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run shellcheck
        run: shellcheck scripts/*.sh
```

---

**当前状态**: 本地仓库已初始化,已创建 v1.0.0 标签,等待推送到 GitHub。

**确认检查**: 运行 `git remote -v` 应该看到 origin 指向你的 GitHub 仓库 URL。
