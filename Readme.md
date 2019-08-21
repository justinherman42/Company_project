## API Project
Repository contains a project built as a self contained notebook, as well as R scripts individualized to run on cmd. Both Notebook files and .R files assume a DBA has created a MySQL database for us and we have saved our credential files. The script loads credential files saved locally as a .cnf file. Please find the following line of code, it should be located in the build_database.R and the notebook file. 

db_credentials<-"C:\\Users\\justin\\Desktop\\xmedia.cnf"

The file should be saved as a .cnf and have the following format: <br />
[db_name]<br />
user=user_Name<br />
password= pw <br />
host= host <br />
port= port <br />
database= db_name <br /> 


### .R files
•	The . R files are all loaded into a subfolder on this hub called r_scripts.
•	The execute_windows_functions.R script needs to be run locally
o	This script Will call the other scripts saved onto Github and execute the project’s work flow
•	The order of execution is as follows:


###  execute_windows_functions.R-->load_packages.R-->load_functions.R-->build_database.R-->Windows_functions.R
<br />
 
+ •	The build_databse.R script, executes a script which makes a request to the api, builds an R dataframe, and inserts that R dataframe into a MYSQL database
•	As mentioned, execute_windows_functions.R calls all other scripts and executes the windows functions as well
•	There are various print statements sent to the CMD throughout to validate the flow is working
•	One key difference between the  R scripts and the notebook is the R scripts will save CSV files to CWD. These CSV files store the results from the windows function queries 
•	CSV files have been added to the folder csv_files


### Notebook file
•	The notebook file is called api_request_project.rmd
o	An HTML version of the notebook has been added as well
•	Unlike the .R files, the windows functions simply print out a searchable datatable for their query results
•	The notebook presents the code documented step by step
•	One other major difference is that the notebook file doesn't overwrite a db if it already exists. As you can't really change the .R files, i decided to amend the .R script files table creation function.  The notebook file will refuse to overwrite, where the R script will overwrite by default.  
•	The notebook file also includes a little EDA in R section and those graphs are stored on the git in the figure.html folder


You can preview the html document [here](http://rpubs.com/justin_herman_42/521061)

