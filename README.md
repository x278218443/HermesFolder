# 🤖 Hermes Agent Profile Backup

Hermes Agent 的 profile 备份，包含配置、技能和人格设定。

## 📁 目录结构

```
HermesFolder/
├── README.md              # 本文件
├── restore.sh             # 一键恢复脚本
├── .gitignore             # 排除敏感文件
├── default/               # 默认 profile
│   ├── config.yaml        # 主配置（API Key 已脱敏）
│   ├── .env.template      # 环境变量模板
│   └── skills/            # 内置技能（21个）
└── aigp/                  # AIGP 股票交易 profile
    ├── config.yaml        # AIGP 配置
    ├── SOUL.md            # 人格设定（严谨、数据驱动）
    └── skills/
        └── stock/         # 7个股票分析技能
            ├── akshare-stock           # AkShare 数据接口
            ├── astock-report           # A股报告+情绪评分
            ├── china-stock-analysis    # A股/港股分析
            ├── claw-stock              # 个股分析师（林奇分类）
            ├── claw-stock-watcher-pro  # 自选股管理
            ├── stock-monitor-skill     # 7大预警规则
            └── xiaodi-financial-analysis-team  # 7人金融团队
```

## 🚀 快速恢复

### 方式一：一键恢复（推荐）

```bash
# 克隆仓库
git clone https://github.com/x278218443/HermesFolder.git
cd HermesFolder

# 恢复所有 profile
bash restore.sh

# 或只恢复指定 profile
bash restore.sh aigp
bash restore.sh default
```

### 方式二：手动恢复

```bash
# 恢复 default profile
cp default/config.yaml ~/.hermes/config.yaml
cp -r default/skills/* ~/.hermes/skills/

# 恢复 AIGP profile
mkdir -p ~/.hermes/profiles/aigp
cp aigp/config.yaml ~/.hermes/profiles/aigp/config.yaml
cp aigp/SOUL.md ~/.hermes/profiles/aigp/SOUL.md
cp -r aigp/skills/* ~/.hermes/profiles/aigp/skills/
```

## ⚠️ 恢复后必做

1. **填入 API Key**
   ```bash
   hermes config env-path   # 查看 .env 位置
   # 编辑 .env，填入你的 API Key
   ```

2. **检查配置**
   ```bash
   hermes doctor
   ```

3. **启动**
   ```bash
   hermes          # 默认 profile
   aigp            # AIGP profile
   ```

## 📋 Profile 说明

### default
- 默认的 Hermes 配置
- 包含所有内置技能
- 用于 AI 流水线等通用任务

### aigp
- **用途**: AI 股票交易分析
- **模型**: mimo-v2.5（高推理强度）
- **人格**: 严谨、数据驱动、风险优先
- **技能**: 7个专业股票分析技能

## 🔒 安全说明

- API Key 已在备份中脱敏（替换为 `YOUR_API_KEY_HERE`）
- `.env` 文件已被 `.gitignore` 排除
- 恢复后需要手动填入 API Key

## 📝 更新备份

```bash
cd HermesFolder
# 同步最新配置
cp ~/.hermes/config.yaml default/config.yaml
cp -r ~/.hermes/profiles/aigp/* aigp/

# 提交
git add .
git commit -m "Update profile backup"
git push
```

## 📄 License

MIT
