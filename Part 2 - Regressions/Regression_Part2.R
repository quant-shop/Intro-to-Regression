# =====================================================================
# QUANTITATIVE HISTORIES WORKSHOP | REGRESSION SESSION PART 2
# Three regression examples using ACS 2023 census tracts in:
#   Mobile County AL, Hennepin County MN, Prince George's County MD, Washington DC
# HOW TO RUN: put your cursor on a line and press Ctrl+Enter (Mac: Cmd+Enter).
# Results print in the Console (bottom left). Plots show in the Plots tab (bottom right).
# NO API KEY NEEDED: this file reads the CSV saved by Part 1 (ECHO_Health_Part1_Data.Rmd).
# OUTCOME: % uninsured, the health outcome available in the ACS.
# =====================================================================

# ---- STEP 1: Load packages ----------------------------------------
# First time ever? Remove the # on the next line and run it once.
# install.packages(c("tidyverse", "broom"))
library(tidyverse)   # reading files, cleaning tables, ggplot2 for plots
library(broom)       # turns regression results into tidy tables (tibbles)

# ---- STEP 2: Read the Part 1 data frame ----------------------------
# A window will open: find and click "echo_health_tracts_acs2023.csv".
# col_types keeps GEOID as text so Alabama's leading 0 (01097...) is not dropped.
health_df <- read_csv(file.choose(), col_types = cols(GEOID = "c", county_fips = "c"))
health_df   # typing a name prints the tibble on screen

# FIPS codes (from Part 1):  01097 = Mobile AL | 27053 = Hennepin MN | 24033 = Prince George's MD | 11001 = Washington DC

# ---- STEP 3: Make the extra percentages we need --------------------
# Part 1 already made pct_black, pct_poverty, pct_uninsured, pct_no_vehicle, pct_rent_burden.
model_df <- health_df %>%
  mutate(county          = factor(county_fips, levels = c("01097", "27053", "24033", "11001"),  # Mobile listed 1st =
                                  labels = c("Mobile AL", "Hennepin MN",                       # the comparison county
                                             "Prince George's MD", "Washington DC")),
         pct_white       = 100 * white_pop / total_pop,           # % White alone (B02001_002)
         pct_hispanic    = 100 * hispanic_pop / total_pop,        # % Hispanic or Latino (B03002_012)
         pct_no_internet = 100 * no_internet / internet_denom,    # % homes with no internet (B28002_013)
         pct_transit     = 100 * commute_transit / commute_total, # % workers riding transit (B08301_010)
         pct_no_plumbing = 100 * no_plumbing / housing_units,     # % homes lacking plumbing (B25047_003)
         income_10k      = med_hh_income / 10000) %>%             # income in $10,000s (easier to read)
  select(GEOID, county, pct_uninsured, pct_black, pct_white, pct_hispanic, pct_poverty, income_10k,
         pct_no_vehicle, pct_rent_burden, pct_transit, pct_no_plumbing, pct_no_internet) %>%
  drop_na()   # drop tracts with blanks so ALL three models use the SAME tracts
model_df
count(model_df, county)   # how many tracts per county

# =====================================================================
# EXAMPLE 1: HEALTH ~ BLACK POPULATION
# Question: Do tracts with a larger Black share have higher uninsured rates?
# =====================================================================
model1 <- lm(pct_uninsured ~ pct_black, data = model_df)
anova(model1)     # ANOVA: does pct_black explain a real share of the variation? (look at Pr(>F))
summary(model1)   # SUMMARY: Estimate = change in % uninsured for each 1-point rise in % Black
tidy(model1)      # same results as a tibble

ggplot(model_df, aes(x = pct_black, y = pct_uninsured)) +
  geom_point(alpha = 0.4) +                          # one dot per tract
  geom_smooth(method = "lm", color = "red") +        # straight regression line + confidence band
  labs(title = "Example 1: Uninsured Rate vs. Black Population Share",
       x = "% Black residents", y = "% Uninsured")

# =====================================================================
# EXAMPLE 2: HEALTH ~ BLACK POPULATION + EDUCATION ACCESS
# Our health file has no degree variables, so we use % of homes with NO INTERNET,
# the "homework gap": kids without home internet struggle to keep up in school.
# Question: Does adding internet access help explain uninsured rates?
# =====================================================================
model2 <- lm(pct_uninsured ~ pct_black + pct_no_internet, data = model_df)
anova(model2)          # ANOVA for each variable, added in order
summary(model2)        # compare the pct_black Estimate here to Example 1 - did it change?
tidy(model2)
anova(model1, model2)  # ANOVA COMPARISON: does adding internet improve the model? small Pr(>F) = yes

ggplot(model_df, aes(x = pct_no_internet, y = pct_uninsured, color = pct_black)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Example 2: Uninsured Rate vs. Homes Without Internet",
       x = "% of homes with no internet access", y = "% Uninsured", color = "% Black")

# =====================================================================
# EXAMPLE 3: THE BEST 10-VARIABLE MODEL
# We tested every 10-variable combination from this file; this one explained the most
# (adjusted R-squared about 0.66, several other combinations were nearly tied).
# Watch two things: % Hispanic is the strongest predictor, and the county terms show
# the other places are well below Mobile AL. Alabama never expanded Medicaid; MN, MD and DC did.
# =====================================================================
model3 <- lm(pct_uninsured ~ pct_black + pct_white + pct_hispanic + pct_poverty + income_10k +
               pct_no_vehicle + pct_rent_burden + pct_transit + pct_no_plumbing + county,
             data = model_df)
anova(model3)
summary(model3)   # county Estimates = difference from Mobile AL, holding everything else equal
tidy(model3)
anova(model2, model3)  # does the full model beat Example 2?

# Which model fits best? Adjusted R-squared = share of variation explained (higher = better)
tibble(model  = c("1: Black share", "2: + no internet", "3: best 10 variables"),
       adj_r2 = c(summary(model1)$adj.r.squared, summary(model2)$adj.r.squared,
                  summary(model3)$adj.r.squared))

# PLOT: straight line (lm) vs. flexible curve (loess)
# lm    = forces ONE straight line through the data (what regression assumes)
# loess = bends to follow the data locally; where it curves away from lm, the relationship is not straight
ggplot(model_df, aes(x = pct_hispanic, y = pct_uninsured)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm",    aes(color = "Standard (lm): straight line"), se = FALSE) +
  geom_smooth(method = "loess", aes(color = "LOESS: flexible curve"),        se = FALSE) +
  labs(title = "Example 3: Straight-Line vs. LOESS Smoothing",
       x = "% Hispanic or Latino residents", y = "% Uninsured", color = "Smoothing method") +
  theme(legend.position = "bottom")
