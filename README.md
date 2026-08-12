# Brief Introduction to Regression, Part 1

Teaching materials for a workshop session on ordinary least squares (OLS)
regression: choosing a model, fitting it, and reading the output table.

**Quantitative Histories Workshop** · Session delivered 11 August 2026
Author: Ari Kamau (TA)

---

## What this is

A single self-contained R Markdown lesson (`Intro_to_Regression_Aug11.Rmd`) that
walks from "what is regression" through to a fully annotated `summary(lm())`
table. It is written to be **run, not just read** — every example uses `mtcars`,
a dataset that ships with R, so nothing needs to be downloaded and nothing
touches your own files.

Knitting the file produces a navigable HTML page with a floating table of
contents, numbered sections, and foldable code chunks.

## Contents

| Section | Topic |
|---|---|
| 1 | What regression is — dependent vs. independent variables, population truth vs. sample estimates |
| 2 | Choosing a model, and why OLS — closed form, minimizing squared residuals, ubiquity in the literature |
| 3 | The data: `mtcars` (32 cars, *Motor Trend* 1974) |
| 4 | OLS with one predictor — fitting `mpg ~ wt`, visualizing residuals, reading every column of the output |
| 5 | Multiple predictors — `mpg ~ wt + hp + am`, and whether the extra variables earned their keep |
| 6 | The three numbers to check every time — p-value, $R^2$ / adjusted $R^2$, degrees of freedom |
| 7 | What can go wrong — the assumptions A1–A6, and a preview of heteroskedasticity, omitted variable bias, confounding, and collinearity |
| Appendix | Vocabulary glossary and a reference table of the R commands used |

Along the way the lesson covers the sum-of-squares decomposition
($SS_{tot} = SS_{reg} + SS_{res}$), residual standard error, the F-statistic,
and why adjusted $R^2$ is the number to compare models on.

## Requirements

- **R** (≥ 4.0 recommended)
- **RStudio** — recommended, for the Knit button and per-chunk execution
- R packages:
  - `rmarkdown` and `knitr` (bundled with RStudio; otherwise install them)
  - `ggplot2` — the document installs this automatically if it is missing

```r
install.packages(c("rmarkdown", "knitr", "ggplot2"))
```

No other data files are needed. `mtcars` is built into base R.

## How to run it

**In RStudio**

1. Open `Intro_to_Regression_Aug11.Rmd`.
2. Press the green play button (▶) at the top-right of any grey chunk to run
   just that chunk.
3. Press **Knit** to render the whole file to HTML.



## Sources

- Yang, Q. (2017). "Regression." In L.A. Schintler & C.L. McNeely (eds.),
  *Encyclopedia of Big Data*. Springer. DOI 10.1007/978-3-319-32001-4_174-1
- Greene, W.H. (2003). *Econometric Analysis*, 5th ed. Prentice Hall.
  Ch. 2 (the classical linear regression model and its assumptions) and
  Ch. 3 (least squares, the sum-of-squares decomposition, and $R^2$)
- Henderson & Velleman (1981), *Motor Trend* 1974 — via R's `mtcars`

