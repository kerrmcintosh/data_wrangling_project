library(tidyverse)
library(readxl)

halloween_2015_raw_data <- read_xlsx("raw_data/boing-boing-candy-2015.xlsx")
halloween_2016_raw_data <- read_xlsx("raw_data/boing-boing-candy-2016.xlsx")
halloween_2017_raw_data <- read_xlsx("raw_data/boing-boing-candy-2017.xlsx")
data_clean2015 <- halloween_2015_raw_data
data_clean2016 <- halloween_2016_raw_data
data_clean2017 <- halloween_2017_raw_data

# Cleaned and uniformed column names, created a column for survey id and year ( deleting timestamp).  I've deleted all columns which are not refering to particular candy.  Removed square brackets from column names.

data_clean2015 <- data_clean2015 %>%
  janitor::clean_names() %>%
  #I wanted to give columns a unique id (which incorporates year) instead of just a timestamp  
  mutate(id = seq.int(nrow(data_clean2015))) %>% 
  mutate(year = 2015) %>%
  mutate(survey_id = paste0(year, "_", id) ) %>%
  mutate(gender = NA) %>%
  mutate(country = NA) %>%
  select(survey_id, are_you_going_actually_going_trick_or_treating_yourself, gender, how_old_are_you, country, everything(), -timestamp, -id,    -year) %>% 
  subset(select = -c(99, 102:126) ) 

# Remove square brackets from treat names / column names
colnames(data_clean2015) <- gsub("\\[|\\]", "", colnames(data_clean2015))

#First 5 columns to be uniform across 2015, 2016 and 2017 data
names_one_2_five <- c("survey_id", "going_out", "gender", "age", "country")
names(data_clean2015)[1:5] <- names_one_2_five

#rename columns now square brackets removed
data_clean2015 <- data_clean2015 %>% 
  rename(anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes = anonymous_brown_globs_that_come_in_black_and_orange_wrappers, hersheys_dark_chocolate = dark_chocolate_hershey, joy_other = 99, despair_other = 100, licorice_yes_black = licorice, hersheys_kisses = hershey_s_kissables, bonkers_the_candy = bonkers)  %>% 
  select(-lapel_pins, -mary_janes, -brach_products_not_including_candy_corn)

# In the below I have cleaned column names, removed columns with irrelevant non candy related data, renamed columns to make columns across 2015, 2016 and 2017 uniform and removed any duplicate content.
# Note bonkers board game removed before the square brackets
data_clean2016 <- data_clean2016 %>%
  janitor::clean_names() %>%
  mutate(id = seq.int(nrow(data_clean2016))) %>% 
  mutate(year = 2016) %>%
  mutate(survey_id = paste0(year, "_", id) ) %>%
  select(survey_id, everything(), -timestamp, -id, -year, -bonkers_the_board_game, -person_of_interest_season_3_dvd_box_set_not_including_disc_4_with_hilarious_outtakes) %>%
  subset(select = -c(6, 107:121) )

colnames(data_clean2016) <- gsub("\\[|\\]", "", colnames(data_clean2016))

data_clean2016 <- data_clean2016 %>%
  rename(anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes = anonymous_brown_globs_that_come_in_black_and_orange_wrappers, sweetums = sweetums_a_friend_to_diabetes, joy_other = please_list_any_items_not_included_above_that_give_you_joy, despair_other = please_list_any_items_not_included_above_that_give_you_despair, box_o_raisins = boxo_raisins) %>%
  select(-mary_janes)

names(data_clean2016)[1:5] <- names_one_2_five


data_clean2017 <- data_clean2017 %>%
  janitor::clean_names() %>%
  mutate(id = seq.int(nrow(data_clean2017))) %>% 
  mutate(year = 2017) %>%
  mutate(survey_id = paste0(year, "_", id) ) %>%
  select(survey_id, everything(), -internal_id, -id, -year) %>%
  subset(select = -c(6, 12, 112:120) )

# treat column names altered to make uniform across 2015 - 2017
colnames(data_clean2017) <- gsub("q6_", "", colnames(data_clean2017))
#col name that started with a number made to match format of other years
colnames(data_clean2017) <- gsub("100_", "x100_", colnames(data_clean2017))

data_clean2017 <- data_clean2017 %>%
  rename(sweetums = sweetums_a_friend_to_diabetes, third_party_m_ms = independent_m_ms, joy_other = q7_joy_other, despair_other = q8_despair_other, box_o_raisins = boxo_raisins) %>% 
  select(-real_housewives_of_orange_county_season_9_blue_ray, -abstained_from_m_ming, -sandwich_sized_bags_filled_with_boo_berry_crunch)

names(data_clean2017)[1:5] <- names_one_2_five

# Using janitor to compare column names and see what I need to work on
# I saved the comparison to a csv and manually reconciled matching columns that I then renamed (where necesary)
# compare <- janitor::compare_df_cols(data_clean2015, data_clean2016, data_clean2017 )
# compare 
# write_csv(compare, ("raw_data/col_compare.csv"))

# halloween handy data from 2015, 2016 and 2017 combined in one dataframe
halloween_candy_all<- bind_rows(data_clean2017,data_clean2016, data_clean2015) %>%
  select(-vials_of_pure_high_fructose_corn_syrup_for_main_lining_into_your_vein)

# optional despair and joy data pulled out to work with / extract data and then merged back in to main data
halloween_candy_extra <-  halloween_candy_all %>% 
  select(survey_id, going_out, gender, age, country, joy_other, despair_other)

# All optional joy related candy data separated in to individual string ( candies) and then changed in to a uniform long format to match main content and removing any Null/NAs 
hall_extra_joy <- halloween_candy_extra %>% 
  select(survey_id, going_out, gender, age, country, joy_other) %>% 
  drop_na(joy_other) %>%
  separate(joy_other, c("1","2", "3", "4", "5", "6", "7", "8", "9", "10"), sep = "\\,|\\and|\\&") %>% 
  pivot_longer(cols = 6:15,
               names_to = "deleting",
               values_to = "treat") %>% 
  select(-deleting) %>% 
  drop_na(treat) %>% 
  mutate(reaction = "joy")

# All optional despair related candy data separated in to individual string ( candies) and then changed in to a uniform long format to match main content and removing any Null/NAs 
hall_extra_despair <- halloween_candy_extra %>% 
  select(survey_id, going_out, gender, age, country, despair_other) %>% 
  drop_na(despair_other) %>%
  separate(despair_other, as.character(1:10), "\\,|\\and|\\&") %>% 
  pivot_longer(cols = 6:15,
               names_to = "deleting",
               values_to = "treat") %>% 
  select(-deleting) %>% 
  drop_na(treat) %>% 
  mutate(reaction = "despair")
View(head(hall_extra_despair, 1000))

# Despair and joy data combined in to one dataframe
halloween_candy_extra <- bind_rows(hall_extra_joy, hall_extra_despair )

# all extra treats made lower case
halloween_candy_extra$treat <- tolower(halloween_candy_extra$treat)

# tryting to categorise some of the extra treats 
halloween_candy_extra  <- halloween_candy_extra %>%
  mutate(
    treat = ifelse(str_detect(treat, "mary"), "anonymous_brown_globs_that_come_in_black_and_orange_wrappers_a_k_a_mary_janes", treat)) %>% 
  mutate(
    treat = ifelse(str_detect(treat, "licorice&black"), "licorice_yes_black", treat)) %>% 
  mutate(
    treat = ifelse(str_detect(treat, "reese|crispy"), "reece_crispy", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "ferrero"), "ferrero_rocher", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "wurl"), "curly_wurlies", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "ruth"), "baby_ruth", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "dime"), "dime_bars", treat))  %>%
  mutate(
    treat = ifelse(str_detect(treat, "tootsie"), "tootsie_rolls", treat))   %>%
  mutate(
    treat = ifelse(str_detect(treat, "rockets|smarties"), "rockets_smarties", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "tim&tams"), "tim_tams", treat)) %>%
  mutate(
    treat = ifelse(str_detect(treat, "hersheys&dark"), "hersheys_dark_chocolate", treat)) %>% 
  filter(nchar(treat) > 3)

#All data excluding the optional choices and layout changed to a long format
halloween_candy_main<-  halloween_candy_all %>% 
  select(-joy_other, -despair_other)  %>% 
  pivot_longer(cols = 6:111,
               names_to = "treat",
               values_to = "reaction")

# Join extras to main
halloween_candy_all <- rbind(halloween_candy_main, halloween_candy_extra)
nrow(halloween_candy_all)

# Remove rows with all NAs
halloween_candy_all <- halloween_candy_all %>% 
  filter(!is.na(reaction))


nrow(halloween_candy_all)

#tidy age column cleaned and getting rid of non relevant data and formats

halloween_candy_all <- halloween_candy_all %>%
  mutate(age = gsub("[^0-9.]", "", halloween_candy_all$age)) 

halloween_candy_all$age <- as.numeric(halloween_candy_all$age)


halloween_candy_all <- halloween_candy_all %>%
  mutate(age = ifelse(age < 5, NA, age), age = ifelse(age > 90, NA, age))
halloween_candy_all$age <- as.integer(halloween_candy_all$age)
head(halloween_candy_all)

# view(sort(unique(halloween_candy_all$country)))
#clean and tidy country column
halloween_candy_all$country <- tolower(halloween_candy_all$country) 


halloween_candy_all <- halloween_candy_all %>% 
  mutate(
    country = ifelse(str_detect(country, "kingdom|england|scotland|endland|kindom"), "uk", country)) %>% 
  mutate(
    country = ifelse(str_detect(country, "california|pittsburgh|staes|states|sates|u.s.|usa!|the best one|merica|stat|carolina|alaska|york|amerca|usa usa usa| election|u s|stetes|trumpistan|anymore|jersey|us of a|aaa|murica|murrika|us"), "usa", country)) %>% 
  mutate(
    country = ifelse(str_detect(country, "can"), "canada", country)) %>% 
  mutate(
    country = ifelse(str_detect(country, "the nethe"), "netherlands", country))  %>% 
  mutate(
    country = ifelse(str_detect(country, "espana"), "spain", country)) %>% 
  mutate(
    country = ifelse(str_detect(country, "korea"), "south korea", country))  %>% 
  mutate(
    country = ifelse(str_detect(country, "usa|uk|mexico|ireland|south africa|switzerland|singapore|spain|portugal|hungary|uae|netherlands|costa rica|greece|iceland|germany|taiwan|belgium|panama|philippines|sweden|kenya|canada|france|japan|denmark|china|croatia|new zealand|brasil|finland") == FALSE, NA, country)) 



# unique(halloween_candy_all$country)

#clean gender column 
halloween_candy_all$gender <- tolower(halloween_candy_all$gender)


halloween_candy_all <- halloween_candy_all %>%
  mutate(
    gender = ifelse(str_detect(gender, "male|female"), gender, NA))

unique(halloween_candy_all$gender)


head(halloween_candy_all)

#clean reaction column
halloween_candy_all$reaction <- tolower(halloween_candy_all$reaction)

write_csv(halloween_candy_all, here::here("clean_data/halloween_candy_clean_data.csv"))
