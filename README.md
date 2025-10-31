# Claude Desktop + RStudio Integration

> **Connect Claude Desktop to RStudio for AI-powered R coding**  
> Version 2.1 | macOS, Windows, Linux

Integrate Claude Desktop with RStudio using two complementary systems:
- **btw** (by Posit): Read documentation, inspect workspace
- **direct.R**: Write files, execute code (with security)

---

## 🚀 Quick Start

### ⚡ TL;DR (Experienced Users)
**Want to get started fast?** → [TLDR.md](TLDR.md) - 5-10 minute setup guide

### With Desktop Commander MCP
```
Tell Claude: "Install RStudio integration using AUTOMATION.yaml"
```
**Done!** Claude installs everything automatically (5-10 min).

### Without Desktop Commander
See [INSTALLATION.md](INSTALLATION.md) for step-by-step guide.

---

## 🎯 What You Get

### Components

**📚 btw (Better Than Words)** - by Posit/RStudio Team
- Read R package documentation
- Inspect workspace objects & data frames
- View session information

**⚡ direct.R** - Community/You
- Write files (`.Rmd`, `.qmd`, `.R`, `.csv`, `.json`)
- Execute code safely (DEV MODE only)
- Workspace restrictions & security checks

### Installation Modes

| Mode | Tools | Write Files | Execute Code | Security |
|------|-------|-------------|--------------|----------|
| **SAFE** | btw only | ❌ | ❌ | High |
| **DEV SAFE** | btw + direct.R | ✅ | ✅ | Medium |

**SAFE MODE:** Claude reads docs & inspects workspace. You execute code.  
**DEV MODE SAFE:** Claude writes files & executes code with security checks.

---

## 📋 Prerequisites

- Claude Desktop (latest version)
- R ≥ 4.0 + RStudio
- `Rscript` in PATH

---

## 🛠️ Installation

### 1. Install R Packages

```r
install.packages(c("mcptools", "pak", "ellmer", "rstudioapi"))
pak::repo_add("https://posit-dev.r-universe.dev")
pak::pak("btw")
```

### 2. Choose Your Mode

#### SAFE MODE (btw only)

**Claude Desktop Config:**

```json
{
  "mcpServers": {
    "r-btw": {
      "command": "Rscript",
      "args": ["-e", "btw::btw_mcp_server()"]
    }
  }
}
```

**Config Location:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

**.Rprofile:**

```r
if (interactive() && requireNamespace("btw", quietly = TRUE)) {
  btw::btw_mcp_session()
  cat("✓ Claude Desktop connected (btw)\n")
}
```

#### DEV MODE SAFE (btw + direct.R)

**1. Create workspace:**
```bash
mkdir -p ~/Desktop/rstudio-workspace
```

**2. Download [direct.R](direct.R)** to workspace

**3. Claude Desktop Config:**

```json
{
  "mcpServers": {
    "r-mcptools": {
      "command": "Rscript",
      "args": [
        "-e",
        "mcptools::mcp_server(tools = '/Users/yourname/Desktop/rstudio-workspace/direct.R')"
      ]
    }
  }
}
```

⚠️ Use **absolute path** (no `~/`), use `/` not `\\` (even Windows)

**4. .Rprofile:**

```r
if (interactive() && requireNamespace("btw", quietly = TRUE)) {
  workspace <- "~/Desktop/rstudio-workspace"
  if (dir.exists(workspace)) setwd(workspace)
  
  # Load direct.R tools
  tools_file <- file.path(workspace, "direct.R")
  if (file.exists(tools_file)) source(tools_file)
  
  # Start btw
  btw::btw_mcp_session()
  
  cat("\n✓ Claude Desktop Integration:\n")
  cat("  📚 btw: Docs & Inspection\n")
  cat("  ⚡ direct.R: Write & Execute\n\n")
}
```

### 3. Restart Claude Desktop

**macOS:** Cmd+Q, then reopen  
**Windows:** Close via Task Manager, reopen

---

## ✅ Testing

### SAFE MODE
```
Claude: "Show me the documentation for dplyr::filter"
Claude: "What objects are in my workspace?"
```

### DEV MODE SAFE
```
Claude: "Create report.Rmd analyzing mtcars"
→ Creates report.Rmd (NOT report.Rmd.R!)

Claude: "Execute: x <- 1:10; mean(x)"
→ Result: 5.5

Claude: "Create file ../outside.txt"
→ ⛔ Blocked (path traversal)

Claude: "Execute: system('echo test')"
→ ⛔ Blocked (dangerous command)
```

---

## 🔧 Features

### Smart File Extensions

direct.R recognizes file types and handles them correctly:

```r
"report.Rmd"   → report.Rmd     ✅
"analysis.qmd" → analysis.qmd   ✅
"data.csv"     → data.csv       ✅
"script"       → script.R       ✅ (only plain files get .R)
```

### Security Features (DEV MODE SAFE)

- ✅ Workspace restriction (files only in project folder)
- ✅ Path traversal blocked (`../` patterns)
- ✅ Dangerous commands blocked (`system()`, `file.remove()`, etc.)
- ⚠️ Data results sent to Anthropic servers

---

## 📚 Documentation

- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide
- **[AUTOMATION.yaml](AUTOMATION.yaml)** - Automated installation for Claude
- **[examples/](examples/)** - Demo R Markdown report & simulation

---

## 🔄 Switch Modes

### SAFE → DEV SAFE
1. Create `direct.R` in workspace
2. Update Claude config to `mcptools::mcp_server(tools='...')`
3. Update `.Rprofile` with direct.R loading
4. Restart Claude Desktop

### DEV SAFE → SAFE
1. Update Claude config to `btw::btw_mcp_server()`
2. Update `.Rprofile` to only load `btw::btw_mcp_session()`
3. Restart Claude Desktop

---

## 🔒 Security

**SAFE MODE:**
- ✅ For all sensitive data (with caution)
- 🟡 Claude can inspect workspace (see variable names, structures)
- ✅ No automatic execution
- ✅ You control what runs

**DEV MODE SAFE:**
- ⚠️ For non-sensitive data only
- ⚠️ Automatic code execution
- ⚠️ Results sent to Anthropic
- ❌ NOT for: Patient data, HR data, financial records, GDPR-critical data

**Best Practices:**
- Review code before execution
- No API keys or passwords in workspace
- Separate workspaces for different projects
- Regular backups
- When in doubt → use SAFE MODE

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Server not visible | Validate JSON syntax, restart Claude (Cmd+Q) |
| btw tools missing | Run `btw::btw_mcp_session()` in R |
| direct.R tools missing | Check `direct.R` exists, run `source()` |
| `.Rmd` becomes `.Rmd.R` | Update `direct.R`, restart R |

**Logs (macOS):**
```bash
tail -50 ~/Library/Logs/Claude/mcp-server-r-*.log
```

---

## 📖 Resources

- [mcptools](https://github.com/posit-dev/mcptools) - MCP framework
- [btw](https://github.com/posit-dev/btw) - R documentation tools
- [ellmer](https://ellmer.tidyverse.org/) - Tool definition
- [MCP Spec](https://spec.modelcontextprotocol.io/) - Protocol

---

**License:** MIT | **Version:** 2.1 | **Support:** GitHub Issues

Made with ❤️ for the R community
