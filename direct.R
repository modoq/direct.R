# ============================================================================
# direct.R - The Director: Active Execution Tools for Claude + RStudio
# Extends btw (passive observation) with write & execute capabilities
# ============================================================================
# Branding: btw watches, director directs 🎬
# - btw = passive reading (by Posit)
# - director = active doing (community-driven)
# ============================================================================

library(ellmer)
library(rstudioapi)
library(btw)

# SECURITY FUNCTION: Path Validation (ENHANCED)
# ----------------------------------------------------------------------------
is_safe_path <- function(path, base_dir = getwd()) {
  tryCatch({
    # IMPORTANT: Check for path traversal patterns BEFORE normalization!
    # Block dangerous patterns immediately
    dangerous_patterns <- c(
      "../",      # Relative path traversal
      "/.."       # Absolute path traversal
    )
    
    for (pattern in dangerous_patterns) {
      if (grepl(pattern, path, fixed = TRUE)) {
        message(sprintf(
          "⛔ Path traversal blocked! Pattern: %s\n   Path: %s",
          pattern, path
        ))
        return(FALSE)
      }
    }
    
    # Expand ~ 
    if (startsWith(path, "~")) {
      path <- path.expand(path)
    }
    
    # If absolute path: normalize directly
    # If relative path: combine with base_dir
    if (startsWith(path, "/")) {
      abs_path <- normalizePath(path, mustWork = FALSE)
    } else {
      abs_path <- normalizePath(file.path(base_dir, path), mustWork = FALSE)
    }
    
    abs_base <- normalizePath(base_dir, mustWork = TRUE)
    
    # Check if path is within workspace
    is_safe <- startsWith(abs_path, abs_base)
    
    if (!is_safe) {
      message(sprintf(
        "⛔ Path outside workspace blocked!\n   Workspace: %s\n   Attempted: %s", 
        abs_base, abs_path
      ))
    }
    
    return(is_safe)
  }, error = function(e) {
    message(paste("❌ Error in path validation:", e$message))
    return(FALSE)
  })
}

# RESTRICTED VERSION: Execute Code (with warnings)
# ----------------------------------------------------------------------------
tool_run_code <- tool(
  function(code, echo = TRUE) {
    if (!rstudioapi::isAvailable()) {
      return("Error: RStudio is not available.")
    }
    
    # Warn about dangerous operations
    dangerous_patterns <- c(
      "system\\(",
      "shell\\(",
      "file\\.remove\\(",
      "unlink\\(",
      "Sys\\.setenv\\(",
      "setwd\\(",
      "source\\("
    )
    
    for (pattern in dangerous_patterns) {
      if (grepl(pattern, code, perl = TRUE)) {
        warning_msg <- paste0(
          "⛔ WARNING: Potentially dangerous command detected!\n",
          "Pattern: ", pattern, "\n",
          "Code will NOT be executed.\n"
        )
        return(warning_msg)
      }
    }
    
    rstudioapi::sendToConsole(code, execute = TRUE, echo = echo)
    return("✅ Code executed")
  },
  name = "run_r_code",
  description = "Executes R code. BLOCKS dangerous operations (system, file.remove, etc.)",
  arguments = list(
    code = type_string("The R code to execute"),
    echo = type_boolean("Echo in Console (default: TRUE)")
  )
)

# SAFE FILE WRITING: Workspace only
# ----------------------------------------------------------------------------
tool_safe_write_file <- tool(
  function(filename, content) {
    # Validate path
    if (!is_safe_path(filename)) {
      return(paste0(
        "⛔ ERROR: Writing outside workspace NOT allowed!\n",
        "Workspace: ", getwd(), "\n",
        "Attempted path: ", filename, "\n",
        "❌ Only files in current workspace can be written."
      ))
    }
    
    # Check if file already exists
    if (file.exists(filename)) {
      return(paste0(
        "⚠️ WARNING: File already exists!\n",
        "File: ", filename, "\n",
        "Use a different name or delete the file first."
      ))
    }
    
    tryCatch({
      writeLines(content, filename)
      abs_path <- normalizePath(filename)
      
      if (rstudioapi::isAvailable()) {
        msg <- sprintf("cat('✅ File created: %s\\n')", basename(filename))
        rstudioapi::sendToConsole(msg, execute = TRUE, echo = FALSE)
      }
      
      return(paste0("✅ File created:\n   ", abs_path))
    }, error = function(e) {
      return(paste0("❌ Error writing file:\n   ", e$message))
    })
  },
  name = "safe_write_file",
  description = "Writes files ONLY in current R working directory. Paths outside workspace are blocked.",
  arguments = list(
    filename = type_string("Filename (relative to workspace)"),
    content = type_string("File content as string")
  )
)

# SAFE CODE SCRIPT WRITING
# ----------------------------------------------------------------------------
tool_write_r_script <- tool(
  function(filename, code) {
    # INTELLIGENT FILE EXTENSION DETECTION
    # Do NOT append .R to these file types:
    special_extensions <- c(
      "\\.Rmd$",   # R Markdown reports
      "\\.qmd$",   # Quarto Markdown
      "\\.Rnw$",   # Sweave (LaTeX + R)
      "\\.csv$",   # CSV data
      "\\.tsv$",   # TSV data
      "\\.txt$",   # Text
      "\\.json$",  # JSON
      "\\.xml$",   # XML
      "\\.md$",    # Markdown
      "\\.html$",  # HTML
      "\\.tex$",   # LaTeX
      "\\.yaml$",  # YAML
      "\\.yml$",   # YAML
      "\\.toml$",  # TOML
      "\\.Rproj$"  # RStudio Project
    )
    
    # Check if file has special extension
    has_special_extension <- any(sapply(special_extensions, function(ext) {
      grepl(ext, filename, ignore.case = TRUE)
    }))
    
    # ONLY add .R for pure R scripts
    if (!has_special_extension && !grepl("\\.R$", filename, ignore.case = TRUE)) {
      filename <- paste0(filename, ".R")
    }
    
    # Validate path
    if (!is_safe_path(filename)) {
      return(paste0(
        "⛔ ERROR: Script writing outside workspace NOT allowed!\n",
        "Workspace: ", getwd(), "\n",
        "Attempted path: ", filename
      ))
    }
    
    # Check for dangerous code patterns
    dangerous_patterns <- c(
      "system\\(",
      "shell\\(",
      "file\\.remove\\(",
      "unlink\\("
    )
    
    for (pattern in dangerous_patterns) {
      if (grepl(pattern, code, perl = TRUE)) {
        return(paste0(
          "⛔ SECURITY WARNING: Dangerous code detected!\n",
          "Pattern: ", pattern, "\n",
          "Script will NOT be created."
        ))
      }
    }
    
    if (file.exists(filename)) {
      return(paste0(
        "⚠️ WARNING: File already exists!\n",
        "File: ", filename
      ))
    }
    
    tryCatch({
      writeLines(code, filename)
      abs_path <- normalizePath(filename)
      
      if (rstudioapi::isAvailable()) {
        # Show appropriate message based on file type
        if (grepl("\\.Rmd$", filename, ignore.case = TRUE)) {
          msg <- sprintf("cat('✅ R Markdown report created: %s\\n')", basename(filename))
        } else if (grepl("\\.qmd$", filename, ignore.case = TRUE)) {
          msg <- sprintf("cat('✅ Quarto document created: %s\\n')", basename(filename))
        } else if (grepl("\\.R$", filename, ignore.case = TRUE)) {
          msg <- sprintf("cat('✅ R script created: %s\\n')", basename(filename))
        } else {
          msg <- sprintf("cat('✅ File created: %s\\n')", basename(filename))
        }
        rstudioapi::sendToConsole(msg, execute = TRUE, echo = FALSE)
      }
      
      # Return message based on file type
      if (grepl("\\.Rmd$", filename, ignore.case = TRUE)) {
        return(paste0("✅ R Markdown report created:\n   ", abs_path))
      } else if (grepl("\\.qmd$", filename, ignore.case = TRUE)) {
        return(paste0("✅ Quarto document created:\n   ", abs_path))
      } else {
        return(paste0("✅ File created:\n   ", abs_path))
      }
    }, error = function(e) {
      return(paste0("❌ Error:", e$message))
    })
  },
  name = "write_r_script",
  description = "Writes files in workspace with intelligent extension detection. Automatically appends .R only for R scripts. Supports: .Rmd, .qmd, .Rnw, .csv, .json, .md, .yaml, etc. without modification.",
  arguments = list(
    filename = type_string("Filename with extension (e.g. 'report.Rmd' or 'script.R')"),
    code = type_string("File content")
  )
)

# UPDATE PLOT COLORS (Safe)
# ----------------------------------------------------------------------------
tool_update_plot_colors <- tool(
  function(plot_variable, color_type, color_low, color_high) {
    if (!rstudioapi::isAvailable()) {
      return("❌ RStudio not available")
    }
    
    if (!color_type %in% c("gradient", "manual")) {
      return("❌ color_type must be 'gradient' or 'manual'")
    }
    
    code <- sprintf(
      '%s <- %s + scale_fill_gradient(low = "%s", high = "%s")',
      plot_variable, plot_variable, color_low, color_high
    )
    
    rstudioapi::sendToConsole(code, execute = TRUE, echo = TRUE)
    return(paste0("✅ Plot colors updated: ", plot_variable))
  },
  name = "update_plot_colors",
  description = "Updates plot colors safely",
  arguments = list(
    plot_variable = type_string("Name of plot variable"),
    color_type = type_string("'gradient' or 'manual'"),
    color_low = type_string("Low color"),
    color_high = type_string("High color")
  )
)

# OPEN DATAFRAME IN VIEWER (Read-Only)
# ----------------------------------------------------------------------------
tool_view_dataframe <- tool(
  function(data_name) {
    if (!rstudioapi::isAvailable()) {
      return("❌ RStudio not available")
    }
    
    code <- sprintf("View(%s)", data_name)
    rstudioapi::sendToConsole(code, execute = TRUE, echo = TRUE)
    return(paste0("✅ Dataframe opened: ", data_name))
  },
  name = "view_dataframe",
  description = "Opens dataframe in RStudio Viewer (read-only)",
  arguments = list(
    data_name = type_string("Name of dataframe")
  )
)

# WORKSPACE INFO (Safe)
# ----------------------------------------------------------------------------
tool_workspace_info <- tool(
  function() {
    info <- list(
      directory = getwd(),
      objects = length(ls(envir = .GlobalEnv)),
      r_version = R.version.string
    )
    
    output <- sprintf(
      "WORKSPACE INFO:\n   Directory: %s\n   Objects: %d\n   R Version: %s",
      info$directory, info$objects, info$r_version
    )
    
    return(output)
  },
  name = "workspace_info",
  description = "Shows workspace information (safe, read-only)",
  arguments = list()
)

# CONFIRMATION
message("✅ direct.R loaded - The Director is ready! 🎬")
message(sprintf("📁 Workspace: %s", getwd()))
message("🛡️ Security features:")
message("   - File writing restricted to workspace")
message("   - Path traversal (../) blocked")
message("   - Dangerous commands blocked")
message("   - All btw tools available")
message("")
message("💡 Remember: btw watches, director directs!")

# RETURN TOOL LIST (required by mcptools)
list(
  tool_run_code,
  tool_safe_write_file,
  tool_write_r_script,
  tool_update_plot_colors,
  tool_view_dataframe,
  tool_workspace_info
)