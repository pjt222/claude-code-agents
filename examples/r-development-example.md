# R Package Development Example 📊

Demonstrates using the `r-developer` agent to create a complete R package.

## Scenario

You need to create an R package called `timeseries` that provides utilities for time series analysis, including functions for data cleaning, visualization, and basic forecasting.

## Initial Prompt

```
Create a new R package called "timeseriestools" with the following features:
1. A function to detect and handle missing values in time series
2. A function to plot time series with trend lines
3. A function to calculate moving averages
4. Proper documentation and tests

Follow CRAN guidelines and use tidyverse conventions.
```

## Expected Behavior

The r-developer agent will:

1. **Create** the package directory structure
2. **Write** DESCRIPTION file with proper metadata
3. **Implement** core functions in R/
4. **Document** functions using roxygen2
5. **Create** testthat test suite
6. **Generate** a vignette with examples
7. **Optionally** use MCP servers for validation

## Sample Output

```markdown
## Creating R Package: timeseriestools

### 📁 Package Structure Created

```
timeseriestools/
├── DESCRIPTION
├── NAMESPACE
├── LICENSE
├── README.md
├── R/
│   ├── handle_missing.R
│   ├── plot_timeseries.R
│   └── moving_average.R
├── man/
│   ├── handle_missing.Rd
│   ├── plot_timeseries.Rd
│   └── moving_average.Rd
├── tests/
│   ├── testthat.R
│   └── testthat/
│       ├── test-handle_missing.R
│       ├── test-plot_timeseries.R
│       └── test-moving_average.R
└── vignettes/
    └── introduction.Rmd
```

### 📄 DESCRIPTION

```
Package: timeseriestools
Title: Utilities for Time Series Analysis
Version: 0.1.0
Authors@R:
    person("Your", "Name", email = "you@example.com", role = c("aut", "cre"),
           comment = c(ORCID = "0000-0000-0000-0000"))
Description: Provides utilities for time series data manipulation,
    visualization, and basic analysis. Includes functions for handling
    missing values, plotting with trend lines, and calculating moving averages.
License: MIT + file LICENSE
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.2.3
Imports:
    ggplot2,
    dplyr,
    tidyr,
    zoo
Suggests:
    testthat (>= 3.0.0),
    knitr,
    rmarkdown
Config/testthat/edition: 3
VignetteBuilder: knitr
```

### 📝 Core Functions

#### R/handle_missing.R

```r
#' Handle Missing Values in Time Series
#'
#' Detects and handles missing values using various interpolation methods.
#'
#' @param x A numeric vector or time series object
#' @param method Interpolation method: "linear", "spline", or "locf"
#' @param max_gap Maximum gap size to interpolate (default: Inf)
#'
#' @return A numeric vector with missing values handled
#' @export
#'
#' @examples
#' x <- c(1, 2, NA, 4, 5, NA, NA, 8)
#' handle_missing(x, method = "linear")
#' handle_missing(x, method = "locf", max_gap = 2)
handle_missing <- function(x, method = c("linear", "spline", "locf"),
                           max_gap = Inf) {
  method <- match.arg(method)

  if (!is.numeric(x)) {
    stop("x must be numeric")
  }

  if (all(is.na(x))) {
    warning("All values are NA, returning unchanged")
    return(x)
  }

  # Identify gaps
  na_runs <- rle(is.na(x))

  result <- switch(method,
    linear = zoo::na.approx(x, maxgap = max_gap, na.rm = FALSE),
    spline = zoo::na.spline(x, maxgap = max_gap, na.rm = FALSE),
    locf = zoo::na.locf(x, maxgap = max_gap, na.rm = FALSE)
  )

  result
}
```

#### R/moving_average.R

```r
#' Calculate Moving Average
#'
#' Computes simple or weighted moving average for time series data.
#'
#' @param x A numeric vector
#' @param window Size of the moving window
#' @param type Type of moving average: "simple" or "weighted"
#' @param align Window alignment: "center", "left", or "right"
#'
#' @return A numeric vector of moving averages
#' @export
#'
#' @examples
#' x <- 1:10
#' moving_average(x, window = 3)
#' moving_average(x, window = 3, type = "weighted")
moving_average <- function(x, window = 3,
                           type = c("simple", "weighted"),
                           align = c("center", "left", "right")) {
  type <- match.arg(type)
  align <- match.arg(align)

  if (window > length(x)) {
    stop("Window size cannot exceed length of x")
  }

  if (window < 1) {
    stop("Window size must be at least 1
")
  }

  weights <- if (type == "weighted") {
    seq_len(window) / sum(seq_len(window))
  } else {
    rep(1/window, window)
  }

  zoo::rollapply(x, width = window, FUN = function(w) sum(w * weights),
                 align = align, fill = NA)
}
```

### ✅ Test Suite

#### tests/testthat/test-handle_missing.R

```r
test_that("handle_missing works with linear interpolation", {
  x <- c(1, 2, NA, 4, 5)
  result <- handle_missing(x, method = "linear")
  expect_equal(result[3], 3)
})

test_that("handle_missing respects max_gap", {
  x <- c(1, NA, NA, NA, 5)
  result <- handle_missing(x, method = "linear", max_gap = 2)
  expect_true(all(is.na(result[2:4])))
})

test_that("handle_missing errors on non-numeric input", {
  expect_error(handle_missing(c("a", "b")), "must be numeric")
})

test_that("handle_missing warns on all-NA input", {
  expect_warning(handle_missing(c(NA, NA, NA)), "All values are NA")
})
```

### 📖 Vignette Preview

```r
# From vignettes/introduction.Rmd

## Basic Usage

library(timeseriestools)

# Handle missing values
data <- c(1, 2, NA, 4, 5, NA, 7, 8)
clean_data <- handle_missing(data, method = "linear")

# Calculate moving average
ma <- moving_average(clean_data, window = 3)

# Plot time series
plot_timeseries(clean_data, show_trend = TRUE)
```

### 🔍 R CMD Check Results

```
── R CMD check ──────────────────────────────────────
✓ No ERRORs
✓ No WARNINGs
ℹ 1 NOTE: New submission

── Test Results ─────────────────────────────────────
✓ All 12 tests passed
✓ Coverage: 94%
```

### Next Steps

1. Run `devtools::check()` to verify package
2. Run `devtools::test()` to execute test suite
3. Build vignette with `devtools::build_vignettes()`
4. Consider submitting to CRAN after thorough testing
```

## Tips for R Package Development

1. **Follow CRAN Guidelines**: Check with `R CMD check --as-cran`
2. **Document Everything**: Use roxygen2 for all exported functions
3. **Test Thoroughly**: Aim for >80% code coverage
4. **Handle Edge Cases**: NA values, empty inputs, invalid types
5. **Minimize Dependencies**: Only import what you truly need

## MCP Integration

With `r-mcptools` and `r-mcp-server` installed, the agent can:
- Execute R code directly to test functions
- Run `R CMD check` automatically
- Install and load the package for testing
- Generate documentation with roxygen2

## Related Agents

- [code-reviewer](../.claude/agents/code-reviewer.md) - For reviewing R code quality
- See also: [MCP Integration Guide](../docs/mcp-integration.md)
