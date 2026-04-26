# Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
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

dbListTables(conn)
employees_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_employees")
testscores_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_testscores")
offices_tbl <- dbGetQuery(conn, "SELECT * FROM datascience_offices")

write.csv(employees_tbl, "../data/employees.csv")
write.csv(testscores_tbl, "../data/testscores.csv")
write.csv(offices_tbl, "../data/offices.csv")

week13_tbl <- employees_tbl %>%
  inner_join(testscores_tbl, by = "employee_id") %>%
  left_join(offices_tbl, by = c("city" = "office"))

write.csv(week13_tbl, "../out/week13.csv")

# Visualization 

# Analysis 

# Publication