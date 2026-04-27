# Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(RPostgres)
library(DBI)

# Data Import and Cleaning 
# This section first connects to the database by using dbConnect along with the server information. The username and password were created in the .Renviron file and are thus not stored here for privacy and security reasons. After connecting, dbExecute was run in order to create a temporary table from the three datasets that currently existed on the database to be used in the analysis, as this new dataset had to combine aspects of the three datasets to filter for employees that had a test score and also include information on office location. This table inner joined by a shared column from the employees and test score datasets (employee_id) and left joined by a related column (city/offices) from the offices dataset. 
conn <- dbConnect(
  Postgres(),
  user = Sys.getenv("NEON_USER"),
  password = Sys.getenv("NEON_PW"),
  dbname = "neondb",
  host = "ep-billowing-union-am14lcnh-pooler.c-5.us-east-1.aws.neon.tech",
  port = 5432, 
  sslmode = "require"
)

dbExecute(conn, "
  CREATE TEMPORARY TABLE week13_tbl AS
  SELECT 
    datascience_employees.*, 
    datascience_testscores.test_score, 
    datascience_offices.office_type
  FROM datascience_employees
  INNER JOIN datascience_testscores 
    ON datascience_employees.employee_id = datascience_testscores.employee_id
  LEFT JOIN datascience_offices
    ON datascience_employees.city = datascience_offices.office
")

# Analysis 
# This section uses SQL functions to complete 5 tasks using the temporary table (week13_tbl) data. The first set of tasks were to display the total number of managers, then the total number of unique managers, then a summary of managers by location. The next set of tasks were to display the mean and standard deviation of years of employment by performance group, and finally to display each managers location classification of their office, ID number, and test score in alphabetical order by location type and descending order of test score. Functions used to accomplish these tasks included SELECT, COUNT, AS, FROM, WHERE, GROUP BY, and ORDER BY inside of dbGetQuery to extract the results tables. 
dbGetQuery(conn, "
  SELECT COUNT(*) AS total_managers 
  FROM week13_tbl 
  WHERE manager_hire = 'Y'
")

dbGetQuery(conn, "
  SELECT COUNT(DISTINCT employee_id) AS unique_managers 
  FROM week13_tbl 
  WHERE manager_hire = 'Y'
")

dbGetQuery(conn, "
  SELECT city, COUNT(*) AS promoted_manager_count 
  FROM week13_tbl 
  WHERE manager_hire = 'Y' 
  GROUP BY city
")

dbGetQuery(conn, "
  SELECT 
    performance_group, 
    AVG(yrs_employed) AS mean_years, 
    STDDEV(yrs_employed) AS sd_years
  FROM week13_tbl
  GROUP BY performance_group
")

dbGetQuery(conn, "
  SELECT office_type, employee_id, test_score
  FROM week13_tbl
  WHERE manager_hire = 'Y'
  ORDER BY office_type ASC, test_score DESC
")