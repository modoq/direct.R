# Examples

This folder contains example files to demonstrate the RStudio MCP integration.

## 📊 demo_report.Rmd

**R Markdown report analyzing the mtcars dataset**

Features:
- Descriptive statistics
- Visualizations (ggplot2)
- Correlation analysis
- Linear regression model
- Model diagnostics

**How to use:**
```r
# In RStudio:
rmarkdown::render("demo_report.Rmd")

# Or click "Knit" button in RStudio
```

**With Claude (DEV MODE SAFE):**
```
Claude: "Render the demo_report.Rmd file"
```

---

## 📈 monte_carlo.R

**Monte Carlo portfolio simulation**

Features:
- 10,000 simulations
- Portfolio value paths
- Distribution analysis
- Risk metrics (VaR, CVaR, Sharpe Ratio)
- Three visualizations

**How to use:**
```r
# In RStudio:
source("monte_carlo.R")
```

**With Claude (DEV MODE SAFE):**
```
Claude: "Run the monte_carlo.R simulation"
```

---

## 🎯 Try with Claude

**SAFE MODE:**
```
Claude: "Show me the code structure of demo_report.Rmd"
Claude: "Explain the monte_carlo.R simulation"
```

**DEV MODE SAFE:**
```
Claude: "Modify demo_report.Rmd to analyze iris dataset instead"
Claude: "Run monte_carlo.R with 20,000 simulations"
Claude: "Create a new report based on demo_report.Rmd for the diamonds dataset"
```

---

**Need help?** See [INSTALLATION.md](../INSTALLATION.md)
