
### Build windows functions

### Uses Lag to build Year over year quarterly growth for desired columns
yty_growth <- function(statistic,table_name){
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db) 
    query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) OVER( PARTITION BY Company ORDER BY Report_Date)  Last_Year_",statistic," FROM ",table_name,") SELECT Company,Report_Date,",statistic, ",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS Growth FROM Last_Year;",sep="" )
    res <- dbGetQuery(my_conn,query)
    write.csv(res, file = paste("yty_growth",statistic,".csv",sep="" ))
    paste("csv saved to ",getwd())
    gc()
    dbDisconnect(my_conn)
}


### Uses dense rank to rank to first develop a growth percent by any col and then rank those growth rates
### Function inputs are statistic, table name, partition set
### if input partition is set to 1, then function will rank individual Company performance
### If partition is not set to 1, function will return ranks of the aggregate banking industry

yty_ranking <- function(statistic,table_name,partition=0){
    ##Build connection
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db)
    
    ##Build query without partition
    if (partition==0){
        query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",
                       statistic,", LAG(",statistic, ",4) OVER( PARTITION BY Company ORDER BY Report_Date) Last_Year_",statistic,
                       " FROM ",table_name," ),", statistic,"_table AS (SELECT Company,Report_Date,",statistic,
                       ",Last_Year_",statistic,", ROUND((-1*Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,
                       ",3) AS Growth FROM Last_Year) SELECT *, CASE WHEN Growth IS NOT NULL then DENSE_RANK() OVER ( ORDER BY Growth desc) end) AS ranked_Growth FROM ",statistic,"_table;",sep="")
        ## Send query request and display result
        res <- dbGetQuery(my_conn,query)
        write.csv(res, file = paste("Industry_Quarterly_ranked_",statistic,".csv",sep="" ))
        paste("csv saved to ",getwd())
        gc()
        dbDisconnect(my_conn)
    }
    
    ##Build query with partition
    else {
        query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) OVER( PARTITION BY Company ORDER BY Report_Date) Last_Year_",statistic," FROM ",table_name," ),", statistic,"_table AS (SELECT Company,Report_Date,",statistic,",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS Growth FROM Last_Year) SELECT *, (CASE WHEN Growth IS NOT NULL then DENSE_RANK() OVER ( PARTITION BY Company ORDER BY Growth desc) end) AS ranked_Growth FROM ",statistic,"_table;",sep="")
        
        ## Send query request and display result
        res <- dbGetQuery(my_conn,query)
        write.csv(res, file = paste("Company_Quarterly_ranked_",statistic,".csv",sep="" ))
        paste("csv saved to ",getwd())
        gc()
        dbDisconnect(my_conn)
    }
}

## aggregate data to yearly data and build out running yearly average for last 3 years
## Query does not take any inputs, it's to show how you would create cumulative sum value FROM customer
## Instead of getting cumulative sum, I took average of past 3 years, and forced Null values for years 2009 and 2010
yearly_cum_sum_revenue <- function()
{
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db)
    query <- paste(
        " WITH yearly_revenue AS (SELECT Company, Year(Report_Date) AS years, sum(revenue) AS revenues FROM financials GROUP BY Company,",
        "Year(Report_Date) ORDER BY Company,Year(Report_Date)) SELECT *, CASE WHEN years not in (2009,2010)	then sum(revenues) OVER",
        "(ORDER BY Company, years rows between 3 preceding and current row) else null end AS 'running_total' FROM yearly_revenue ORDER BY Company,years;", sep="" )
    
    ## Send query request and display result
    res <- dbGetQuery(my_conn,query)
    write.csv(res, file = paste("Three_Year_Avg_revenue.csv",sep="" ))
    paste("csv saved to ",getwd())
    gc()
    dbDisconnect(my_conn)
}           


