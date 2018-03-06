
# README
# text analysis for emergin tasks

setwd("P:/Projects/MANUFACTURING/ADVANCED INDUSTRIES/DIGITALIZATION/Data/ONET/Raw")
library(dplyr)
library(tidytext)

tasks <- c("db_22_2_text/Emerging Tasks.txt",
           "db_21_2_text/Emerging Tasks.txt",
           "db_20_2_text/Emerging Tasks.txt")
EMG_tasks <- lapply (tasks, read.table, sep = '\t', header = TRUE, fill = TRUE, colClass = 'character')

EMG_tasks <- EMG_tasks %>% bind_rows() %>% unique()

# save(EMG_tasks, file = 'V:/Sifan/Digitalization/EMG_tasks.Rda')

# Text analysis Sand Box --------------------------------------------------

load("EMG_tasks.Rda")

words <- EMG_tasks %>%
  unnest_tokens(word, Task) %>%
  group_by(word) %>%
  summarise(count = n())