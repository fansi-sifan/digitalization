# DIGITALIZATION PROJECT
# Sifan Liu
# Mar 2018 update

# README
# ONET Database Releases Archive: http://www.onetcenter.org/db_releases.html
# ONET update summary: http://www.onetcenter.org/dataUpdates.html


setwd("P:/Projects/MANUFACTURING/ADVANCED INDUSTRIES/DIGITALIZATION/Data/ONET/Raw")
library(dplyr)

# Read all file names as list ------------------------------------------------------

Work <- c("db_50/WorkActivity.txt", 
           "db_60/WorkActivity.txt",
           "db_17_0/Work Activities.txt",
           "db_22_2_text/Work Activities.txt")

Know <- c("db_50/Knowledge.txt", 
          "db_60/Knowledge.txt",
          "db_17_0/Knowledge.txt",
          "db_22_2_text/Knowledge.txt")

xwalks <- list.files(path = "../crosswalks", full.names = TRUE, all.files = FALSE)

# Read raw ------------------------------------------------------------

allfiles_w <- lapply (Work, read.table, sep = '\t', header = TRUE)
allfiles_k <- lapply (Know, read.table, sep = '\t', header = TRUE)
ONET_xwalk <- lapply(xwalks, read.csv, colClasses = "character")


