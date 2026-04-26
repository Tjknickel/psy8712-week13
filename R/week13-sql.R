# Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(RPostgres)
library(DBI)

# Data Import and Cleaning 
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