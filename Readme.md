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
+ The . R files are all loaded into the main branch of the github.
+ The **execute_windows_functions.R** script neeeds to be run locally
  + This script Will call the other scripts saved onto github and execute the projects work flow
+ The order of execution is as follows: 

###  execute_windows_functions.R-->load_packages.R-->load_functions.R-->build_database.R-->Windows_functions.R
<br />
 
+ The build_databse.R script, executes a script which calls to the api and inserts results into a mysql db
+ As mentioned, execute_windows_functions.R calls all other scripts and executes the windows functions as well
+ there are various print statements sent to the cmd throughout to validate the flow is working
+ One key difference between the .R files and the notebook is the .R files will save to current working drive the query results from the windows functions


### Notebook file
+ The notebook file is here as an all in one work flow
+ It produces an html document which is easy to read and has also been uploaded to the repository
+ Unlike the .R files, the windows functions simply print out a searchable datatable for their query results
+ I recommend you view the html file api_request_project.html, as it documents the project in an easily digestible manner 
