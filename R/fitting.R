# This is where all functions related to model fitting should appear

#' Fit smooth-in-time parametric hazard functions.
#'
#' Miettinen and Hanley (2009) explained how case-base sampling can be used to
#' estimate smooth-in-time parametric hazard functions. The idea is to sample
#' person-moments, which may or may not correspond to an event, and then fit the
#' hazard using logistic regression.
#'
#' The object \code{data} should either be the output of the function
#' \link{\code{sampleCaseBase}} or the source dataset on which case-base
#' sampling will be performed. In the latter case, it is assumed that
#' \code{data} contains the two columns corresponding to the supplied time and
#' event variables. If either the \code{time} or \code{event} argument is
#' missing, the function looks for columns named \code{"time"}, \code{"event"},
#' or \code{"status"}.
#'
#' @param formula an object of class "formula" (or one that can be coerced to
#'   that class): a symbolic description of the model to be fitted. The details
#'   of model specification are given under Details.
#' @param data a data frame, list or environment containing the variables in the
#'   model. If not found in data, the variables are taken from
#'   \code{environment(formula)}, typically the environment from which
#'   \code{fitSmoothHazard} is called.
#' @param time a character string giving the name of the time variable. See
#'   Details.
#' @param event a character string giving the name of the event variable. See
#'   Details.
#' @param link A character string, which gives the specification for the model
#'   link function. Default is the \code{logit} link.
#' @param ... Additional parameters passed to \code{\link{sampleCaseBase}}. If
#'   \code{data} inherits from the class \code{cbData}, then these parameters
#'   are ignored.
#' @return An object of class \code{caseBase}, which inherits from the classes
#'   \code{glm} and \code{lm}. As such, functions like \code{summary} and
#'   \code{coefficients} give familiar results.
#' @export
fitSmoothHazard <- function(formula, data, time, event, link = "logit", ...) {

    # Call sampleCaseBase
    if (!inherits(data, "cbData")) {
        originalData <- as.data.frame(data)
        data <- sampleCaseBase(originalData, ...)
        if (length(list(...)) != 2) {
            warning("sampleCaseBase is using some default values; see documentation for more details.")
        }
    } else {
        originalData <- NULL
    }

    # Update formula to add offset term
    formula <- update(formula, ~ . + offset(offset))
    model <- glm(formula, data = data, family = binomial(link=link))
    model$originalData <- originalData

    class(model) <- c("caseBase", class(model))

    return(model)
}