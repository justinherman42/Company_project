
### Library import
rm(list=ls())
library(httr)
library(jsonlite)
library(lubridate)
library(tidyverse)
library(RMariaDB)
library(DT)
library(knitr)
library(kableExtra)


## Build df displaying package versions  
pack_ver1 <- cbind("httr",as.character(packageVersion("httr")))
pack_ver2 <- cbind("jsonlite",as.character(packageVersion("jsonlite")))
pack_ver3 <- cbind("lubridate",as.character(packageVersion("lubridate")))
pack_ver4 <- cbind("tidyverse",as.character(packageVersion("tidyverse")))
pack_ver5 <- cbind("RMariaDB",as.character(packageVersion("RMariaDB")))
pack_ver6 <- cbind("DT",as.character(packageVersion("DT")))
pack_ver7 <- cbind("knitr",as.character(packageVersion("knitr")))
pack_ver8 <- cbind("kableExtra",as.character(packageVersion("kableExtra")))

pack_versions <- as.data.frame(rbind(pack_ver1,pack_ver2,pack_ver3,pack_ver4,pack_ver5,pack_ver6,pack_ver7,pack_ver8))
colnames(pack_versions) <- c("Package Name", "Version")
kable(pack_versions)

print("made")
print("it")
print("here")
### Functions
print("made it here")
### Function accesses financial data API and returns a dataframe ready to be inserted into SQL 
### Function takes companies stock tag as an input string   
json_to_df <- function(tag)
{
    ## Build url
    url <- paste("https://financialmodelingprep.com/api/v3/financials/income-statement/",tag,"?period=quarter",sep="")
    headers = c('Upgrade-Insecure-Requests' = '1')
    params = list(`datatype` = 'json')
    
    ## Make request
    result <- GET(url = url, httr::add_headers(.headers=headers), query = params)
    result<- rawToChar(result$content)
    df <- as.data.frame(fromJSON(result)[2])
    
    ## Fix table column names- remove financials. and special char "."
    colnames(df) <- gsub("financials.|\\.","",colnames(df))
    
    ## Convert Date to datetime/ rename date as reportdate
    df$Report_Date <- as.Date(df$date, '%Y-%m-%d')
    df <-  df %>%
        select(-date)
    
    ## Build tag column to identify stock ticker
    df$Company <- tag
    
    ## Build primary key column convert financial data to numeric
    df$Id <- paste(as.character(df$Report_Date),df$Company,sep="-")
    cols.num <- colnames(df)[1:31]
    df[,cols.num] <- sapply(df[cols.num],as.numeric)
    
    ## Data check for NA-
    table(is.na(df))
    return(df)
}


### Function initalizes table creation in mysql
### takes stock tag(chracter), tablename(character)
### If table already exists, will tell you to use different name or use update function instead
build_table <- function(tag,tablename){
    
    ## import df from json api call function 
    df <- json_to_df(tag)
    
    ## grab credentials from credential file
    db_credentials<-"C:\\Users\\justin\\Desktop\\xmedia.cnf"
    my_sql_db<-"xmedia"
    
    ## make connection
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db)
    
    ## Build table from df
    tryCatch(dbWriteTable(my_conn, value = df, 
                          name = tablename,
                          overwrite =FALSE,
                          row.names = FALSE) ,error= function(e){print("table can not be overwritten and already exists. Please use update table function or change name")})
    
    ## Set primary key to Companytag+Date
    res <- dbSendQuery(my_conn, paste("ALTER TABLE",tablename,"ADD CONSTRAINT websites_pk
                                 PRIMARY KEY (`Id`(40)) ;"))
    ## Disconnect
    dbClearResult(res)
    dbDisconnect(my_conn)
}


### loops through list of stock tags and updates SQL DB 
### Will not update db if any of stock data in new queried df already exists in SQL DB
update_table <- function(tags,tablename){
    for (tag in tags){
        
        ## set error checker
        skip_to_next <- FALSE
        
        ## import df from json api call function 
        df <- json_to_df(tag)
        
        ## grab credentials from credential file
        db_credentials<-"C:\\Users\\justin\\Desktop\\xmedia.cnf"
        my_sql_db<-"xmedia"
        
        ## make connection
        my_conn<-dbConnect(RMariaDB::MariaDB(),
                           default.file=db_credentials,
                           group=my_sql_db) 
        
        # insert df into SQL.  Catches primary key conflicts(duplicate data), prints stock wasnt updated, and moves on in loop
        tryCatch(dbWriteTable(my_conn, value = df, 
                              name = tablename, 
                              overwrite= FALSE,   
                              append = TRUE,                         
                              row.names = FALSE),error= function(e){skip_to_next <<- TRUE})
        if(skip_to_next) { print(paste("Company",tag, "data already exists in DB"))
            gc()
            dbDisconnect(my_conn)
            next }
        gc()
        dbDisconnect(my_conn)
        print(paste("db was updated correctly with: ",tag ))
    }
}

### Call functions and build db {.tabset .tabset-fade}

top_10_banks <- c('WFC', 'PNC', 'BBT', 'STI', 'KEY', 'MTB', 'HBAN', 'ZION', 'CMA', 'FITB',"CFG")
## build a table in sql
build_table('USB',"financials")
update_table(top_10_banks,"financials")

### Explore SQL DB

## practice some query with db
db_credentials<-"C:\\Users\\justin\\Desktop\\xmedia.cnf"
my_sql_db<-"xmedia"
my_conn<-dbConnect(RMariaDB::MariaDB(),
                   default.file=db_credentials,
                   group=my_sql_db) 

## print out description of table
print(dbGetQuery(my_conn, "DESCRIBE financials;"))

## Check for NA values
res <- dbGetQuery(my_conn, "SELECT * FROM financials;")
table(is.na(res))

## look at sql db
res <- dbGetQuery(my_conn, "SELECT * FROM financials;")
datatable(res)
gc()
dbDisconnect(my_conn)

### Build windows functions


### Uses Lag to build Year over year quarterly growth for desired columns
yty_growth <- function(statistic,table_name){
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db) 
    query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) OVER( PARTITION BY Company ORDER BY Report_Date)  Last_Year_",statistic," FROM ",table_name,") SELECT Company,Report_Date,",statistic, ",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS Growth FROM Last_Year;",sep="" )
    res <- dbGetQuery(my_conn,query)
    datatable(res)
    gc()
    dbDisconnect(my_conn)
    return(datatable(res))
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
        datatable(res)
        gc()
        dbDisconnect(my_conn)
        return(datatable(res))
    }
    
    ##Build query with partition
    else {
        query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) OVER( PARTITION BY Company ORDER BY Report_Date) Last_Year_",statistic," FROM ",table_name," ),", statistic,"_table AS (SELECT Company,Report_Date,",statistic,",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS Growth FROM Last_Year) SELECT *, (CASE WHEN Growth IS NOT NULL then DENSE_RANK() OVER ( PARTITION BY Company ORDER BY Growth desc) end) AS ranked_Growth FROM ",statistic,"_table;",sep="")
        
        ## Send query request and display result
        res <- dbGetQuery(my_conn,query)
        datatable(res)
        gc()
        dbDisconnect(my_conn)
        return(datatable(res))
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
    datatable(res)
    gc()
    dbDisconnect(my_conn)
    return(datatable(res))
}           


### Execute yty_Growth with Revenue 

### Uses Lag to build Year over year quarterly Growth for desired columns
yty_growth <- function(statistic,table_name){
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db) 
    query <- paste("WITH Last_Year AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) Over( PARTITION BY Company ORDER BY Report_Date)  Last_Year_",statistic," FROM ",table_name,") SELECT Company,Report_Date,",statistic, ",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS Growth FROM Last_Year;",sep="" )
    print(query)
    res <- dbGetQuery(my_conn,query)
    datatable(res)
    gc()
    dbDisconnect(my_conn)
    return(datatable(res))
}

yty_growth("Revenue","financials")


### Execute yty_Growth with operating expenses

yty_growth <- function(statistic,table_name){
    my_conn<-dbConnect(RMariaDB::MariaDB(),
                       default.file=db_credentials,
                       group=my_sql_db) 
    query <- paste("WITH Last_Year  AS (SELECT Company,Report_Date,",statistic,", LAG(",statistic, ",4) Over( PARTITION BY Company ORDER BY Report_Date)  Last_Year_",statistic," FROM ",table_name,") SELECT Company,Report_Date,",statistic, ",Last_Year_",statistic,", ROUND((Last_Year_",statistic,"-",statistic,")/Last_Year_",statistic,"*-1,3) AS growth FROM Last_Year;",sep="" )
    print(query)
    res <- dbGetQuery(my_conn,query)
    datatable(res)
    gc()
    dbDisconnect(my_conn)
    return(datatable(res))
}
yty_growth("OperatingExpenses","financials")
