#### Multivariate Computation ####


#' Recode a variable.
#'
#' A wrapper of \code{\link[car:recode]{car::recode()}}.
#'
#' @param var Variable (numeric, character, or factor).
#' @param recodes A character string definine the rule of recoding. e.g., \code{"lo:1=0; c(2,3)=1; 4=2; 5:hi=3; else=999"}
#'
#' @return A vector of recoded variable.
#'
#' @examples
#' d=data.table(var=c(NA, 0, 1, 2, 3, 4, 5, 6))
#' d[, `:=`(
#'   var.new=RECODE(var, "lo:1=0; c(2,3)=1; 4=2; 5:hi=3; else=999")
#' )]
#' d
#'
#' @export
RECODE=function(var, recodes) {
  car::recode(var, recodes)
}


#' Rescale a variable (e.g., from 5-point to 7-point).
#'
#' @param var Variable (numeric).
#' @param from Numeric vector, the range of old scale (e.g., \code{1:5}).
#' If not defined, it will compute the range of \code{var}.
#' @param to Numeric vector, the range of new scale (e.g., \code{1:7}).
#'
#' @return A vector of rescaled variable.
#'
#' @examples
#' d=data.table(var=rep(1:5, 2))
#' d[,":="(var1=RESCALE(var, to=1:7),
#'         var2=RESCALE(var, from=1:5, to=1:7))]
#' d  # var1 is equal to var2
#'
#' @export
RESCALE=function(var, from=range(var, na.rm=T), to) {
  (var - median(from)) / (max(from) - median(from)) * (max(to) - median(to)) + median(to)
}


#' Min-max scaling (min-max normalization).
#'
#' This function resembles \code{\link[bruceR:RESCALE]{RESCALE()}}
#' and it is just equivalent to \code{RESCALE(var, to=0:1)}.
#'
#' @param v Variable (numeric vector).
#' @param min Minimum value (default is 0).
#' @param max Maximum value (default is 1).
#'
#' @return A vector of rescaled variable.
#'
#' @examples
#' scaler(1:5)
#' # the same: RESCALE(1:5, to=0:1)
#'
#' @export
scaler=function(v, min=0, max=1) {
  min + (v - min(v, na.rm=T)) * (max - min) / (max(v, na.rm=T) - min(v, na.rm=T))
}


#' Multivariate computation.
#'
#' @description
#' Easily compute multivariate sum, mean, and other scores.
#' Reverse scoring can also be easily implemented without saving extra variables.
#' \code{\link{Alpha}} function uses a similar method to deal with reverse scoring.
#'
#' Three options to specify variables:
#' \enumerate{
#'   \item \strong{\code{var + items}}: use the common and unique parts of variable names.
#'   \item \strong{\code{vars}}: directly define a character vector of variables.
#'   \item \strong{\code{varrange}}: use the starting and stopping positions of variables.
#' }
#'
#' @param data Data frame.
#' @param var \strong{[Option 1]}
#' The common part across the variables. e.g., \code{"RSES"}
#' @param items \strong{[Option 1]}
#' The unique part across the variables. e.g., \code{1:10}
#' @param vars \strong{[Option 2]}
#' A character vector specifying the variables. e.g., \code{c("X1", "X2", "X3", "X4", "X5")}
#' @param varrange \strong{[Option 3]}
#' A character string specifying the positions ("starting:stopping") of variables. e.g., \code{"A1:E5"}
#' @param value [Only for \code{COUNT}] The value to be counted.
#' @param rev [Optional] Variables that need to be reversed. It can be
#' (1) a character vector specifying the reverse-scoring variables (recommended), or
#' (2) a numeric vector specifying the item number of reverse-scoring variables (not recommended).
#' @param likert [Optional] Range of likert scale (e.g., \code{1:5}, \code{c(1, 5)}).
#' If not provided, it will be automatically estimated from the given data (BUT you should use this carefully).
#' @param na.rm Ignore missing values. Default is \code{TRUE}.
#' @param values [Only for \code{CONSEC}] Values to be counted as consecutive identical values. Default is all numbers (\code{0:9}).
#'
#' @return A vector of computed values.
#'
#' @examples
#' d=data.table(x1=1:5,
#'              x4=c(2,2,5,4,5),
#'              x3=c(3,2,NA,NA,5),
#'              x2=c(4,4,NA,2,5),
#'              x5=c(5,4,1,4,5))
#' d
#' ## I deliberately set this order to show you
#' ## the difference between "vars" and "varrange".
#'
#' d[,`:=`(
#'   na=COUNT(d, "x", 1:5, value=NA),
#'   n.2=COUNT(d, "x", 1:5, value=2),
#'   sum=SUM(d, "x", 1:5),
#'   m1=MEAN(d, "x", 1:5),
#'   m2=MEAN(d, vars=c("x1", "x4")),
#'   m3=MEAN(d, varrange="x1:x2", rev="x2", likert=1:5),
#'   cons1=CONSEC(d, "x", 1:5),
#'   cons2=CONSEC(d, varrange="x1:x5")
#' )]
#' d
#'
#' data=as.data.table(psych::bfi)
#' data[,`:=`(
#'   E=MEAN(d, "E", 1:5, rev=c(1,2), likert=1:6),
#'   O=MEAN(d, "O", 1:5, rev=c(2,5), likert=1:6)
#' )]
#' data
#'
#' @name %%COMPUTE%%
## @aliases COUNT SUM MEAN STD CONSEC
NULL


convert2vars=function(data,
                      var=NULL, items=NULL,
                      vars=NULL,
                      varrange=NULL,
                      rev=NULL) {
  if(!is.null(varrange)) {
    dn=names(data)
    varrange=gsub(" ", "", strsplit(varrange, ":")[[1]])
    vars=dn[which(dn==varrange[1]):which(dn==varrange[2])]
  }
  if(is.null(vars)) vars=paste0(var, items)
  if(is.numeric(rev)) rev=paste0(var, rev)  # bug fixed on 2019-09-28
  if(is.character(rev)) rev=which(vars %in% rev)
  vars.raw=vars
  # vars=paste(deparse(substitute(data)), vars, sep="$")
  vars=paste0(deparse(substitute(data)), "$`", vars, "`")
  return(list(vars.raw=vars.raw, vars=vars, rev=rev))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes \strong{Count} a certain value across multiple variables.
#' @export
COUNT=function(data, var=NULL, items=NULL, vars=NULL, varrange=NULL,
               value=NA) {
  Count=function(...) sum(c(...), na.rm=TRUE)
  v.r=convert2vars(data, var, items, vars, varrange)
  vars=v.r$vars
  if(is.na(value))
    varlist=paste0("is.na(", vars, ")")
  else
    varlist=paste0(vars, "==", value)
  eval(parse(text=paste0("mapply(Count, ", paste(varlist, collapse=", "), ")")))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes Compute \strong{mode} across multiple variables.
#' @export
MODE=function(data, var=NULL, items=NULL, vars=NULL, varrange=NULL) {
  getmode=function(v) {
    uniqv=unique(v)
    uniqv[which.max(tabulate(match(v, uniqv)))]
  }
  Mode=function(...) getmode(c(...))
  varlist=convert2vars(data, var, items, vars, varrange)$vars
  eval(parse(text=paste0("mapply(Mode, ", paste(varlist, collapse=", "), ")")))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes Compute \strong{sum} across multiple variables.
#' @export
SUM=function(data, var=NULL, items=NULL, vars=NULL, varrange=NULL,
             rev=NULL, likert=NULL,
             na.rm=TRUE) {
  Sum=function(...) sum(..., na.rm=na.rm)
  v.r=convert2vars(data, var, items, vars, varrange, rev)
  vars=v.r$vars
  rev=v.r$rev
  if(!is.null(rev) & is.null(likert)) {
    ranges=apply(as.data.frame(data)[,v.r$vars.raw], 2, function(...) range(..., na.rm=TRUE))
    likert=c(min(ranges[1,], na.rm=TRUE), max(ranges[2,], na.rm=TRUE))
    warning("The range of likert scale was automatically estimated from the given data. If you are not sure about this, please specify the `likert` argument. See ?SUM", call.=TRUE)
  }
  pre=rep("", length(vars))
  pre[rev]=ifelse(is.null(likert), "", paste0(sum(range(likert)), "-"))
  varlist=paste0(pre, vars)
  eval(parse(text=paste0("mapply(Sum, ", paste(varlist, collapse=", "), ")")))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes Compute \strong{mean} across multiple variables.
#' @export
MEAN=function(data, var=NULL, items=NULL, vars=NULL, varrange=NULL,
              rev=NULL, likert=NULL,
              na.rm=TRUE) {
  Mean=function(...) mean(c(...), na.rm=na.rm)
  v.r=convert2vars(data, var, items, vars, varrange, rev)
  vars=v.r$vars
  rev=v.r$rev
  if(!is.null(rev) & is.null(likert)) {
    ranges=apply(as.data.frame(data)[,v.r$vars.raw], 2, function(...) range(..., na.rm=TRUE))
    likert=c(min(ranges[1,], na.rm=TRUE), max(ranges[2,], na.rm=TRUE))
    warning("The range of likert scale was automatically estimated from the given data. If you are not sure about this, please specify the `likert` argument. See ?MEAN", call.=TRUE)
  }
  pre=rep("", length(vars))
  pre[rev]=ifelse(is.null(likert), "", paste0(sum(range(likert)), "-"))
  varlist=paste0(pre, vars)
  eval(parse(text=paste0("mapply(Mean, ", paste(varlist, collapse=", "), ")")))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes Compute \strong{standard deviation} across multiple variables.
#' @export
STD=function(data, var=NULL, items=NULL, vars=NULL, varrange=NULL,
             rev=NULL, likert=NULL,
             na.rm=TRUE) {
  Std=function(...) sd(c(...), na.rm=na.rm)
  v.r=convert2vars(data, var, items, vars, varrange, rev)
  vars=v.r$vars
  rev=v.r$rev
  if(!is.null(rev) & is.null(likert)) {
    ranges=apply(as.data.frame(data)[,v.r$vars.raw], 2, function(...) range(..., na.rm=TRUE))
    likert=c(min(ranges[1,], na.rm=TRUE), max(ranges[2,], na.rm=TRUE))
    warning("The range of likert scale was automatically estimated from the given data. If you are not sure about this, please specify the `likert` argument. See ?STD", call.=TRUE)
  }
  pre=rep("", length(vars))
  pre[rev]=ifelse(is.null(likert), "", paste0(sum(range(likert)), "-"))
  varlist=paste0(pre, vars)
  eval(parse(text=paste0("mapply(Std, ", paste(varlist, collapse=", "), ")")))
}


#' @describeIn grapes-grapes-COMPUTE-grapes-grapes Compute \strong{consecutive identical digits} across multiple variables (especially useful in detecting careless responding).
#' @export
CONSEC=function(data, var=NULL, items=NULL,
                vars=NULL,
                varrange=NULL,
                values=0:9) {
  Conseq=function(string, number=values) {
    # Consecutive Identical Digits
    pattern=paste(paste0(number, "{2,}"), collapse="|")
    ifelse(grepl(pattern, string), max(nchar(str_extract_all(string=string, pattern=pattern, simplify=TRUE))), 0)
  }
  v.r=convert2vars(data, var, items, vars, varrange)
  vars=v.r$vars
  varlist=vars
  eval(parse(text=paste0("mapply(Conseq, paste0(", paste(varlist, collapse=", "), "))")))
}




#### Reliability, EFA, and CFA ####


#' Reliability analysis (Cronbach's \eqn{\alpha} and McDonald's \eqn{\omega}).
#'
#' @description
#' An extension of \code{\link[psych:alpha]{psych::alpha()}} and \code{\link[psych:omega]{psych::omega()}},
#' reporting (1) scale statistics
#' (Cronbach's \eqn{\alpha} and McDonald's \eqn{\omega}) and
#' (2) item statistics
#' (item-rest correlation [i.e., corrected item-total correlation]
#' and Cronbach's \eqn{\alpha} if item deleted).
#'
#' Three options to specify variables:
#' \enumerate{
#'   \item \strong{\code{var + items}}: use the common and unique parts of variable names.
#'   \item \strong{\code{vars}}: directly define a character vector of variables.
#'   \item \strong{\code{varrange}}: use the starting and stopping positions of variables.
#' }
#'
#' @inheritParams %%COMPUTE%%
#' @param digits,nsmall Number of decimal places of output. Default is \code{3}.
#'
#' @return
#' A list of results obtained from
#' \code{\link[psych:alpha]{psych::alpha()}} and \code{\link[psych:omega]{psych::omega()}}.
#'
#' @examples
#' # ?psych::bfi
#' data=psych::bfi
#' Alpha(data, "E", 1:5)  # "E1" & "E2" should be reversed
#' Alpha(data, "E", 1:5, rev=1:2)  # correct
#' Alpha(data, "E", 1:5, rev=c("E1", "E2"))  # also correct
#' Alpha(data, vars=c("E1", "E2", "E3", "E4", "E5"), rev=c("E1", "E2"))
#' Alpha(data, varrange="E1:E5", rev=c("E1", "E2"))
#'
#' # using dplyr::select()
#' data %>% select(E1, E2, E3, E4, E5) %>%
#'   Alpha(vars=names(.), rev=c("E1", "E2"))
#'
#' @seealso
#' \code{\link{MEAN}}, \code{\link{EFA}}, \code{\link{CFA}}
#'
#' @export
Alpha=function(data, var, items, vars=NULL, varrange=NULL, rev=NULL,
               digits=3, nsmall=digits) {
  if(!is.null(varrange)) {
    dn=names(data)
    varrange=gsub(" ", "", strsplit(varrange, ":")[[1]])
    vars=dn[which(dn==varrange[1]):which(dn==varrange[2])]
  }
  if(is.null(vars)) vars=paste0(var, items)
  if(is.numeric(rev)) rev=paste0(var, rev)
  n.total=nrow(data)
  data=na.omit(as.data.frame(data)[vars])
  n.valid=nrow(data)
  for(v in vars) {
    data[[v]]=as.numeric(data[[v]])
    if(v %in% rev) {
      data[[v]]=min(data[[v]])+max(data[[v]])-data[[v]]
      vr=paste(v, "(rev)")
      Run("data=dplyr::rename(data, `{vr}`={v})")
    }
  }
  nitems=length(vars)

  suppressMessages({
    suppressWarnings({
      alpha=psych::alpha(data, delete=FALSE, warnings=FALSE)
      omega=psych::omega(data, nfactors=1, flip=FALSE)
      loadings=psych::principal(data, nfactors=1, scores=FALSE)$loadings

      items=cbind(
        alpha$item.stats[c("mean", "sd", "r.drop")],
        alpha$alpha.drop[c("raw_alpha")])
      names(items)=c("Mean", "S.D.",
                     "Item-Rest Cor.",
                     "Cronbach\u2019s \u03b1")
      items.need.rev=vars[loadings<0]
    })
  })

  Print("
  \n
  <<cyan Reliability Analysis>>

  Summary:
  Total Items: {nitems}
  Scale Range: {min(data)} ~ {max(data)}
  Total Cases: {n.total}
  Valid Cases: {n.valid} ({100*n.valid/n.total:.1}%)

  Scale Statistics:
  <<italic Mean>> = {alpha$total$mean:.{nsmall}}
  <<italic S.D.>> = {alpha$total$sd:.{nsmall}}
  Cronbach\u2019s \u03b1 = {alpha$total$raw_alpha:.{nsmall}}
  McDonald\u2019s \u03c9 = {omega$omega.tot:.{nsmall}}
  ")
  # Cronbach's \u03b1: {alpha$total$raw_alpha:.{nsmall}} (based on raw scores)
  # Cronbach's \u03b1: {alpha$total$std.alpha:.{nsmall}} (based on standardized items)

  if(alpha$total$raw_alpha<0.5 | length(items.need.rev)>0) {
    cat("\n")
    if(alpha$total$raw_alpha<0.5)
      Print("<<yellow Warning: Scale reliability is low. You may check item codings.>>")
    if(length(items.need.rev)==1)
      Print("<<yellow Item {items.need.rev} correlates negatively with the scale and may be reversed.>>")
    if(length(items.need.rev)>1)
      Print("<<yellow Items {paste(items.need.rev, collapse=', ')} correlate negatively with the scale and may be reversed.>>")
    if(length(items.need.rev)>0)
      Print("<<yellow You can specify this argument: rev=c(\"{paste(items.need.rev, collapse='\", \"')}\")>>")
  }

  cat("\n")
  print_table(items, nsmalls=nsmall,
              title="Item Statistics (Cronbach\u2019s \u03b1 If Item Deleted):",
              note="Item-Rest Cor. = Corrected Item-Total Correlation")
  cat("\n")

  # rel=jmv::reliability(data, vars=eval(vars), revItems=eval(rev),
  #                      meanScale=TRUE, sdScale=TRUE,
  #                      alphaScale=TRUE, omegaScale=TRUE,
  #                      itemRestCor=TRUE, alphaItems=TRUE, omegaItems=TRUE)
  # rel$items$setTitle("Item Reliability Statistics (if item is dropped)")

  invisible(list(alpha=alpha, omega=omega))
}


#' Principal Component Analysis (PCA) and Exploratory Factor analysis (EFA).
#'
#' @description
#' An extension of \code{\link[psych:principal]{psych::principal()}} and \code{\link[psych:fa]{psych::fa()}},
#' performing either Principal Component Analysis (PCA) or Exploratory Factor Analysis (EFA).
#'
#' Three options to specify variables:
#' \enumerate{
#'   \item \strong{\code{var + items}}: use the common and unique parts of variable names.
#'   \item \strong{\code{vars}}: directly define a character vector of variables.
#'   \item \strong{\code{varrange}}: use the starting and stopping positions of variables.
#' }
#'
#' @inheritParams %%COMPUTE%%
#' @param method Extraction method.
#' \itemize{
#'   \item \code{"pca"} - Principal Component Analysis (default)
#'   \item \code{"pa"} - Principal Axis Factor Analysis
#'   \item \code{"ml"} - Maximum Likelihood Factor Analysis
#'   \item \code{"minres"} - Minimum Residual Factor Analysis
#'   \item \code{"uls"} - Unweighted Least Squares Factor Analysis
#'   \item \code{"ols"} - Ordinary Least Squares Factor Analysis
#'   \item \code{"wls"} - Weighted Least Squares Factor Analysis
#'   \item \code{"gls"} - Generalized Least Squares Factor Analysis
#'   \item \code{"alpha"} - Alpha Factor Analysis (Kaiser & Coffey, 1965)
#' }
#' @param rotation Rotation method.
#' \itemize{
#'   \item \code{"none"} - None (not suggested)
#'   \item \code{"varimax"} - Varimax (default)
#'   \item \code{"oblimin"} - Direct Oblimin
#'   \item \code{"promax"} - Promax
#'   \item \code{"quartimax"} - Quartimax
#'   \item \code{"equamax"} - Equamax
#' }
#' @param nfactors How to determine the number of factors/components?
#' \itemize{
#'   \item \code{"eigen"} - based on eigenvalue (> minimum eigenvalue) (default)
#'   \item \code{"parallel"} - based on parallel analysis
#'   \item (any number >= 1) - user-defined fixed number
#' }
#' @param sort.loadings Sort factor/component loadings by size? Default is \code{TRUE}.
#' @param hide.loadings A number (0~1) for hiding absolute factor/component loadings below this value.
#' Default is \code{0} (does not hide any loading).
#' @param plot.scree Display the scree plot? Default is \code{TRUE}.
#' @param kaiser Do the Kaiser normalization (as in SPSS)? Default is \code{TRUE}.
#' @param max.iter Maximum number of iterations for convergence. Default is \code{25} (the same as in SPSS).
#' @param min.eigen Minimum eigenvalue (used if \code{nfactors="eigen"}). Default is \code{1}.
#' @param digits,nsmall Number of decimal places of output. Default is \code{3}.
#' @param file File name of MS Word (\code{.doc}).
#' @param ... Arguments passed from \code{PCA()} to \code{EFA()}.
#'
#' @note
#' Results based on the \code{varimax} rotation method are identical to SPSS.
#' The other rotation methods may produce results slightly different from SPSS.
#'
#' @return
#' A list of results:
#' \describe{
#'   \item{\code{result}}{The R object returned from \code{\link[psych:principal]{psych::principal()}} or \code{\link[psych:fa]{psych::fa()}}}
#'   \item{\code{result.kaiser}}{The R object returned from \code{\link[psych:kaiser]{psych::kaiser()}} (if any)}
#'   \item{\code{extraction.method}}{Extraction method}
#'   \item{\code{rotation.method}}{Rotation method}
#'   \item{\code{eigenvalues}}{A \code{data.frame} of eigenvalues and sum of squared (SS) loadings}
#'   \item{\code{loadings}}{A \code{data.frame} of factor/component loadings and communalities}
#'   \item{\code{scree.plot}}{A \code{ggplot2} object of the scree plot}
#' }
#'
#' @describeIn EFA Exploratory Factor Analysis
#'
#' @seealso
#' \code{\link{MEAN}}, \code{\link{Alpha}}, \code{\link{CFA}}
#'
#' @examples
#' data=psych::bfi
#' EFA(data, "E", 1:5)              # var + items
#' EFA(data, "E", 1:5, nfactors=2)  # var + items
#'
#' EFA(data, varrange="A1:O5",
#'     nfactors="parallel",
#'     hide.loadings=0.45)
#'
#' # the same as above:
#' # using dplyr::select() and dplyr::matches()
#' # to select variables whose names end with numbers
#' # (regexp: \\d matches all numbers, $ matches the end of a string)
#' data %>% select(matches("\\d$")) %>%
#'   EFA(vars=names(.),       # all selected variables
#'       method="pca",        # default
#'       rotation="varimax",  # default
#'       nfactors="parallel", # parallel analysis
#'       hide.loadings=0.45)  # hide loadings < 0.45
#'
#' @export
EFA=function(data, var, items, vars=NULL, varrange=NULL, rev=NULL,
             method=c("pca", "pa", "ml", "minres", "uls", "ols", "wls", "gls", "alpha"),
             rotation=c("none", "varimax", "oblimin", "promax", "quartimax", "equamax"),
             nfactors=c("eigen", "parallel", "(any number >= 1)"),
             sort.loadings=TRUE,
             hide.loadings=0.00,
             plot.scree=TRUE,
             # plot.factor=TRUE,
             kaiser=TRUE,
             max.iter=25,
             min.eigen=1,
             digits=3, nsmall=digits,
             file=NULL) {
  if(!is.null(varrange)) {
    dn=names(data)
    varrange=gsub(" ", "", strsplit(varrange, ":")[[1]])
    vars=dn[which(dn==varrange[1]):which(dn==varrange[2])]
  }
  if(is.null(vars)) vars=paste0(var, items)
  if(is.numeric(rev)) rev=paste0(var, rev)
  n.total=nrow(data)
  data=na.omit(as.data.frame(data)[vars])
  n.valid=nrow(data)
  for(v in vars) {
    data[[v]]=as.numeric(data[[v]])
    if(v %in% rev) {
      data[[v]]=min(data[[v]])+max(data[[v]])-data[[v]]
      vr=paste(v, "(rev)")
      Run("data=dplyr::rename(data, `{vr}`={v})")
    }
  }
  nitems=length(vars)

  # determine number of factors
  eigen.value=eigen(cor(data), only.values=TRUE)$values
  eigen.parallel=NULL
  error.nfactors="`nfactors` should be \"eigen\", \"parallel\", or an integer (>= 1)."
  if(length(nfactors)>1) nfactors="eigen"
  if(is.numeric(nfactors)) {
    if(nfactors<1) stop(error.nfactors, call.=FALSE)
    nfactors=nfactors
  } else if(nfactors=="eigen") {
    nfactors=sum(eigen.value>min.eigen)
  } else if(nfactors=="parallel") {
    eigen.parallel=parallel_analysis(nrow(data), ncol(data), niter=20)
    nfactors=max(which(eigen.value<=eigen.parallel)[1]-1, 1)
    if(is.na(nfactors)) nfactors=length(eigen.value)
  } else {
    stop(error.nfactors, call.=FALSE)
  }

  # extraction method
  valid.methods=c("pca", "pa", "ml", "minres", "uls", "ols", "wls", "gls", "alpha")
  if(length(method)>1) method="pca"
  if(method %notin% valid.methods)
    stop(Glue("
    EFA() has changed significantly since bruceR v0.8.0.
    `method` should be one of \"{paste(valid.methods, collapse='\", \"')}\".
    Please see the help page: help(EFA)"), call.=FALSE)
  Method=switch(
    method,
    "pca"="Principal Component Analysis",
    "pa"="Principal Axis Factor Analysis",
    "ml"="Maximum Likelihood Factor Analysis",
    "minres"="Minimum Residual Factor Analysis",
    "uls"="Unweighted Least Squares Factor Analysis",
    "ols"="Ordinary Least Squares Factor Analysis",
    "wls"="Weighted Least Squares Factor Analysis",
    "gls"="Generalized Least Squares Factor Analysis",
    "alpha"="Alpha Factor Analysis (Kaiser & Coffey, 1965)")

  # rotation method
  valid.rotations=c("none", "varimax", "oblimin", "promax", "quartimax", "equamax")
  if(length(rotation)>1) rotation="varimax"
  if(rotation %notin% valid.rotations)
    stop(Glue("
    EFA() has changed significantly since bruceR v0.8.0.
    `rotation` should be one of \"{paste(valid.rotations, collapse='\", \"')}\".
    Please see the help page: help(EFA)"), call.=FALSE)
  Method.Rotation=switch(
    rotation,
    "none"="None",
    "varimax"="Varimax",
    "oblimin"="Oblimin",
    "promax"="Promax",
    "quartimax"="Quartimax",
    "equamax"="Equamax")
  if(rotation %in% c("none", "equamax")) kaiser=FALSE
  if(kaiser) Method.Rotation=paste(Method.Rotation, "(with Kaiser Normalization)")
  if(nfactors==1) Method.Rotation="(Only one component was extracted. The solution was not rotated.)"

  # analyze
  suppressMessages({
    suppressWarnings({
      kmo=psych::KMO(data)$MSA
      btl=psych::cortest.bartlett(data, n=nrow(data))
      if(method=="pca") {
        efa=psych::principal(
          data, nfactors=nfactors, rotate=rotation)
      } else {
        efa=psych::fa(
          data, nfactors=nfactors, rotate=rotation,
          fm=method, max.iter=max.iter)
      }
      if(kaiser & nfactors>1) {
        Rotation=rotation
        if(rotation=="varimax") Rotation="Varimax"  # GPArotation::Varimax
        if(rotation=="promax") Rotation="Promax"  # psych::Promax
        efak=psych::kaiser(efa, rotate=Rotation)
        loadings=efak$loadings
      } else {
        efak=NULL
        loadings=efa$loadings
      }
      class(loadings)="matrix"
    })
  })

  # print
  analysis=ifelse(method=="pca",
                  "Principal Component Analysis",
                  "Explanatory Factor Analysis")
  tag=ifelse(method=="pca", "Component", "Factor")
  Print("
  \n
  <<cyan {analysis}>>

  Summary:
  Total Items: {nitems}
  Scale Range: {min(data)} ~ {max(data)}
  Total Cases: {n.total}
  Valid Cases: {n.valid} ({100*n.valid/n.total:.1}%)

  Extraction Method:
  - {Method}
  Rotation Method:
  - {Method.Rotation}

  KMO and Bartlett's Test:
  - Kaiser-Meyer-Olkin (KMO) Measure of Sampling Adequacy: MSA = {kmo:.{nsmall}}
  - Bartlett's Test of Sphericity: Approx. {p(chi2=btl$chisq, df=btl$df)}
  ")

  # eigenvalues and SS loadings
  SS.loadings=apply(apply(loadings, 2, function(x) x^2), 2, sum)
  SS.loadings=c(SS.loadings, rep(NA, nitems-nfactors))
  eigen=data.frame(
    Eigenvalue=eigen.value,
    PropVar0=100*(eigen.value/nitems),
    CumuVar0=cumsum(100*(eigen.value/nitems)),
    SS.Loading=SS.loadings,
    PropVar1=100*(SS.loadings/nitems),
    CumuVar1=cumsum(100*(SS.loadings/nitems))
  )
  row.names(eigen)=paste(tag, 1:nitems)
  names(eigen)=c("Eigenvalue", "Variance %", "Cumulative %",
                 "SS Loading", "Variance %", "Cumulative %")
  cat("\n")
  print_table(eigen, nsmalls=nsmall,
              title="Total Variance Explained:")

  # factor loadings
  loadings=as.data.frame(loadings)
  abs.loadings=abs(loadings)
  max=apply(abs.loadings, 1, max)
  which.max=apply(abs.loadings, 1, which.max)
  loadings$Communality=efa$communality
  # loadings$Uniqueness=efa$uniquenesses
  if(sort.loadings) loadings=loadings[order(which.max, -max), ]
  for(v in names(loadings)[1:nfactors]) {
    loadings[abs(loadings[[v]])<abs(hide.loadings), v]=NA
  }
  info1=ifelse(rotation!="none" & nfactors>1, " (Rotated)", "")
  info2=ifelse(sort.loadings, " (Sorted by Size)", "")
  loadings.info=info1%^%info2
  cat("\n")
  print_table(loadings, nsmalls=nsmall,
              title=Glue("{tag} Loadings{loadings.info}:"))
  Print("
  Communality = Sum of Squared (SS) Factor Loadings
  (Uniqueness = 1 - Communality)
  \n
  ")
  if(!is.null(file))
    print_table(loadings, nsmalls=nsmall, file=file,
                title=Glue("{tag} Loadings{loadings.info}:"),
                note=Glue("Extraction Method: {Method}.</p><p>Rotation Method: {Method.Rotation}."))

  # scree plot
  dp=data.frame(
    Type="Data",
    Component=1:length(eigen.value),
    Eigenvalue=eigen.value)
  if(!is.null(eigen.parallel)) {
    dp=rbind(dp, data.frame(
      Type="Parallel (Simulation)",
      Component=1:length(eigen.parallel),
      Eigenvalue=eigen.parallel))
  }
  Type=Component=Eigenvalue=NULL
  p=ggplot(dp, aes(x=Component, y=Eigenvalue, color=Type, fill=Type)) +
    geom_hline(yintercept=min.eigen, linetype=2) +
    geom_path(size=1) +
    geom_point(size=2.5, shape=21) +
    scale_y_continuous(limits=c(0, ceiling(max(eigen.value)))) +
    scale_color_manual(values=c("black", "grey50")) +
    scale_fill_manual(values=c("grey50", "grey90")) +
    labs(x=tag, title="Scree Plot") +
    theme_bruce() +
    theme(legend.position=c(0.85, 0.75))
  if(plot.scree) {
    try({
      plot.error=TRUE
      print(p)
      plot.error=FALSE
    }, silent=TRUE)
    if(plot.error) {
      warning=Glue("
        Plot is NOT successfully displayed in the RStudio `Plots` Pane.
        Please check if the `Plots` Pane of your RStudio is too small.
        You should enlarge the `Plots` Pane (and/or clear all plots).")
      warning(warning, call.=TRUE)
      cat("\n")
    }
  }

  # jmv::efa(data, vars=eval(expand_vars(vartext)),
  #          nFactorMethod=method,  # "eigen", "parallel", "fixed"
  #          extraction=extraction,  # "pa", "ml", "minres"
  #          rotation=rotation,  # "none", "varimax", "quartimax", "promax", "oblimin", "simplimax"
  #          minEigen=1,
  #          nFactors=nFactors,
  #          hideLoadings=hideLoadings, sortLoadings=TRUE,
  #          screePlot=TRUE, eigen=TRUE,
  #          factorCor=TRUE, factorSummary=TRUE, modelFit=TRUE,
  #          kmo=TRUE, bartlett=TRUE)

  invisible(list(
    result=efa,
    result.kaiser=efak,
    extraction.method=Method,
    rotation.method=Method.Rotation,
    eigenvalues=eigen,
    loadings=loadings,
    scree.plot=p))
}


#' @describeIn EFA Principal Component Analysis - a wrapper of \code{EFA(..., method="pca")}
#' @export
PCA=function(..., method="pca") { EFA(..., method=method) }


parallel_analysis=function(nrow, ncol, niter=20) {
  sim.eigen=lapply(1:niter, function(x) {
    sim.data=matrix(rnorm(nrow*ncol), nrow=nrow, ncol=ncol)
    eigen(cor(sim.data), only.values=TRUE)$values
  })
  sim.eigen=t(matrix(unlist(sim.eigen), ncol=niter))
  sim.eigen.CI=apply(sim.eigen, 2, function(x) quantile(x, 0.95))
  return(sim.eigen.CI)
}


## Expand multiple variables with complex string formats
## Input: "X[1:5] + Y[c(1,3)] + Z"
## Output:
expand_vars=function(vartext) {
  vartexts=gsub(" ", "", strsplit(vartext, "\\+")[[1]])
  vars=c()
  for(vartext.i in vartexts) {
    if(grepl("\\[|\\]", vartext.i)==TRUE) {
      vars.i=eval(parse(text=paste0("paste0('", gsub("\\]", ")", gsub("\\[", "',", vartext.i)))))
    } else {
      vars.i=vartext.i
    }
    vars=c(vars, vars.i)
  }
  return(vars)
}


## CFA model formula transformation
modelCFA.trans=function(style=c("jmv", "lavaan"),
                        model, highorder="") {
  # model: free style input
  model=gsub("^\\s+|\\s+$", "", model)
  model=strsplit(gsub(" ", "", strsplit(model, "(;|\\n)+")[[1]]), "=~")
  # jmv style
  model.jmv=list()
  for(i in 1:length(model)) {
    var=model[[i]][[2]]
    vars=expand_vars(var)
    model.jmv[[i]]=list(label=model[[i]][[1]],
                        vars=vars)
  }
  # lavaan style
  model.lav=c()
  for(i in 1:length(model.jmv)) {
    model.i=paste(model.jmv[[i]]$label, paste(model.jmv[[i]]$vars, collapse=" + "), sep=" =~ ")
    model.lav=c(model.lav, model.i)
  }
  model.lav=paste(model.lav, collapse="\n")
  # high-order CFA (only for lavaan)
  factors=sapply(model.jmv, function(x) x$label)
  if(highorder!="")
    model.lav=paste(model.lav,
                    paste(highorder, "=~",
                          paste(factors, collapse=" + ")),
                    paste(highorder, "~~", highorder),
                    sep="\n")
  # output
  if(style=="jmv") return(model.jmv)
  if(style=="lavaan") return(model.lav)
}


#' Confirmatory Factor Analysis (CFA).
#'
#' An extension of \code{\link[lavaan:cfa]{lavaan::cfa()}}.
#'
#' @inheritParams %%COMPUTE%%
#' @param model Model formula. See examples.
#' @param highorder High-order factor. Default is \code{""}.
#' @param orthogonal Default is \code{FALSE}. If \code{TRUE}, all covariances among latent variables are set to zero.
#' @param missing Default is \code{"listwise"}. Alternative is \code{"fiml"} ("Full Information Maximum Likelihood").
## @param CI \code{TRUE} or \code{FALSE} (default), provide confidence intervals for the model estimates.
## @param MI \code{TRUE} or \code{FALSE} (default), provide modification indices for the parameters not included in the model.
#' @param digits,nsmall Number of decimal places of output. Default is \code{3}.
#' @param file File name of MS Word (\code{.doc}).
#'
#' @return
#' A list of results returned by \code{\link[lavaan:cfa]{lavaan::cfa()}}.
#'
#' @seealso
#' \code{\link{Alpha}}, \code{\link{EFA}}, \code{\link{lavaan_summary}}
#'
#' @examples
#' \donttest{data.cfa=lavaan::HolzingerSwineford1939
#' CFA(data.cfa, "Visual =~ x[1:3]; Textual =~ x[c(4,5,6)]; Speed =~ x7 + x8 + x9")
#' CFA(data.cfa, model="
#'     Visual =~ x[1:3]
#'     Textual =~ x[c(4,5,6)]
#'     Speed =~ x7 + x8 + x9
#'     ", highorder="Ability")
#'
#' data.bfi=na.omit(psych::bfi)
#' CFA(data.bfi, "E =~ E[1:5]; A =~ A[1:5]; C =~ C[1:5]; N =~ N[1:5]; O =~ O[1:5]")
#' }
#' @export
CFA=function(data, model="A =~ a[1:5]; B =~ b[c(1,3,5)]; C =~ c1 + c2 + c3",
             highorder="", orthogonal=FALSE, missing="listwise",
             # CI=FALSE, MI=FALSE,
             digits=3, nsmall=digits,
             file=NULL) {
  # model.jmv=modelCFA.trans("jmv", model)
  model.lav=modelCFA.trans("lavaan", model, highorder)
  # if(orthogonal==TRUE | highorder!="") style="lavaan"

  cat("\n")
  Print("<<cyan Model Syntax (lavaan):>>")
  cat(model.lav)
  cat("\n")

  # # jmv style
  # if("jmv" %in% style) {
  #   fit.jmv=jmv::cfa(data=data, factors=model.jmv,
  #                    resCov=NULL,
  #                    constrain="facVar", # or "facInd"
  #                    # 'facVar' fixes the factor variances to 1
  #                    # 'facInd' fixes each factor to the scale of its first indicator
  #                    ci=CI, mi=MI, # modification indices
  #                    stdEst=TRUE, resCovEst=TRUE,
  #                    # pathDiagram=plot,
  #                    fitMeasures=c("cfi", "tli", "rmsea", "srmr", "aic", "bic"),
  #                    miss=missing) # fiml (default), listwise
  #   cat("\n#### jamovi style output ####\n")
  #   print(fit.jmv)
  # }

  # lavaan style
  fit.lav=lavaan::cfa(model=model.lav,
                      data=data,
                      std.lv=TRUE,
                      # TRUE: fixing the factor residual variances to 1
                      # FALSE: fixing the factor loading of the first indicator to 1
                      orthogonal=orthogonal,
                      missing=missing) # fiml, listwise (default)
  # cat("\n#### lavaan output ####\n\n")
  lavaan_summary(fit.lav, ci="raw", nsmall=nsmall, file=file)
  # lavaan::summary(fit.lav,
  #                 fit.measures=TRUE,
  #                 standardized=TRUE,
  #                 ci=CI,
  #                 modindices=MI)
  # if(MI) print(lavaan::modificationIndices(fit.lav))
  # if(plot) semPlot::semPaths(fit.lav, "std", curveAdjacent=TRUE,
  #                            style="lisrel", nDigits=2, edge.label.cex=1)

  invisible(fit.lav)
}

