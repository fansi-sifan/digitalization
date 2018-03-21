# DIGITALIZATION PROJECT
# Sifan Liu
# Mar 2018 update

# README
# ONET Database Releases Archive: http://www.onetcenter.org/db_releases.html
# ONET update summary: http://www.onetcenter.org/dataUpdates.html


setwd("P:/Projects/MANUFACTURING/ADVANCED INDUSTRIES/DIGITALIZATION/Data/ONET/RAW")
library(dplyr)
library(readxl)

# Read all file names as list ------------------------------------------------------

Work <- c("db_50/WorkActivity.txt", 
           "db_60/WorkActivity.txt",
           "db_17_0/Work Activities.txt",
           "db_22_2_text/Work Activities.txt")

Know <- c("db_50/Knowledge.txt", 
          "db_60/Knowledge.txt",
          "db_17_0/Knowledge.txt",
          "db_22_2_text/Knowledge.txt")

xwalks <- list.files(path = "../Digitization_cleaned/ONET/crosswalks", full.names = TRUE, all.files = FALSE)

# Read raw ------------------------------------------------------------

# ONET raw data
allfiles_w <- lapply (Work, read.table, sep = '\t', header = TRUE)
allfiles_k <- lapply (Know, read.table, sep = '\t', header = TRUE)
ONET_xwalk <- lapply(xwalks, read.csv, colClasses = "character")

# OES raw data
OES2002 <- read_excel("../../OES/2002/national_2002_dl.xls") %>% select(occ_code, group, tot_emp, a_mean, a_median)
OES2010 <- read_excel('../../OES/2010/national_M2010_dl.xls') %>% select(OCC_CODE, GROUP, TOT_EMP, A_MEAN, A_MEDIAN)
OES2016 <- read_excel('../../OES/2016/national_M2016_dl.xlsX') %>% select(OCC_CODE, OCC_GROUP, TOT_EMP, A_MEAN, A_MEDIAN)
OES_xwalk00 <- read.csv("../../OES/oes xwalk00.csv")
OES_xwalk07 <- read.csv("../../OES/oes xwalk07.csv")

# CPS raw data
