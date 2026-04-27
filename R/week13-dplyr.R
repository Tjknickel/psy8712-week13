# Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(RPostgres)
library(DBI)

# Data Import and Cleaning 
# This section first connects to the database by using dbConnect along with the server information. The username and password were created in the .Renviron file and are thus not stored here for privacy and security reasons. After connecting, three datasets were imported from the database using dbGetQuery and were also saved as csv files. dbListTables returns the names of the datasets that the user has access to, which was used to import the correct datasets. Finally, week13_tbl was created by joining together two of the datasets by a shared column (employee_id) and then joining by another related column from the third datatset (city/office). This final created dataframe was also then saved as a csv file. 
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

write.csv(week13_tbl, "../out/week13.csv", row.names = FALSE)

# Analysis 
# This section uses tidyr and dplyr functions to analysis the week13_tbl data to complete 5 tasks. The first set of tasks were to display the total number of managers, then the total number of unique managers, then a summary of managers by location. The next set of tasks were to display the mean and standard deviation of years of employment by performance group, and finally to display each managers location classification of their office, ID number, and test score in alphabetical order by location type and descending order of test score. Functions used to accomplish these tasks included filter, summarize, group_by, mutate, select, and arrange. 
week13_tbl %>% 
  filter(manager_hire == "Y") %>% 
  summarize(total_managers = n())

week13_tbl %>% 
  filter(manager_hire == "Y") %>% 
  summarize(unique_managers = n_distinct(employee_id))

week13_tbl %>% 
  filter(manager_hire == "Y") %>% 
  group_by(city) %>% 
  summarize(manager_count = n())

week13_tbl %>% 
  mutate(performance_group = factor(performance_group, levels = c("Bottom", "Middle", "Top"))) %>% 
  group_by(performance_group) %>% 
  summarize(
    mean_years = mean(yrs_employed, na.rm = TRUE),
    sd_years = sd(yrs_employed, na.rm = TRUE)
  )

week13_tbl %>% 
  filter(manager_hire == "Y") %>% 
  select(office_type, employee_id, test_score) %>% 
  arrange(office_type, desc(test_score))
