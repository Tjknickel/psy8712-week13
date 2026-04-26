# Script Settings and Resources 
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)
library(RPostgres)
library(DBI)

# Data Import and Cleaning 
conn <- dbConnect(
  Postgres(),
  user = "",
  password = "",
  dbname = "",
  host = "",
  port = 5432, 
  sslmode = "require"
)


# Visualization 

# Analysis 

# Publication