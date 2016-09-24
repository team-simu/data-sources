setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(readr)
library(ggplot2)
library(dplyr)

scorecard_df <- read_delim('./Scorecard_v2.csv', delim = ',')
scorecard_df$X1 <- NULL
scorecard_df <- scorecard_df%>% mutate(ZIP_5 = substr(ZIP, 1, 5))

## check at what columns don't have duplicate data
# numDups <- c()
# for (columnIndex in seq(1520,1600,10)){
#   numDups <- c(numDups, sum(duplicated(scorecard_df[, c(1:columnIndex)])))
# }
# plot(numDups)
# scorecard_df[duplicated(scorecard_df[,c(colnames(scorecard_df)[1:10])]),]
# duplicates have differing Lat and Long

dups <- duplicated(scorecard_df[, c(1:3)])

# duplicates example
# scorecard_df[scorecard_df$STABBR=='UT', ]
# 1 230038 367000   3670 Brigham Young University-Provo          Provo     UT      84602       3     1         1       3       4       2      49      7   0.6278       0.6278     570     680     580
# 2 230603 367800   3678       Southern Utah University     Cedar City     UT      84720       3     1         1       3       4       1      49      7   0.7643       0.7643     460     580     450
# 3 230728 367700   3677          Utah State University          Logan     UT 84322-1400       3     1         1       3       4       1      49      7   0.9733       0.9733     470     610     480
# 4 230764 367500   3675             University of Utah Salt Lake City     UT 84112-9008       3     1         1       3       4       1      49      7   0.8320       0.8320     490     630     513
# 5 230807 368100   3681            Westminster College Salt Lake City     UT      84105       3     1         1       3       4       2      49      7   0.6798       0.6798     488     620     500
# 6 230807 368100   3681            Westminster College Salt Lake City     UT      84105       3     1         1       3       4       2      49      7   0.6798       0.6798     488     620     500
# 7 230807 368100   3681            Westminster College Salt Lake City     UT      84105       3     1         1       3       4       2      49      7   0.6798       0.6798     488     620     500

scorecard_df <- scorecard_df[!dups, ]

# duplicates example after removal
# scorecard_df[scorecard_df$STABBR=='UT', ]
# 1 230038 367000   3670 Brigham Young University-Provo          Provo     UT      84602       3     1         1       3       4       2      49      7   0.6278       0.6278     570     680     580
# 2 230603 367800   3678       Southern Utah University     Cedar City     UT      84720       3     1         1       3       4       1      49      7   0.7643       0.7643     460     580     450
# 3 230728 367700   3677          Utah State University          Logan     UT 84322-1400       3     1         1       3       4       1      49      7   0.9733       0.9733     470     610     480
# 4 230764 367500   3675             University of Utah Salt Lake City     UT 84112-9008       3     1         1       3       4       1      49      7   0.8320       0.8320     490     630     513
# 5 230807 368100   3681            Westminster College Salt Lake City     UT      84105       3     1         1       3       4       2      49      7   0.6798       0.6798     488     620     500

## look at which columns have a single value eg. all column entries are 'PrivacySuppressed'
# colUniqueVals <- data.frame()#column_name='column', unique_vals= 1, stringsAsFactors = FALSE)
# for (column in colnames(scorecard_df)){
#   this_row <- data.frame(column_name=column, unique_vals= length(table(scorecard_df[column])), stringsAsFactors = FALSE)
#   colUniqueVals <- rbind(colUniqueVals, this_row)
# }

# sum(colUniqueVals$unique_vals==1)
## 69 columns that are single values all the way down
# colUniqueVals[colUniqueVals$unique_vals==1,'column_name']
# [1] "CIP01CERT4"                   "CIP03CERT4"                   "CIP04CERT4"                   "DISTANCEONLY"                 "MD_INC_DEATH_YR2_RT"          "HI_INC_DEATH_YR2_RT"         
# [7] "HI_INC_UNKN_2YR_TRANS_YR2_RT" "DEP_DEATH_YR2_RT"             "IND_DEATH_YR2_RT"             "MALE_DEATH_YR2_RT"            "PELL_DEATH_YR2_RT"            "NOPELL_DEATH_YR2_RT"         
# [13] "NOPELL_UNKN_2YR_TRANS_YR2_RT" "LOAN_DEATH_YR2_RT"            "NOLOAN_DEATH_YR2_RT"          "NOLOAN_COMP_4YR_TRANS_YR2_RT" "NOLOAN_UNKN_4YR_TRANS_YR2_RT" "NOLOAN_UNKN_2YR_TRANS_YR2_RT"
# [19] "MD_INC_DEATH_YR3_RT"          "DEP_DEATH_YR3_RT"             "IND_DEATH_YR3_RT"             "IND_UNKN_4YR_TRANS_YR3_RT"    "LOAN_DEATH_YR3_RT"            "NOLOAN_DEATH_YR3_RT"         
# [25] "NOLOAN_UNKN_4YR_TRANS_YR3_RT" "NOLOAN_UNKN_2YR_TRANS_YR3_RT" "MD_INC_DEATH_YR4_RT"          "HI_INC_DEATH_YR4_RT"          "HI_INC_UNKN_2YR_TRANS_YR4_RT" "DEP_DEATH_YR4_RT"            
# [31] "IND_DEATH_YR4_RT"             "LOAN_DEATH_YR4_RT"            "NOLOAN_DEATH_YR4_RT"          "NOLOAN_UNKN_4YR_TRANS_YR4_RT" "NOLOAN_UNKN_2YR_TRANS_YR4_RT" "LO_INC_DEATH_YR6_RT"         
# [37] "MD_INC_DEATH_YR6_RT"          "HI_INC_DEATH_YR6_RT"          "HI_INC_UNKN_2YR_TRANS_YR6_RT" "DEP_DEATH_YR6_RT"             "IND_DEATH_YR6_RT"             "FEMALE_DEATH_YR6_RT"         
# [43] "MALE_DEATH_YR6_RT"            "PELL_DEATH_YR6_RT"            "NOPELL_DEATH_YR6_RT"          "LOAN_DEATH_YR6_RT"            "NOLOAN_DEATH_YR6_RT"          "NOLOAN_UNKN_4YR_TRANS_YR6_RT"
# [49] "FIRSTGEN_DEATH_YR6_RT"        "NOT1STGEN_DEATH_YR6_RT"       "LO_INC_DEATH_YR8_RT"          "MD_INC_DEATH_YR8_RT"          "HI_INC_DEATH_YR8_RT"          "HI_INC_UNKN_2YR_TRANS_YR8_RT"
# [55] "DEP_DEATH_YR8_RT"             "IND_DEATH_YR8_RT"             "FEMALE_DEATH_YR8_RT"          "MALE_DEATH_YR8_RT"            "PELL_DEATH_YR8_RT"            "LOAN_DEATH_YR8_RT"           
# [61] "NOLOAN_DEATH_YR8_RT"          "NOLOAN_UNKN_4YR_TRANS_YR8_RT" "FIRSTGEN_DEATH_YR8_RT"        "APPL_SCH_PCT_GE2"             "APPL_SCH_PCT_GE3"             "APPL_SCH_PCT_GE4"            
# [67] "APPL_SCH_PCT_GE5"             "APPL_SCH_N"                   "CURROPER" 


these <- scorecard_df[100:120, colUniqueVals[colUniqueVals$unique_vals==1,'column_name']]
scorecard_df <- scorecard_df[, !(colnames(scorecard_df) %in%  colUniqueVals[colUniqueVals$unique_vals==1,'column_name'])]
scorecard_df$STATE_NAME <- state.name[match(scorecard_df$STABBR, state.abb)]
scorecard_df <- scorecard_df%>% mutate(ZIP_5 = substr(ZIP, 1, 5))
write_csv(scorecard_df, path = './Scorecard_v3.csv')
