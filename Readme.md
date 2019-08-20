## API Project
Repository contains a project built as a self contained notebook, as well as R scripts individualized to run on cmd. Both Notebook files and .R files assume a dba has created a mysql database for us and we have saved our credential files.  The script loads credential files saved locally as a cnf file. 

Please find the following line of code, it should be located in the build_database.R or in the notebook file and insert your .cnf file

db_credentials<-"C:\\Users\\justin\\Desktop\\xmedia.cnf"

the file should be saved as a .cnf and have the following format:<br />
[db_name]<br />
user=user_Name<br />
password= pw <br />
host= host <br />
port= port <br />
database= db_name <br /> 


### .R files
+ The . R files are all loaded into a subfolder on this hub called r_scripts.
+ The **execute_windows_functions.R** script neeeds to be run locally
  + This script Will call the other scripts saved onto github and execute the projects work flow
+ The order of execution is as follows: 

###  execute_windows_functions.R-->load_packages.R-->load_functions.R-->build_database.R-->Windows_functions.R
<br />
 
+ The build_databse.R script, executes a script which calls to the api and inserts results into a mysql db
+ As mentioned, execute_windows_functions.R calls all other scripts and executes the windows functions as well
+ there are various print statements sent to the cmd throughout to validate the flow is working
+ One key difference between the .R files and the notebook is the .R files will save to current working drive the query results from the windows functions
+ I have added all of the csv files from the windows function query's to csv file folder

### Notebook file
+ The notebook file is here as an all in one work flow
+ It produces an html document which is easy to read and has also been uploaded to the repository
+ Unlike the .R files, the windows functions simply print out a searchable datatable for their query results
+ I recommend you view the html file api_request_project.html, as it documents the project in an easily digestible manner 
+ One other major difference is that the notebook file doesn't overwrite a db if it already exists. As you can't really change the .R files, i decided for sake of brevity it would be easier to allow the script to run at cmd prompt as many times as you would like.  The notebook file will require that you either delete the old db, rename the new db creation, or skip the initial function to build table.

You can preview the html document [here](http://rpubs.com/justin_herman_42/521061)

