# bruceR

**BR**oadly **U**seful **C**onvenient and **E**fficient **R** functions

![](https://img.shields.io/badge/R-package-success)
![](https://img.shields.io/badge/Version-0.6.0-success)
![](https://img.shields.io/github/license/psychbruce/bruceR?label=License&color=success)
[![](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![](https://img.shields.io/github/stars/psychbruce/bruceR?style=social)](https://github.com/psychbruce/bruceR/stargazers)

<a href="https://en.wikipedia.org/wiki/Creative_Commons_license"><img src="https://s1.ax1x.com/2020/07/28/aAjUJg.jpg" width="120px" height="42px"></a>

- 复制、修改、使用、分享本代码库，必须遵守<b>「创作共用许可协议 CC BY-NC-SA」（原作者署名-非商业用途使用-相同方式共享）</b>


## Author

[包寒吴霜 \| Bao H.-W.-S.](https://psychbruce.github.io)

E-mail: [baohws@foxmail.com](mailto:baohws@foxmail.com)

Website: [psychbruce.github.io](https://psychbruce.github.io)

[ResearchGate](https://www.researchgate.net/profile/Han_Wu_Shuang_Bao) |
[GitHub](https://github.com/psychbruce) |
[知乎](https://www.zhihu.com/people/psychbruce)


## Citation

```r
citation("bruceR")
```
Bao, H.-W.-S. (2021). bruceR: BRoadly Useful Convenient and Efficient R functions. R package version 0.6.0. https://github.com/psychbruce/bruceR


## User Guide

### Installation

```r
## Method 1: Install from CRAN (coming soon...)
install.packages("bruceR")

## Method 2: Install from GitHub (using "devtools")
install.packages("devtools")
devtools::install_github("psychbruce/bruceR")

## Method 3: Install from GitHub (using "pacman")
install.packages("pacman")
pacman::p_install_gh("psychbruce/bruceR")
```
- [Installation Guide for bruceR (安装遇到问题时请阅读！)](https://github.com/psychbruce/stats/blob/master/Installation_Guide_for_bruceR.md)


### Package Dependency

`bruceR` depends on many important R packages.

Loading `bruceR` by `library(bruceR)` will also load these R packages for you:

- [Data]:
  + [`rio`](https://cran.r-project.org/package=rio):
  Data import and export (for all file formats).
  + [`dplyr`](https://cran.r-project.org/package=dplyr):
  Data manipulation and processing.
  + [`tidyr`](https://cran.r-project.org/package=tidyr):
  Data cleaning and reshaping.
  + [`stringr`](https://cran.r-project.org/package=stringr):
  Toolbox for string operation (with regular expressions).
  + [`forcats`](https://cran.r-project.org/package=forcats):
  Toolbox for factor manipulation (for categorical variables).
  + [`data.table`](https://cran.r-project.org/package=data.table):
  Advanced `data.frame` with higher efficiency.

- [Stat]:
  + [`psych`](https://cran.r-project.org/package=psych):
  Toolbox for psychological and psychometric research.
  + [`emmeans`](https://cran.r-project.org/package=emmeans):
  Toolbox for estimated marginal means and contrasts.
  + [`effectsize`](https://cran.r-project.org/package=effectsize):
  Indices of effect size and standardized parameters.
  + [`performance`](https://cran.r-project.org/package=performance):
  Assessment of regression models performance.

- [Plot]:
  + [`ggplot2`](https://cran.r-project.org/package=ggplot2):
  Data visualization.
  + [`cowplot`](https://cran.r-project.org/package=cowplot):
  Advanced toolbox for `ggplot2` (arrange multiple plots and add labels).
  + [`see`](https://cran.r-project.org/package=see):
  Advanced toolbox for `ggplot2` (extra geoms, scales, themes, and color palettes).

`library(bruceR)` is enough.


### Main Functions in `bruceR`

- [x] Basic Use and Analysis
  + `set.wd()`
  + `Print()`, `Glue()`
  + `Describe()`, `Freq()`, `Corr()`
  + `LOOKUP()`, `RANDBETWEEN()`
  + `%notin%`, `%partin%`, `%allin%`, `%nonein%`, `%anyin%`
- [x] Multivariate Computation
  + `RECODE()`, `RESCALE()`
  + `COUNT()`, `MODE()`, `SUM()`, `MEAN()`, `STD()`, `CONSEC()`
- [x] Reliability and Validity Analysis
  + `Alpha()`
  + `EFA()`
  + `CFA()`
- [x] Multi-Factor Analysis of Variance, Simple-Effect Analysis, and Multiple Comparison
  + `MANOVA()`
  + `EMMEANS()`
- [x] Advanced Toolbox for Statistics
  + `grand_mean_center()`, `group_mean_center()`
  + `GLM_summary()`, `HLM_summary()`, `regress()`
  + `model_summary()`
  + `med_summary()`
  + `ccf_plot()`
  + `granger_test()`
- [x] Theme for `ggplot2`
  + `theme_bruce()`


### Learn More From Help Pages

```r
library(bruceR)

## Overview
?bruceR

## See help pages of R functions
## (use `?function` or `help(function)`)
?Describe
?Corr
?SUM
?MEAN
?MANOVA
?EMMEANS
?model_summary
?med_summary
?GLM_summary
?HLM_summary
...
```


## Release Notes

### Current Version: `0.6.0`

### Major Changes:

- `0.6.0` - 2021.03
  + Passed R CMD check: `0 errors √ | 0 warnings √ | 0 notes √`
  + New function `model_summary()`: Tidy report of (single/multiple) regression models (into console or to a Word/HTML file; based on the `texreg` package; supporting most types of models)
  + New function `med_summary()`: Tidy report of (simple/moderated) mediation analyses (based on the `mediation` package)
  + New function `ccf_plot`: Cross-correlation analysis (plotting with `ggplot2`)
  + New function `granger_test`: Granger test of predictive causality (based on the `lmtest::grangertest()` function)
  + More packages for default loading
  + Less packages for default installation (you can install all suggested packages by using the `pkg_install_suggested()` function)
  + Tidy welcome messages when you `library(bruceR)`
  + Deprecated some useless/defective functions (see [details](https://github.com/psychbruce/bruceR/blob/master/R/deprecated.R))
  + Reorganized [raw code files](https://github.com/psychbruce/bruceR/tree/master/R)
  + Fixed some bugs and improved some functions
- `0.5.0` - 2020.08
  + Automatically checking updates when `library(bruceR)`
  + Requiring R version 4.0+
  + Improved many functions
  + Fixed many bugs
- `0.4.0` - 2019.12
  + Added citation information
  + General bug-fixes and improvements
- `0.3.0` - 2019.10
  + New functions `MANOVA` and `EMMEANS`: ANOVA, simple-effect analyses, and multiple comparisons (based on the `afex` and `emmeans` packages)
  + General bug-fixes and improvements
- `0.2.0` - 2019.08
  + Added help pages
  + General bug-fixes and improvements
- `0.1.0` - 2019.06
  + Initial commit
