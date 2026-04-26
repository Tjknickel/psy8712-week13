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


# Visualization 

# Analysis 

# Publication