# =============================================================================
# Monte Carlo Portfolio Simulation
# =============================================================================
# Example: Simulate portfolio returns using Monte Carlo method
# Created with Claude & R
# =============================================================================

library(ggplot2)
library(dplyr)

# Parameters
set.seed(42)
n_simulations <- 10000
n_days <- 252  # Trading days in a year
initial_investment <- 10000

# Expected returns and volatility (annualized)
expected_return <- 0.08  # 8% annual return
volatility <- 0.15        # 15% annual volatility

# Daily parameters
daily_return <- expected_return / n_days
daily_vol <- volatility / sqrt(n_days)

# =============================================================================
# Run Monte Carlo Simulation
# =============================================================================

cat("Running", n_simulations, "Monte Carlo simulations...\n")

# Matrix to store all paths
portfolio_paths <- matrix(nrow = n_days + 1, ncol = n_simulations)
portfolio_paths[1, ] <- initial_investment

# Simulate paths
for (sim in 1:n_simulations) {
  for (day in 2:(n_days + 1)) {
    # Random return for this day
    daily_shock <- rnorm(1, mean = daily_return, sd = daily_vol)
    
    # Update portfolio value
    portfolio_paths[day, sim] <- portfolio_paths[day - 1, sim] * (1 + daily_shock)
  }
}

cat("✅ Simulation complete!\n\n")

# =============================================================================
# Calculate Statistics
# =============================================================================

final_values <- portfolio_paths[n_days + 1, ]

stats <- data.frame(
  Metric = c("Mean", "Median", "5th Percentile", "95th Percentile", 
             "Min", "Max", "Std Dev"),
  Value = c(
    mean(final_values),
    median(final_values),
    quantile(final_values, 0.05),
    quantile(final_values, 0.95),
    min(final_values),
    max(final_values),
    sd(final_values)
  )
)

cat("=== Portfolio Value After 1 Year ===\n")
print(stats, row.names = FALSE, digits = 2)

# Probability of loss
prob_loss <- mean(final_values < initial_investment) * 100
cat("\nProbability of loss:", round(prob_loss, 2), "%\n")

# Expected return
expected_value <- mean(final_values)
expected_return_pct <- ((expected_value - initial_investment) / initial_investment) * 100
cat("Expected return:", round(expected_return_pct, 2), "%\n\n")

# =============================================================================
# Visualization 1: Sample Paths
# =============================================================================

cat("Creating visualizations...\n")

# Select random paths to plot
n_paths_to_plot <- 100
sample_indices <- sample(1:n_simulations, n_paths_to_plot)

# Convert to data frame for plotting
plot_data <- data.frame(
  Day = rep(0:n_days, n_paths_to_plot),
  Value = as.vector(portfolio_paths[, sample_indices]),
  Path = rep(1:n_paths_to_plot, each = n_days + 1)
)

p1 <- ggplot(plot_data, aes(x = Day, y = Value, group = Path)) +
  geom_line(alpha = 0.1, color = "steelblue") +
  geom_hline(yintercept = initial_investment, linetype = "dashed", 
             color = "red", size = 1) +
  labs(title = paste("Monte Carlo Simulation:", n_paths_to_plot, "Sample Paths"),
       subtitle = paste(n_simulations, "simulations total"),
       x = "Trading Day",
       y = "Portfolio Value ($)") +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar_format())

print(p1)

# =============================================================================
# Visualization 2: Final Value Distribution
# =============================================================================

final_df <- data.frame(FinalValue = final_values)

p2 <- ggplot(final_df, aes(x = FinalValue)) +
  geom_histogram(bins = 50, fill = "steelblue", alpha = 0.7, color = "white") +
  geom_vline(xintercept = initial_investment, linetype = "dashed", 
             color = "red", size = 1) +
  geom_vline(xintercept = mean(final_values), linetype = "solid", 
             color = "darkblue", size = 1) +
  labs(title = "Distribution of Final Portfolio Values",
       subtitle = paste("After", n_days, "trading days"),
       x = "Final Portfolio Value ($)",
       y = "Frequency") +
  theme_minimal() +
  scale_x_continuous(labels = scales::dollar_format()) +
  annotate("text", x = initial_investment, y = Inf, 
           label = "Initial", vjust = 2, hjust = -0.1, color = "red") +
  annotate("text", x = mean(final_values), y = Inf, 
           label = "Mean", vjust = 2, hjust = -0.1, color = "darkblue")

print(p2)

# =============================================================================
# Visualization 3: Probability Distribution
# =============================================================================

# Calculate percentiles
percentiles <- seq(0, 1, by = 0.01)
percentile_values <- quantile(final_values, percentiles)

percentile_df <- data.frame(
  Percentile = percentiles * 100,
  Value = percentile_values
)

p3 <- ggplot(percentile_df, aes(x = Percentile, y = Value)) +
  geom_line(color = "steelblue", size = 1) +
  geom_ribbon(aes(ymin = initial_investment, ymax = Value), 
              fill = "lightblue", alpha = 0.3) +
  geom_hline(yintercept = initial_investment, linetype = "dashed", 
             color = "red", size = 1) +
  labs(title = "Cumulative Distribution of Final Values",
       subtitle = "Value at each percentile",
       x = "Percentile",
       y = "Portfolio Value ($)") +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar_format())

print(p3)

cat("\n✅ All visualizations created!\n")

# =============================================================================
# Risk Metrics
# =============================================================================

cat("\n=== Risk Metrics ===\n")

# Value at Risk (VaR)
var_95 <- quantile(final_values, 0.05)
var_loss <- initial_investment - var_95
cat("Value at Risk (95%):", scales::dollar(var_loss), "\n")
cat("  → In 5% of scenarios, loss exceeds", scales::dollar(var_loss), "\n")

# Conditional Value at Risk (CVaR / Expected Shortfall)
cvar_95 <- mean(final_values[final_values <= var_95])
cvar_loss <- initial_investment - cvar_95
cat("\nConditional VaR (95%):", scales::dollar(cvar_loss), "\n")
cat("  → Average loss in worst 5% scenarios\n")

# Sharpe Ratio (simplified)
risk_free_rate <- 0.02  # 2% risk-free rate
excess_return <- expected_return - risk_free_rate
sharpe_ratio <- excess_return / volatility
cat("\nSharpe Ratio:", round(sharpe_ratio, 2), "\n")
cat("  → Risk-adjusted return\n")

cat("\n=== Simulation Complete! ===\n")
