library(devtools)
source_github <- function(u) {
    # load package
    require(RCurl)
    
    # read script lines from website
    script <- getURL(u, ssl.verifypeer = FALSE)
    
    # parase lines and evaluate in the global environment
    eval(parse(text = script))
}


## Grab windows functions

source_github("https://raw.githubusercontent.com/justinherman42/Company_project/master/build_database.R")
source_github("https://raw.githubusercontent.com/justinherman42/Company_project/master/Windows_functions.R")

### Execute yty_Growth with Revenue 
yty_growth("Revenue","financials")

### Execute yty_Growth with operating expenses
yty_growth("OperatingExpenses","financials")

## Industry level ranking
yty_ranking("Revenue","financials")

## Company level ranking
yty_ranking("Revenue","financials",partition=1)

## 3 year moving average 
yearly_cum_sum_revenue()