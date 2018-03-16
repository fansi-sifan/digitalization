setwd('V:/Sifan/Digitalization')
source('Load.R')

library(reshape2)
library(data.table)

# filter digital content --------------------------------------------------

allfiles_w <- lapply (allfiles_w, filter, Element.Name == 'Interacting With Computers')
allfiles_k <- lapply (allfiles_k, filter, Element.Name == 'Computers and Electronics')

rm(Work, Know)

# Master ONET xwalk ------------------------------------------------------------

ONET_xwalkMaster <- ONET_xwalk[[1]] %>% 
  left_join(ONET_xwalk[[2]], by = 'O.NET.SOC.2006.Code') %>%
  left_join(ONET_xwalk[[3]], by = 'O.NET.SOC.2009.Code') %>%
  left_join(ONET_xwalk[[4]], by = 'O.NET.SOC.2010.Code') %>%
  select(-contains('.x'), - contains('y'))

rm(xwalks, ONET_xwalk)


# ONET 2 SOC --------------------------------------------------------------

digital_00 <- lapply(append(allfiles_k[1:2], allfiles_w[1:2]),left_join,
                     ONET_xwalkMaster, by=c("O.NET.SOC.Code"="O.NET.SOC.2000.Code"))
digital_10 <- lapply(append(allfiles_k[3:4], allfiles_w[3:4]),left_join,
                     ONET_xwalkMaster, by=c("O.NET.SOC.Code"="O.NET.SOC.2010.Code"))

digital <- bind_rows(digital_00, digital_10) 
digital <- digital %>% unique()%>%
  dcast(O.NET.SOC.Code+O.NET.SOC.2000.Title+SOC.2010.Code+SOC.2010.Title+Date+Element.Name ~ Scale.ID, 
        value.var = "Data.Value", mean) 


# calculate digital scores ----------------------------------------------------------

digital <- digital %>%
  mutate(score = ((IM-1)/4) * (LV/7)^0.5*50)

occ_digital <- digital %>% 
  dcast(O.NET.SOC.Code+SOC.2010.Code+SOC.2010.Title+Date ~Element.Name, value.var = "score", mean ) %>%
  mutate(Score = `Computers and Electronics` + `Interacting With Computers`)

occ_digital$year <- as.numeric(stringr::str_sub(occ_digital$Date, -4,-1))



# collapse ----------------------------------------------------------------

#For ONET occupations that are not covered by crosswalk, use six digit O*NET code as SOC code. 

occ_digital$occ6 <- ifelse(is.na(occ_digital$SOC.2010.Code),
                          substr(occ_digital$O.NET.SOC.Code, 1,7),
                          occ_digital$SOC.2010.Code)

occ_master <- occ_digital %>% group_by(occ6, year) %>%
  summarise_if(is.numeric, mean) %>%
  ungroup() %>% group_by(occ6) %>%
  slice(c(1,n()))%>%
  mutate(order = row_number(occ6)) %>%
  mutate(st = ifelse(order == 1 & year <= 2004, 1,0),
         ed = ifelse(order == 2 & year >= 2009, 1, 0)) 

occ_master_wide <- dcast(setDT(occ_master), occ6 ~ order, value.var = c("Score", "st", "ed"))
occ_master_wide$eligible <- factor(ifelse(occ_master_wide$st_1*occ_master_wide$ed_2==1,1,0))

summary(occ_master_wide)

occupation_scores <- occ_master_wide %>%
  left_join(ONET_xwalkMaster[6:7], by = c('occ6' = 'SOC.2010.Code')) %>% unique()%>%
  select(occ6, SOC.2010.Title, Score_1, Score_2, eligible) %>%
  mutate(level_1 = factor(ifelse(Score_1 > 60, 3, ifelse(Score_1 < 33, 1, 2))),
         level_2 = factor(ifelse(Score_2 > 60, 3, ifelse(Score_2 < 33, 1, 2))))

save(occupation_scores, file = 'V:/Sifan/Digitalization/occupation_scores.Rda')


# master OES xwalk

names(OES2002) <- names(OES2010) <- names(OES2016)
names(OES2002) <- paste0(names(OES2016) ,"_02")
names(OES2010) <- paste0(names(OES2016) ,"_10")
names(OES2016) <- paste0(names(OES2016) ,"_16")

OES2002$OCC_CODE_02 <- gsub("-", "_", OES2002$OCC_CODE_02)
OES2010$OCC_CODE_10 <- gsub("-", "_", OES2010$OCC_CODE_10)
OES2016$OCC_CODE_16 <- gsub("-", "_", OES2016$OCC_CODE_16)
occupation_scores$occ6 <- gsub("-", "_", occupation_scores$occ6)

OES_xwalk <- OES2016 %>% 
  left_join(OES_xwalk00, by = c("OCC_CODE_16" = "X2010.SOC.code")) %>%
  left_join(OES2002, by = c("X2000.SOC.code" = "OCC_CODE_02")) %>%
  left_join(OES_xwalk07,  by = c("OCC_CODE_16" = "X2010.SOC.code"))

# collapse ONET to OES occupations
OES_OCC <- occupation_scores %>% 
  left_join(OES_xwalk[c("OCC_CODE_16", "TOT_EMP_16", "A_MEAN_16", "TOT_EMP_02", "A_MEAN_02")],by = c("occ6" = "OCC_CODE_16"))



