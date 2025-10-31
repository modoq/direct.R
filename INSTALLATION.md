# Connect Claude Desktop with RStudio - Complete Guide

> **Version:** 2.1  
> **Date:** October 31, 2025  
> **For:** macOS, Windows, Linux  
> **NEW:** btw + direct.R with .Rmd Support

This guide shows you step-by-step how to connect Claude Desktop with RStudio, enabling Claude to inspect your R sessions, read documentation, create files, and **optionally execute code safely**.

## 🎭 Architecture: Two Components for Optimal Functionality

This integration uses **two complementary systems**:

### 📚 btw (Better Than Words) - Professional R Tools by Posit
- **Developer:** Posit (formerly RStudio) https://posit-dev.github.io/btw/
- **Function:** Gives Claude "eyes and ears" in your R environment
- **Features:** 
  - Documentation tools (package help, function docs, release notes)
  - Environment inspection (describe DataFrames, list objects)
  - Session information (R version, platform, packages)

### 🎬 direct.R - Safe Execution Tools for Claude + RStudio
- **Developer:** Community / You
- **Function:** Gives Claude "hands" to work safely
- **Features:**
  - Write files (.Rmd, .qmd, .R, .csv, .json - intelligent detection!)
  - Execute code (with security checks, DEV MODE only)
  - Workspace restrictions (path traversal blocked)
  - Dangerous commands blocked (system(), file.remove(), etc.)

**Why both?** btw enables Claude to understand your R environment, direct.R enables Claude to work there safely!

=> **btw watches, direct.R executes** 🎬

---

## 📋 Table of Contents

1. [What This Integration Can Do](#what-this-integration-can-do)
2. [Three Security Modes](#three-security-modes)
3. [Prerequisites](#prerequisites)
4. [Installation - SAFE MODE](#installation---safe-mode) ⭐ Recommended for beginners
5. [Installation - DEV MODE SAFE](#installation---dev-mode-safe) ⚡ With code execution
6. [Testing the Installation](#testing-the-installation)
7. [Usage](#usage)
8. [Troubleshooting](#troubleshooting)
9. [Switching Between Modes](#switching-between-modes)
10. [Uninstallation](#uninstallation)
11. [Security Notes](#security-notes)

---

## 🎯 What This Integration Can Do

After successful installation, Claude can:

### Thanks to btw (Documentation & Environment):
- ✅ **Search R documentation** (help pages, vignettes, package info)
- ✅ **Inspect workspace** (view objects, dataframes, variables)
- ✅ **Describe DataFrames** (structure, types, summary statistics)
- ✅ **Retrieve package information** (installed packages, versions, news)
- ✅ **See session details** (R version, platform, library paths)

### Thanks to direct.R (Writing & Execution):
- ✅ **Create files** (.Rmd, .qmd, .R, .csv, .json - intelligent extension detection!)
- ✅ **Write R code** and save to RStudio scripts
- ✅ **Generate reports** (R Markdown, Quarto) - WITHOUT .Rmd.R bug!
- ⚡ **Automatically execute code** (DEV MODE SAFE only, with security checks)
- ⚡ **Workspace restrictions** (only within your project)

### Best of Both Worlds:
- ✅ **Analyze data** (CSV, Excel, JSON, etc.) - btw inspects, direct.R executes
- ✅ **Create visualizations** (ggplot2, plotly, base R) - btw shows docs, direct.R creates code
- ✅ **Calculate statistics** (descriptive statistics, tests, models)
- ✅ **Explain and debug code** - btw reads docs, direct.R tests code
- ✅ **Interpret results** and explain clearly

**Example Workflow:**
```
You: "Create a report about mtcars using dplyr"

Claude uses:
1. btw: Reads dplyr documentation ✅
2. btw: Inspects mtcars dataset ✅
3. direct.R: Creates report.Rmd (NOT report.Rmd.R!) ✅
4. direct.R: Executes code (DEV MODE only) ✅
```

---

## 🛡️ Three Security Modes

This integration offers three modes with different security levels:

### 1. SAFE MODE (Recommended for Beginners) 🟢

**Uses:** Only btw tools  
**Claude can:**
- ✅ Read R documentation
- ✅ Inspect workspace (see variable names, structures)
- ✅ Describe DataFrames
- ❌ NOT: Write files
- ❌ NOT: Execute code

**Security:**
- 🟡 **Passive access** - Claude can see what's in the workspace
- ✅ **No automatic execution** - You keep control
- ✅ **You execute code** - Claude suggests, you confirm

**Suitable for:**
- ✅ All sensitive data (with caution for strictly confidential data)
- ✅ Projects with sensitive data
- ✅ Production environments
- ✅ GDPR-critical data

**Why safer for sensitive data (but not 100% safe!):**
- 🟡 **Limited data access** - Claude can inspect workspace and thus see data (e.g. dataframe structure, variable names)
- ✅ **No automatic code execution** - Claude cannot independently run `head(df)` or similar
- ✅ **Full control** - You decide what gets executed and see every code suggestion
- ✅ **Audit trail** - Everything Claude does is transparent and traceable
- ⚠️ **Important:** Even in SAFE MODE, don't use highly sensitive data if you want to be absolutely certain - btw tools can inspect workspace objects

**Conclusion:** SAFE MODE is safer than DEV MODE, but for absolutely confidential data (classified documents, health data under strictest confidentiality) you should not use any MCP integration.

**Installation:** See [Installation - SAFE MODE](#installation---safe-mode)

---

### 2. DEV MODE SAFE (For Advanced Users) 🟡

**Uses:** btw tools + direct.R  
**Claude can:**
- ✅ Everything from SAFE MODE (read docs, inspect workspace)
- ✅ **PLUS: Write files** (.Rmd, .qmd, .R, .csv, .json)
- ✅ **PLUS: Automatically execute code**

**Security:**
- ⚠️ **Active access** - Claude can execute code and read results
- ⚠️ **Data to Anthropic** - Executed results are transmitted
- ✅ **With security checks:**
  - File writing only in workspace
  - Path traversal (`../`) blocked
  - Dangerous commands blocked (`system()`, `file.remove()`, etc.)
  - Intelligent file extension detection (.Rmd stays .Rmd!)

**Suitable for:**
- ✅ Non-sensitive data
- ✅ Personal analysis projects
- ✅ Learning & experiments
- ❌ NOT: Patient data, HR data, financial information, GDPR-critical data

**⚠️ WHY LESS safe for sensitive data:**
- ⚠️ **Automatic code execution** - Claude executes code and reads results without your confirmation
- ⚠️ **Direct data access** - Claude can execute `head(df)`, `summary(df)` etc. anytime and then see the data
- ⚠️ **Data goes to Anthropic** - When Claude executes code and reads results, this data is transmitted to Anthropic
- ⚠️ **Workspace data actively retrievable** - Unlike SAFE MODE, Claude can proactively read data
- ⚠️ **Privacy risk** - With patient data, personnel data, financial information: GDPR violation possible

**The main difference to SAFE MODE:**
- SAFE MODE: Claude can inspect workspace (passive), but not execute code itself
- DEV MODE: Claude can actively execute code and thus retrieve and read data anytime

**Example scenario:**
```r
# You have patient data loaded:
patients <- read.csv("confidential.csv")

# In DEV MODE SAFE you ask Claude:
"Show me the first rows"

# Claude executes: head(patients)
# → Data is sent to Anthropic! ⚠️

# In SAFE MODE:
# Claude only creates: head(patients)
# → YOU execute and see result
# → Data stays local! ✅
```

**Installation:** See [Installation - DEV MODE SAFE](#installation---dev-mode-safe)

---

### 3. DEV MODE UNSAFE (⚠️ NOT RECOMMENDED) 🔴

**What it can do:**
- Full code execution without restrictions
- ⚠️ **EXTREMELY DANGEROUS**

**For whom:**
- Only for tests in isolated environments
- **NEVER in production!**

**We do NOT document this mode** - if you need it, you already know what you're doing.

---

## 📦 Prerequisites

Before you start, make sure the following is installed:

### Required:
- ✅ **Claude Desktop App** (latest version)
  - Download: https://claude.ai/download
- ✅ **R** (version 4.0 or higher)
  - Download: https://cran.r-project.org/
- ✅ **RStudio** (desktop version recommended)
  - Download: https://posit.co/download/rstudio-desktop/
- ✅ **Rscript** must be in system PATH
  - Test in terminal: `Rscript --version`
  - Should output R version

### Optional but recommended:
- Git (for package installation from GitHub)
- Basic knowledge of R

### System Requirements:
- **macOS:** 10.15 (Catalina) or higher
- **Windows:** Windows 10 or higher
- **Linux:** Ubuntu 20.04+ or equivalent
- **RAM:** At least 4 GB (8 GB recommended)
- **Disk Space:** At least 2 GB free space

---

## 🚀 Installation - SAFE MODE

### Step 1: Install R Packages

Open RStudio and execute the following commands in the R console:

```r
# Step 1.1: Install mcptools (from CRAN)
install.packages("mcptools")
```

Wait until installation is complete. You should see a success message.

```r
# Step 1.2: Install pak (package manager)
install.packages("pak")
```

```r
# Step 1.3: Install btw from R-universe
pak::repo_add("https://posit-dev.r-universe.dev")
pak::pak("btw")
```

**Important:** Also install `ellmer` and `rstudioapi`:
```r
install.packages("ellmer")
install.packages("rstudioapi")
```

**Verification:**
```r
# Check if packages are installed
library(mcptools)
library(btw)
library(ellmer)
library(rstudioapi)
```

If no error message appears, installation was successful! ✅

---

### Step 2: Configure Claude Desktop (SAFE MODE)

#### 2.1: Find Config File

The Claude Desktop configuration file is located here:

**macOS:**
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Windows:**
```
%APPDATA%\Claude\claude_desktop_config.json
```

**Linux:**
```
~/.config/Claude/claude_desktop_config.json
```

#### 2.2: Add SAFE MODE Config

Add the following entry to `mcpServers`:

```json
{
  "mcpServers": {
    "r-mcptools": {
      "command": "Rscript",
      "args": ["-e", "btw::btw_mcp_server()"]
    }
  }
}
```

**That's it for SAFE MODE!** 🎉

Jump to [Step 3: Configure .Rprofile](#step-3-configure-rprofile)

---

## ⚡ Installation - DEV MODE SAFE

**⚠️ IMPORTANT:** Only for non-sensitive projects! Read the [Security Notes](#security-notes) carefully.

### Prerequisite: SAFE MODE Already Installed

Make sure you've already completed Step 1 (R Packages) from SAFE MODE.

### Step 1: Create direct.R Tools

#### 1.1: Create Workspace Folder

Create a folder for your RStudio workspace:

```r
# In RStudio
dir.create("~/Desktop/rstudio-workspace", showWarnings = FALSE)
setwd("~/Desktop/rstudio-workspace")
```

#### 1.2: Create direct.R File

Create a file `direct.R` in your workspace:

```r
# In RStudio
file.edit("direct.R")
```

Copy the content from the `direct.R` file in this repository.

**IMPORTANT:**
- Save the file
- Check for no syntax errors:
  ```r
  source("direct.R")
  # Should output "✅ direct.R loaded"
  ```

#### 1.3: Note Absolute Path

```r
# Get absolute path to direct.R
file.path(getwd(), "direct.R")
```

Copy this path (e.g., `/Users/yourname/Desktop/rstudio-workspace/direct.R`)

---

### Step 2: Claude Desktop Config for DEV MODE SAFE

Open the config file:

**macOS:**
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Windows:**
```
%APPDATA%\Claude\claude_desktop_config.json
```

**Linux:**
```
~/.config/Claude/claude_desktop_config.json
```

**REPLACE** the `r-mcptools` entry with:

```json
{
  "mcpServers": {
    "r-mcptools": {
      "command": "Rscript",
      "args": [
        "-e",
        "mcptools::mcp_server(tools = '/ABSOLUTE/PATH/direct.R')"
      ]
    }
  }
}
```

**⚠️ Critical Points:**
- Use ABSOLUTE path (not relative!)
- Windows: Use `/` instead of `\\` in paths - e.g. "mcptools::mcp_server(tools = 'C:/Users/yourname/Desktop/rstudio-workspace/direct.R')"
- Check JSON syntax: https://jsonlint.com/

---

## 🔧 Step 3: Configure .Rprofile

**For both modes (SAFE and DEV MODE SAFE):**

```r
# In RStudio
file.edit("~/.Rprofile")
```

Add:

```r
# Claude Desktop + RStudio Integration
if (interactive() && requireNamespace("btw", quietly = TRUE)) {
  btw::btw_mcp_session()
  cat("✓ R session registered for Claude Desktop\n")
}
```

Save and restart R!

---

## 🔄 Step 4: Restart Claude Desktop

1. **Completely quit Claude** (Cmd+Q / Right-click → Exit)
2. **Wait 5 seconds**
3. **Restart Claude**
4. **Check:**
   - Settings → Developer → MCP Server
   - Status: "Connected" or green ✅

---

## ✅ Testing the Installation

### Test Checklist

#### Basic Test (both modes):
```
Claude, show me which R sessions are available
```

**Expected:** At least one session is displayed

#### SAFE MODE Test:
```
Create a demo script for data analysis and save it as demo.R
```

**Expected:** File is created, but NOT automatically executed

#### DEV MODE SAFE Test 1: Code Execution
```
Execute the following code: x <- 1:10; mean(x)
```

**Expected:** Code is executed, result: 5.5  
**Why important:** Normal, safe R code must work

#### DEV MODE SAFE Test 2: Workspace Protection
```
Write a file: ../test_outside.txt
```

**Expected:** ⛔ Blocked with error message  
**Why important:** `../` is path traversal - with this, Claude could overwrite files outside your workspace (e.g., important system files, other projects, sensitive documents)

#### DEV MODE SAFE Test 3: Dangerous Commands
```
Execute: system("whoami")
```

**Expected:** ⛔ Blocked with message "Dangerous command detected"  
**Why important:** `system()` allows shell commands - with this, Claude could execute arbitrary programs, delete files (`rm -rf`), start network requests, or install malware

---

## 💡 Usage

### SAFE MODE Workflow:

```
User in Claude: "Create a script for time series analysis"
Claude: [Creates analysis.R]
User in RStudio: [Opens analysis.R, checks code, executes]
User in Claude: "What do the results show?"
Claude: [Discusses results]
```

### DEV MODE SAFE Workflow:

```
User: "Load the file data.csv and show me the first rows"
Claude: [Automatically executes: 
         df <- read.csv("data.csv")
         head(df)]
User: "Create a plot"
Claude: [Executes: ggplot(...)]
```

### Tips:

1. **Be specific:** "Boxplot for salary by department"
2. **Name files:** "Analyze sales_2024.csv"
3. **Give context:** "The data is loaded as 'df'"
4. **In DEV MODE:** "Execute" vs. "Create script"

---

## 🔧 Troubleshooting

### Problem 1: MCP Server Doesn't Start

**Symptom:** `r-mcptools` not visible in Claude Desktop

**Solution:**
1. Check JSON syntax: https://jsonlint.com/
2. Test Rscript:
   ```bash
   Rscript --version
   ```
3. Check logs:
   ```bash
   # macOS
   tail -f ~/Library/Logs/Claude/mcp-server-r-mcptools.log
   ```

**Common errors in logs:**
- `"there is no package called 'btw'"` → Reinstall package
- `"could not find function 'tool'"` → Install ellmer
- `"tools must be a list"` → direct.R must return `list(...)`

---

### Problem 2: "direct.R" Error

**Symptom:** Server starts, but tools are missing

**Diagnosis:**
```r
# Test in RStudio
tools <- source("direct.R")
length(tools$value)  # Should be 6
```

**Common errors:**
1. **Syntax error in R code:**
   ```r
   # Test:
   source("direct.R")
   # If error: debug line by line
   ```

2. **Wrong path in config:**
   - Must be absolute path
   - Windows: `/` instead of `\\`
   - No spaces without quotes

3. **Outdated ellmer version:**
   ```r
   packageVersion("ellmer")  # Should be >= 0.3.0
   update.packages("ellmer")
   ```

---

### Problem 3: Path Traversal Not Blocked

**Symptom:** `../` allows writing outside workspace

**Solution:**
1. Check direct.R:
   ```r
   # Line ~17 should be:
   dangerous_patterns <- c("../", "/..")  # NOT "\\.\\../"
   ```

2. Restart Claude Desktop (Cmd+Q, reopen)

3. Test:
   ```r
   # Test in Claude
   "Write test with filename: ../test.txt"
   # Must be blocked!
   ```

---

### Problem 4: "Code Not Executed" (DEV MODE)

**Symptom:** run_r_code tool not available

**Check:**
1. Is DEV MODE SAFE config active?
   ```json
   "args": ["-e", "mcptools::mcp_server(tools = '...')"]
   ```
   
2. Was Claude restarted?

3. Tools present?
   ```r
   tools <- source("direct.R")
   sapply(tools$value, function(x) x@name)
   # Should show: run_r_code, safe_write_file, ...
   ```

---

### Problem 5: "Permission Denied" for Config

**Solution:**
```bash
# macOS/Linux
sudo chmod 644 ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Windows: Open editor as administrator
```

---

### Problem 6: R Session Not Visible

**Symptom:** "No R sessions available"

**Solution:**
1. Is RStudio running?
2. .Rprofile correct?
   ```r
   file.edit("~/.Rprofile")
   # Check if btw::btw_mcp_session() is present
   ```
3. Manually register:
   ```r
   btw::btw_mcp_session()
   ```
4. Completely restart R (Session → Restart R)

---

## 🔄 Switching Between Modes

### From SAFE MODE to DEV MODE SAFE:

1. Create `direct.R` (see above)
2. Change config:
   ```json
   "args": ["-e", "mcptools::mcp_server(tools = '/path/direct.R')"]
   ```
3. Restart Claude

### From DEV MODE SAFE to SAFE MODE:

1. Change config back:
   ```json
   "args": ["-e", "btw::btw_mcp_server()"]
   ```
2. Restart Claude

**Golden Rule:** If unsure → SAFE MODE!

---

## 🗑️ Uninstallation

### Step 1: Clean Config
```json
{
  "mcpServers": {
    // Remove r-mcptools entry
  }
}
```

### Step 2: Clean .Rprofile
```r
file.edit("~/.Rprofile")
# Remove btw::btw_mcp_session() lines
```

### Step 3: Remove Packages (optional)
```r
remove.packages(c("btw", "mcptools", "ellmer"))
```

### Step 4: Restart Claude

---

## 🔒 Security Notes

### SAFE MODE:
- ✅ Maximum security
- ✅ No automatic code execution
- ✅ Full control with user
- ✅ Suitable for sensitive data

### DEV MODE SAFE:
- ⚠️ Code execution active
- ✅ Workspace restrictions
- ✅ Path traversal blocked
- ✅ Dangerous commands blocked
- ⚠️ Data goes through Anthropic servers
- ❌ NOT for GDPR-critical data

### Best Practices:

**Always:**
- ✅ Use SAFE MODE for company/sensitive data
- ✅ Review generated code before execution
- ✅ Separate R sessions for different projects
- ✅ Regular backups

**Never:**
- ❌ Store API keys or passwords in workspace
- ❌ DEV MODE with confidential patient data
- ❌ Blindly execute any code
- ❌ Production data in DEV MODE

### Avoid MCP Security "Lethal Trifecta":

❌ **Dangerous:**
- Access to private data +
- Exposure to untrusted content +
- External communication

✅ **Our Implementation:**
- Workspace restrictions
- Code review before execution
- Transparent operations
- User has final control

---

## 📚 Further Resources

### Documentation:
- **mcptools:** https://posit-dev.github.io/mcptools/
- **btw:** https://posit-dev.github.io/btw/
- **ellmer:** https://ellmer.tidyverse.org/
- **MCP Spec:** https://spec.modelcontextprotocol.io/

### Important GitHub Repos:
- **mcptools:** https://github.com/posit-dev/mcptools
- **btw:** https://github.com/posit-dev/btw
- **MCP Specification:** https://github.com/modelcontextprotocol

### Community & Support:
- **MCP Discord:** https://discord.gg/modelcontextprotocol
- **GitHub Issues:** See repos above

---

## 🤝 Support

### If you have problems:

1. **Check [Troubleshooting](#troubleshooting)**
2. **Check logs:**
   ```bash
   # macOS
   tail -100 ~/Library/Logs/Claude/mcp-server-r-mcptools.log
   ```
3. **Create GitHub issue with:**
   - OS and version
   - R version
   - Chosen mode (SAFE/DEV)
   - Complete error message
   - What was already tried

---

## 📝 Changelog

**Version 2.1** (October 31, 2025)
- NEW: Complete English translation
- IMPROVED: Clear messaging "btw watches, direct.R directs"

**Version 2.0** (October 30, 2025)
- NEW: DEV MODE SAFE with code execution
- NEW: Three security modes documented
- NEW: Comprehensive troubleshooting from real sessions
- NEW: direct.R template
- FIX: Path traversal security
- FIX: ellmer 0.3.0 syntax
- IMPROVED: Clearer installation instructions

**Version 1.0** (October 30, 2025)
- First guide
- SAFE MODE documentation

---

## ⚖️ License

This guide: MIT License

Packages:
- mcptools: MIT
- btw: MIT
- ellmer: MIT

---

**Good luck with Claude + RStudio!** 🎉

**Questions?** See support section above.

**Most important tip:** Start with SAFE MODE, switch to DEV MODE SAFE only if needed!
