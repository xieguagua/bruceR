% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bruceR_stats_02_scale.R
\name{CFA}
\alias{CFA}
\title{Confirmatory Factor Analysis (CFA).}
\usage{
CFA(
  data,
  model = "A =~ a[1:5]; B =~ b[c(1,3,5)]; C =~ c1 + c2 + c3",
  highorder = "",
  orthogonal = FALSE,
  missing = "listwise",
  digits = 3,
  nsmall = digits,
  file = NULL
)
}
\arguments{
\item{data}{Data frame.}

\item{model}{Model formula. See examples.}

\item{highorder}{High-order factor. Default is \code{""}.}

\item{orthogonal}{Default is \code{FALSE}. If \code{TRUE}, all covariances among latent variables are set to zero.}

\item{missing}{Default is \code{"listwise"}. Alternative is \code{"fiml"} ("Full Information Maximum Likelihood").}

\item{digits, nsmall}{Number of decimal places of output. Default is \code{3}.}

\item{file}{File name of MS Word (\code{.doc}).}
}
\value{
A list of results returned by \code{\link[lavaan:cfa]{lavaan::cfa()}}.
}
\description{
An extension of \code{\link[lavaan:cfa]{lavaan::cfa()}}.
}
\examples{
\donttest{data.cfa=lavaan::HolzingerSwineford1939
CFA(data.cfa, "Visual =~ x[1:3]; Textual =~ x[c(4,5,6)]; Speed =~ x7 + x8 + x9")
CFA(data.cfa, model="
    Visual =~ x[1:3]
    Textual =~ x[c(4,5,6)]
    Speed =~ x7 + x8 + x9
    ", highorder="Ability")

data.bfi=na.omit(psych::bfi)
CFA(data.bfi, "E =~ E[1:5]; A =~ A[1:5]; C =~ C[1:5]; N =~ N[1:5]; O =~ O[1:5]")
}
}
\seealso{
\code{\link{Alpha}}, \code{\link{EFA}}, \code{\link{lavaan_summary}}
}
