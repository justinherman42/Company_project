
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