
# README
# text analysis for emergin tasks

setwd("P:/Projects/MANUFACTURING/ADVANCED INDUSTRIES/DIGITALIZATION/Data/ONET/Raw")
title <- read.delim('db_22_2_text/Occupation Data.txt')

library(dplyr)
library(tidytext)
library(stringr)
library(wordcloud)
library(tidyr)
library(reshape2)

tasks <- c("db_22_2_text/Emerging Tasks.txt",
           "db_21_2_text/Emerging Tasks.txt",
           "db_20_2_text/Emerging Tasks.txt")

EMG_tasks <- lapply (tasks, read.delim2, sep = '\t', header = TRUE, colClass = 'character')

EMG_tasks <- EMG_tasks %>% bind_rows() %>% unique()

# save(EMG_tasks, file = 'V:/Sifan/Digitalization/EMG_tasks.Rda')

# Text analysis Sand Box --------------------------------------------------

load("EMG_tasks.Rda")


# unigram
words <- EMG_tasks %>%
  unnest_tokens(word, Task) %>%
  filter(str_detect(word,"[a-z]")) %>%
  anti_join(stop_words) %>%
  group_by(word) %>%
  filter(!word %in% c("incumbent", "occupational", "expert")) %>%
  count(word, sort = TRUE) %>% 
  with(wordcloud(word,n, min.freq = 5, random.order = FALSE, rot.per = 0.2))

# bigram

biwords <- EMG_tasks %>%
  unnest_tokens(biword, Task, token = "ngrams", n = 2) %>%
  separate(biword, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% c("incumbent", "occupational", "expert"), 
         !word1 %in% stop_words$word,
         !word2 %in% c("incumbent", "occupational", "expert"), 
         !word2 %in% stop_words$word) %>%
  unite(bigram, word1, word2, sep = " ")%>%
  count(bigram, sort = TRUE) %>%
  with(wordcloud(bigram, n, min.freq = 3, random.order = FALSE))

triwords <- EMG_tasks %>%
  unnest_tokens(triword, Task, token = "ngrams", n = 3) %>%
  separate(triword, c("word1", "word2", "word3"), sep = " ") %>%
  filter(!word1 %in% c("incumbent", "occupational", "expert"), 
         !word1 %in% stop_words$word,
         !word2 %in% c("incumbent", "occupational", "expert"), 
         !word2 %in% stop_words$word,
         !word3 %in% c("incumbent", "occupational", "expert"), 
         !word3 %in% stop_words$word) %>%
  unite(trigram, word1, word2, word3, sep = " ")%>%
  count(trigram, sort = TRUE) %>%
  with(wordcloud(trigram, n, min.freq = 2))

# digital task

digital_task <- c("data", "software", "computer", "digital","CNC", "CAD")

Digital_tasks <- EMG_tasks[1:2] %>%
  left_join(ONET_xwalkMaster[5:6], by = c("O.NET.SOC.Code" = "O.NET.SOC.2010.Code")) %>%
  left_join(occupation_scores, by = c("SOC.2010.Code" = 'occ6')) %>%
  left_join(title[1:2], by = "O.NET.SOC.Code")%>%
  mutate(digital = ifelse(grepl(paste(digital_task, collapse="|"), Task), 1,0)) %>% unique() 

write.csv(Digital_tasks, "C:/Users/sliu/OneDrive - The Brookings Institution/_Working/digitalization/emerging_tasks.csv")
