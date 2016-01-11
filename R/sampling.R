#' Create case-base dataset for use in fitting parametric hazard functions
#'
#' This function implements the case-base sampling approach described in Hanley
#' and Miettinen, Int J Biostatistics 2009. It can be used to fit smooth-in-time
#' parametric functions easily, via logistic regression.
#'
#' It is assumed that \code{data} contains the two columns corresponding to the
#' supplied time and event variables. If either the \code{time} or \code{event}
#' argument is missing, the function looks for columns named \code{"time"},
#' \code{"event"}, or \code{"status"}.
#'
#' @param data a data.frame or data.table containing the source dataset.
#' @param time a character string giving the name of the time variable. See
#'   Details.
#' @param event a character string giving the name of the event variable. See
#'   Details.
#' @param ratio Integer, giving the ratio of the size of the base series to that
#'   of the case series. Defaults to 10.
#' @param type There are currently two sampling procedures available:
#'   \code{uniform}, where person-moments are sampled uniformly across
#'   individuals and follow-up time; and \code{multinomial}, where individuals
#'   are sampled proportionally to their follow-up time.
#' @return The function returns a dataset, with the same format as the source
#'   dataset, and where each row corresponds to a person-moment sampled from the
#'   case or the base series. otherwise)
#' @export
sampleCaseBase <- function(data, time, event, ratio = 10, type = c("uniform", "multinomial")) {
    if (missing(time)) {
        if (any(grepl("^time", names(data), ignore.case = TRUE))) {
            time <- grep("^time", names(data), ignore.case = TRUE, value = TRUE)
        } else {
            stop("data does not contain time variable")
        }
    }
    if (missing(event)) {
        if (any(grepl("^event", names(data), ignore.case = TRUE))) {
            event <- grep("^event", names(data), ignore.case = TRUE, value = TRUE)
        } else {
            if (any(grepl("^status", names(data), ignore.case = TRUE))) {
                event <- grep("^status", names(data), ignore.case = TRUE, value = TRUE)
            } else {
                stop("data does not contain event or status variable")
            }
        }
    }
    if (!all(c(time, event) %in% colnames(data))) {
        stop("data does not contain supplied time and event variables")
    }
    type <- match.arg(type)
    # Create survival object from dataset
    selectTime <- (names(data) == time)
    survObj <- survival::Surv(subset(data, select=selectTime, drop = TRUE),
                              subset(data, select=(names(data) == event), drop = TRUE))

    n <- nrow(survObj) # no. of subjects
    B <- sum(survObj[, "time"])             # total person-time in base
    c <- sum(survObj[, "status"])          # no. of cases (events)
    b <- ratio * c               # size of base series
    offset <- log(B / b)            # offset so intercept = log(ID | x, t = 0 )

    if (type == "uniform") {
        # The idea here is to sample b individuals, with replacement, and then
        # to sample uniformly a time point for each of them. The sampled time
        # point must lie between the beginning and the end of follow-up
        p <- survObj[, "time"]/B
        who <- sample(n, b, replace = TRUE, prob = p)
        bSeries <- as.matrix(survObj[who, ])
        bSeries[, "status"] <- 0
        bSeries[, "time"] <- runif(b) * bSeries[, "time"]
    }

    if (type == "multinomial") {
        # Multinomial sampling: probability of individual contributing a
        # person-moment to base series is proportional to time variable
        # dt <- B/(b+1)
        # pSum <- c(0) #Allocate memory first!!
        # for (i in 1:n) {
        #     pSum <- c(pSum, pSum[i] + survObj[i, "time"])
        # }
        pSum <- c(0, cumsum(survObj[, "time"]))
        everyDt <- B*(1:b)/(b+1)
        who <- findInterval(everyDt, pSum)
        bSeries <- as.matrix(survObj[who, ])
        bSeries[, "status"] <- 0
        bSeries[, "time"] <- everyDt - pSum[who]
    }

    # Next commented line will break on data.table
    # bSeries <- cbind(bSeries, data[who, colnames(data) != c("time", "event")])
    selectTimeEvent <- (colnames(data) != c(time, event))
    bSeries <- cbind(bSeries, subset(data, select = selectTimeEvent)[who,])
    names(bSeries)[names(bSeries) == "status"] <- event

    cSeries <- data[which(subset(data, select=(names(data) == event)) == 1),]
    # cSeries <- survObj[survObj[, "status"] == 1, ]
    # cSeries <- cSeries[, c(i.var, id.var, x.vars, time)]
    # cSeries$y <- 1
    # cSeries[, time] <- cSeries[, time]

    # Combine case and base series
    cbSeries <- rbind(cSeries, bSeries)
    # Add offset to dataset
    cbSeries <- cbind(cbSeries, rep_len(offset, nrow(cbSeries)))
    names(cbSeries)[ncol(cbSeries)] <- "offset"

    class(cbSeries) <- c("cbData", class(cbSeries))
    return(cbSeries)
}