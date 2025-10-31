# TL;DR - Quick Installation Guide

> **For experienced users who want to get started fast.**  
> For detailed explanations, see [INSTALLATION.md](INSTALLATION.md)

---

## 🎯 What You're Installing

**The Concept:** btw watches, direct.R acts 🎬

- **btw** (by Posit) = Read documentation & inspect workspace
- **direct.R** (community) = Write files & execute code safely

---

## ⚡ Quick Install - SAFE MODE (Read-Only)

**5 minutes setup - Maximum security**

### 1. Install R Packages
```r
# In RStudio Console
install.packages(c("mcptools", "pak", "ellmer", "rstudioapi"))
pak::repo_add("https://posit-dev.r-universe.dev")
pak::pak("btw")
```

### 2. Configure Claude Desktop
Edit: `~/Library/Application Support/Claude/claude_desktop_config.json`

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

### 3. Configure .Rprofile
```r
# In RStudio
file.edit("~/.Rprofile")
```

Add:
```r
if (interactive() && requireNamespace("btw", quietly = TRUE)) {
  btw::btw_mcp_session()
  cat("✓ R session registered for Claude Desktop\n")
}
```

### 4. Restart
- Save files
- Restart R (Session → Restart R)
- Quit Claude Desktop (Cmd+Q)
- Start Claude Desktop

### 5. Test
```
Claude: "Show me which R sessions are available"
```

**Done!** ✅

---

## 🔥 Quick Install - DEV MODE SAFE (With Execution)

**10 minutes setup - For non-sensitive data only**

### Prerequisites
Complete SAFE MODE installation first ☝️

### 1. Create Workspace
```r
# In RStudio - works on all platforms
# macOS/Linux:     ~/Desktop/rstudio-workspace
# Windows:         ~/Documents/rstudio-workspace (or Desktop)

dir.create("~/Desktop/rstudio-workspace", showWarnings = FALSE)
setwd("~/Desktop/rstudio-workspace")

# Alternative for Windows users:
# dir.create("~/Documents/rstudio-workspace", showWarnings = FALSE)
# setwd("~/Documents/rstudio-workspace")
```

### 2. Get direct.R
Copy `direct.R` from this repo to your workspace.

### 3. Update Claude Config
Replace the `r-btw` entry with:

```json
{
  "mcpServers": {
    "r-mcptools": {
      "command": "Rscript",
      "args": [
        "-e",
        "mcptools::mcp_server(tools = 'ABSOLUTE_PATH_TO_direct.R')"
      ]
    }
  }
}
```

**Platform-specific examples:**

**macOS/Linux:**
```json
"mcptools::mcp_server(tools = '/Users/USERNAME/Desktop/rstudio-workspace/direct.R')"
```

**Windows:**
```json
"mcptools::mcp_server(tools = 'C:/Users/USERNAME/Documents/rstudio-workspace/direct.R')"
```

⚠️ **Critical:**
- Use **absolute path** (not `~/`)
- Windows: Use **forward slashes** `/` (not `\\`)
- Replace `USERNAME` with your actual username

### 4. Test direct.R
```r
# In RStudio
source("direct.R")
# Should output: "✅ direct.R loaded - The Director is ready! 🎬"
```

### 5. Restart
- Quit Claude (Cmd+Q)
- Start Claude

### 6. Test
```
Claude: "Execute: x <- 1:10; mean(x)"
Expected: 5.5 ✅

Claude: "Write a file: ../test.txt"
Expected: ⛔ Blocked (path traversal) ✅
```

**Done!** 🚀

---

## 🆘 Quick Troubleshooting

### Server not visible in Claude
```bash
# Check JSON syntax
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json | python -m json.tool

# Check logs
tail -f ~/Library/Logs/Claude/mcp-server-r-*.log
```

### R Session not found
```r
# In RStudio
btw::btw_mcp_session()
```

### direct.R not loading
```r
# Test in RStudio
source("~/Desktop/rstudio-workspace/direct.R")
# Check for errors
```

---

## 🔄 Switch Modes

### SAFE → DEV MODE SAFE
1. Create `direct.R` in workspace
2. Update Claude config (see above)
3. Restart Claude (Cmd+Q)

### DEV MODE SAFE → SAFE
1. Change config back to `btw::btw_mcp_server()`
2. Restart Claude (Cmd+Q)

---

## 📝 File Locations Reference

### macOS
```
Claude Config:  ~/Library/Application Support/Claude/claude_desktop_config.json
R Profile:      ~/.Rprofile
Workspace:      ~/Desktop/rstudio-workspace/
Logs:           ~/Library/Logs/Claude/
```

### Windows
```
Claude Config:  %APPDATA%\Claude\claude_desktop_config.json
R Profile:      ~/Documents/.Rprofile
Workspace:      C:\Users\USERNAME\Desktop\rstudio-workspace\
```

### Linux
```
Claude Config:  ~/.config/Claude/claude_desktop_config.json
R Profile:      ~/.Rprofile
Workspace:      ~/Desktop/rstudio-workspace/
```

---

## ⚠️ Security Reminder

**SAFE MODE:**
- ✅ Suitable for sensitive data
- ✅ No automatic execution
- ✅ Full control

**DEV MODE SAFE:**
- ⚠️ Data goes to Anthropic servers
- ⚠️ Automatic code execution
- ❌ NOT for: Patient data, HR data, financial records, GDPR-critical data

**Golden Rule:** If unsure → SAFE MODE!

---

## 📚 Need More Details?

- [INSTALLATION.md](INSTALLATION.md) - Full guide with explanations
- [README.md](README.md) - Project overview
- [examples/](examples/) - Example workflows

---

**Got questions?** Check [INSTALLATION.md](INSTALLATION.md) troubleshooting section.

**Ready to go?** Start chatting with Claude about your R code! 🎉
