

```python
import pandas
import matplotlib
% matplotlib inline
```

    
    


```python
import os
os.chdir("../../Documents/Portfolio/Education project/")
os.listdir("./")
```




    ['adm2014.csv',
     'CollegeScorecardDataDictionary-09-08-2015.csv',
     'CollegeScorecard_Raw_Data (2)',
     'CollegeScorecard_Raw_Data (2).zip',
     'g20145ak.txt',
     'Integrated_Postsecondary_Education_Data_System_20132014.csv',
     'merged_2011_PP.csv',
     'merged_2012_PP.csv',
     'merged_2013_PP.csv',
     'Objective Hypothesis.docx',
     'US Zip Codes from 2013 Government Data']




```python
data_2011 = pandas.read_csv("merged_2011_PP.csv")
data_2012 = pandas.read_csv("merged_2012_PP.csv")
data_2013 = pandas.read_csv("merged_2013_PP.csv")
```

    C:\Users\Marissa\AppData\Local\Enthought\Canopy\User\lib\site-packages\IPython\core\interactiveshell.py:2723: DtypeWarning: Columns (1517,1532,1575) have mixed types. Specify dtype option on import or set low_memory=False.
      interactivity=interactivity, compiler=compiler, result=result)
    C:\Users\Marissa\AppData\Local\Enthought\Canopy\User\lib\site-packages\IPython\core\interactiveshell.py:2723: DtypeWarning: Columns (9,1561,1575,1725,1726,1727,1728) have mixed types. Specify dtype option on import or set low_memory=False.
      interactivity=interactivity, compiler=compiler, result=result)
    

### Create map to decode variable names


```python
dictionary_data = pandas.read_csv("CollegeScorecardDataDictionary-09-08-2015.csv")
temp_map_variables = dictionary_data.loc[:,["NAME OF DATA ELEMENT","VARIABLE NAME"] ].apply(lambda x: {x[1]: x[0]}, axis = 1 )
map_variables = {}
for element in temp_map_variables:
    col_name = element.keys() 
    #print col_name
    map_variables.update(element)
```

### Backfill values for categories only available in 2013

Some of the most recent data is only in 2013 data while the completion rates, repayment rates, etc.. are only available to 2012. From opendata.stackexchange.com:
Most of the data on student outcomes (e.g., completion rates, repayment rates, and debt measures) are not available past the 2013-14 year at this time. For some elements, like the earnings data, the most recent data available describe cohorts measured in the 2011 and 2012 tax years. However, a few elements—including header data like institutional name and address, Minority Serving Institution status, currently operating status, and HCM2 status—are more recent. These data are, for the purposes of convenience, also included in the 2013 file (which comprises both 2013 and other more recent data). In our next annual update, we will add another file, which will include 2014-15 data for may outcomes, as well as more recent data related to the institution. We recognize this can be an unwieldy way to work with the data, so we will continue to explore ways to make this information clearer and easier to access.
This means that we need to merge fields like Minoring Serving Institution status, currently operating status, and HCM2 status from the 2012 data with the 2013 data.



```python
data = data_2011
data_count = data.count() 
print (data_count.values < 100).sum()
drop_2011 = []
for i, name in enumerate(data.columns):
    if data_count[name] < 100:
        #print "%5i %35s %10i" %(i, name, data_count[[i]])
        #try:
            #print "      %90s" %map_variables[name]
        #except:
            #print "None"
        drop_2011.append(name)
        
```

    161
    


```python
data = data_2013
data_count = data.count() 
print (data_count.values < 100).sum()
drop_2013 = []
for i, name in enumerate(data.columns):
    if data_count[name] < 100:
        #print "%5i %35s %10i" %(i, name, data_count[[i]])
        #try:
        #    print "      %90s" %map_variables[name]
        #except:
        #    print "None"
        drop_2013.append(name)


```

    1174
    


```python
print "2011:" , len(drop_2011)
print "2013:" , len(drop_2013)
def intersect(a,b):
    return list(set(a) & set(b))
intersect_2011_2013 = intersect(drop_2011, drop_2013)
print "Intersection 2011-2013", len(intersect_2011_2013)

print "\n\nWhat variables are in the 2013 data and not in the 2011 data"
for i, n in enumerate(sorted(set(drop_2011) - set(drop_2013))):
    print i, n, map_variables.get(n, "None")
fill_2013 = sorted(set(drop_2011) - set(drop_2013))
```

    2011: 161
    2013: 1174
    Intersection 2011-2013 98
    
    
    What variables are in the 2013 data and not in the 2011 data
    0 AANAPII Flag for Asian American Native American Pacific Islander-serving institution
    1 ANNHI Flag for Alaska Native Native Hawaiian serving institution
    2 AccredAgency Accreditor for institution
    3 C150_4_POOLED Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years), pooled for two year rolling averages
    4 C150_4_POOLED_SUPP 150% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For four year school, students are considered to have graduated "on time" if they graduate within 6 years.
    5 C150_L4_POOLED Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion), pooled for two year rolling averages
    6 C150_L4_POOLED_SUPP 150% completion rate for less-than-four-year institutions, pooled in two-year rolling averages and suppressed for small n size
    7 C200_4_POOLED None
    8 C200_4_POOLED_SUPP 200% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size
    9 C200_L4_POOLED None
    10 C200_L4_POOLED_SUPP 200% completion rate for less-than-four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For two year schools, students are considered to have graduated "on time" if they graduate within 4 years.
    11 CCBASIC Carnegie Classification -- basic
    12 CCSIZSET Carnegie Classification -- size and setting
    13 CCUGPROF Carnegie Classification -- undergraduate profile
    14 COMPL_RPY_7YR_N Number of students in the 7-year repayment rate of completers cohort
    15 COMPL_RPY_7YR_RT Seven-year repayment rate for completers
    16 CURROPER Flag for currently operating institution, 0=closed, 1=operating
    17 D150_4_POOLED Adjusted cohort count for completion rate at four-year institutions (denominator of completion rate), pooled for two-year rolling averages
    18 D150_L4_POOLED Adjusted cohort count for completion rate at less-than-four-year institutions (denominator of completion rate), pooled for two-year rolling averages
    19 D200_4_POOLED None
    20 D200_L4_POOLED None
    21 DEP_RPY_7YR_N Number of students in the 7-year repayment rate of dependent students cohort
    22 DEP_RPY_7YR_RT Seven-year repayment rate for dependent students
    23 FEMALE_RPY_7YR_N Number of students in the 7-year repayment rate of female students cohort
    24 FEMALE_RPY_7YR_RT Seven-year repayment rate for females
    25 FIRSTGEN_RPY_7YR_N Number of students in the 7-year repayment rate of first-generation students cohort
    26 FIRSTGEN_RPY_7YR_RT Seven-year repayment rate for first-generation students
    27 HBCU Flag for Historically Black College and University
    28 HCM2 Schools that are on Heightened Cash Monitoring 2 by the Department of Education
    29 HI_INC_RPY_7YR_N Number of students in the 7-year repayment rate of high-income (above $75,000 in nominal family income) students cohort
    30 HI_INC_RPY_7YR_RT Seven-year repayment rate by family income ($75,000+)
    31 HSI Flag for Hispanic-serving institution
    32 IND_RPY_7YR_N Number of students in the 7-year repayment rate of independent students cohort
    33 IND_RPY_7YR_RT Seven-year repayment rate for independent students
    34 INSTURL URL for institution's homepage
    35 LATITUDE Latitude
    36 LOCALE Locale of institution
    37 LONGITUDE Longitude
    38 LO_INC_RPY_7YR_N Number of students in the 7-year repayment rate of low-income (less than $30,000 in nominal family income) students cohort
    39 LO_INC_RPY_7YR_RT Seven-year repayment rate by family income ($0-30,000)
    40 MALE_RPY_7YR_N Number of students in the 7-year repayment rate of male students cohort
    41 MALE_RPY_7YR_RT Seven-year repayment rate for males
    42 MD_INC_RPY_7YR_N Number of students in the 7-year repayment rate of middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    43 MD_INC_RPY_7YR_RT Seven-year repayment rate by family income ($30,000-75,000)
    44 MENONLY Flag for men-only college
    45 NANTI Flag for Native American non-tribal institution
    46 NONCOM_RPY_7YR_N Number of students in the 7-year repayment rate of non-completers cohort
    47 NONCOM_RPY_7YR_RT Seven-year repayment rate for non-completers
    48 NOPELL_RPY_7YR_N Number of students in the 7-year repayment rate of no-Pell students cohort
    49 NOPELL_RPY_7YR_RT Seven-year repayment rate for students who never received a Pell grant while at school
    50 NOTFIRSTGEN_RPY_7YR_N Number of students in the 7-year repayment rate of not-first-generation students cohort
    51 NOTFIRSTGEN_RPY_7YR_RT Seven-year repayment rate for students who are not first-generation
    52 NPCURL URL for institution's net price calculator
    53 PBI Flag for predominantly black institution
    54 PELL_RPY_7YR_N Number of students in the 7-year repayment rate of Pell students cohort
    55 PELL_RPY_7YR_RT Seven-year repayment rate for students who received a Pell grant while at the school
    56 RELAFFIL Religous affiliation of the institution
    57 RPY_7YR_N Number of students in the 7-year repayment rate cohort
    58 RPY_7YR_RT Fraction of repayment cohort that has not defaulted, and with loan balances that have declined seven years since entering repayment, excluding enrolled and military deferment from calculation.  (rolling averages)
    59 TRIBAL Flag for tribal college and university
    60 WOMENONLY Flag for women-only college
    61 poolyrs Years used for rolling averages of completion rate C150_[4/L4]_POOLED
    62 poolyrs200 None
    


```python
## Variables to get from 2013 data
Specialized_mission = ["AANAPII", "ANNHI", "HBCU", "HSI", "MENONLY", "NANTI", "PBI", "TRIBAL", "WOMENONLY"]
Base_descriptors = ["CCBASIC", "CCSIZSET", "CCUGPROF", "CURROPER", "LATITUDE", "LONGITUDE", "LOCALE"]
Pooled_Completion = [name for name in fill_2013 if name[0:4] in ["C150", "C200", "D150", "D200", "pool"]]

Repayment = [name for name in fill_2013 if "RPY_7YR" in name]
print Pooled_Completion
print Repayment

print [name for name in fill_2013 if name not in (Specialized_mission + Base_descriptors + Pooled_Completion + Repayment)]
```

    ['C150_4_POOLED', 'C150_4_POOLED_SUPP', 'C150_L4_POOLED', 'C150_L4_POOLED_SUPP', 'C200_4_POOLED', 'C200_4_POOLED_SUPP', 'C200_L4_POOLED', 'C200_L4_POOLED_SUPP', 'D150_4_POOLED', 'D150_L4_POOLED', 'D200_4_POOLED', 'D200_L4_POOLED', 'poolyrs', 'poolyrs200']
    ['COMPL_RPY_7YR_N', 'COMPL_RPY_7YR_RT', 'DEP_RPY_7YR_N', 'DEP_RPY_7YR_RT', 'FEMALE_RPY_7YR_N', 'FEMALE_RPY_7YR_RT', 'FIRSTGEN_RPY_7YR_N', 'FIRSTGEN_RPY_7YR_RT', 'HI_INC_RPY_7YR_N', 'HI_INC_RPY_7YR_RT', 'IND_RPY_7YR_N', 'IND_RPY_7YR_RT', 'LO_INC_RPY_7YR_N', 'LO_INC_RPY_7YR_RT', 'MALE_RPY_7YR_N', 'MALE_RPY_7YR_RT', 'MD_INC_RPY_7YR_N', 'MD_INC_RPY_7YR_RT', 'NONCOM_RPY_7YR_N', 'NONCOM_RPY_7YR_RT', 'NOPELL_RPY_7YR_N', 'NOPELL_RPY_7YR_RT', 'NOTFIRSTGEN_RPY_7YR_N', 'NOTFIRSTGEN_RPY_7YR_RT', 'PELL_RPY_7YR_N', 'PELL_RPY_7YR_RT', 'RPY_7YR_N', 'RPY_7YR_RT']
    ['AccredAgency', 'HCM2', 'INSTURL', 'NPCURL', 'RELAFFIL']
    

### Combine these variables with the 2011 data



```python
print data_2011["AANAPII"].count()

data_2011[(Specialized_mission + Base_descriptors + Pooled_Completion + Repayment)] = data_2013[(Specialized_mission + Base_descriptors + Pooled_Completion + Repayment)]

print data_2011["AANAPII"].count()
print data_2013["AANAPII"].count()
```

    0
    7383
    7383
    

### Trim out the columns with a lot of nulls



```python
data = data_2011
data_count = data.count() 
print (data_count.values < 1000).sum()
data_trim = data.copy()
errors = []
drop_cols = []
for i, name in enumerate(data.columns):
    if data_count[name] < 1000:
        print "%5i %35s %10i" %(i, name, data_count[[i]])
        try:
            print "      %90s" %map_variables[name]
        except:
            print "None"
        try:
            data_trim = data_trim.drop([name], axis = 1)
            drop_cols.append(name)
        except:
            errors.append(name)
```

    114
        7                        AccredAgency          0
                                                                          Accreditor for institution
        8                             INSTURL          0
                                                                      URL for institution's homepage
        9                              NPCURL          0
                                                          URL for institution's net price calculator
       11                                HCM2          0
                     Schools that are on Heightened Cash Monitoring 2 by the Department of Education
       20                             locale2          0
                                                               Degree of urbanization of institution
       35                            RELAFFIL          0
                                                             Religous affiliation of the institution
       42                             SATWR25        748
                                          25th percentile of SAT scores at the institution (writing)
       43                             SATWR75        748
                                          75th percentile of SAT scores at the institution (writing)
       46                            SATWRMID        748
                                                 Midpoint of SAT scores at the institution (writing)
       53                             ACTWR25        265
                                                            25th percentile of the ACT writing score
       54                             ACTWR75        265
                                                            75th percentile of the ACT writing score
       58                            ACTWRMID        265
                                                                   Midpoint of the ACT writing score
      291                                  UG          0
                                                            Enrollment of all undergraduate students
      301                        UGDS_WHITENH          0
          Total share of enrollment of undergraduate degree-seeking students who are white non-Hispanic
      302                        UGDS_BLACKNH          0
          Total share of enrollment of undergraduate degree-seeking students who are black non-Hispanic
      303                            UGDS_API          0
          Total share of enrollment of undergraduate degree-seeking students who are Asian/Pacific Islander
      304                        UGDS_AIANOld          0
          Total share of enrollment of undergraduate degree-seeking students who are American Indian/Alaska Native
      305                        UGDS_HISPOld          0
                 Total share of enrollment of undergraduate degree-seeking students who are Hispanic
      306                              UG_NRA          0
                     Total share of enrollment of undergraduate students who are non-resident aliens
      307                             UG_UNKN          0
                           Total share of enrollment of undergraduate students whose race is unknown
      308                          UG_WHITENH          0
                      Total share of enrollment of undergraduate students who are white non-Hispanic
      309                          UG_BLACKNH          0
                      Total share of enrollment of undergraduate students who are black non-Hispanic
      310                              UG_API          0
                  Total share of enrollment of undergraduate students who are Asian/Pacific Islander
      311                          UG_AIANOld          0
           Total share of enrollment of undergraduate students who are American Indian/Alaska Native
      312                          UG_HISPOld          0
                                Total share of enrollment of undergraduate students who are Hispanic
      314                           PPTUG_EF2          0
                      Share of undergraduate, degree-/certificate-seeking students who are part-time
      318                           NPT4_PROG          0
          Average net price for the largest program at the institution for program-year institutions
      319                          NPT4_OTHER          0
          Average net price for the largest program at the institution for schools on "other" academic year calendars
      330                          NPT41_PROG          0
                          Average net price for $0-$30,000 family income (program-year institutions)
      331                          NPT42_PROG          0
                     Average net price for $30,001-$48,000 family income (program-year institutions)
      332                          NPT43_PROG          0
                     Average net price for $48,001-$75,000 family income (program-year institutions)
      333                          NPT44_PROG          0
                    Average net price for $75,001-$110,000 family income (program-year institutions)
      334                          NPT45_PROG          0
                           Average net price for $110,000+ family income (program-year institutions)
      335                         NPT41_OTHER          0
               Average net price for $0-$30,000 family income (other academic calendar institutions)
      336                         NPT42_OTHER          0
          Average net price for $30,001-$48,000 family income (other academic calendar institutions)
      337                         NPT43_OTHER          0
          Average net price for $48,001-$75,000 family income (other academic calendar institutions)
      338                         NPT44_OTHER          0
          Average net price for $75,001-$110,000 family income (other academic calendar institutions)
      339                         NPT45_OTHER          0
                Average net price for $110,000+ family income (other academic calendar institutions)
      342                       NPT4_048_PROG          0
                          Average net price for $0-$48,000 family income (program-year institutions)
      343                      NPT4_048_OTHER          0
               Average net price for $0-$48,000 family income (other academic calendar institutions)
      348                      NPT4_3075_PROG          0
                     Average net price for $30,001-$75,000 family income (program-year institutions)
      349                     NPT4_3075_OTHER          0
          Average net price for $30,001-$75,000 family income (other academic calendar institutions)
      350                      NPT4_75UP_PROG          0
                            Average net price for $75,000+ family income (program-year institutions)
      351                     NPT4_75UP_OTHER          0
                 Average net price for $75,000+ family income (other academic calendar institutions)
      354                           NUM4_PROG          0
                                             Number of Title IV students (program-year institutions)
      355                          NUM4_OTHER          0
                                  Number of Title IV students (other academic calendar institutions)
      366                          NUM41_PROG          0
                   Number of Title IV students, $0-$30,000 family income (program-year institutions)
      367                          NUM42_PROG          0
              Number of Title IV students, $30,001-$48,000 family income (program-year institutions)
      368                          NUM43_PROG          0
              Number of Title IV students, $48,001-$75,000 family income (program-year institutions)
      369                          NUM44_PROG          0
             Number of Title IV students, $75,001-$110,000 family income (program-year institutions)
      370                          NUM45_PROG          0
                    Number of Title IV students, $110,000+ family income (program-year institutions)
      371                         NUM41_OTHER          0
          Number of Title IV students, $0-$30,000 family income (other academic calendar institutions)
      372                         NUM42_OTHER          0
          Number of Title IV students, $30,001-$48,000 family income (other academic calendar institutions)
      373                         NUM43_OTHER          0
          Number of Title IV students, $48,001-$75,000 family income (other academic calendar institutions)
      374                         NUM44_OTHER          0
          Number of Title IV students, $75,001-$110,000 family income (other academic calendar institutions)
      375                         NUM45_OTHER          0
          Number of Title IV students, $110,000+ family income (other academic calendar institutions)
      401                         C150_4_NHPI        270
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Native Hawaiian/Pacific Islander students
      402                         C150_4_2MOR        504
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for students of two-or-more-races
      405                      C150_4_WHITENH          0
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for white students
      406                      C150_4_BLACKNH          0
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for black students
      407                          C150_4_API          0
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Asian/Pacific Islander students
      408                      C150_4_AIANOld          0
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
      409                      C150_4_HISPOld          0
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Hispanic students
      415                        C150_L4_NHPI        427
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Native Hawaiian/Pacific Islander students
      416                        C150_L4_2MOR        751
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for students of two-or-more-races
      417                         C150_L4_NRA        655
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for non-resident alien students
      419                     C150_L4_WHITENH          0
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for white non-Hispanic students
      420                     C150_L4_BLACKNH          0
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for black non-Hispanic students
      421                         C150_L4_API          0
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Asian/Pacific Islander students
      422                     C150_L4_AIANOld          0
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
      423                     C150_L4_HISPOld          0
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Hispanic students
     1603                            count_ed          0
                                                            Count of students in the earnings cohort
     1604                           loan_ever          0
                                       Share of students who received a federal loan while in school
     1605                           pell_ever          0
                                         Share of students who received a Pell Grant while in school
     1606                           age_entry          0
                                                                  Average age of entry, via SSA data
     1607                        age_entry_sq          0
                                                                 Average of the age of entry squared
     1608                             agege24          0
                                                                Percent of students over 23 at entry
     1609                              female          0
                                                              Share of female students, via SSA data
     1610                             married          0
                                                                           Share of married students
     1611                           dependent          0
                                                                         Share of dependent students
     1612                             veteran          0
                                                                           Share of veteran students
     1613                           first_gen          0
                                                                  Share of first-generation students
     1614                              faminc          0
                                                                               Average family income
     1615                           md_faminc          0
                                                                                Median family income
     1616                          faminc_ind          0
                                                      Average family income for independent students
     1617                            lnfaminc          0
                                                                 Average of the log of family income
     1618                        lnfaminc_ind          0
                                        Average of the log of family income for independent students
     1619                           pct_white          0
                   Percent of the population from students' zip codes that is White, via Census data
     1620                           pct_black          0
                   Percent of the population from students' zip codes that is Black, via Census data
     1621                           pct_asian          0
                   Percent of the population from students' zip codes that is Asian, via Census data
     1622                        pct_hispanic          0
                Percent of the population from students' zip codes that is Hispanic, via Census data
     1623                              pct_ba          0
          Percent of the population from students' zip codes with a bachelor's degree over the age 25, via Census data
     1624                       pct_grad_prof          0
          Percent of the population from students' zip codes over 25 with a professional degree, via Census data
     1625                         pct_born_us          0
          Percent of the population from students' zip codes that was born in the US, via Census data
     1626                       median_hh_inc          0
                                                                             Median household income
     1627                        poverty_rate          0
                                                                       Poverty rate, via Census data
     1628                          unemp_rate          0
                                                                  Unemployment rate, via Census data
     1629                    ln_median_hh_inc          0
                                                                  Log of the median household income
     1630                         fsend_count          0
                             Number of students who sent their FAFSA reports to at least one college
     1631                             fsend_1          0
                                          Share of students who submitted FAFSAs to only one college
     1632                             fsend_2          0
                                              Share of students who submitted FAFSAs to two colleges
     1633                             fsend_3          0
                                            Share of students who submitted FAFSAs to three colleges
     1634                             fsend_4          0
                                             Share of students who submitted FAFSAs to four colleges
     1635                             fsend_5          0
                                    Share of students who submitted FAFSAs to at least five colleges
     1688                       count_nwne_p7          0
                                 Number of students not working and not enrolled 7 years after entry
     1689                        count_wne_p7          0
                                     Number of students working and not enrolled 7 years after entry
     1690                      mn_earn_wne_p7          0
                              Mean earnings of students working and not enrolled 7 years after entry
     1691                      sd_earn_wne_p7          0
             Standard deviation of earnings of students working and not enrolled 7 years after entry
     1692                           gt_25k_p7          0
                Share of students earning over $25,000/year (threshold earnings) 7 years after entry
     1703                       count_nwne_p9          0
                                 Number of students not working and not enrolled 9 years after entry
     1704                        count_wne_p9          0
                                     Number of students working and not enrolled 9 years after entry
     1705                      mn_earn_wne_p9          0
                              Mean earnings of students working and not enrolled 9 years after entry
     1706                      sd_earn_wne_p9          0
             Standard deviation of earnings of students working and not enrolled 9 years after entry
     1707                           gt_25k_p9          0
                Share of students earning over $25,000/year (threshold earnings) 9 years after entry
    


```python
data_count = data_trim.count() 
print (data_count.values < 4000).sum()
for i, name in enumerate(data_trim.columns):
    if data_count.values[[i]] < 4000:
        print i, name, data_count[name]
        print "%5i %35s %10i" %(i, name, data_count[[i]])
        try:
            print "      %90s" %map_variables[name]
        except:
            print "None"
```

    77
    19 CCUGPROF 3559
       19                            CCUGPROF       3559
                                                    Carnegie Classification -- undergraduate profile
    20 CCSIZSET 3576
       20                            CCSIZSET       3576
                                                         Carnegie Classification -- size and setting
    30 ADM_RATE 2347
       30                            ADM_RATE       2347
                                                                                      Admission rate
    31 ADM_RATE_ALL 2638
       31                        ADM_RATE_ALL       2638
                                     Admission rate for all campuses rolled up to the 6-digit OPE ID
    32 SATVR25 1267
       32                             SATVR25       1267
                                 25th percentile of SAT scores at the institution (critical reading)
    33 SATVR75 1267
       33                             SATVR75       1267
                                 75th percentile of SAT scores at the institution (critical reading)
    34 SATMT25 1290
       34                             SATMT25       1290
                                             25th percentile of SAT scores at the institution (math)
    35 SATMT75 1290
       35                             SATMT75       1290
                                             75th percentile of SAT scores at the institution (math)
    36 SATVRMID 1267
       36                            SATVRMID       1267
                                        Midpoint of SAT scores at the institution (critical reading)
    37 SATMTMID 1290
       37                            SATMTMID       1290
                                                    Midpoint of SAT scores at the institution (math)
    38 ACTCM25 1333
       38                             ACTCM25       1333
                                                         25th percentile of the ACT cumulative score
    39 ACTCM75 1333
       39                             ACTCM75       1333
                                                         75th percentile of the ACT cumulative score
    40 ACTEN25 1136
       40                             ACTEN25       1136
                                                            25th percentile of the ACT English score
    41 ACTEN75 1136
       41                             ACTEN75       1136
                                                            75th percentile of the ACT English score
    42 ACTMT25 1135
       42                             ACTMT25       1135
                                                               25th percentile of the ACT math score
    43 ACTMT75 1135
       43                             ACTMT75       1135
                                                               75th percentile of the ACT math score
    44 ACTCMMID 1333
       44                            ACTCMMID       1333
                                                                Midpoint of the ACT cumulative score
    45 ACTENMID 1136
       45                            ACTENMID       1136
                                                                   Midpoint of the ACT English score
    46 ACTMTMID 1135
       46                            ACTMTMID       1135
                                                                      Midpoint of the ACT math score
    47 SAT_AVG 1422
       47                             SAT_AVG       1422
                                                   Average SAT equivalent score of students admitted
    48 SAT_AVG_ALL 1533
       48                         SAT_AVG_ALL       1533
          Average SAT equivalent score of students admitted for all campuses rolled up to the 6-digit OPE ID
    290 NPT4_PUB 1961
      290                            NPT4_PUB       1961
                                   Average net price for Title IV institutions (public institutions)
    292 NPT41_PUB 1958
      292                           NPT41_PUB       1958
                                Average net price for $0-$30,000 family income (public institutions)
    293 NPT42_PUB 1771
      293                           NPT42_PUB       1771
                           Average net price for $30,001-$48,000 family income (public institutions)
    294 NPT43_PUB 1673
      294                           NPT43_PUB       1673
                           Average net price for $48,001-$75,000 family income (public institutions)
    295 NPT44_PUB 1447
      295                           NPT44_PUB       1447
                          Average net price for $75,001-$110,000 family income (public institutions)
    296 NPT45_PUB 1209
      296                           NPT45_PUB       1209
                                 Average net price for $110,000+ family income (public institutions)
    299 NPT43_PRIV 3594
      299                          NPT43_PRIV       3594
          Average net price for $48,001-$75,000 family income (private for-profit and nonprofit institutions)
    300 NPT44_PRIV 2921
      300                          NPT44_PRIV       2921
          Average net price for $75,001-$110,000 family income (private for-profit and nonprofit institutions)
    301 NPT45_PRIV 2333
      301                          NPT45_PRIV       2333
          Average net price for $110,000+ family income (private for-profit and nonprofit institutions)
    302 NPT4_048_PUB 1960
      302                        NPT4_048_PUB       1960
                                Average net price for $0-$48,000 family income (public institutions)
    304 NPT4_3075_PUB 1790
      304                       NPT4_3075_PUB       1790
                           Average net price for $30,001-$75,000 family income (public institutions)
    306 NPT4_75UP_PUB 1459
      306                       NPT4_75UP_PUB       1459
                                  Average net price for $75,000+ family income (public institutions)
    307 NPT4_75UP_PRIV 3062
      307                      NPT4_75UP_PRIV       3062
          Average net price for $75,000+ family income (private for-profit and nonprofit institutions)
    308 NUM4_PUB 1975
      308                            NUM4_PUB       1975
                                                   Number of Title IV students (public institutions)
    310 NUM41_PUB 1963
      310                           NUM41_PUB       1963
                         Number of Title IV students, $0-$30,000 family income (public institutions)
    311 NUM42_PUB 1963
      311                           NUM42_PUB       1963
                    Number of Title IV students, $30,001-$48,000 family income (public institutions)
    312 NUM43_PUB 1963
      312                           NUM43_PUB       1963
                    Number of Title IV students, $48,001-$75,000 family income (public institutions)
    313 NUM44_PUB 1963
      313                           NUM44_PUB       1963
                   Number of Title IV students, $75,001-$110,000 family income (public institutions)
    314 NUM45_PUB 1963
      314                           NUM45_PUB       1963
                          Number of Title IV students, $110,000+ family income (public institutions)
    321 COSTT4_P 2536
      321                            COSTT4_P       2536
                                              Average cost of attendance (program-year institutions)
    324 TUITIONFEE_PROG 2643
      324                     TUITIONFEE_PROG       2643
                                                      Tuition and fees for program-year institutions
    330 C150_4 2370
      330                              C150_4       2370
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years)
    331 C150_L4 3895
      331                             C150_L4       3895
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion)
    332 C150_4_POOLED 2472
      332                       C150_4_POOLED       2472
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years), pooled for two year rolling averages
    335 PFTFTUG1_EF 3737
      335                         PFTFTUG1_EF       3737
          Share of undergraduate students who are first-time, full-time degree-/certificate-seeking undergraduate students
    336 D150_4 2370
      336                              D150_4       2370
          Adjusted cohort count for completion rate at four-year institutions (denominator of completion rate)
    337 D150_L4 3895
      337                             D150_L4       3895
          Adjusted cohort count for completion rate at less-than-four-year institutions (denominator of completion rate)
    338 D150_4_POOLED 2472
      338                       D150_4_POOLED       2472
          Adjusted cohort count for completion rate at four-year institutions (denominator of completion rate), pooled for two-year rolling averages
    340 C150_4_WHITE 2258
      340                        C150_4_WHITE       2258
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for white students
    341 C150_4_BLACK 2099
      341                        C150_4_BLACK       2099
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for black students
    342 C150_4_HISP 2066
      342                         C150_4_HISP       2066
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Hispanic students
    343 C150_4_ASIAN 1791
      343                        C150_4_ASIAN       1791
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Asian students
    344 C150_4_AIAN 1488
      344                         C150_4_AIAN       1488
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
    345 C150_4_NRA 1467
      345                          C150_4_NRA       1467
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for non-resident alien students
    346 C150_4_UNKN 1635
      346                         C150_4_UNKN       1635
          Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for students whose race is unknown
    347 C150_L4_WHITE 2122
      347                       C150_L4_WHITE       2122
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for white students
    348 C150_L4_BLACK 1913
      348                       C150_L4_BLACK       1913
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for black students
    349 C150_L4_HISP 1832
      349                        C150_L4_HISP       1832
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Hispanic students
    350 C150_L4_ASIAN 1475
      350                       C150_L4_ASIAN       1475
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Asian students
    351 C150_L4_AIAN 1333
      351                        C150_L4_AIAN       1333
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
    352 C150_L4_UNKN 1367
      352                        C150_L4_UNKN       1367
          Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for students whose race is unknown
    353 C200_4 2047
      353                              C200_4       2047
    None
    354 C200_L4 3742
      354                             C200_L4       3742
    None
    355 D200_4 2047
      355                              D200_4       2047
    None
    356 D200_L4 3742
      356                             D200_L4       3742
    None
    357 RET_FT4 2363
      357                             RET_FT4       2363
                              First-time, full-time student retention rate at four-year institutions
    358 RET_FTL4 3945
      358                            RET_FTL4       3945
                    First-time, full-time student retention rate at less-than-four-year institutions
    359 RET_PT4 1502
      359                             RET_PT4       1502
                              First-time, part-time student retention rate at four-year institutions
    360 RET_PTL4 2275
      360                            RET_PTL4       2275
                    First-time, part-time student retention rate at less-than-four-year institutions
    361 C200_4_POOLED 2160
      361                       C200_4_POOLED       2160
    None
    362 C200_L4_POOLED 3794
      362                      C200_L4_POOLED       3794
    None
    364 D200_4_POOLED 2160
      364                       D200_4_POOLED       2160
    None
    365 D200_L4_POOLED 3794
      365                      D200_L4_POOLED       3794
    None
    1612 C150_4_POOLED_SUPP 2472
     1612                  C150_4_POOLED_SUPP       2472
          150% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For four year school, students are considered to have graduated "on time" if they graduate within 6 years.
    1613 C200_L4_POOLED_SUPP 3794
     1613                 C200_L4_POOLED_SUPP       3794
          200% completion rate for less-than-four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For two year schools, students are considered to have graduated "on time" if they graduate within 4 years.
    1614 C200_4_POOLED_SUPP 2160
     1614                  C200_4_POOLED_SUPP       2160
          200% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size
    


```python
data_trim.columns
```




    Index([u'UNITID', u'OPEID', u'opeid6', u'INSTNM', u'CITY', u'STABBR', u'ZIP',
           u'sch_deg', u'main', u'NUMBRANCH',
           ...
           u'PELL_RPY_3YR_RT_SUPP', u'NOPELL_RPY_3YR_RT_SUPP',
           u'FEMALE_RPY_3YR_RT_SUPP', u'MALE_RPY_3YR_RT_SUPP',
           u'FIRSTGEN_RPY_3YR_RT_SUPP', u'NOTFIRSTGEN_RPY_3YR_RT_SUPP',
           u'C150_L4_POOLED_SUPP', u'C150_4_POOLED_SUPP', u'C200_L4_POOLED_SUPP',
           u'C200_4_POOLED_SUPP'],
          dtype='object', length=1615)



### Filter academic institutions

Having the SAT and ACT scores is important and seems an efficient filter to the institutions with more complete data. So does the question of whether a school is currently operational or not.


```python
data_trim.groupby("CURROPER").count()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>UNITID</th>
      <th>OPEID</th>
      <th>opeid6</th>
      <th>INSTNM</th>
      <th>CITY</th>
      <th>STABBR</th>
      <th>ZIP</th>
      <th>sch_deg</th>
      <th>main</th>
      <th>NUMBRANCH</th>
      <th>...</th>
      <th>PELL_RPY_3YR_RT_SUPP</th>
      <th>NOPELL_RPY_3YR_RT_SUPP</th>
      <th>FEMALE_RPY_3YR_RT_SUPP</th>
      <th>MALE_RPY_3YR_RT_SUPP</th>
      <th>FIRSTGEN_RPY_3YR_RT_SUPP</th>
      <th>NOTFIRSTGEN_RPY_3YR_RT_SUPP</th>
      <th>C150_L4_POOLED_SUPP</th>
      <th>C150_4_POOLED_SUPP</th>
      <th>C200_L4_POOLED_SUPP</th>
      <th>C200_4_POOLED_SUPP</th>
    </tr>
    <tr>
      <th>CURROPER</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>470</td>
      <td>470</td>
      <td>470</td>
      <td>470</td>
      <td>470</td>
      <td>470</td>
      <td>470</td>
      <td>463</td>
      <td>470</td>
      <td>470</td>
      <td>...</td>
      <td>384</td>
      <td>384</td>
      <td>384</td>
      <td>384</td>
      <td>384</td>
      <td>384</td>
      <td>307</td>
      <td>70</td>
      <td>284</td>
      <td>57</td>
    </tr>
    <tr>
      <th>1</th>
      <td>7205</td>
      <td>7205</td>
      <td>7205</td>
      <td>7205</td>
      <td>7205</td>
      <td>7205</td>
      <td>7205</td>
      <td>7117</td>
      <td>7205</td>
      <td>7205</td>
      <td>...</td>
      <td>6119</td>
      <td>6119</td>
      <td>6119</td>
      <td>6119</td>
      <td>6119</td>
      <td>6119</td>
      <td>3711</td>
      <td>2402</td>
      <td>3510</td>
      <td>2103</td>
    </tr>
  </tbody>
</table>
<p>2 rows × 1614 columns</p>
</div>




```python
import numpy as np
# Check that there is a value in either SAT_AVG or ACTCMMID
trim_2 = data_trim[data_trim.apply(lambda x: np.isfinite(x["SAT_AVG"]) or np.isfinite(x["ACTCMMID"]), axis=1)]
# Check that the school is still in operation
trim_3 = trim_2[trim_2["CURROPER"] == 1]
print "Total institutions", trim_3["INSTNM"].count()
for name in sorted(trim_3.columns):
    print trim_3[name].count(), name, map_variables.get(name, "None")

```

    Total institutions 1361
    1361 AANAPII Flag for Asian American Native American Pacific Islander-serving institution
    1278 ACTCM25 25th percentile of the ACT cumulative score
    1278 ACTCM75 75th percentile of the ACT cumulative score
    1278 ACTCMMID Midpoint of the ACT cumulative score
    1086 ACTEN25 25th percentile of the ACT English score
    1086 ACTEN75 75th percentile of the ACT English score
    1086 ACTENMID Midpoint of the ACT English score
    1085 ACTMT25 25th percentile of the ACT math score
    1085 ACTMT75 75th percentile of the ACT math score
    1085 ACTMTMID Midpoint of the ACT math score
    1361 ADM_RATE Admission rate
    1361 ADM_RATE_ALL Admission rate for all campuses rolled up to the 6-digit OPE ID
    1361 ANNHI Flag for Alaska Native Native Hawaiian serving institution
    1361 APPL_SCH_N Number of students in the FAFSA applications cohort
    1361 APPL_SCH_PCT_GE2 Number of applications is greater than or equal to 2
    1361 APPL_SCH_PCT_GE3 Number of applications is greater than or equal to 3
    1361 APPL_SCH_PCT_GE4 Number of applications is greater than or equal to 4
    1361 APPL_SCH_PCT_GE5 Number of applications is greater than or equal to 5
    1345 AVGFACSAL Average faculty salary
    1310 C150_4 Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years)
    984 C150_4_AIAN Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
    1164 C150_4_ASIAN Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Asian students
    1264 C150_4_BLACK Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for black students
    1248 C150_4_HISP Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for Hispanic students
    1049 C150_4_NRA Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for non-resident alien students
    661 C150_4_POOLED Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years), pooled for two year rolling averages
    661 C150_4_POOLED_SUPP 150% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For four year school, students are considered to have graduated "on time" if they graduate within 6 years.
    1011 C150_4_UNKN Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for students whose race is unknown
    1288 C150_4_WHITE Completion rate for first-time, full-time students at four-year institutions (150% of expected time to completion/6 years) for white students
    36 C150_L4 Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion)
    17 C150_L4_AIAN Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for American Indian/Alaska Native students
    20 C150_L4_ASIAN Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Asian students
    25 C150_L4_BLACK Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for black students
    22 C150_L4_HISP Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for Hispanic students
    599 C150_L4_POOLED Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion), pooled for two year rolling averages
    599 C150_L4_POOLED_SUPP 150% completion rate for less-than-four-year institutions, pooled in two-year rolling averages and suppressed for small n size
    15 C150_L4_UNKN Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for students whose race is unknown
    35 C150_L4_WHITE Completion rate for first-time, full-time students at less-than-four-year institutions (150% of expected time to completion/6 years) for white students
    1298 C200_4 None
    618 C200_4_POOLED None
    618 C200_4_POOLED_SUPP 200% completion rate for four-year institutions, pooled in two-year rolling averages and suppressed for small n size
    37 C200_L4 None
    599 C200_L4_POOLED None
    599 C200_L4_POOLED_SUPP 200% completion rate for less-than-four-year institutions, pooled in two-year rolling averages and suppressed for small n size.  For two year schools, students are considered to have graduated "on time" if they graduate within 4 years.
    1061 CCBASIC Carnegie Classification -- basic
    900 CCSIZSET Carnegie Classification -- size and setting
    897 CCUGPROF Carnegie Classification -- undergraduate profile
    1361 CDR2 Two-year cohort default rate
    1359 CDR3 Three-year cohort default rate
    1361 CIP01ASSOC Associate degree in Agriculture, Agriculture Operations, And Related Sciences.
    1361 CIP01BACHL Bachelor's degree in Agriculture, Agriculture Operations, And Related Sciences.
    1361 CIP01CERT1 Certificate of less than one academic year in Agriculture, Agriculture Operations, And Related Sciences.
    1361 CIP01CERT2 Certificate of at least one but less than two academic years in Agriculture, Agriculture Operations, And Related Sciences.
    1361 CIP01CERT4 Awards of at least two but less than four academic years in Agriculture, Agriculture Operations, And Related Sciences.
    1361 CIP03ASSOC Associate degree in Natural Resources And Conservation.
    1361 CIP03BACHL Bachelor's degree in Natural Resources And Conservation.
    1361 CIP03CERT1 Certificate of less than one academic year in Natural Resources And Conservation.
    1361 CIP03CERT2 Certificate of at least one but less than two academic years in Natural Resources And Conservation.
    1361 CIP03CERT4 Award of at least two but less than four academic years in Natural Resources And Conservation.
    1361 CIP04ASSOC Associate degree in Architecture And Related Services.
    1361 CIP04BACHL Bachelor's degree in Architecture And Related Services.
    1361 CIP04CERT1 Certificate of less than one academic year in Architecture And Related Services.
    1361 CIP04CERT2 Certificate of at least one but less than two academic years in Architecture And Related Services.
    1361 CIP04CERT4 Award of more than two but less than four academic years in Architecture And Related Services.
    1361 CIP05ASSOC Associate degree in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 CIP05BACHL Bachelor's degree in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 CIP05CERT1 Certificate of less than one academic year in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 CIP05CERT2 Certificate of at least one but less than two academic years in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 CIP05CERT4 Award of more than two but less than four academic years in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 CIP09ASSOC Associate degree in Communication, Journalism, And Related Programs.
    1361 CIP09BACHL Bachelor's degree in Communication, Journalism, And Related Programs.
    1361 CIP09CERT1 Certificate of less than one academic year in Communication, Journalism, And Related Programs.
    1361 CIP09CERT2 Certificate of at least one but less than two academic years in Communication, Journalism, And Related Programs.
    1361 CIP09CERT4 Award of more than two but less than four academic years in Communication, Journalism, And Related Programs.
    1361 CIP10ASSOC Associate degree in Communications Technologies/Technicians And Support Services.
    1361 CIP10BACHL Bachelor's degree in Communications Technologies/Technicians And Support Services.
    1361 CIP10CERT1 Certificate of less than one academic year in Communications Technologies/Technicians And Support Services.
    1361 CIP10CERT2 Certificate of at least one but less than two academic years in Communications Technologies/Technicians And Support Services.
    1361 CIP10CERT4 Award of more than two but less than four academic years in Communications Technologies/Technicians And Support Services.
    1361 CIP11ASSOC Associate degree in Computer And Information Sciences And Support Services.
    1361 CIP11BACHL Bachelor's degree in Computer And Information Sciences And Support Services.
    1361 CIP11CERT1 Certificate of less than one academic year in Computer And Information Sciences And Support Services.
    1361 CIP11CERT2 Certificate of at least one but less than two academic years in Computer And Information Sciences And Support Services.
    1361 CIP11CERT4 Award of more than two but less than four academic years in Computer And Information Sciences And Support Services.
    1361 CIP12ASSOC Associate degree in Personal And Culinary Services.
    1361 CIP12BACHL Bachelor's degree in Personal And Culinary Services.
    1361 CIP12CERT1 Certificate of less than one academic year in Personal And Culinary Services.
    1361 CIP12CERT2 Certificate of at least one but less than two academic years in Personal And Culinary Services.
    1361 CIP12CERT4 Award of more than two but less than four academic years in Personal And Culinary Services.
    1361 CIP13ASSOC Associate degree in Education.
    1361 CIP13BACHL Bachelor's degree in Education.
    1361 CIP13CERT1 Certificate of less than one academic year in Education.
    1361 CIP13CERT2 Certificate of at least one but less than two academic years in Education.
    1361 CIP13CERT4 Award of more than two but less than four academic years in Education.
    1361 CIP14ASSOC Associate degree in Engineering.
    1361 CIP14BACHL Bachelor's degree in Engineering.
    1361 CIP14CERT1 Certificate of less than one academic year in Engineering.
    1361 CIP14CERT2 Certificate of at least one but less than two academic years in Engineering.
    1361 CIP14CERT4 Award of more than two but less than four academic years in Engineering.
    1361 CIP15ASSOC Associate degree in Engineering Technologies And Engineering-Related Fields.
    1361 CIP15BACHL Bachelor's degree in Engineering Technologies And Engineering-Related Fields.
    1361 CIP15CERT1 Certificate of less than one academic year in Engineering Technologies And Engineering-Related Fields.
    1361 CIP15CERT2 Certificate of at least one but less than two academic years in Engineering Technologies And Engineering-Related Fields.
    1361 CIP15CERT4 Award of more than two but less than four academic years in Engineering Technologies And Engineering-Related Fields.
    1361 CIP16ASSOC Associate degree in Foreign Languages, Literatures, And Linguistics.
    1361 CIP16BACHL Bachelor's degree in Foreign Languages, Literatures, And Linguistics.
    1361 CIP16CERT1 Certificate of less than one academic year in Foreign Languages, Literatures, And Linguistics.
    1361 CIP16CERT2 Certificate of at least one but less than two academic years in Foreign Languages, Literatures, And Linguistics.
    1361 CIP16CERT4 Award of more than two but less than four academic years in Foreign Languages, Literatures, And Linguistics.
    1361 CIP19ASSOC Associate degree in Family And Consumer Sciences/Human Sciences.
    1361 CIP19BACHL Bachelor's degree in Family And Consumer Sciences/Human Sciences.
    1361 CIP19CERT1 Certificate of less than one academic year in Family And Consumer Sciences/Human Sciences.
    1361 CIP19CERT2 Certificate of at least one but less than two academic years in Family And Consumer Sciences/Human Sciences.
    1361 CIP19CERT4 Award of more than two but less than four academic years in Family And Consumer Sciences/Human Sciences.
    1361 CIP22ASSOC Associate degree in Legal Professions And Studies.
    1361 CIP22BACHL Bachelor's degree in Legal Professions And Studies.
    1361 CIP22CERT1 Certificate of less than one academic year in Legal Professions And Studies.
    1361 CIP22CERT2 Certificate of at least one but less than two academic years in Legal Professions And Studies.
    1361 CIP22CERT4 Award of more than two but less than four academic years in Legal Professions And Studies.
    1361 CIP23ASSOC Associate degree in English Language And Literature/Letters.
    1361 CIP23BACHL Bachelor's degree in English Language And Literature/Letters.
    1361 CIP23CERT1 Certificate of less than one academic year in English Language And Literature/Letters.
    1361 CIP23CERT2 Certificate of at least one but less than two academic years in English Language And Literature/Letters.
    1361 CIP23CERT4 Award of more than two but less than four academic years in English Language And Literature/Letters.
    1361 CIP24ASSOC Associate degree in Liberal Arts And Sciences, General Studies And Humanities.
    1361 CIP24BACHL Bachelor's degree in Liberal Arts And Sciences, General Studies And Humanities.
    1361 CIP24CERT1 Certificate of less than one academic year in Liberal Arts And Sciences, General Studies And Humanities.
    1361 CIP24CERT2 Certificate of at least one but less than two academic years in Liberal Arts And Sciences, General Studies And Humanities.
    1361 CIP24CERT4 Award of more than two but less than four academic years in Liberal Arts And Sciences, General Studies And Humanities.
    1361 CIP25ASSOC Associate degree in Library Science.
    1361 CIP25BACHL Bachelor's degree in Library Science.
    1361 CIP25CERT1 Certificate of less than one academic year in Library Science.
    1361 CIP25CERT2 Certificate of at least one but less than two academic years in Library Science.
    1361 CIP25CERT4 Award of more than two but less than four academic years in Library Science.
    1361 CIP26ASSOC Associate degree in Biological And Biomedical Sciences.
    1361 CIP26BACHL Bachelor's degree in Biological And Biomedical Sciences.
    1361 CIP26CERT1 Certificate of less than one academic year in Biological And Biomedical Sciences.
    1361 CIP26CERT2 Certificate of at least one but less than two academic years in Biological And Biomedical Sciences.
    1361 CIP26CERT4 Award of more than two but less than four academic years in Biological And Biomedical Sciences.
    1361 CIP27ASSOC Associate degree in Mathematics And Statistics.
    1361 CIP27BACHL Bachelor's degree in Mathematics And Statistics.
    1361 CIP27CERT1 Certificate of less than one academic year in Mathematics And Statistics.
    1361 CIP27CERT2 Certificate of at least one but less than two academic years in Mathematics And Statistics.
    1361 CIP27CERT4 Award of more than two but less than four academic years in Mathematics And Statistics.
    1361 CIP29ASSOC Associate degree in Military Technologies And Applied Sciences.
    1361 CIP29BACHL Bachelor's degree in Military Technologies And Applied Sciences.
    1361 CIP29CERT1 Certificate of less than one academic year in Military Technologies And Applied Sciences.
    1361 CIP29CERT2 Certificate of at least one but less than two academic years in Military Technologies And Applied Sciences.
    1361 CIP29CERT4 Award of more than two but less than four academic years in Military Technologies And Applied Sciences.
    1361 CIP30ASSOC Associate degree in Multi/Interdisciplinary Studies.
    1361 CIP30BACHL Bachelor's degree in Multi/Interdisciplinary Studies.
    1361 CIP30CERT1 Certificate of less than one academic year in Multi/Interdisciplinary Studies.
    1361 CIP30CERT2 Certificate of at least one but less than two academic years in Multi/Interdisciplinary Studies.
    1361 CIP30CERT4 Award of more than two but less than four academic years in Multi/Interdisciplinary Studies.
    1361 CIP31ASSOC Associate degree in Parks, Recreation, Leisure, And Fitness Studies.
    1361 CIP31BACHL Bachelor's degree in Parks, Recreation, Leisure, And Fitness Studies.
    1361 CIP31CERT1 Certificate of less than one academic year in Parks, Recreation, Leisure, And Fitness Studies.
    1361 CIP31CERT2 Certificate of at least one but less than two academic years in Parks, Recreation, Leisure, And Fitness Studies.
    1361 CIP31CERT4 Award of more than two but less than four academic years in Parks, Recreation, Leisure, And Fitness Studies.
    1361 CIP38ASSOC Associate degree in Philosophy And Religious Studies.
    1361 CIP38BACHL Bachelor's degree in Philosophy And Religious Studies.
    1361 CIP38CERT1 Certificate of less than one academic year in Philosophy And Religious Studies.
    1361 CIP38CERT2 Certificate of at least one but less than two academic years in Philosophy And Religious Studies.
    1361 CIP38CERT4 Award of more than two but less than four academic years in Philosophy And Religious Studies.
    1361 CIP39ASSOC Associate degree in Theology And Religious Vocations.
    1361 CIP39BACHL Bachelor's degree in Theology And Religious Vocations.
    1361 CIP39CERT1 Certificate of less than one academic year in Theology And Religious Vocations.
    1361 CIP39CERT2 Certificate of at least one but less than two academic years in Theology And Religious Vocations.
    1361 CIP39CERT4 Award of more than two but less than four academic years in Theology And Religious Vocations.
    1361 CIP40ASSOC Associate degree in Physical Sciences.
    1361 CIP40BACHL Bachelor's degree in Physical Sciences.
    1361 CIP40CERT1 Certificate of less than one academic year in Physical Sciences.
    1361 CIP40CERT2 Certificate of at least one but less than two academic years in Physical Sciences.
    1361 CIP40CERT4 Award of more than two but less than four academic years in Physical Sciences.
    1361 CIP41ASSOC Associate degree in Science Technologies/Technicians.
    1361 CIP41BACHL Bachelor's degree in Science Technologies/Technicians.
    1361 CIP41CERT1 Certificate of less than one academic year in Science Technologies/Technicians.
    1361 CIP41CERT2 Certificate of at least one but less than two academic years in Science Technologies/Technicians.
    1361 CIP41CERT4 Award of more than two but less than four academic years in Science Technologies/Technicians.
    1361 CIP42ASSOC Associate degree in Psychology.
    1361 CIP42BACHL Bachelor's degree in Psychology.
    1361 CIP42CERT1 Certificate of less than one academic year in Psychology.
    1361 CIP42CERT2 Certificate of at least one but less than two academic years in Psychology.
    1361 CIP42CERT4 Award of more than two but less than four academic years in Psychology.
    1361 CIP43ASSOC Associate degree in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 CIP43BACHL Bachelor's degree in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 CIP43CERT1 Certificate of less than one academic year in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 CIP43CERT2 Certificate of at least one but less than two academic years in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 CIP43CERT4 Award of more than two but less than four academic years in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 CIP44ASSOC Associate degree in Public Administration And Social Service Professions.
    1361 CIP44BACHL Bachelor's degree in Public Administration And Social Service Professions.
    1361 CIP44CERT1 Certificate of less than one academic year in Public Administration And Social Service Professions.
    1361 CIP44CERT2 Certificate of at least one but less than two academic years in Public Administration And Social Service Professions.
    1361 CIP44CERT4 Award of more than two but less than four academic years in Public Administration And Social Service Professions.
    1361 CIP45ASSOC Associate degree in Social Sciences.
    1361 CIP45BACHL Bachelor's degree in Social Sciences.
    1361 CIP45CERT1 Certificate of less than one academic year in Social Sciences.
    1361 CIP45CERT2 Certificate of at least one but less than two academic years in Social Sciences.
    1361 CIP45CERT4 Award of more than two but less than four academic years in Social Sciences.
    1361 CIP46ASSOC Associate degree in Construction Trades.
    1361 CIP46BACHL Bachelor's degree in Construction Trades.
    1361 CIP46CERT1 Certificate of less than one academic year in Construction Trades.
    1361 CIP46CERT2 Certificate of at least one but less than two academic years in Construction Trades.
    1361 CIP46CERT4 Award of more than two but less than four academic years in Construction Trades.
    1361 CIP47ASSOC Associate degree in Mechanic And Repair Technologies/Technicians.
    1361 CIP47BACHL Bachelor's degree in Mechanic And Repair Technologies/Technicians.
    1361 CIP47CERT1 Certificate of less than one academic year in Mechanic And Repair Technologies/Technicians.
    1361 CIP47CERT2 Certificate of at least one but less than two academic years in Mechanic And Repair Technologies/Technicians.
    1361 CIP47CERT4 Award of more than two but less than four academic years in Mechanic And Repair Technologies/Technicians.
    1361 CIP48ASSOC Associate degree in Precision Production.
    1361 CIP48BACHL Bachelor's degree in Precision Production.
    1361 CIP48CERT1 Certificate of less than one academic year in Precision Production.
    1361 CIP48CERT2 Certificate of at least one but less than two academic years in Precision Production.
    1361 CIP48CERT4 Award of more than two but less than four academic years in Precision Production.
    1361 CIP49ASSOC Associate degree in Transportation And Materials Moving.
    1361 CIP49BACHL Bachelor's degree in Transportation And Materials Moving.
    1361 CIP49CERT1 Certificate of less than one academic year in Transportation And Materials Moving.
    1361 CIP49CERT2 Certificate of at least one but less than two academic years in Transportation And Materials Moving.
    1361 CIP49CERT4 Award of more than two but less than four academic years in Transportation And Materials Moving.
    1361 CIP50ASSOC Associate degree in Visual And Performing Arts.
    1361 CIP50BACHL Bachelor's degree in Visual And Performing Arts.
    1361 CIP50CERT1 Certificate of less than one academic year in Visual And Performing Arts.
    1361 CIP50CERT2 Certificate of at least one but less than two academic years in Visual And Performing Arts.
    1361 CIP50CERT4 Award of more than two but less than four academic years in Visual And Performing Arts.
    1361 CIP51ASSOC Associate degree in Health Professions And Related Programs.
    1361 CIP51BACHL Bachelor's degree in Health Professions And Related Programs.
    1361 CIP51CERT1 Certificate of less than one academic year in Health Professions And Related Programs.
    1361 CIP51CERT2 Certificate of at least one but less than two academic years in Health Professions And Related Programs.
    1361 CIP51CERT4 Award of more than two but less than four academic years in Health Professions And Related Programs.
    1361 CIP52ASSOC Associate degree in Business, Management, Marketing, And Related Support Services.
    1361 CIP52BACHL Bachelor's degree in Business, Management, Marketing, And Related Support Services.
    1361 CIP52CERT1 Certificate of less than one academic year in Business, Management, Marketing, And Related Support Services.
    1361 CIP52CERT2 Certificate of at least one but less than two academic years in Business, Management, Marketing, And Related Support Services.
    1361 CIP52CERT4 Award of more than two but less than four academic years in Business, Management, Marketing, And Related Support Services.
    1361 CIP54ASSOC Associate degree in History.
    1361 CIP54BACHL Bachelor's degree in History.
    1361 CIP54CERT1 Certificate of less than one academic year in History.
    1361 CIP54CERT2 Certificate of at least one but less than two academic years in History.
    1361 CIP54CERT4 Award of more than two but less than four academic years in History.
    1361 CITY City
    1357 COMPL_RPY_1YR_N Number of students in the 1-year repayment rate of completers cohort
    1357 COMPL_RPY_1YR_RT One-year repayment rate for completers
    1351 COMPL_RPY_3YR_N Number of students in the 3-year repayment rate of completers cohort
    1351 COMPL_RPY_3YR_RT Three-year repayment rate for completers
    1351 COMPL_RPY_3YR_RT_SUPP 3-year repayment rate for completers, suppressed for n=30
    1348 COMPL_RPY_5YR_N Number of students in the 5-year repayment rate of completers cohort
    1348 COMPL_RPY_5YR_RT Five-year repayment rate for completers
    1178 COMPL_RPY_7YR_N Number of students in the 7-year repayment rate of completers cohort
    1178 COMPL_RPY_7YR_RT Seven-year repayment rate for completers
    1361 COMP_2YR_TRANS_YR2_RT Percent who transferred to a 2-year institution and completed within 2 years
    1361 COMP_2YR_TRANS_YR3_RT Percent who transferred to a 2-year institution and completed within 3 years
    1354 COMP_2YR_TRANS_YR4_RT Percent who transferred to a 2-year institution and completed within 4 years
    1351 COMP_2YR_TRANS_YR6_RT Percent who transferred to a 2-year institution and completed within 6 years
    1348 COMP_2YR_TRANS_YR8_RT Percent who transferred to a 2-year institution and completed within 8 years
    1361 COMP_4YR_TRANS_YR2_RT Percent who transferred to a 4-year institution and completed within 2 years
    1361 COMP_4YR_TRANS_YR3_RT Percent who transferred to a 4-year institution and completed within 3 years
    1354 COMP_4YR_TRANS_YR4_RT Percent who transferred to a 4-year institution and completed within 4 years
    1351 COMP_4YR_TRANS_YR6_RT Percent who transferred to a 4-year institution and completed within 6 years
    1348 COMP_4YR_TRANS_YR8_RT Percent who transferred to a 4-year institution and completed within 8 years
    1361 COMP_ORIG_YR2_RT Percent completed within 2 years at original institution
    1361 COMP_ORIG_YR3_RT Percent completed within 3 years at original institution
    1354 COMP_ORIG_YR4_RT Percent completed within 4 years at original institution
    1351 COMP_ORIG_YR6_RT Percent completed within 6 years at original institution
    1348 COMP_ORIG_YR8_RT Percent completed within 8 years at original institution
    1361 CONTROL Control of institution
    1355 COSTT4_A Average cost of attendance (academic year institutions)
    2 COSTT4_P Average cost of attendance (program-year institutions)
    1358 CUML_DEBT_N Number of students in the cumulative loan debt cohort
    1358 CUML_DEBT_P10 Cumulative loan debt at the 10th percentile
    1358 CUML_DEBT_P25 Cumulative loan debt at the 25th percentile
    1358 CUML_DEBT_P75 Cumulative loan debt at the 75th percentile
    1358 CUML_DEBT_P90 Cumulative loan debt at the 90th percentile
    1361 CURROPER Flag for currently operating institution, 0=closed, 1=operating
    1310 D150_4 Adjusted cohort count for completion rate at four-year institutions (denominator of completion rate)
    661 D150_4_POOLED Adjusted cohort count for completion rate at four-year institutions (denominator of completion rate), pooled for two-year rolling averages
    36 D150_L4 Adjusted cohort count for completion rate at less-than-four-year institutions (denominator of completion rate)
    599 D150_L4_POOLED Adjusted cohort count for completion rate at less-than-four-year institutions (denominator of completion rate), pooled for two-year rolling averages
    1298 D200_4 None
    618 D200_4_POOLED None
    37 D200_L4 None
    599 D200_L4_POOLED None
    1361 DEATH_YR2_RT Percent died within 2 years at original institution
    1361 DEATH_YR3_RT Percent died within 3 years at original institution
    1354 DEATH_YR4_RT Percent died within 4 years at original institution
    1351 DEATH_YR6_RT Percent died within 6 years at original institution
    1348 DEATH_YR8_RT Percent died within 8 years at original institution
    1358 DEBT_MDN The original amount of the loan principal upon entering repayment
    1358 DEBT_MDN_SUPP Median debt, suppressed for n=30
    1358 DEBT_N The number of students in the median debt cohort
    1361 DEP_COMP_2YR_TRANS_YR2_RT Percent of dependent students who transferred to a 2-year institution and completed within 2 years
    1361 DEP_COMP_2YR_TRANS_YR3_RT Percent of dependent students who transferred to a 2-year institution and completed within 3 years
    1354 DEP_COMP_2YR_TRANS_YR4_RT Percent of dependent students who transferred to a 2-year institution and completed within 4 years
    1351 DEP_COMP_2YR_TRANS_YR6_RT Percent of dependent students who transferred to a 2-year institution and completed within 6 years
    1348 DEP_COMP_2YR_TRANS_YR8_RT Percent of dependent students who transferred to a 2-year institution and completed within 8 years
    1361 DEP_COMP_4YR_TRANS_YR2_RT Percent of dependent students who transferred to a 4-year institution and completed within 2 years
    1361 DEP_COMP_4YR_TRANS_YR3_RT Percent of dependent students who transferred to a 4-year institution and completed within 3 years
    1354 DEP_COMP_4YR_TRANS_YR4_RT Percent of dependent students who transferred to a 4-year institution and completed within 4 years
    1351 DEP_COMP_4YR_TRANS_YR6_RT Percent of dependent students who transferred to a 4-year institution and completed within 6 years
    1348 DEP_COMP_4YR_TRANS_YR8_RT Percent of dependent students who transferred to a 4-year institution and completed within 8 years
    1361 DEP_COMP_ORIG_YR2_RT Percent of dependent students who completed within 2 years at original institution
    1361 DEP_COMP_ORIG_YR3_RT Percent of dependent students who completed within 3 years at original institution
    1354 DEP_COMP_ORIG_YR4_RT Percent of dependent students who completed within 4 years at original institution
    1351 DEP_COMP_ORIG_YR6_RT Percent of dependent students who completed within 6 years at original institution
    1348 DEP_COMP_ORIG_YR8_RT Percent of dependent students who completed within 8 years at original institution
    1361 DEP_DEATH_YR2_RT Percent of dependent students who died within 2 years at original institution
    1361 DEP_DEATH_YR3_RT Percent of dependent students who died within 3 years at original institution
    1354 DEP_DEATH_YR4_RT Percent of dependent students who died within 4 years at original institution
    1351 DEP_DEATH_YR6_RT Percent of dependent students who died within 6 years at original institution
    1348 DEP_DEATH_YR8_RT Percent of dependent students who died within 8 years at original institution
    1358 DEP_DEBT_MDN The median debt for dependent students
    1358 DEP_DEBT_N The number of students in the median debt dependent students cohort
    1361 DEP_ENRL_2YR_TRANS_YR2_RT Percent of dependent students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 DEP_ENRL_2YR_TRANS_YR3_RT Percent of dependent students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 DEP_ENRL_2YR_TRANS_YR4_RT Percent of dependent students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 DEP_ENRL_2YR_TRANS_YR6_RT Percent of dependent students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 DEP_ENRL_2YR_TRANS_YR8_RT Percent of dependent students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 DEP_ENRL_4YR_TRANS_YR2_RT Percent of dependent students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 DEP_ENRL_4YR_TRANS_YR3_RT Percent of dependent students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 DEP_ENRL_4YR_TRANS_YR4_RT Percent of dependent students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 DEP_ENRL_4YR_TRANS_YR6_RT Percent of dependent students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 DEP_ENRL_4YR_TRANS_YR8_RT Percent of dependent students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 DEP_ENRL_ORIG_YR2_RT Percent of dependent students who were still enrolled at original institution within 2 years 
    1361 DEP_ENRL_ORIG_YR3_RT Percent of dependent students who were still enrolled at original institution within 3 years
    1354 DEP_ENRL_ORIG_YR4_RT Percent of dependent students who were still enrolled at original institution within 4 years
    1351 DEP_ENRL_ORIG_YR6_RT Percent of dependent students who were still enrolled at original institution within 6 years
    1348 DEP_ENRL_ORIG_YR8_RT Percent of dependent students who were still enrolled at original institution within 8 years
    1361 DEP_INC_AVG Average family income of dependent students in real 2014 dollars.
    1361 DEP_INC_N Number of students in the family income dependent students cohort
    1361 DEP_INC_PCT_H1 Dependent students with family incomes between $75,001-$110,000 in nominal dollars
    1361 DEP_INC_PCT_H2 Dependent students with family incomes between $110,001+ in nominal dollars
    1361 DEP_INC_PCT_LO Percentage of students who are financially independent and have family incomes between $0-30,000
    1361 DEP_INC_PCT_M1 Dependent students with family incomes between $30,001-$48,000 in nominal dollars
    1361 DEP_INC_PCT_M2 Dependent students with family incomes between $48,001-$75,000 in nominal dollars
    1357 DEP_RPY_1YR_N Number of students in the 1-year repayment rate of dependent students cohort
    1357 DEP_RPY_1YR_RT One-year repayment rate for dependent students
    1351 DEP_RPY_3YR_N Number of students in the 3-year repayment rate of dependent students cohort
    1351 DEP_RPY_3YR_RT Three-year repayment rate for dependent students
    1351 DEP_RPY_3YR_RT_SUPP 3-year repayment rate for dependent students, suppressed for n=30
    1348 DEP_RPY_5YR_N Number of students in the 5-year repayment rate of dependent students cohort
    1348 DEP_RPY_5YR_RT Five-year repayment rate for dependent students
    1178 DEP_RPY_7YR_N Number of students in the 7-year repayment rate of dependent students cohort
    1178 DEP_RPY_7YR_RT Seven-year repayment rate for dependent students
    1361 DEP_STAT_N Number of students in the disaggregation with valid dependency status
    1361 DEP_STAT_PCT_IND Percentage of students who are financially independent
    1361 DEP_UNKN_2YR_TRANS_YR2_RT Percent of dependent students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 DEP_UNKN_2YR_TRANS_YR3_RT Percent of dependent students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 DEP_UNKN_2YR_TRANS_YR4_RT Percent of dependent students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 DEP_UNKN_2YR_TRANS_YR6_RT Percent of dependent students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 DEP_UNKN_2YR_TRANS_YR8_RT Percent of dependent students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 DEP_UNKN_4YR_TRANS_YR2_RT Percent of dependent students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 DEP_UNKN_4YR_TRANS_YR3_RT Percent of dependent students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 DEP_UNKN_4YR_TRANS_YR4_RT Percent of dependent students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 DEP_UNKN_4YR_TRANS_YR6_RT Percent of dependent students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 DEP_UNKN_4YR_TRANS_YR8_RT Percent of dependent students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 DEP_UNKN_ORIG_YR2_RT Percent of dependent students with status unknown within 2 years at original institution
    1361 DEP_UNKN_ORIG_YR3_RT Percent of dependent students with status unknown within 3 years at original institution
    1354 DEP_UNKN_ORIG_YR4_RT Percent of dependent students with status unknown within 4 years at original institution
    1351 DEP_UNKN_ORIG_YR6_RT Percent of dependent students with status unknown within 6 years at original institution
    1348 DEP_UNKN_ORIG_YR8_RT Percent of dependent students with status unknown within 8 years at original institution
    1361 DEP_WDRAW_2YR_TRANS_YR2_RT Percent of dependent students who transferred to a 2-year institution and withdrew within 2 years 
    1361 DEP_WDRAW_2YR_TRANS_YR3_RT Percent of dependent students who transferred to a 2-year institution and withdrew within 3 years
    1354 DEP_WDRAW_2YR_TRANS_YR4_RT Percent of dependent students who transferred to a 2-year institution and withdrew within 4 years
    1351 DEP_WDRAW_2YR_TRANS_YR6_RT Percent of dependent students who transferred to a 2-year institution and withdrew within 6 years
    1348 DEP_WDRAW_2YR_TRANS_YR8_RT Percent of dependent students who transferred to a 2-year institution and withdrew within 8 years
    1361 DEP_WDRAW_4YR_TRANS_YR2_RT Percent of dependent students who transferred to a 4-year institution and withdrew within 2 years 
    1361 DEP_WDRAW_4YR_TRANS_YR3_RT Percent of dependent students who transferred to a 4-year institution and withdrew within 3 years
    1354 DEP_WDRAW_4YR_TRANS_YR4_RT Percent of dependent students who transferred to a 4-year institution and withdrew within 4 years
    1351 DEP_WDRAW_4YR_TRANS_YR6_RT Percent of dependent students who transferred to a 4-year institution and withdrew within 6 years
    1348 DEP_WDRAW_4YR_TRANS_YR8_RT Percent of dependent students who transferred to a 4-year institution and withdrew within 8 years
    1361 DEP_WDRAW_ORIG_YR2_RT Percent of dependent students withdrawn from original institution within 2 years 
    1361 DEP_WDRAW_ORIG_YR3_RT Percent of dependent students withdrawn from original institution within 3 years
    1354 DEP_WDRAW_ORIG_YR4_RT Percent of dependent students withdrawn from original institution within 4 years
    1351 DEP_WDRAW_ORIG_YR6_RT Percent of dependent students withdrawn from original institution within 6 years
    1348 DEP_WDRAW_ORIG_YR8_RT Percent of dependent students withdrawn from original institution within 8 years
    1361 DEP_YR2_N Number of dependent students in overall 2-year completion cohort
    1361 DEP_YR3_N Number of dependent students in overall 3-year completion cohort
    1354 DEP_YR4_N Number of dependent students in overall 4-year completion cohort
    1351 DEP_YR6_N Number of dependent students in overall 6-year completion cohort
    1348 DEP_YR8_N Number of dependent students in overall 8-year completion cohort
    1361 DISTANCEONLY Flag for distance-education-only education
    1361 ENRL_2YR_TRANS_YR2_RT Percent who transferred to a 2-year institution and were still enrolled within 2 years
    1361 ENRL_2YR_TRANS_YR3_RT Percent who transferred to a 2-year institution and were still enrolled within 3 years
    1354 ENRL_2YR_TRANS_YR4_RT Percent who transferred to a 2-year institution and were still enrolled within 4 years
    1351 ENRL_2YR_TRANS_YR6_RT Percent who transferred to a 2-year institution and were still enrolled within 6 years
    1348 ENRL_2YR_TRANS_YR8_RT Percent who transferred to a 2-year institution and were still enrolled within 8 years
    1361 ENRL_4YR_TRANS_YR2_RT Percent who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 ENRL_4YR_TRANS_YR3_RT Percent who transferred to a 4-year institution and were still enrolled within 3 years
    1354 ENRL_4YR_TRANS_YR4_RT Percent who transferred to a 4-year institution and were still enrolled within 4 years
    1351 ENRL_4YR_TRANS_YR6_RT Percent who transferred to a 4-year institution and were still enrolled within 6 years
    1348 ENRL_4YR_TRANS_YR8_RT Percent who transferred to a 4-year institution and were still enrolled within 8 years
    1361 ENRL_ORIG_YR2_RT Percent still enrolled at original institution within 2 years 
    1361 ENRL_ORIG_YR3_RT Percent still enrolled at original institution within 3 years
    1354 ENRL_ORIG_YR4_RT Percent still enrolled at original institution within 4 years
    1351 ENRL_ORIG_YR6_RT Percent still enrolled at original institution within 6 years
    1348 ENRL_ORIG_YR8_RT Percent still enrolled at original institution within 8 years
    1361 FEMALE_COMP_2YR_TRANS_YR2_RT Percent of female students who transferred to a 2-year institution and completed within 2 years
    1361 FEMALE_COMP_2YR_TRANS_YR3_RT Percent of female students who transferred to a 2-year institution and completed within 3 years
    1354 FEMALE_COMP_2YR_TRANS_YR4_RT Percent of female students who transferred to a 2-year institution and completed within 4 years
    1351 FEMALE_COMP_2YR_TRANS_YR6_RT Percent of female students who transferred to a 2-year institution and completed within 6 years
    1348 FEMALE_COMP_2YR_TRANS_YR8_RT Percent of female students who transferred to a 2-year institution and completed within 8 years
    1361 FEMALE_COMP_4YR_TRANS_YR2_RT Percent of female students who transferred to a 4-year institution and completed within 2 years
    1361 FEMALE_COMP_4YR_TRANS_YR3_RT Percent of female students who transferred to a 4-year institution and completed within 3 years
    1354 FEMALE_COMP_4YR_TRANS_YR4_RT Percent of female students who transferred to a 4-year institution and completed within 4 years
    1351 FEMALE_COMP_4YR_TRANS_YR6_RT Percent of female students who transferred to a 4-year institution and completed within 6 years
    1348 FEMALE_COMP_4YR_TRANS_YR8_RT Percent of female students who transferred to a 4-year institution and completed within 8 years
    1361 FEMALE_COMP_ORIG_YR2_RT Percent of female students who completed within 2 years at original institution
    1361 FEMALE_COMP_ORIG_YR3_RT Percent of female students who completed within 3 years at original institution
    1354 FEMALE_COMP_ORIG_YR4_RT Percent of female students who completed within 4 years at original institution
    1351 FEMALE_COMP_ORIG_YR6_RT Percent of female students who completed within 6 years at original institution
    1348 FEMALE_COMP_ORIG_YR8_RT Percent of female students who completed within 8 years at original institution
    1361 FEMALE_DEATH_YR2_RT Percent of female students who died within 2 years at original institution
    1361 FEMALE_DEATH_YR3_RT Percent of female students who died within 3 years at original institution
    1354 FEMALE_DEATH_YR4_RT Percent of female students who died within 4 years at original institution
    1351 FEMALE_DEATH_YR6_RT Percent of female students who died within 6 years at original institution
    1348 FEMALE_DEATH_YR8_RT Percent of female students who died within 8 years at original institution
    1358 FEMALE_DEBT_MDN The median debt for female students
    1358 FEMALE_DEBT_N The number of students in the median debt female students cohort
    1361 FEMALE_ENRL_2YR_TRANS_YR2_RT Percent of female students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 FEMALE_ENRL_2YR_TRANS_YR3_RT Percent of female students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 FEMALE_ENRL_2YR_TRANS_YR4_RT Percent of female students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 FEMALE_ENRL_2YR_TRANS_YR6_RT Percent of female students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 FEMALE_ENRL_2YR_TRANS_YR8_RT Percent of female students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 FEMALE_ENRL_4YR_TRANS_YR2_RT Percent of female students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 FEMALE_ENRL_4YR_TRANS_YR3_RT Percent of female students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 FEMALE_ENRL_4YR_TRANS_YR4_RT Percent of female students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 FEMALE_ENRL_4YR_TRANS_YR6_RT Percent of female students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 FEMALE_ENRL_4YR_TRANS_YR8_RT Percent of female students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 FEMALE_ENRL_ORIG_YR2_RT Percent of female students who were still enrolled at original institution within 2 years 
    1361 FEMALE_ENRL_ORIG_YR3_RT Percent of female students who were still enrolled at original institution within 3 years
    1354 FEMALE_ENRL_ORIG_YR4_RT Percent of female students who were still enrolled at original institution within 4 years
    1351 FEMALE_ENRL_ORIG_YR6_RT Percent of female students who were still enrolled at original institution within 6 years
    1348 FEMALE_ENRL_ORIG_YR8_RT Percent of female students who were still enrolled at original institution within 8 years
    1357 FEMALE_RPY_1YR_N Number of students in the 1-year repayment rate of female students cohort
    1357 FEMALE_RPY_1YR_RT One-year repayment rate for females
    1351 FEMALE_RPY_3YR_N Number of students in the 3-year repayment rate of female students cohort
    1351 FEMALE_RPY_3YR_RT Three-year repayment rate for females
    1351 FEMALE_RPY_3YR_RT_SUPP 3-year repayment rate for female students, suppressed for n=30
    1348 FEMALE_RPY_5YR_N Number of students in the 5-year repayment rate of female students cohort
    1348 FEMALE_RPY_5YR_RT Five-year repayment rate for females
    1178 FEMALE_RPY_7YR_N Number of students in the 7-year repayment rate of female students cohort
    1178 FEMALE_RPY_7YR_RT Seven-year repayment rate for females
    1361 FEMALE_UNKN_2YR_TRANS_YR2_RT Percent of female students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 FEMALE_UNKN_2YR_TRANS_YR3_RT Percent of female students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 FEMALE_UNKN_2YR_TRANS_YR4_RT Percent of female students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 FEMALE_UNKN_2YR_TRANS_YR6_RT Percent of female students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 FEMALE_UNKN_2YR_TRANS_YR8_RT Percent of female students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 FEMALE_UNKN_4YR_TRANS_YR2_RT Percent of female students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 FEMALE_UNKN_4YR_TRANS_YR3_RT Percent of female students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 FEMALE_UNKN_4YR_TRANS_YR4_RT Percent of female students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 FEMALE_UNKN_4YR_TRANS_YR6_RT Percent of female students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 FEMALE_UNKN_4YR_TRANS_YR8_RT Percent of female students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 FEMALE_UNKN_ORIG_YR2_RT Percent of female students with status unknown within 2 years at original institution
    1361 FEMALE_UNKN_ORIG_YR3_RT Percent of female students with status unknown within 3 years at original institution
    1354 FEMALE_UNKN_ORIG_YR4_RT Percent of female students with status unknown within 4 years at original institution
    1351 FEMALE_UNKN_ORIG_YR6_RT Percent of female students with status unknown within 6 years at original institution
    1348 FEMALE_UNKN_ORIG_YR8_RT Percent of female students with status unknown within 8 years at original institution
    1361 FEMALE_WDRAW_2YR_TRANS_YR2_RT Percent of female students who transferred to a 2-year institution and withdrew within 2 years 
    1361 FEMALE_WDRAW_2YR_TRANS_YR3_RT Percent of female students who transferred to a 2-year institution and withdrew within 3 years
    1354 FEMALE_WDRAW_2YR_TRANS_YR4_RT Percent of female students who transferred to a 2-year institution and withdrew within 4 years
    1351 FEMALE_WDRAW_2YR_TRANS_YR6_RT Percent of female students who transferred to a 2-year institution and withdrew within 6 years
    1348 FEMALE_WDRAW_2YR_TRANS_YR8_RT Percent of female students who transferred to a 2-year institution and withdrew within 8 years
    1361 FEMALE_WDRAW_4YR_TRANS_YR2_RT Percent of female students who transferred to a 4-year institution and withdrew within 2 years 
    1361 FEMALE_WDRAW_4YR_TRANS_YR3_RT Percent of female students who transferred to a 4-year institution and withdrew within 3 years
    1354 FEMALE_WDRAW_4YR_TRANS_YR4_RT Percent of female students who transferred to a 4-year institution and withdrew within 4 years
    1351 FEMALE_WDRAW_4YR_TRANS_YR6_RT Percent of female students who transferred to a 4-year institution and withdrew within 6 years
    1348 FEMALE_WDRAW_4YR_TRANS_YR8_RT Percent of female students who transferred to a 4-year institution and withdrew within 8 years
    1361 FEMALE_WDRAW_ORIG_YR2_RT Percent of female students withdrawn from original institution within 2 years 
    1361 FEMALE_WDRAW_ORIG_YR3_RT Percent of female students withdrawn from original institution within 3 years
    1354 FEMALE_WDRAW_ORIG_YR4_RT Percent of female students withdrawn from original institution within 4 years
    1351 FEMALE_WDRAW_ORIG_YR6_RT Percent of female students withdrawn from original institution within 6 years
    1348 FEMALE_WDRAW_ORIG_YR8_RT Percent of female students withdrawn from original institution within 8 years
    1361 FEMALE_YR2_N Number of female students in overall 2-year completion cohort
    1361 FEMALE_YR3_N Number of female students in overall 3-year completion cohort
    1354 FEMALE_YR4_N Number of female students in overall 4-year completion cohort
    1351 FEMALE_YR6_N Number of female students in overall 6-year completion cohort
    1348 FEMALE_YR8_N Number of female students in overall 8-year completion cohort
    1361 FIRSTGEN_COMP_2YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 2-year institution and completed within 2 years
    1361 FIRSTGEN_COMP_2YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 2-year institution and completed within 3 years
    1354 FIRSTGEN_COMP_2YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 2-year institution and completed within 4 years
    1351 FIRSTGEN_COMP_2YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 2-year institution and completed within 6 years
    1348 FIRSTGEN_COMP_2YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 2-year institution and completed within 8 years
    1361 FIRSTGEN_COMP_4YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 4-year institution and completed within 2 years
    1361 FIRSTGEN_COMP_4YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 4-year institution and completed within 3 years
    1354 FIRSTGEN_COMP_4YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 4-year institution and completed within 4 years
    1351 FIRSTGEN_COMP_4YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 4-year institution and completed within 6 years
    1348 FIRSTGEN_COMP_4YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 4-year institution and completed within 8 years
    1361 FIRSTGEN_COMP_ORIG_YR2_RT Percent of first-generation students who completed within 2 years at original institution
    1361 FIRSTGEN_COMP_ORIG_YR3_RT Percent of first-generation students who completed within 3 years at original institution
    1354 FIRSTGEN_COMP_ORIG_YR4_RT Percent of first-generation students who completed within 4 years at original institution
    1351 FIRSTGEN_COMP_ORIG_YR6_RT Percent of first-generation students who completed within 6 years at original institution
    1348 FIRSTGEN_COMP_ORIG_YR8_RT Percent of first-generation students who completed within 8 years at original institution
    1361 FIRSTGEN_DEATH_YR2_RT Percent of first-generation students who died within 2 years at original institution
    1361 FIRSTGEN_DEATH_YR3_RT Percent of first-generation students who died within 3 years at original institution
    1354 FIRSTGEN_DEATH_YR4_RT Percent of first-generation students who died within 4 years at original institution
    1351 FIRSTGEN_DEATH_YR6_RT Percent of first-generation students who died within 6 years at original institution
    1348 FIRSTGEN_DEATH_YR8_RT Percent of first-generation students who died within 8 years at original institution
    1358 FIRSTGEN_DEBT_MDN The median debt for first-generation students
    1358 FIRSTGEN_DEBT_N The number of students in the median debt first-generation students cohort
    1361 FIRSTGEN_ENRL_2YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 FIRSTGEN_ENRL_2YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 FIRSTGEN_ENRL_2YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 FIRSTGEN_ENRL_2YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 FIRSTGEN_ENRL_2YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 FIRSTGEN_ENRL_4YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 FIRSTGEN_ENRL_4YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 FIRSTGEN_ENRL_4YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 FIRSTGEN_ENRL_4YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 FIRSTGEN_ENRL_4YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 FIRSTGEN_ENRL_ORIG_YR2_RT Percent of first-generation students who were still enrolled at original institution within 2 years 
    1361 FIRSTGEN_ENRL_ORIG_YR3_RT Percent of first-generation students who were still enrolled at original institution within 3 years
    1354 FIRSTGEN_ENRL_ORIG_YR4_RT Percent of first-generation students who were still enrolled at original institution within 4 years
    1351 FIRSTGEN_ENRL_ORIG_YR6_RT Percent of first-generation students who were still enrolled at original institution within 6 years
    1348 FIRSTGEN_ENRL_ORIG_YR8_RT Percent of first-generation students who were still enrolled at original institution within 8 years
    1357 FIRSTGEN_RPY_1YR_N Number of students in the 1-year repayment rate of first-generation students cohort
    1357 FIRSTGEN_RPY_1YR_RT One-year repayment rate for first-generation students
    1351 FIRSTGEN_RPY_3YR_N Number of students in the 3-year repayment rate of first-generation students cohort
    1351 FIRSTGEN_RPY_3YR_RT Three-year repayment rate for first-generation students
    1351 FIRSTGEN_RPY_3YR_RT_SUPP 3-year repayment rate for first-generation students, suppressed for n=30
    1348 FIRSTGEN_RPY_5YR_N Number of students in the 5-year repayment rate of first-generation students cohort
    1348 FIRSTGEN_RPY_5YR_RT Five-year repayment rate for first-generation students
    1178 FIRSTGEN_RPY_7YR_N Number of students in the 7-year repayment rate of first-generation students cohort
    1178 FIRSTGEN_RPY_7YR_RT Seven-year repayment rate for first-generation students
    1361 FIRSTGEN_UNKN_2YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 FIRSTGEN_UNKN_2YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 FIRSTGEN_UNKN_2YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 FIRSTGEN_UNKN_2YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 FIRSTGEN_UNKN_2YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 FIRSTGEN_UNKN_4YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 FIRSTGEN_UNKN_4YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 FIRSTGEN_UNKN_4YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 FIRSTGEN_UNKN_4YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 FIRSTGEN_UNKN_4YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 FIRSTGEN_UNKN_ORIG_YR2_RT Percent of first-generation students with status unknown within 2 years at original institution
    1361 FIRSTGEN_UNKN_ORIG_YR3_RT Percent of first-generation students with status unknown within 3 years at original institution
    1354 FIRSTGEN_UNKN_ORIG_YR4_RT Percent of first-generation students with status unknown within 4 years at original institution
    1351 FIRSTGEN_UNKN_ORIG_YR6_RT Percent of first-generation students with status unknown within 6 years at original institution
    1348 FIRSTGEN_UNKN_ORIG_YR8_RT Percent of first-generation students with status unknown within 8 years at original institution
    1361 FIRSTGEN_WDRAW_2YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 2-year institution and withdrew within 2 years 
    1361 FIRSTGEN_WDRAW_2YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 2-year institution and withdrew within 3 years
    1354 FIRSTGEN_WDRAW_2YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 2-year institution and withdrew within 4 years
    1351 FIRSTGEN_WDRAW_2YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 2-year institution and withdrew within 6 years
    1348 FIRSTGEN_WDRAW_2YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 2-year institution and withdrew within 8 years
    1361 FIRSTGEN_WDRAW_4YR_TRANS_YR2_RT Percent of first-generation students who transferred to a 4-year institution and withdrew within 2 years 
    1361 FIRSTGEN_WDRAW_4YR_TRANS_YR3_RT Percent of first-generation students who transferred to a 4-year institution and withdrew within 3 years
    1354 FIRSTGEN_WDRAW_4YR_TRANS_YR4_RT Percent of first-generation students who transferred to a 4-year institution and withdrew within 4 years
    1351 FIRSTGEN_WDRAW_4YR_TRANS_YR6_RT Percent of first-generation students who transferred to a 4-year institution and withdrew within 6 years
    1348 FIRSTGEN_WDRAW_4YR_TRANS_YR8_RT Percent of first-generation students who transferred to a 4-year institution and withdrew within 8 years
    1361 FIRSTGEN_WDRAW_ORIG_YR2_RT Percent of first-generation students withdrawn from original institution within 2 years 
    1361 FIRSTGEN_WDRAW_ORIG_YR3_RT Percent of first-generation students withdrawn from original institution within 3 years
    1354 FIRSTGEN_WDRAW_ORIG_YR4_RT Percent of first-generation students withdrawn from original institution within 4 years
    1351 FIRSTGEN_WDRAW_ORIG_YR6_RT Percent of first-generation students withdrawn from original institution within 6 years
    1348 FIRSTGEN_WDRAW_ORIG_YR8_RT Percent of first-generation students withdrawn from original institution within 8 years
    1361 FIRSTGEN_YR2_N Number of first-generation students in overall 2-year completion cohort
    1361 FIRSTGEN_YR3_N Number of first-generation students in overall 3-year completion cohort
    1354 FIRSTGEN_YR4_N Number of first-generation students in overall 4-year completion cohort
    1351 FIRSTGEN_YR6_N Number of first-generation students in overall 6-year completion cohort
    1348 FIRSTGEN_YR8_N Number of first-generation students in overall 8-year completion cohort
    1358 GRAD_DEBT_MDN The median debt for students who have completed
    1358 GRAD_DEBT_MDN10YR Median loan debt of completers in monthly payments (10-year amortization plan)
    1358 GRAD_DEBT_MDN10YR_SUPP Median debt of completers expressed in 10-year monthly payments, suppressed for n=30
    1358 GRAD_DEBT_MDN_SUPP Median debt of completers, suppressed for n=30
    1358 GRAD_DEBT_N The number of students in the median debt completers cohort
    1361 HBCU Flag for Historically Black College and University
    1361 HIGHDEG Highest degree awarded
    0        Non-degree-granting
    1        Certificate degree
    2        Associate degree
    3        Bachelor's degree
    4        Graduate degree
    1361 HI_INC_COMP_2YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 2 years
    1361 HI_INC_COMP_2YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 3 years
    1354 HI_INC_COMP_2YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 4 years
    1351 HI_INC_COMP_2YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 6 years
    1348 HI_INC_COMP_2YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 8 years
    1361 HI_INC_COMP_4YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 2 years
    1361 HI_INC_COMP_4YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 3 years
    1354 HI_INC_COMP_4YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 4 years
    1351 HI_INC_COMP_4YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 6 years
    1348 HI_INC_COMP_4YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 8 years
    1361 HI_INC_COMP_ORIG_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who completed within 2 years at original institution
    1361 HI_INC_COMP_ORIG_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who completed within 3 years at original institution
    1354 HI_INC_COMP_ORIG_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who completed within 4 years at original institution
    1351 HI_INC_COMP_ORIG_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who completed within 6 years at original institution
    1348 HI_INC_COMP_ORIG_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who completed within 8 years at original institution
    1361 HI_INC_DEATH_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who died within 2 years at original institution
    1361 HI_INC_DEATH_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who died within 3 years at original institution
    1354 HI_INC_DEATH_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who died within 4 years at original institution
    1351 HI_INC_DEATH_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who died within 6 years at original institution
    1348 HI_INC_DEATH_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who died within 8 years at original institution
    1358 HI_INC_DEBT_MDN The median debt for students with family income $75,001+
    1358 HI_INC_DEBT_N The number of students in the median debt high-income (above $75,000 in nominal family income) students cohort
    1361 HI_INC_ENRL_2YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 HI_INC_ENRL_2YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 HI_INC_ENRL_2YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 HI_INC_ENRL_2YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 HI_INC_ENRL_2YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 HI_INC_ENRL_4YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 HI_INC_ENRL_4YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 HI_INC_ENRL_4YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 HI_INC_ENRL_4YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 HI_INC_ENRL_4YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 HI_INC_ENRL_ORIG_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who were still enrolled at original institution within 2 years 
    1361 HI_INC_ENRL_ORIG_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who were still enrolled at original institution within 3 years
    1354 HI_INC_ENRL_ORIG_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who were still enrolled at original institution within 4 years
    1351 HI_INC_ENRL_ORIG_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who were still enrolled at original institution within 6 years
    1348 HI_INC_ENRL_ORIG_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who were still enrolled at original institution within 8 years
    1357 HI_INC_RPY_1YR_N Number of students in the 1-year repayment rate of high-income (above $75,000 in nominal family income) students cohort
    1357 HI_INC_RPY_1YR_RT One-year repayment rate by family income ($75,000+)
    1351 HI_INC_RPY_3YR_N Number of students in the 3-year repayment rate of high-income (above $75,000 in nominal family income) students cohort
    1351 HI_INC_RPY_3YR_RT Three-year repayment rate by family income ($75,000+)
    1351 HI_INC_RPY_3YR_RT_SUPP 3-year repayment rate for high-income (above $75,000 in nominal family income) students, suppressed for n=30
    1348 HI_INC_RPY_5YR_N Number of students in the 5-year repayment rate of high-income (above $75,000 in nominal family income) students cohort
    1348 HI_INC_RPY_5YR_RT Five-year repayment rate by family income ($75,000+)
    1178 HI_INC_RPY_7YR_N Number of students in the 7-year repayment rate of high-income (above $75,000 in nominal family income) students cohort
    1178 HI_INC_RPY_7YR_RT Seven-year repayment rate by family income ($75,000+)
    1361 HI_INC_UNKN_2YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 HI_INC_UNKN_2YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 HI_INC_UNKN_2YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 HI_INC_UNKN_2YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 HI_INC_UNKN_2YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 HI_INC_UNKN_4YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 HI_INC_UNKN_4YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 HI_INC_UNKN_4YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 HI_INC_UNKN_4YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 HI_INC_UNKN_4YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 HI_INC_UNKN_ORIG_YR2_RT Percent of high-income (above $75,000 in nominal family income) students with status unknown within 2 years at original institution
    1361 HI_INC_UNKN_ORIG_YR3_RT Percent of high-income (above $75,000 in nominal family income) students with status unknown within 3 years at original institution
    1354 HI_INC_UNKN_ORIG_YR4_RT Percent of high-income (above $75,000 in nominal family income) students with status unknown within 4 years at original institution
    1351 HI_INC_UNKN_ORIG_YR6_RT Percent of high-income (above $75,000 in nominal family income) students with status unknown within 6 years at original institution
    1348 HI_INC_UNKN_ORIG_YR8_RT Percent of high-income (above $75,000 in nominal family income) students with status unknown within 8 years at original institution
    1361 HI_INC_WDRAW_2YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 2 years 
    1361 HI_INC_WDRAW_2YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 3 years
    1354 HI_INC_WDRAW_2YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 4 years
    1351 HI_INC_WDRAW_2YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 6 years
    1348 HI_INC_WDRAW_2YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 8 years
    1361 HI_INC_WDRAW_4YR_TRANS_YR2_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 2 years 
    1361 HI_INC_WDRAW_4YR_TRANS_YR3_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 3 years
    1354 HI_INC_WDRAW_4YR_TRANS_YR4_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 4 years
    1351 HI_INC_WDRAW_4YR_TRANS_YR6_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 6 years
    1348 HI_INC_WDRAW_4YR_TRANS_YR8_RT Percent of high-income (above $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 8 years
    1361 HI_INC_WDRAW_ORIG_YR2_RT Percent of high-income (above $75,000 in nominal family income) students withdrawn from original institution within 2 years 
    1361 HI_INC_WDRAW_ORIG_YR3_RT Percent of high-income (above $75,000 in nominal family income) students withdrawn from original institution within 3 years
    1354 HI_INC_WDRAW_ORIG_YR4_RT Percent of high-income (above $75,000 in nominal family income) students withdrawn from original institution within 4 years
    1351 HI_INC_WDRAW_ORIG_YR6_RT Percent of high-income (above $75,000 in nominal family income) students withdrawn from original institution within 6 years
    1348 HI_INC_WDRAW_ORIG_YR8_RT Percent of high-income (above $75,000 in nominal family income) students withdrawn from original institution within 8 years
    1361 HI_INC_YR2_N Number of high-income (above $75,000 in nominal family income) students in overall 2-year completion cohort
    1361 HI_INC_YR3_N Number of high-income (above $75,000 in nominal family income) students in overall 3-year completion cohort
    1354 HI_INC_YR4_N Number of high-income (above $75,000 in nominal family income) students in overall 4-year completion cohort
    1351 HI_INC_YR6_N Number of high-income (above $75,000 in nominal family income) students in overall 6-year completion cohort
    1348 HI_INC_YR8_N Number of high-income (above $75,000 in nominal family income) students in overall 8-year completion cohort
    1361 HSI Flag for Hispanic-serving institution
    1361 INC_N Number of students in the family income cohort
    1361 INC_PCT_H1 Aided students with family incomes between $75,001-$110,000 in nominal dollars
    1361 INC_PCT_H2 Aided students with family incomes between $110,001+ in nominal dollars
    1361 INC_PCT_LO Percentage of aided students whose family income is between $0-$30,000
    1361 INC_PCT_M1 Aided students with family incomes between $30,001-$48,000 in nominal dollars
    1361 INC_PCT_M2 Aided students with family incomes between $48,001-$75,000 in nominal dollars
    1361 IND_COMP_2YR_TRANS_YR2_RT Percent of independent students who transferred to a 2-year institution and completed within 2 years
    1361 IND_COMP_2YR_TRANS_YR3_RT Percent of independent students who transferred to a 2-year institution and completed within 3 years
    1354 IND_COMP_2YR_TRANS_YR4_RT Percent of independent students who transferred to a 2-year institution and completed within 4 years
    1351 IND_COMP_2YR_TRANS_YR6_RT Percent of independent students who transferred to a 2-year institution and completed within 6 years
    1348 IND_COMP_2YR_TRANS_YR8_RT Percent of independent students who transferred to a 2-year institution and completed within 8 years
    1361 IND_COMP_4YR_TRANS_YR2_RT Percent of independent students who transferred to a 4-year institution and completed within 2 years
    1361 IND_COMP_4YR_TRANS_YR3_RT Percent of independent students who transferred to a 4-year institution and completed within 3 years
    1354 IND_COMP_4YR_TRANS_YR4_RT Percent of independent students who transferred to a 4-year institution and completed within 4 years
    1351 IND_COMP_4YR_TRANS_YR6_RT Percent of independent students who transferred to a 4-year institution and completed within 6 years
    1348 IND_COMP_4YR_TRANS_YR8_RT Percent of independent students who transferred to a 4-year institution and completed within 8 years
    1361 IND_COMP_ORIG_YR2_RT Percent of independent students who completed within 2 years at original institution
    1361 IND_COMP_ORIG_YR3_RT Percent of independent students who completed within 3 years at original institution
    1354 IND_COMP_ORIG_YR4_RT Percent of independent students who completed within 4 years at original institution
    1351 IND_COMP_ORIG_YR6_RT Percent of independent students who completed within 6 years at original institution
    1348 IND_COMP_ORIG_YR8_RT Percent of independent students who completed within 8 years at original institution
    1361 IND_DEATH_YR2_RT Percent of independent students who died within 2 years at original institution
    1361 IND_DEATH_YR3_RT Percent of independent students who died within 3 years at original institution
    1354 IND_DEATH_YR4_RT Percent of independent students who died within 4 years at original institution
    1351 IND_DEATH_YR6_RT Percent of independent students who died within 6 years at original institution
    1348 IND_DEATH_YR8_RT Percent of independent students who died within 8 years at original institution
    1358 IND_DEBT_MDN The median debt for independent students
    1358 IND_DEBT_N The number of students in the median debt independent students cohort
    1361 IND_ENRL_2YR_TRANS_YR2_RT Percent of independent students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 IND_ENRL_2YR_TRANS_YR3_RT Percent of independent students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 IND_ENRL_2YR_TRANS_YR4_RT Percent of independent students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 IND_ENRL_2YR_TRANS_YR6_RT Percent of independent students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 IND_ENRL_2YR_TRANS_YR8_RT Percent of independent students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 IND_ENRL_4YR_TRANS_YR2_RT Percent of independent students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 IND_ENRL_4YR_TRANS_YR3_RT Percent of independent students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 IND_ENRL_4YR_TRANS_YR4_RT Percent of independent students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 IND_ENRL_4YR_TRANS_YR6_RT Percent of independent students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 IND_ENRL_4YR_TRANS_YR8_RT Percent of independent students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 IND_ENRL_ORIG_YR2_RT Percent of independent students who were still enrolled at original institution within 2 years 
    1361 IND_ENRL_ORIG_YR3_RT Percent of independent students who were still enrolled at original institution within 3 years
    1354 IND_ENRL_ORIG_YR4_RT Percent of independent students who were still enrolled at original institution within 4 years
    1351 IND_ENRL_ORIG_YR6_RT Percent of independent students who were still enrolled at original institution within 6 years
    1348 IND_ENRL_ORIG_YR8_RT Percent of independent students who were still enrolled at original institution within 8 years
    1361 IND_INC_AVG Average family income of independent students in real 2014 dollars. 
    1361 IND_INC_N Number of students in the family income independent students cohort
    1361 IND_INC_PCT_H1 Independent students with family incomes between $75,001-$110,000 in nominal dollars
    1361 IND_INC_PCT_H2 Independent students with family incomes between $110,001+ in nominal dollars
    1361 IND_INC_PCT_LO Percentage of students who are financially dependent and have family incomes between $0-30,000
    1361 IND_INC_PCT_M1 Independent students with family incomes between $30,001-$48,000 in nominal dollars
    1361 IND_INC_PCT_M2 Independent students with family incomes between $48,001-$75,000 in nominal dollars
    1357 IND_RPY_1YR_N Number of students in the 1-year repayment rate of independent students cohort
    1357 IND_RPY_1YR_RT One-year repayment rate for independent students
    1351 IND_RPY_3YR_N Number of students in the 3-year repayment rate of independent students cohort
    1351 IND_RPY_3YR_RT Three-year repayment rate for independent students
    1351 IND_RPY_3YR_RT_SUPP 3-year repayment rate for independent students, suppressed for n=30
    1348 IND_RPY_5YR_N Number of students in the 5-year repayment rate of independent students cohort
    1348 IND_RPY_5YR_RT Five-year repayment rate for independent students
    1178 IND_RPY_7YR_N Number of students in the 7-year repayment rate of independent students cohort
    1178 IND_RPY_7YR_RT Seven-year repayment rate for independent students
    1361 IND_UNKN_2YR_TRANS_YR2_RT Percent of independent students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 IND_UNKN_2YR_TRANS_YR3_RT Percent of independent students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 IND_UNKN_2YR_TRANS_YR4_RT Percent of independent students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 IND_UNKN_2YR_TRANS_YR6_RT Percent of independent students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 IND_UNKN_2YR_TRANS_YR8_RT Percent of independent students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 IND_UNKN_4YR_TRANS_YR2_RT Percent of independent students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 IND_UNKN_4YR_TRANS_YR3_RT Percent of independent students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 IND_UNKN_4YR_TRANS_YR4_RT Percent of independent students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 IND_UNKN_4YR_TRANS_YR6_RT Percent of independent students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 IND_UNKN_4YR_TRANS_YR8_RT Percent of independent students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 IND_UNKN_ORIG_YR2_RT Percent of independent students with status unknown within 2 years at original institution
    1361 IND_UNKN_ORIG_YR3_RT Percent of independent students with status unknown within 3 years at original institution
    1354 IND_UNKN_ORIG_YR4_RT Percent of independent students with status unknown within 4 years at original institution
    1351 IND_UNKN_ORIG_YR6_RT Percent of independent students with status unknown within 6 years at original institution
    1348 IND_UNKN_ORIG_YR8_RT Percent of independent students with status unknown within 8 years at original institution
    1361 IND_WDRAW_2YR_TRANS_YR2_RT Percent of independent students who transferred to a 2-year institution and withdrew within 2 years 
    1361 IND_WDRAW_2YR_TRANS_YR3_RT Percent of independent students who transferred to a 2-year institution and withdrew within 3 years
    1354 IND_WDRAW_2YR_TRANS_YR4_RT Percent of independent students who transferred to a 2-year institution and withdrew within 4 years
    1351 IND_WDRAW_2YR_TRANS_YR6_RT Percent of independent students who transferred to a 2-year institution and withdrew within 6 years
    1348 IND_WDRAW_2YR_TRANS_YR8_RT Percent of independent students who transferred to a 2-year institution and withdrew within 8 years
    1361 IND_WDRAW_4YR_TRANS_YR2_RT Percent of independent students who transferred to a 4-year institution and withdrew within 2 years 
    1361 IND_WDRAW_4YR_TRANS_YR3_RT Percent of independent students who transferred to a 4-year institution and withdrew within 3 years
    1354 IND_WDRAW_4YR_TRANS_YR4_RT Percent of independent students who transferred to a 4-year institution and withdrew within 4 years
    1351 IND_WDRAW_4YR_TRANS_YR6_RT Percent of independent students who transferred to a 4-year institution and withdrew within 6 years
    1348 IND_WDRAW_4YR_TRANS_YR8_RT Percent of independent students who transferred to a 4-year institution and withdrew within 8 years
    1361 IND_WDRAW_ORIG_YR2_RT Percent of independent students withdrawn from original institution within 2 years 
    1361 IND_WDRAW_ORIG_YR3_RT Percent of independent students withdrawn from original institution within 3 years
    1354 IND_WDRAW_ORIG_YR4_RT Percent of independent students withdrawn from original institution within 4 years
    1351 IND_WDRAW_ORIG_YR6_RT Percent of independent students withdrawn from original institution within 6 years
    1348 IND_WDRAW_ORIG_YR8_RT Percent of independent students withdrawn from original institution within 8 years
    1361 IND_YR2_N Number of independent students in overall 2-year completion cohort
    1361 IND_YR3_N Number of independent students in overall 3-year completion cohort
    1354 IND_YR4_N Number of independent students in overall 4-year completion cohort
    1351 IND_YR6_N Number of independent students in overall 6-year completion cohort
    1348 IND_YR8_N Number of independent students in overall 8-year completion cohort
    1341 INEXPFTE Instructional expenditures per full-time equivalent student
    1361 INSTNM Institution name
    1359 LATITUDE Latitude
    1361 LOAN_COMP_2YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and completed within 2 years
    1361 LOAN_COMP_2YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and completed within 3 years
    1354 LOAN_COMP_2YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and completed within 4 years
    1351 LOAN_COMP_2YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and completed within 6 years
    1348 LOAN_COMP_2YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and completed within 8 years
    1361 LOAN_COMP_4YR_TRANS_YR2_RT Percent of students who received a federel loan at the institution and who transferred to a 4-year institution and completed within 2 years
    1361 LOAN_COMP_4YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and completed within 3 years
    1354 LOAN_COMP_4YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and completed within 4 years
    1351 LOAN_COMP_4YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and completed within 6 years
    1348 LOAN_COMP_4YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and completed within 8 years
    1361 LOAN_COMP_ORIG_YR2_RT Percent of students who received a federal loan at the institution and who completed in 2 years at original institution
    1361 LOAN_COMP_ORIG_YR3_RT Percent of students who received a federal loan at the institution and who completed in 3 years at original institution
    1354 LOAN_COMP_ORIG_YR4_RT Percent of students who received a federal loan at the institution and who completed in 4 years at original institution
    1351 LOAN_COMP_ORIG_YR6_RT Percent of students who received a federal loan at the institution and who completed in 6 years at original institution
    1348 LOAN_COMP_ORIG_YR8_RT Percent of students who received a federal loan at the institution and who completed in 8 years at original institution
    1361 LOAN_DEATH_YR2_RT Percent of students who received a federal loan at the institution and who died within 2 years at original institution
    1361 LOAN_DEATH_YR3_RT Percent of students who received a federal loan at the institution and who died within 3 years at original institution
    1354 LOAN_DEATH_YR4_RT Percent of students who received a federal loan at the institution and who died within 4 years at original institution
    1351 LOAN_DEATH_YR6_RT Percent of students who received a federal loan at the institution and who died within 6 years at original institution
    1348 LOAN_DEATH_YR8_RT Percent of students who received a federal loan at the institution and who died within 8 years at original institution
    1361 LOAN_ENRL_2YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 2 years
    1361 LOAN_ENRL_2YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 3 years
    1354 LOAN_ENRL_2YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 4 years
    1351 LOAN_ENRL_2YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 6 years
    1348 LOAN_ENRL_2YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 8 years
    1361 LOAN_ENRL_4YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 LOAN_ENRL_4YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 3 years
    1354 LOAN_ENRL_4YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 4 years
    1351 LOAN_ENRL_4YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 6 years
    1348 LOAN_ENRL_4YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 8 years
    1361 LOAN_ENRL_ORIG_YR2_RT Percent of students who received a federal loan at the institution and who were still enrolled at original institution within 2 years 
    1361 LOAN_ENRL_ORIG_YR3_RT Percent of students who received a federal loan at the institution and who were still enrolled at original institution within 3 years
    1354 LOAN_ENRL_ORIG_YR4_RT Percent of students who received a federal loan at the institution and who were still enrolled at original institution within 4 years
    1351 LOAN_ENRL_ORIG_YR6_RT Percent of students who received a federal loan at the institution and who were still enrolled at original institution within 6 years
    1348 LOAN_ENRL_ORIG_YR8_RT Percent of students who received a federal loan at the institution and who were still enrolled at original institution within 8 years
    1361 LOAN_UNKN_2YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 LOAN_UNKN_2YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 LOAN_UNKN_2YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 LOAN_UNKN_2YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 LOAN_UNKN_2YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 LOAN_UNKN_4YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 LOAN_UNKN_4YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 LOAN_UNKN_4YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 LOAN_UNKN_4YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 LOAN_UNKN_4YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 LOAN_UNKN_ORIG_YR2_RT Percent of students who received a federal loan at the institution and with status unknown within 2 years at original institution
    1361 LOAN_UNKN_ORIG_YR3_RT Percent of students who received a federal loan at the institution and with status unknown within 3 years at original institution
    1354 LOAN_UNKN_ORIG_YR4_RT Percent of students who received a federal loan at the institution and with status unknown within 4 years at original institution
    1351 LOAN_UNKN_ORIG_YR6_RT Percent of students who received a federal loan at the institution and with status unknown within 6 years at original institution
    1348 LOAN_UNKN_ORIG_YR8_RT Percent of students who received a federal loan at the institution and with status unknown within 8 years at original institution
    1361 LOAN_WDRAW_2YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 2 years 
    1361 LOAN_WDRAW_2YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 3 years
    1354 LOAN_WDRAW_2YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 4 years
    1351 LOAN_WDRAW_2YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 6 years
    1348 LOAN_WDRAW_2YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 8 years
    1361 LOAN_WDRAW_4YR_TRANS_YR2_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 2 years 
    1361 LOAN_WDRAW_4YR_TRANS_YR3_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 3 years
    1354 LOAN_WDRAW_4YR_TRANS_YR4_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 4 years
    1351 LOAN_WDRAW_4YR_TRANS_YR6_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 6 years
    1348 LOAN_WDRAW_4YR_TRANS_YR8_RT Percent of students who received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 8 years
    1361 LOAN_WDRAW_ORIG_YR2_RT Percent of students who received a federal loan at the institution and withdrew from original institution within 2 years 
    1361 LOAN_WDRAW_ORIG_YR3_RT Percent of students who received a federal loan at the institution and withdrew from original institution within 3 years
    1354 LOAN_WDRAW_ORIG_YR4_RT Percent of students who received a federal loan at the institution and withdrew from original institution within 4 years
    1351 LOAN_WDRAW_ORIG_YR6_RT Percent of students who received a federal loan at the institution and withdrew from original institution within 6 years
    1348 LOAN_WDRAW_ORIG_YR8_RT Percent of students who received a federal loan at the institution and withdrew from original institution within 8 years
    1361 LOAN_YR2_N Number of loan students in overall 2-year completion cohort
    1361 LOAN_YR3_N Number of loan students in overall 3-year completion cohort
    1354 LOAN_YR4_N Number of loan students in overall 4-year completion cohort
    1351 LOAN_YR6_N Number of loan students in overall 6-year completion cohort
    1348 LOAN_YR8_N Number of loan students in overall 8-year completion cohort
    1360 LOCALE Locale of institution
    1359 LONGITUDE Longitude
    1361 LO_INC_COMP_2YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and completed within 2 years
    1361 LO_INC_COMP_2YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and completed within 3 years
    1354 LO_INC_COMP_2YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and completed within 4 years
    1351 LO_INC_COMP_2YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and completed within 6 years
    1348 LO_INC_COMP_2YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and completed within 8 years
    1361 LO_INC_COMP_4YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and completed within 2 years
    1361 LO_INC_COMP_4YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and completed within 3 years
    1354 LO_INC_COMP_4YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and completed within 4 years
    1351 LO_INC_COMP_4YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and completed within 6 years
    1348 LO_INC_COMP_4YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and completed within 8 years
    1361 LO_INC_COMP_ORIG_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who completed within 2 years at original institution
    1361 LO_INC_COMP_ORIG_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who completed within 3 years at original institution
    1354 LO_INC_COMP_ORIG_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who completed within 4 years at original institution
    1351 LO_INC_COMP_ORIG_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who completed within 6 years at original institution
    1348 LO_INC_COMP_ORIG_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who completed within 8 years at original institution
    1361 LO_INC_DEATH_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who died within 2 years at original institution
    1361 LO_INC_DEATH_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who died within 3 years at original institution
    1354 LO_INC_DEATH_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who died within 4 years at original institution
    1351 LO_INC_DEATH_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who died within 6 years at original institution
    1348 LO_INC_DEATH_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who died within 8 years at original institution
    1358 LO_INC_DEBT_MDN The median debt for students with family income between $0-$30,000
    1358 LO_INC_DEBT_N The number of students in the median debt low-income (less than $30,000 in nominal family income) students cohort
    1361 LO_INC_ENRL_2YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 LO_INC_ENRL_2YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 LO_INC_ENRL_2YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 LO_INC_ENRL_2YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 LO_INC_ENRL_2YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 LO_INC_ENRL_4YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 LO_INC_ENRL_4YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 LO_INC_ENRL_4YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 LO_INC_ENRL_4YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 LO_INC_ENRL_4YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 LO_INC_ENRL_ORIG_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who were still enrolled at original institution within 2 years 
    1361 LO_INC_ENRL_ORIG_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who were still enrolled at original institution within 3 years
    1354 LO_INC_ENRL_ORIG_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who were still enrolled at original institution within 4 years
    1351 LO_INC_ENRL_ORIG_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who were still enrolled at original institution within 6 years
    1348 LO_INC_ENRL_ORIG_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who were still enrolled at original institution within 8 years
    1357 LO_INC_RPY_1YR_N Number of students in the 1-year repayment rate of low-income (less than $30,000 in nominal family income) students cohort
    1357 LO_INC_RPY_1YR_RT One-year repayment rate by family income ($0-30,000)
    1351 LO_INC_RPY_3YR_N Number of students in the 3-year repayment rate of low-income (less than $30,000 in nominal family income) students cohort
    1351 LO_INC_RPY_3YR_RT Three-year repayment rate by family income ($0-30,000)
    1351 LO_INC_RPY_3YR_RT_SUPP 3-year repayment rate for low-income (less than $30,000 in nominal family income) students, suppressed for n=30
    1348 LO_INC_RPY_5YR_N Number of students in the 5-year repayment rate of low-income (less than $30,000 in nominal family income) students cohort
    1348 LO_INC_RPY_5YR_RT Five-year repayment rate by family income ($0-30,000)
    1178 LO_INC_RPY_7YR_N Number of students in the 7-year repayment rate of low-income (less than $30,000 in nominal family income) students cohort
    1178 LO_INC_RPY_7YR_RT Seven-year repayment rate by family income ($0-30,000)
    1361 LO_INC_UNKN_2YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 LO_INC_UNKN_2YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 LO_INC_UNKN_2YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 LO_INC_UNKN_2YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 LO_INC_UNKN_2YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 LO_INC_UNKN_4YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 LO_INC_UNKN_4YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 LO_INC_UNKN_4YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 LO_INC_UNKN_4YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 LO_INC_UNKN_4YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 LO_INC_UNKN_ORIG_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students with status unknown within 2 years at original institution
    1361 LO_INC_UNKN_ORIG_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students with status unknown within 3 years at original institution
    1354 LO_INC_UNKN_ORIG_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students with status unknown within 4 years at original institution
    1351 LO_INC_UNKN_ORIG_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students with status unknown within 6 years at original institution
    1348 LO_INC_UNKN_ORIG_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students with status unknown within 8 years at original institution
    1361 LO_INC_WDRAW_2YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 2 years 
    1361 LO_INC_WDRAW_2YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 3 years
    1354 LO_INC_WDRAW_2YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 4 years
    1351 LO_INC_WDRAW_2YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 6 years
    1348 LO_INC_WDRAW_2YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 8 years
    1361 LO_INC_WDRAW_4YR_TRANS_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 2 years 
    1361 LO_INC_WDRAW_4YR_TRANS_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 3 years
    1354 LO_INC_WDRAW_4YR_TRANS_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 4 years
    1351 LO_INC_WDRAW_4YR_TRANS_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 6 years
    1348 LO_INC_WDRAW_4YR_TRANS_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 8 years
    1361 LO_INC_WDRAW_ORIG_YR2_RT Percent of low-income (less than $30,000 in nominal family income) students withdrawn from original institution within 2 years 
    1361 LO_INC_WDRAW_ORIG_YR3_RT Percent of low-income (less than $30,000 in nominal family income) students withdrawn from original institution within 3 years
    1354 LO_INC_WDRAW_ORIG_YR4_RT Percent of low-income (less than $30,000 in nominal family income) students withdrawn from original institution within 4 years
    1351 LO_INC_WDRAW_ORIG_YR6_RT Percent of low-income (less than $30,000 in nominal family income) students withdrawn from original institution within 6 years
    1348 LO_INC_WDRAW_ORIG_YR8_RT Percent of low-income (less than $30,000 in nominal family income) students withdrawn from original institution within 8 years
    1361 LO_INC_YR2_N Number of low-income (less than $30,000 in nominal family income) students in overall 2-year completion cohort
    1361 LO_INC_YR3_N Number of low-income (less than $30,000 in nominal family income) students in overall 3-year completion cohort
    1354 LO_INC_YR4_N Number of low-income (less than $30,000 in nominal family income) students in overall 4-year completion cohort
    1351 LO_INC_YR6_N Number of low-income (less than $30,000 in nominal family income) students in overall 6-year completion cohort
    1348 LO_INC_YR8_N Number of low-income (less than $30,000 in nominal family income) students in overall 8-year completion cohort
    1361 MALE_COMP_2YR_TRANS_YR2_RT Percent of male students who transferred to a 2-year institution and completed within 2 years
    1361 MALE_COMP_2YR_TRANS_YR3_RT Percent of male students who transferred to a 2-year institution and completed within 3 years
    1354 MALE_COMP_2YR_TRANS_YR4_RT Percent of male students who transferred to a 2-year institution and completed within 4 years
    1351 MALE_COMP_2YR_TRANS_YR6_RT Percent of male students who transferred to a 2-year institution and completed within 6 years
    1348 MALE_COMP_2YR_TRANS_YR8_RT Percent of male students who transferred to a 2-year institution and completed within 8 years
    1361 MALE_COMP_4YR_TRANS_YR2_RT Percent of male students who transferred to a 4-year institution and completed within 2 years
    1361 MALE_COMP_4YR_TRANS_YR3_RT Percent of male students who transferred to a 4-year institution and completed within 3 years
    1354 MALE_COMP_4YR_TRANS_YR4_RT Percent of male students who transferred to a 4-year institution and completed within 4 years
    1351 MALE_COMP_4YR_TRANS_YR6_RT Percent of male students who transferred to a 4-year institution and completed within 6 years
    1348 MALE_COMP_4YR_TRANS_YR8_RT Percent of male students who transferred to a 4-year institution and completed within 8 years
    1361 MALE_COMP_ORIG_YR2_RT Percent of male students who completed within 2 years at original institution
    1361 MALE_COMP_ORIG_YR3_RT Percent of male students who completed within 3 years at original institution
    1354 MALE_COMP_ORIG_YR4_RT Percent of male students who completed within 4 years at original institution
    1351 MALE_COMP_ORIG_YR6_RT Percent of male students who completed within 6 years at original institution
    1348 MALE_COMP_ORIG_YR8_RT Percent of male students who completed within 8 years at original institution
    1361 MALE_DEATH_YR2_RT Percent of male students who died within 2 years at original institution
    1361 MALE_DEATH_YR3_RT Percent of male students who died within 3 years at original institution
    1354 MALE_DEATH_YR4_RT Percent of male students who died within 4 years at original institution
    1351 MALE_DEATH_YR6_RT Percent of male students who died within 6 years at original institution
    1348 MALE_DEATH_YR8_RT Percent of male students who died within 8 years at original institution
    1358 MALE_DEBT_MDN The median debt for male students
    1358 MALE_DEBT_N The number of students in the median debt male students cohort
    1361 MALE_ENRL_2YR_TRANS_YR2_RT Percent of male students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 MALE_ENRL_2YR_TRANS_YR3_RT Percent of male students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 MALE_ENRL_2YR_TRANS_YR4_RT Percent of male students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 MALE_ENRL_2YR_TRANS_YR6_RT Percent of male students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 MALE_ENRL_2YR_TRANS_YR8_RT Percent of male students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 MALE_ENRL_4YR_TRANS_YR2_RT Percent of male students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 MALE_ENRL_4YR_TRANS_YR3_RT Percent of male students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 MALE_ENRL_4YR_TRANS_YR4_RT Percent of male students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 MALE_ENRL_4YR_TRANS_YR6_RT Percent of male students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 MALE_ENRL_4YR_TRANS_YR8_RT Percent of male students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 MALE_ENRL_ORIG_YR2_RT Percent of male students who were still enrolled at original institution within 2 years 
    1361 MALE_ENRL_ORIG_YR3_RT Percent of male students who were still enrolled at original institution within 3 years
    1354 MALE_ENRL_ORIG_YR4_RT Percent of male students who were still enrolled at original institution within 4 years
    1351 MALE_ENRL_ORIG_YR6_RT Percent of male students who were still enrolled at original institution within 6 years
    1348 MALE_ENRL_ORIG_YR8_RT Percent of male students who were still enrolled at original institution within 8 years
    1357 MALE_RPY_1YR_N Number of students in the 1-year repayment rate of male students cohort
    1357 MALE_RPY_1YR_RT One-year repayment rate for males
    1351 MALE_RPY_3YR_N Number of students in the 3-year repayment rate of male students cohort
    1351 MALE_RPY_3YR_RT Three-year repayment rate for males
    1351 MALE_RPY_3YR_RT_SUPP 3-year repayment rate for male students, suppressed for n=30
    1348 MALE_RPY_5YR_N Number of students in the 5-year repayment rate of male students cohort
    1348 MALE_RPY_5YR_RT Five-year repayment rate for males
    1178 MALE_RPY_7YR_N Number of students in the 7-year repayment rate of male students cohort
    1178 MALE_RPY_7YR_RT Seven-year repayment rate for males
    1361 MALE_UNKN_2YR_TRANS_YR2_RT Percent of male students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 MALE_UNKN_2YR_TRANS_YR3_RT Percent of male students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 MALE_UNKN_2YR_TRANS_YR4_RT Percent of male students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 MALE_UNKN_2YR_TRANS_YR6_RT Percent of male students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 MALE_UNKN_2YR_TRANS_YR8_RT Percent of male students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 MALE_UNKN_4YR_TRANS_YR2_RT Percent of male students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 MALE_UNKN_4YR_TRANS_YR3_RT Percent of male students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 MALE_UNKN_4YR_TRANS_YR4_RT Percent of male students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 MALE_UNKN_4YR_TRANS_YR6_RT Percent of male students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 MALE_UNKN_4YR_TRANS_YR8_RT Percent of male students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 MALE_UNKN_ORIG_YR2_RT Percent of male students with status unknown within 2 years at original institution
    1361 MALE_UNKN_ORIG_YR3_RT Percent of male students with status unknown within 3 years at original institution
    1354 MALE_UNKN_ORIG_YR4_RT Percent of male students with status unknown within 4 years at original institution
    1351 MALE_UNKN_ORIG_YR6_RT Percent of male students with status unknown within 6 years at original institution
    1348 MALE_UNKN_ORIG_YR8_RT Percent of male students with status unknown within 8 years at original institution
    1361 MALE_WDRAW_2YR_TRANS_YR2_RT Percent of male students who transferred to a 2-year institution and withdrew within 2 years 
    1361 MALE_WDRAW_2YR_TRANS_YR3_RT Percent of male students who transferred to a 2-year institution and withdrew within 3 years
    1354 MALE_WDRAW_2YR_TRANS_YR4_RT Percent of male students who transferred to a 2-year institution and withdrew within 4 years
    1351 MALE_WDRAW_2YR_TRANS_YR6_RT Percent of male students who transferred to a 2-year institution and withdrew within 6 years
    1348 MALE_WDRAW_2YR_TRANS_YR8_RT Percent of male students who transferred to a 2-year institution and withdrew within 8 years
    1361 MALE_WDRAW_4YR_TRANS_YR2_RT Percent of male students who transferred to a 4-year institution and withdrew within 2 years 
    1361 MALE_WDRAW_4YR_TRANS_YR3_RT Percent of male students who transferred to a 4-year institution and withdrew within 3 years
    1354 MALE_WDRAW_4YR_TRANS_YR4_RT Percent of male students who transferred to a 4-year institution and withdrew within 4 years
    1351 MALE_WDRAW_4YR_TRANS_YR6_RT Percent of male students who transferred to a 4-year institution and withdrew within 6 years
    1348 MALE_WDRAW_4YR_TRANS_YR8_RT Percent of male students who transferred to a 4-year institution and withdrew within 8 years
    1361 MALE_WDRAW_ORIG_YR2_RT Percent of male students withdrawn from original institution within 2 years 
    1361 MALE_WDRAW_ORIG_YR3_RT Percent of male students withdrawn from original institution within 3 years
    1354 MALE_WDRAW_ORIG_YR4_RT Percent of male students withdrawn from original institution within 4 years
    1351 MALE_WDRAW_ORIG_YR6_RT Percent of male students withdrawn from original institution within 6 years
    1348 MALE_WDRAW_ORIG_YR8_RT Percent of male students withdrawn from original institution within 8 years
    1361 MALE_YR2_N Number of male students in overall 2-year completion cohort
    1361 MALE_YR3_N Number of male students in overall 3-year completion cohort
    1354 MALE_YR4_N Number of male students in overall 4-year completion cohort
    1351 MALE_YR6_N Number of male students in overall 6-year completion cohort
    1348 MALE_YR8_N Number of male students in overall 8-year completion cohort
    1361 MD_INC_COMP_2YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 2 years
    1361 MD_INC_COMP_2YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 3 years
    1354 MD_INC_COMP_2YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 4 years
    1351 MD_INC_COMP_2YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 6 years
    1348 MD_INC_COMP_2YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and completed within 8 years
    1361 MD_INC_COMP_4YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 2 years
    1361 MD_INC_COMP_4YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 3 years
    1354 MD_INC_COMP_4YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 4 years
    1351 MD_INC_COMP_4YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 6 years
    1348 MD_INC_COMP_4YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and completed within 8 years
    1361 MD_INC_COMP_ORIG_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who completed within 2 years at original institution
    1361 MD_INC_COMP_ORIG_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who completed within 3 years at original institution
    1354 MD_INC_COMP_ORIG_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who completed within 4 years at original institution
    1351 MD_INC_COMP_ORIG_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who completed within 6 years at original institution
    1348 MD_INC_COMP_ORIG_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who completed within 8 years at original institution
    1361 MD_INC_DEATH_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who died within 2 years at original institution
    1361 MD_INC_DEATH_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who died within 3 years at original institution
    1354 MD_INC_DEATH_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who died within 4 years at original institution
    1351 MD_INC_DEATH_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who died within 6 years at original institution
    1348 MD_INC_DEATH_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who died within 8 years at original institution
    1358 MD_INC_DEBT_MDN The median debt for students with family income between $30,001-$75,000
    1358 MD_INC_DEBT_N The number of students in the median debt middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    1361 MD_INC_ENRL_2YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 MD_INC_ENRL_2YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 MD_INC_ENRL_2YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 MD_INC_ENRL_2YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 MD_INC_ENRL_2YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 MD_INC_ENRL_4YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 MD_INC_ENRL_4YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 MD_INC_ENRL_4YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 MD_INC_ENRL_4YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 MD_INC_ENRL_4YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 MD_INC_ENRL_ORIG_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who were still enrolled at original institution within 2 years 
    1361 MD_INC_ENRL_ORIG_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who were still enrolled at original institution within 3 years
    1354 MD_INC_ENRL_ORIG_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who were still enrolled at original institution within 4 years
    1351 MD_INC_ENRL_ORIG_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who were still enrolled at original institution within 6 years
    1348 MD_INC_ENRL_ORIG_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who were still enrolled at original institution within 8 years
    1357 MD_INC_RPY_1YR_N Number of students in the 1-year repayment rate of middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    1357 MD_INC_RPY_1YR_RT One-year repayment rate by family income ($30,000-75,000)
    1351 MD_INC_RPY_3YR_N Number of students in the 3-year repayment rate of middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    1351 MD_INC_RPY_3YR_RT Three-year repayment rate by family income ($30,000-75,000)
    1351 MD_INC_RPY_3YR_RT_SUPP 3-year repayment rate for middle-income (between $30,000 and $75,000 in nominal family income) students, suppressed for n=30
    1348 MD_INC_RPY_5YR_N Number of students in the 5-year repayment rate of middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    1348 MD_INC_RPY_5YR_RT Five-year repayment rate by family income ($30,000-75,000)
    1178 MD_INC_RPY_7YR_N Number of students in the 7-year repayment rate of middle-income (between $30,000 and $75,000 in nominal family income) students cohort
    1178 MD_INC_RPY_7YR_RT Seven-year repayment rate by family income ($30,000-75,000)
    1361 MD_INC_UNKN_2YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 MD_INC_UNKN_2YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 MD_INC_UNKN_2YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 MD_INC_UNKN_2YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 MD_INC_UNKN_2YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 MD_INC_UNKN_4YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 MD_INC_UNKN_4YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 MD_INC_UNKN_4YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 MD_INC_UNKN_4YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 MD_INC_UNKN_4YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 MD_INC_UNKN_ORIG_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students with status unknown within 2 years at original institution
    1361 MD_INC_UNKN_ORIG_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students with status unknown within 3 years at original institution
    1354 MD_INC_UNKN_ORIG_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students with status unknown within 4 years at original institution
    1351 MD_INC_UNKN_ORIG_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students with status unknown within 6 years at original institution
    1348 MD_INC_UNKN_ORIG_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students with status unknown within 8 years at original institution
    1361 MD_INC_WDRAW_2YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 2 years 
    1361 MD_INC_WDRAW_2YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 3 years
    1354 MD_INC_WDRAW_2YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 4 years
    1351 MD_INC_WDRAW_2YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 6 years
    1348 MD_INC_WDRAW_2YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 2-year institution and withdrew within 8 years
    1361 MD_INC_WDRAW_4YR_TRANS_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 2 years 
    1361 MD_INC_WDRAW_4YR_TRANS_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 3 years
    1354 MD_INC_WDRAW_4YR_TRANS_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 4 years
    1351 MD_INC_WDRAW_4YR_TRANS_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 6 years
    1348 MD_INC_WDRAW_4YR_TRANS_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students who transferred to a 4-year institution and withdrew within 8 years
    1361 MD_INC_WDRAW_ORIG_YR2_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students withdrawn from original institution within 2 years 
    1361 MD_INC_WDRAW_ORIG_YR3_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students withdrawn from original institution within 3 years
    1354 MD_INC_WDRAW_ORIG_YR4_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students withdrawn from original institution within 4 years
    1351 MD_INC_WDRAW_ORIG_YR6_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students withdrawn from original institution within 6 years
    1348 MD_INC_WDRAW_ORIG_YR8_RT Percent of middle-income (between $30,000 and $75,000 in nominal family income) students withdrawn from original institution within 8 years
    1361 MD_INC_YR2_N Number of middle-income (between $30,000 and $75,000 in nominal family income) students in overall 2-year completion cohort
    1361 MD_INC_YR3_N Number of middle-income (between $30,000 and $75,000 in nominal family income) students in overall 3-year completion cohort
    1354 MD_INC_YR4_N Number of middle-income (between $30,000 and $75,000 in nominal family income) students in overall 4-year completion cohort
    1351 MD_INC_YR6_N Number of middle-income (between $30,000 and $75,000 in nominal family income) students in overall 6-year completion cohort
    1348 MD_INC_YR8_N Number of middle-income (between $30,000 and $75,000 in nominal family income) students in overall 8-year completion cohort
    1361 MENONLY Flag for men-only college
    1361 NANTI Flag for Native American non-tribal institution
    1361 NOLOAN_COMP_2YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and completed within 2 years
    1361 NOLOAN_COMP_2YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and completed within 3 years
    1354 NOLOAN_COMP_2YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and completed within 4 years
    1351 NOLOAN_COMP_2YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and completed within 6 years
    1348 NOLOAN_COMP_2YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and completed within 8 years
    1361 NOLOAN_COMP_4YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and completed within 2 years
    1361 NOLOAN_COMP_4YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and completed within 3 years
    1354 NOLOAN_COMP_4YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and completed within 4 years
    1351 NOLOAN_COMP_4YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and completed within 6 years
    1348 NOLOAN_COMP_4YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and completed within 8 years
    1361 NOLOAN_COMP_ORIG_YR2_RT Percent of students who never received a federal loan at the institution and who completed in 2 years at original institution
    1361 NOLOAN_COMP_ORIG_YR3_RT Percent of students who never received a federal loan at the institution and who completed in 3 years at original institution
    1354 NOLOAN_COMP_ORIG_YR4_RT Percent of students who never received a federal loan at the institution and who completed in 4 years at original institution
    1351 NOLOAN_COMP_ORIG_YR6_RT Percent of students who never received a federal loan at the institution and who completed in 6 years at original institution
    1348 NOLOAN_COMP_ORIG_YR8_RT Percent of students who never received a federal loan at the institution and who completed in 8 years at original institution
    1361 NOLOAN_DEATH_YR2_RT Percent of students who never received a federal loan at the institution and who died within 2 years at original institution
    1361 NOLOAN_DEATH_YR3_RT Percent of students who never received a federal loan at the institution and who died within 3 years at original institution
    1354 NOLOAN_DEATH_YR4_RT Percent of students who never received a federal loan at the institution and who died within 4 years at original institution
    1351 NOLOAN_DEATH_YR6_RT Percent of students who never received a federal loan at the institution and who died within 6 years at original institution
    1348 NOLOAN_DEATH_YR8_RT Percent of students who never received a federal loan at the institution and who died within 8 years at original institution
    1361 NOLOAN_ENRL_2YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 2 years
    1361 NOLOAN_ENRL_2YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 3 years
    1354 NOLOAN_ENRL_2YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 4 years
    1351 NOLOAN_ENRL_2YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 6 years
    1348 NOLOAN_ENRL_2YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and were still enrolled within 8 years
    1361 NOLOAN_ENRL_4YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 NOLOAN_ENRL_4YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 3 years
    1354 NOLOAN_ENRL_4YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 4 years
    1351 NOLOAN_ENRL_4YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 6 years
    1348 NOLOAN_ENRL_4YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and were still enrolled within 8 years
    1361 NOLOAN_ENRL_ORIG_YR2_RT Percent of students who never received a federal loan at the institution and who were still enrolled at original institution within 2 years 
    1361 NOLOAN_ENRL_ORIG_YR3_RT Percent of students who never received a federal loan at the institution and who were still enrolled at original institution within 3 years
    1354 NOLOAN_ENRL_ORIG_YR4_RT Percent of students who never received a federal loan at the institution and who were still enrolled at original institution within 4 years
    1351 NOLOAN_ENRL_ORIG_YR6_RT Percent of students who never received a federal loan at the institution and who were still enrolled at original institution within 6 years
    1348 NOLOAN_ENRL_ORIG_YR8_RT Percent of students who never received a federal loan at the institution and who were still enrolled at original institution within 8 years
    1361 NOLOAN_UNKN_2YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 NOLOAN_UNKN_2YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 NOLOAN_UNKN_2YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 NOLOAN_UNKN_2YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 NOLOAN_UNKN_2YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 NOLOAN_UNKN_4YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 NOLOAN_UNKN_4YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 NOLOAN_UNKN_4YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 NOLOAN_UNKN_4YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 NOLOAN_UNKN_4YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 NOLOAN_UNKN_ORIG_YR2_RT Percent of students who never received a federal loan at the institution and with status unknown within 2 years at original institution
    1361 NOLOAN_UNKN_ORIG_YR3_RT Percent of students who never received a federal loan at the institution and with status unknown within 3 years at original institution
    1354 NOLOAN_UNKN_ORIG_YR4_RT Percent of students who never received a federal loan at the institution and with status unknown within 4 years at original institution
    1351 NOLOAN_UNKN_ORIG_YR6_RT Percent of students who never received a federal loan at the institution and with status unknown within 6 years at original institution
    1348 NOLOAN_UNKN_ORIG_YR8_RT Percent of students who never received a federal loan at the institution and with status unknown within 8 years at original institution
    1361 NOLOAN_WDRAW_2YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 2 years 
    1361 NOLOAN_WDRAW_2YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 3 years
    1354 NOLOAN_WDRAW_2YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 4 years
    1351 NOLOAN_WDRAW_2YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 6 years
    1348 NOLOAN_WDRAW_2YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 2-year institution and withdrew within 8 years
    1361 NOLOAN_WDRAW_4YR_TRANS_YR2_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 2 years 
    1361 NOLOAN_WDRAW_4YR_TRANS_YR3_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 3 years
    1354 NOLOAN_WDRAW_4YR_TRANS_YR4_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 4 years
    1351 NOLOAN_WDRAW_4YR_TRANS_YR6_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 6 years
    1348 NOLOAN_WDRAW_4YR_TRANS_YR8_RT Percent of students who never received a federal loan at the institution and who transferred to a 4-year institution and withdrew within 8 years
    1361 NOLOAN_WDRAW_ORIG_YR2_RT Percent of students who never received a federal loan at the institution and withdrew from original institution within 2 years 
    1361 NOLOAN_WDRAW_ORIG_YR3_RT Percent of students who never received a federal loan at the institution and withdrew from original institution within 3 years
    1354 NOLOAN_WDRAW_ORIG_YR4_RT Percent of students who never received a federal loan at the institution and withdrew from original institution within 4 years
    1351 NOLOAN_WDRAW_ORIG_YR6_RT Percent of students who never received a federal loan at the institution and withdrew from original institution within 6 years
    1348 NOLOAN_WDRAW_ORIG_YR8_RT Percent of students who never received a federal loan at the institution and withdrew from original institution within 8 years
    1361 NOLOAN_YR2_N Number of no-loan students in overall 2-year completion cohort
    1361 NOLOAN_YR3_N Number of no-loan students in overall 3-year completion cohort
    1354 NOLOAN_YR4_N Number of no-loan students in overall 4-year completion cohort
    1351 NOLOAN_YR6_N Number of no-loan students in overall 6-year completion cohort
    1348 NOLOAN_YR8_N Number of no-loan students in overall 8-year completion cohort
    1357 NONCOM_RPY_1YR_N Number of students in the 1-year repayment rate of non-completers cohort
    1357 NONCOM_RPY_1YR_RT One-year repayment rate for non-completers
    1351 NONCOM_RPY_3YR_N Number of students in the 3-year repayment rate of non-completers cohort
    1351 NONCOM_RPY_3YR_RT Three-year repayment rate for non-completers
    1351 NONCOM_RPY_3YR_RT_SUPP 3-year repayment rate for non-completers, suppressed for n=30
    1348 NONCOM_RPY_5YR_N Number of students in the 5-year repayment rate of non-completers cohort
    1348 NONCOM_RPY_5YR_RT Five-year repayment rate for non-completers
    1178 NONCOM_RPY_7YR_N Number of students in the 7-year repayment rate of non-completers cohort
    1178 NONCOM_RPY_7YR_RT Seven-year repayment rate for non-completers
    1361 NOPELL_COMP_2YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 2 years
    1361 NOPELL_COMP_2YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 3 years
    1354 NOPELL_COMP_2YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 4 years
    1351 NOPELL_COMP_2YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 6 years
    1348 NOPELL_COMP_2YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 8 years
    1361 NOPELL_COMP_4YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 2 years
    1361 NOPELL_COMP_4YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 3 years
    1354 NOPELL_COMP_4YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 4 years
    1351 NOPELL_COMP_4YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 6 years
    1348 NOPELL_COMP_4YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 8 years
    1361 NOPELL_COMP_ORIG_YR2_RT Percent of students who never received a Pell Grant at the institution and who completed in 2 years at original institution
    1361 NOPELL_COMP_ORIG_YR3_RT Percent of students who never received a Pell Grant at the institution and who completed in 3 years at original institution
    1354 NOPELL_COMP_ORIG_YR4_RT Percent of students who never received a Pell Grant at the institution and who completed in 4 years at original institution
    1351 NOPELL_COMP_ORIG_YR6_RT Percent of students who never received a Pell Grant at the institution and who completed in 6 years at original institution
    1348 NOPELL_COMP_ORIG_YR8_RT Percent of students who never received a Pell Grant at the institution and who completed in 8 years at original institution
    1361 NOPELL_DEATH_YR2_RT Percent of students who never received a Pell Grant at the institution and who died within 2 years at original institution
    1361 NOPELL_DEATH_YR3_RT Percent of students who never received a Pell Grant at the institution and who died within 3 years at original institution
    1354 NOPELL_DEATH_YR4_RT Percent of students who never received a Pell Grant at the institution and who died within 4 years at original institution
    1351 NOPELL_DEATH_YR6_RT Percent of students who never received a Pell Grant at the institution and who died within 6 years at original institution
    1348 NOPELL_DEATH_YR8_RT Percent of students who never received a Pell Grant at the institution and who died within 8 years at original institution
    1358 NOPELL_DEBT_MDN The median debt for no-Pell students
    1358 NOPELL_DEBT_N The number of students in the median debt no-Pell students cohort
    1361 NOPELL_ENRL_2YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 2 years
    1361 NOPELL_ENRL_2YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 3 years
    1354 NOPELL_ENRL_2YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 4 years
    1351 NOPELL_ENRL_2YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 6 years
    1348 NOPELL_ENRL_2YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 8 years
    1361 NOPELL_ENRL_4YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 NOPELL_ENRL_4YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 3 years
    1354 NOPELL_ENRL_4YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 4 years
    1351 NOPELL_ENRL_4YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 6 years
    1348 NOPELL_ENRL_4YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 8 years
    1361 NOPELL_ENRL_ORIG_YR2_RT Percent of students who never received a Pell Grant at the institution and who were still enrolled at original institution within 2 years 
    1361 NOPELL_ENRL_ORIG_YR3_RT Percent of students who never received a Pell Grant at the institution and who were still enrolled at original institution within 3 years
    1354 NOPELL_ENRL_ORIG_YR4_RT Percent of students who never received a Pell Grant at the institution and who were still enrolled at original institution within 4 years
    1351 NOPELL_ENRL_ORIG_YR6_RT Percent of students who never received a Pell Grant at the institution and who were still enrolled at original institution within 6 years
    1348 NOPELL_ENRL_ORIG_YR8_RT Percent of students who never received a Pell Grant at the institution and who were still enrolled at original institution within 8 years
    1357 NOPELL_RPY_1YR_N Number of students in the 1-year repayment rate of no-Pell students cohort
    1357 NOPELL_RPY_1YR_RT One-year repayment rate for students who never received a Pell grant while at school
    1351 NOPELL_RPY_3YR_N Number of students in the 3-year repayment rate of no-Pell students cohort
    1351 NOPELL_RPY_3YR_RT Three-year repayment rate for students who never received a Pell grant while at school
    1351 NOPELL_RPY_3YR_RT_SUPP 3-year repayment rate for no-Pell students, suppressed for n=30
    1348 NOPELL_RPY_5YR_N Number of students in the 5-year repayment rate of no-Pell students cohort
    1348 NOPELL_RPY_5YR_RT Five-year repayment rate for students who never received a Pell grant while at school
    1178 NOPELL_RPY_7YR_N Number of students in the 7-year repayment rate of no-Pell students cohort
    1178 NOPELL_RPY_7YR_RT Seven-year repayment rate for students who never received a Pell grant while at school
    1361 NOPELL_UNKN_2YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 NOPELL_UNKN_2YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 NOPELL_UNKN_2YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 NOPELL_UNKN_2YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 NOPELL_UNKN_2YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 NOPELL_UNKN_4YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 NOPELL_UNKN_4YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 NOPELL_UNKN_4YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 NOPELL_UNKN_4YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 NOPELL_UNKN_4YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 NOPELL_UNKN_ORIG_YR2_RT Percent of students who never received a Pell Grant at the institution and with status unknown within 2 years at original institution
    1361 NOPELL_UNKN_ORIG_YR3_RT Percent of students who never received a Pell Grant at the institution and with status unknown within 3 years at original institution
    1354 NOPELL_UNKN_ORIG_YR4_RT Percent of students who never received a Pell Grant at the institution and with status unknown within 4 years at original institution
    1351 NOPELL_UNKN_ORIG_YR6_RT Percent of students who never received a Pell Grant at the institution and with status unknown within 6 years at original institution
    1348 NOPELL_UNKN_ORIG_YR8_RT Percent of students who never received a Pell Grant at the institution and with status unknown within 8 years at original institution
    1361 NOPELL_WDRAW_2YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 2 years 
    1361 NOPELL_WDRAW_2YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 3 years
    1354 NOPELL_WDRAW_2YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 4 years
    1351 NOPELL_WDRAW_2YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 6 years
    1348 NOPELL_WDRAW_2YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 8 years
    1361 NOPELL_WDRAW_4YR_TRANS_YR2_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 2 years 
    1361 NOPELL_WDRAW_4YR_TRANS_YR3_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 3 years
    1354 NOPELL_WDRAW_4YR_TRANS_YR4_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 4 years
    1351 NOPELL_WDRAW_4YR_TRANS_YR6_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 6 years
    1348 NOPELL_WDRAW_4YR_TRANS_YR8_RT Percent of students who never received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 8 years
    1361 NOPELL_WDRAW_ORIG_YR2_RT Percent of students who never received a Pell Grant at the institution and withdrew from original institution within 2 years 
    1361 NOPELL_WDRAW_ORIG_YR3_RT Percent of students who never received a Pell Grant at the institution and withdrew from original institution within 3 years
    1354 NOPELL_WDRAW_ORIG_YR4_RT Percent of students who never received a Pell Grant at the institution and withdrew from original institution within 4 years
    1351 NOPELL_WDRAW_ORIG_YR6_RT Percent of students who never received a Pell Grant at the institution and withdrew from original institution within 6 years
    1348 NOPELL_WDRAW_ORIG_YR8_RT Percent of students who never received a Pell Grant at the institution and withdrew from original institution within 8 years
    1361 NOPELL_YR2_N Number of no-Pell students in overall 2-year completion cohort
    1361 NOPELL_YR3_N Number of no-Pell students in overall 3-year completion cohort
    1354 NOPELL_YR4_N Number of no-Pell students in overall 4-year completion cohort
    1351 NOPELL_YR6_N Number of no-Pell students in overall 6-year completion cohort
    1348 NOPELL_YR8_N Number of no-Pell students in overall 8-year completion cohort
    1361 NOT1STGEN_COMP_2YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 2-year institution and completed within 2 years
    1361 NOT1STGEN_COMP_2YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 2-year institution and completed within 3 years
    1354 NOT1STGEN_COMP_2YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 2-year institution and completed within 4 years
    1351 NOT1STGEN_COMP_2YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 2-year institution and completed within 6 years
    1348 NOT1STGEN_COMP_2YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 2-year institution and completed within 8 years
    1361 NOT1STGEN_COMP_4YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 4-year institution and completed within 2 years
    1361 NOT1STGEN_COMP_4YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 4-year institution and completed within 3 years
    1354 NOT1STGEN_COMP_4YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 4-year institution and completed within 4 years
    1351 NOT1STGEN_COMP_4YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 4-year institution and completed within 6 years
    1348 NOT1STGEN_COMP_4YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 4-year institution and completed within 8 years
    1361 NOT1STGEN_COMP_ORIG_YR2_RT Percent of not-first-generation students who completed within 2 years at original institution
    1361 NOT1STGEN_COMP_ORIG_YR3_RT Percent of not-first-generation students who completed within 3 years at original institution
    1354 NOT1STGEN_COMP_ORIG_YR4_RT Percent of not-first-generation students who completed within 4 years at original institution
    1351 NOT1STGEN_COMP_ORIG_YR6_RT Percent of not-first-generation students who completed within 6 years at original institution
    1348 NOT1STGEN_COMP_ORIG_YR8_RT Percent of not-first-generation students who completed within 8 years at original institution
    1361 NOT1STGEN_DEATH_YR2_RT Percent of not-first-generation students who died within 2 years at original institution
    1361 NOT1STGEN_DEATH_YR3_RT Percent of not-first-generation students who died within 3 years at original institution
    1354 NOT1STGEN_DEATH_YR4_RT Percent of not-first-generation students who died within 4 years at original institution
    1351 NOT1STGEN_DEATH_YR6_RT Percent of not-first-generation students who died within 6 years at original institution
    1348 NOT1STGEN_DEATH_YR8_RT Percent of not-first-generation students who died within 8 years at original institution
    1361 NOT1STGEN_ENRL_2YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 2-year institution and were still enrolled within 2 years
    1361 NOT1STGEN_ENRL_2YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 2-year institution and were still enrolled within 3 years
    1354 NOT1STGEN_ENRL_2YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 2-year institution and were still enrolled within 4 years
    1351 NOT1STGEN_ENRL_2YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 2-year institution and were still enrolled within 6 years
    1348 NOT1STGEN_ENRL_2YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 2-year institution and were still enrolled within 8 years
    1361 NOT1STGEN_ENRL_4YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 NOT1STGEN_ENRL_4YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 4-year institution and were still enrolled within 3 years
    1354 NOT1STGEN_ENRL_4YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 4-year institution and were still enrolled within 4 years
    1351 NOT1STGEN_ENRL_4YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 4-year institution and were still enrolled within 6 years
    1348 NOT1STGEN_ENRL_4YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 4-year institution and were still enrolled within 8 years
    1361 NOT1STGEN_ENRL_ORIG_YR2_RT Percent of not-first-generation students who were still enrolled at original institution within 2 years 
    1361 NOT1STGEN_ENRL_ORIG_YR3_RT Percent of not-first-generation students who were still enrolled at original institution within 3 years
    1354 NOT1STGEN_ENRL_ORIG_YR4_RT Percent of not-first-generation students who were still enrolled at original institution within 4 years
    1351 NOT1STGEN_ENRL_ORIG_YR6_RT Percent of not-first-generation students who were still enrolled at original institution within 6 years
    1348 NOT1STGEN_ENRL_ORIG_YR8_RT Percent of not-first-generation students who were still enrolled at original institution within 8 years
    1361 NOT1STGEN_UNKN_2YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 NOT1STGEN_UNKN_2YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 NOT1STGEN_UNKN_2YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 NOT1STGEN_UNKN_2YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 NOT1STGEN_UNKN_2YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 NOT1STGEN_UNKN_4YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 NOT1STGEN_UNKN_4YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 NOT1STGEN_UNKN_4YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 NOT1STGEN_UNKN_4YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 NOT1STGEN_UNKN_4YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 NOT1STGEN_UNKN_ORIG_YR2_RT Percent of not-first-generation students with status unknown within 2 years at original institution
    1361 NOT1STGEN_UNKN_ORIG_YR3_RT Percent of not-first-generation students with status unknown within 3 years at original institution
    1354 NOT1STGEN_UNKN_ORIG_YR4_RT Percent of not-first-generation students with status unknown within 4 years at original institution
    1351 NOT1STGEN_UNKN_ORIG_YR6_RT Percent of not-first-generation students with status unknown within 6 years at original institution
    1348 NOT1STGEN_UNKN_ORIG_YR8_RT Percent of not-first-generation students with status unknown within 8 years at original institution
    1361 NOT1STGEN_WDRAW_2YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 2-year institution and withdrew within 2 years 
    1361 NOT1STGEN_WDRAW_2YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 2-year institution and withdrew within 3 years
    1354 NOT1STGEN_WDRAW_2YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 2-year institution and withdrew within 4 years
    1351 NOT1STGEN_WDRAW_2YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 2-year institution and withdrew within 6 years
    1348 NOT1STGEN_WDRAW_2YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 2-year institution and withdrew within 8 years
    1361 NOT1STGEN_WDRAW_4YR_TRANS_YR2_RT Percent of not-first-generation students who transferred to a 4-year institution and withdrew within 2 years 
    1361 NOT1STGEN_WDRAW_4YR_TRANS_YR3_RT Percent of not-first-generation students who transferred to a 4-year institution and withdrew within 3 years
    1354 NOT1STGEN_WDRAW_4YR_TRANS_YR4_RT Percent of not-first-generation students who transferred to a 4-year institution and withdrew within 4 years
    1351 NOT1STGEN_WDRAW_4YR_TRANS_YR6_RT Percent of not-first-generation students who transferred to a 4-year institution and withdrew within 6 years
    1348 NOT1STGEN_WDRAW_4YR_TRANS_YR8_RT Percent of not-first-generation students who transferred to a 4-year institution and withdrew within 8 years
    1361 NOT1STGEN_WDRAW_ORIG_YR2_RT Percent of not-first-generation students withdrawn from original institution within 2 years 
    1361 NOT1STGEN_WDRAW_ORIG_YR3_RT Percent of not-first-generation students withdrawn from original institution within 3 years
    1354 NOT1STGEN_WDRAW_ORIG_YR4_RT Percent of not-first-generation students withdrawn from original institution within 4 years
    1351 NOT1STGEN_WDRAW_ORIG_YR6_RT Percent of not-first-generation students withdrawn from original institution within 6 years
    1348 NOT1STGEN_WDRAW_ORIG_YR8_RT Percent of not-first-generation students withdrawn from original institution within 8 years
    1361 NOT1STGEN_YR2_N Number of not-first-generation students in overall 2-year completion cohort
    1361 NOT1STGEN_YR3_N Number of not-first-generation students in overall 3-year completion cohort
    1354 NOT1STGEN_YR4_N Number of not-first-generation students in overall 4-year completion cohort
    1351 NOT1STGEN_YR6_N Number of not-first-generation students in overall 6-year completion cohort
    1348 NOT1STGEN_YR8_N Number of not-first-generation students in overall 8-year completion cohort
    1358 NOTFIRSTGEN_DEBT_MDN The median debt for not-first-generation students
    1358 NOTFIRSTGEN_DEBT_N The number of students in the median debt not-first-generation students cohort
    1357 NOTFIRSTGEN_RPY_1YR_N Number of students in the 1-year repayment rate of not-first-generation students cohort
    1357 NOTFIRSTGEN_RPY_1YR_RT One-year repayment rate for students who are not first-generation
    1351 NOTFIRSTGEN_RPY_3YR_N Number of students in the 3-year repayment rate of not-first-generation students cohort
    1351 NOTFIRSTGEN_RPY_3YR_RT Three-year repayment rate for students who are not first-generation
    1351 NOTFIRSTGEN_RPY_3YR_RT_SUPP 3-year repayment rate for non-first-generation students, suppressed for n=30
    1348 NOTFIRSTGEN_RPY_5YR_N Number of students in the 5-year repayment rate of not-first-generation students cohort
    1348 NOTFIRSTGEN_RPY_5YR_RT Five-year repayment rate for students who are not first-generation
    1178 NOTFIRSTGEN_RPY_7YR_N Number of students in the 7-year repayment rate of not-first-generation students cohort
    1178 NOTFIRSTGEN_RPY_7YR_RT Seven-year repayment rate for students who are not first-generation
    836 NPT41_PRIV Average net price for $0-$30,000 family income (private for-profit and nonprofit institutions)
    516 NPT41_PUB Average net price for $0-$30,000 family income (public institutions)
    831 NPT42_PRIV Average net price for $30,001-$48,000 family income (private for-profit and nonprofit institutions)
    514 NPT42_PUB Average net price for $30,001-$48,000 family income (public institutions)
    828 NPT43_PRIV Average net price for $48,001-$75,000 family income (private for-profit and nonprofit institutions)
    513 NPT43_PUB Average net price for $48,001-$75,000 family income (public institutions)
    817 NPT44_PRIV Average net price for $75,001-$110,000 family income (private for-profit and nonprofit institutions)
    508 NPT44_PUB Average net price for $75,001-$110,000 family income (public institutions)
    793 NPT45_PRIV Average net price for $110,000+ family income (private for-profit and nonprofit institutions)
    485 NPT45_PUB Average net price for $110,000+ family income (public institutions)
    838 NPT4_048_PRIV Average net price for $0-$48,000 family income (private for-profit and nonprofit institutions)
    516 NPT4_048_PUB Average net price for $0-$48,000 family income (public institutions)
    837 NPT4_3075_PRIV Average net price for $30,001-$75,000 family income (private for-profit and nonprofit institutions)
    516 NPT4_3075_PUB Average net price for $30,001-$75,000 family income (public institutions)
    821 NPT4_75UP_PRIV Average net price for $75,000+ family income (private for-profit and nonprofit institutions)
    508 NPT4_75UP_PUB Average net price for $75,000+ family income (public institutions)
    841 NPT4_PRIV Average net price for Title IV institutions (private for-profit and nonprofit institutions)
    516 NPT4_PUB Average net price for Title IV institutions (public institutions)
    841 NUM41_PRIV Number of Title IV students, $0-$30,000 family income (private for-profit and nonprofit institutions)
    517 NUM41_PUB Number of Title IV students, $0-$30,000 family income (public institutions)
    841 NUM42_PRIV Number of Title IV students, $30,001-$48,000 family income (private for-profit and nonprofit institutions)
    517 NUM42_PUB Number of Title IV students, $30,001-$48,000 family income (public institutions)
    841 NUM43_PRIV Number of Title IV students, $48,001-$75,000 family income (private for-profit and nonprofit institutions)
    517 NUM43_PUB Number of Title IV students, $48,001-$75,000 family income (public institutions)
    841 NUM44_PRIV Number of Title IV students, $75,001-$110,000 family income (private for-profit and nonprofit institutions)
    517 NUM44_PUB Number of Title IV students, $75,001-$110,000 family income (public institutions)
    841 NUM45_PRIV Number of Title IV students, $110,000+ family income (private for-profit and nonprofit institutions)
    517 NUM45_PUB Number of Title IV students, $110,000+ family income (public institutions)
    842 NUM4_PRIV Number of Title IV students (private for-profit and nonprofit institutions)
    518 NUM4_PUB Number of Title IV students (public institutions)
    1361 NUMBRANCH Number of branch campuses
    1361 OPEID 8-digit OPE ID for institution
    1361 OVERALL_YR2_N Number of students completed in overall 2-year completion cohort
    1361 OVERALL_YR3_N Number of students in overall 3-year completion cohort
    1354 OVERALL_YR4_N Number of students in overall 4-year completion cohort
    1351 OVERALL_YR6_N Number of students in overall 6-year completion cohort
    1348 OVERALL_YR8_N Number of students in overall 8-year completion cohort
    1361 PAR_ED_N Number of students in the parents' education level cohort
    1361 PAR_ED_PCT_1STGEN Percentage first-generation students
    1361 PAR_ED_PCT_HS Percent of students whose parents' highest educational level is high school
    1361 PAR_ED_PCT_MS Percent of students whose parents' highest educational level is middle school
    1361 PAR_ED_PCT_PS Percent of students whose parents' highest educational level was is some form of postsecondary education
    1361 PBI Flag for predominantly black institution
    1361 PCIP01 Percentage of degrees awarded in Agriculture, Agriculture Operations, And Related Sciences.
    1361 PCIP03 Percentage of degrees awarded in Natural Resources And Conservation.
    1361 PCIP04 Percentage of degrees awarded in Architecture And Related Services.
    1361 PCIP05 Percentage of degrees awarded in Area, Ethnic, Cultural, Gender, And Group Studies.
    1361 PCIP09 Percentage of degrees awarded in Communication, Journalism, And Related Programs.
    1361 PCIP10 Percentage of degrees awarded in Communications Technologies/Technicians And Support Services.
    1361 PCIP11 Percentage of degrees awarded in Computer And Information Sciences And Support Services.
    1361 PCIP12 Percentage of degrees awarded in Personal And Culinary Services.
    1361 PCIP13 Percentage of degrees awarded in Education.
    1361 PCIP14 Percentage of degrees awarded in Engineering.
    1361 PCIP15 Percentage of degrees awarded in Engineering Technologies And Engineering-Related Fields.
    1361 PCIP16 Percentage of degrees awarded in Foreign Languages, Literatures, And Linguistics.
    1361 PCIP19 Percentage of degrees awarded in Family And Consumer Sciences/Human Sciences.
    1361 PCIP22 Percentage of degrees awarded in Legal Professions And Studies.
    1361 PCIP23 Percentage of degrees awarded in English Language And Literature/Letters.
    1361 PCIP24 Percentage of degrees awarded in Liberal Arts And Sciences, General Studies And Humanities.
    1361 PCIP25 Percentage of degrees awarded in Library Science.
    1361 PCIP26 Percentage of degrees awarded in Biological And Biomedical Sciences.
    1361 PCIP27 Percentage of degrees awarded in Mathematics And Statistics.
    1361 PCIP29 Percentage of degrees awarded in Military Technologies And Applied Sciences.
    1361 PCIP30 Percentage of degrees awarded in Multi/Interdisciplinary Studies.
    1361 PCIP31 Percentage of degrees awarded in Parks, Recreation, Leisure, And Fitness Studies.
    1361 PCIP38 Percentage of degrees awarded in Philosophy And Religious Studies.
    1361 PCIP39 Percentage of degrees awarded in Theology And Religious Vocations.
    1361 PCIP40 Percentage of degrees awarded in Physical Sciences.
    1361 PCIP41 Percentage of degrees awarded in Science Technologies/Technicians.
    1361 PCIP42 Percentage of degrees awarded in Psychology.
    1361 PCIP43 Percentage of degrees awarded in Homeland Security, Law Enforcement, Firefighting And Related Protective Services.
    1361 PCIP44 Percentage of degrees awarded in Public Administration And Social Service Professions.
    1361 PCIP45 Percentage of degrees awarded in Social Sciences.
    1361 PCIP46 Percentage of degrees awarded in Construction Trades.
    1361 PCIP47 Percentage of degrees awarded in Mechanic And Repair Technologies/Technicians.
    1361 PCIP48 Percentage of degrees awarded in Precision Production.
    1361 PCIP49 Percentage of degrees awarded in Transportation And Materials Moving.
    1361 PCIP50 Percentage of degrees awarded in Visual And Performing Arts.
    1361 PCIP51 Percentage of degrees awarded in Health Professions And Related Programs.
    1361 PCIP52 Percentage of degrees awarded in Business, Management, Marketing, And Related Support Services.
    1361 PCIP54 Percentage of degrees awarded in History.
    1360 PCTFLOAN Percent of all federal undergraduate students receiving a federal student loan
    1360 PCTPELL Percentage of undergraduates who receive a Pell Grant
    1361 PELL_COMP_2YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 2 years
    1361 PELL_COMP_2YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 3 years
    1354 PELL_COMP_2YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 4 years
    1351 PELL_COMP_2YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 6 years
    1348 PELL_COMP_2YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and completed within 8 years
    1361 PELL_COMP_4YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 2 years
    1361 PELL_COMP_4YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 3 years
    1354 PELL_COMP_4YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 4 years
    1351 PELL_COMP_4YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 6 years
    1348 PELL_COMP_4YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and completed within 8 years
    1361 PELL_COMP_ORIG_YR2_RT Percent of students who received a Pell Grant at the institution and who completed in 2 years at original institution
    1361 PELL_COMP_ORIG_YR3_RT Percent of students who received a Pell Grant at the institution and who completed in 3 years at original institution
    1354 PELL_COMP_ORIG_YR4_RT Percent of students who received a Pell Grant at the institution and who completed in 4 years at original institution
    1351 PELL_COMP_ORIG_YR6_RT Percent of students who received a Pell Grant at the institution and who completed in 6 years at original institution
    1348 PELL_COMP_ORIG_YR8_RT Percent of students who received a Pell Grant at the institution and who completed in 8 years at original institution
    1361 PELL_DEATH_YR2_RT Percent of students who received a Pell Grant at the institution and who died within 2 years at original institution
    1361 PELL_DEATH_YR3_RT Percent of students who received a Pell Grant at the institution and who died within 3 years at original institution
    1354 PELL_DEATH_YR4_RT Percent of students who received a Pell Grant at the institution and who died within 4 years at original institution
    1351 PELL_DEATH_YR6_RT Percent of students who received a Pell Grant at the institution and who died within 6 years at original institution
    1348 PELL_DEATH_YR8_RT Percent of students who received a Pell Grant at the institution and who died within 8 years at original institution
    1358 PELL_DEBT_MDN The median debt for Pell students
    1358 PELL_DEBT_N The number of students in the median debt Pell students cohort
    1361 PELL_ENRL_2YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 2 years
    1361 PELL_ENRL_2YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 3 years
    1354 PELL_ENRL_2YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 4 years
    1351 PELL_ENRL_2YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 6 years
    1348 PELL_ENRL_2YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and were still enrolled within 8 years
    1361 PELL_ENRL_4YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 2 years 
    1361 PELL_ENRL_4YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 3 years
    1354 PELL_ENRL_4YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 4 years
    1351 PELL_ENRL_4YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 6 years
    1348 PELL_ENRL_4YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and were still enrolled within 8 years
    1361 PELL_ENRL_ORIG_YR2_RT Percent of students who received a Pell Grant at the institution and who were still enrolled at original institution within 2 years 
    1361 PELL_ENRL_ORIG_YR3_RT Percent of students who received a Pell Grant at the institution and who were still enrolled at original institution within 3 years
    1354 PELL_ENRL_ORIG_YR4_RT Percent of students who received a Pell Grant at the institution and who were still enrolled at original institution within 4 years
    1351 PELL_ENRL_ORIG_YR6_RT Percent of students who received a Pell Grant at the institution and who were still enrolled at original institution within 6 years
    1348 PELL_ENRL_ORIG_YR8_RT Percent of students who received a Pell Grant at the institution and who were still enrolled at original institution within 8 years
    1357 PELL_RPY_1YR_N Number of students in the 1-year repayment rate of Pell students cohort
    1357 PELL_RPY_1YR_RT One-year repayment rate for students who received a Pell grant while at the school
    1351 PELL_RPY_3YR_N Number of students in the 3-year repayment rate of Pell students cohort
    1351 PELL_RPY_3YR_RT Three-year repayment rate for students who received a Pell grant while at the school
    1351 PELL_RPY_3YR_RT_SUPP 3-year repayment rate for Pell students, suppressed for n=30
    1348 PELL_RPY_5YR_N Number of students in the 5-year repayment rate of Pell students cohort
    1348 PELL_RPY_5YR_RT Five-year repayment rate for students who received a Pell grant while at the school
    1178 PELL_RPY_7YR_N Number of students in the 7-year repayment rate of Pell students cohort
    1178 PELL_RPY_7YR_RT Seven-year repayment rate for students who received a Pell grant while at the school
    1361 PELL_UNKN_2YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 PELL_UNKN_2YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 PELL_UNKN_2YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 PELL_UNKN_2YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 PELL_UNKN_2YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 PELL_UNKN_4YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 PELL_UNKN_4YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 PELL_UNKN_4YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 PELL_UNKN_4YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 PELL_UNKN_4YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 PELL_UNKN_ORIG_YR2_RT Percent of students who received a Pell Grant at the institution and with status unknown within 2 years at original institution
    1361 PELL_UNKN_ORIG_YR3_RT Percent of students who received a Pell Grant at the institution and with status unknown within 3 years at original institution
    1354 PELL_UNKN_ORIG_YR4_RT Percent of students who received a Pell Grant at the institution and with status unknown within 4 years at original institution
    1351 PELL_UNKN_ORIG_YR6_RT Percent of students who received a Pell Grant at the institution and with status unknown within 6 years at original institution
    1348 PELL_UNKN_ORIG_YR8_RT Percent of students who received a Pell Grant at the institution and with status unknown within 8 years at original institution
    1361 PELL_WDRAW_2YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 2 years 
    1361 PELL_WDRAW_2YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 3 years
    1354 PELL_WDRAW_2YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 4 years
    1351 PELL_WDRAW_2YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 6 years
    1348 PELL_WDRAW_2YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 2-year institution and withdrew within 8 years
    1361 PELL_WDRAW_4YR_TRANS_YR2_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 2 years 
    1361 PELL_WDRAW_4YR_TRANS_YR3_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 3 years
    1354 PELL_WDRAW_4YR_TRANS_YR4_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 4 years
    1351 PELL_WDRAW_4YR_TRANS_YR6_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 6 years
    1348 PELL_WDRAW_4YR_TRANS_YR8_RT Percent of students who received a Pell Grant at the institution and who transferred to a 4-year institution and withdrew within 8 years
    1361 PELL_WDRAW_ORIG_YR2_RT Percent of students who received a Pell Grant at the institution and withdrew from original institution within 2 years 
    1361 PELL_WDRAW_ORIG_YR3_RT Percent of students who received a Pell Grant at the institution and withdrew from original institution within 3 years
    1354 PELL_WDRAW_ORIG_YR4_RT Percent of students who received a Pell Grant at the institution and withdrew from original institution within 4 years
    1351 PELL_WDRAW_ORIG_YR6_RT Percent of students who received a Pell Grant at the institution and withdrew from original institution within 6 years
    1348 PELL_WDRAW_ORIG_YR8_RT Percent of students who received a Pell Grant at the institution and withdrew from original institution within 8 years
    1361 PELL_YR2_N Number of Pell students in overall 2-year completion cohort
    1361 PELL_YR3_N Number of Pell students in overall 3-year completion cohort
    1354 PELL_YR4_N Number of Pell students in overall 4-year completion cohort
    1351 PELL_YR6_N Number of Pell students in overall 6-year completion cohort
    1348 PELL_YR8_N Number of Pell students in overall 8-year completion cohort
    1350 PFTFAC Proportion of faculty that is full-time
    1346 PFTFTUG1_EF Share of undergraduate students who are first-time, full-time degree-/certificate-seeking undergraduate students
    1361 PPTUG_EF Share of undergraduate, degree-/certificate-seeking students who are part-time
    1361 PREDDEG Predominant degree awarded
    0        Not classified
    1        Predominantly certificate-degree granting
    2        Predominantly associate's-degree granting
    3        Predominantly bachelor's-degree granting
    4        Entirely graduate-degree granting
    1361 REPAY_DT_MDN Median Date Student Enters Repayment
    1361 REPAY_DT_N Number of students in the cohort for date students enter repayment
    1321 RET_FT4 First-time, full-time student retention rate at four-year institutions
    38 RET_FTL4 First-time, full-time student retention rate at less-than-four-year institutions
    852 RET_PT4 First-time, part-time student retention rate at four-year institutions
    22 RET_PTL4 First-time, part-time student retention rate at less-than-four-year institutions
    1357 RPY_1YR_N Number of students in the 1-year repayment rate cohort
    1357 RPY_1YR_RT Fraction of repayment cohort that has not defaulted, and with loan balances that have declined one year since entering repayment, excluding enrolled and military deferment from calculation. (Rolling averages)
    1351 RPY_3YR_N Number of students in the 3-year repayment rate cohort
    1351 RPY_3YR_RT Fraction of repayment cohort that has not defaulted, and with loan balances that have declined three years since entering repayment, excluding enrolled and military deferment from calculation.  (rolling averages)
    1351 RPY_3YR_RT_SUPP 3-year repayment rate, suppressed for n=30
    1348 RPY_5YR_N Number of students in the 5-year repayment rate cohort
    1348 RPY_5YR_RT Fraction of repayment cohort that has not defaulted, and with loan balances that have declined five years since entering repayment, excluding enrolled and military deferment from calculation.  (rolling averages)
    1178 RPY_7YR_N Number of students in the 7-year repayment rate cohort
    1178 RPY_7YR_RT Fraction of repayment cohort that has not defaulted, and with loan balances that have declined seven years since entering repayment, excluding enrolled and military deferment from calculation.  (rolling averages)
    1234 SATMT25 25th percentile of SAT scores at the institution (math)
    1234 SATMT75 75th percentile of SAT scores at the institution (math)
    1234 SATMTMID Midpoint of SAT scores at the institution (math)
    1211 SATVR25 25th percentile of SAT scores at the institution (critical reading)
    1211 SATVR75 75th percentile of SAT scores at the institution (critical reading)
    1211 SATVRMID Midpoint of SAT scores at the institution (critical reading)
    1361 SAT_AVG Average SAT equivalent score of students admitted
    1361 SAT_AVG_ALL Average SAT equivalent score of students admitted for all campuses rolled up to the 6-digit OPE ID
    1361 SEPAR_DT_MDN Median Date Student Separated
    1361 SEPAR_DT_N Number of students in the cohort for date students separated from the school
    1361 STABBR State postcode
    1361 TRIBAL Flag for tribal college and university
    1341 TUITFTE Net tuition revenue per full-time equivalent student
    1355 TUITIONFEE_IN In-state tuition and fees
    1355 TUITIONFEE_OUT Out-of-state tuition and fees
    3 TUITIONFEE_PROG Tuition and fees for program-year institutions
    1356 UG25abv Percentage of undergraduates aged 25 and above
    1361 UGDS Enrollment of undergraduate degree-seeking students
    1361 UGDS_2MOR Total share of enrollment of undergraduate degree-seeking students who are two or more races
    1361 UGDS_AIAN Total share of enrollment of undergraduate degree-seeking students who are American Indian/Alaska Native
    1361 UGDS_ASIAN Total share of enrollment of undergraduate degree-seeking students who are Asian
    1361 UGDS_BLACK Total share of enrollment of undergraduate degree-seeking students who are black
    1361 UGDS_HISP Total share of enrollment of undergraduate degree-seeking students who are Hispanic
    1361 UGDS_NHPI Total share of enrollment of undergraduate degree-seeking students who are Native Hawaiian/Pacific Islander
    1361 UGDS_NRA Total share of enrollment of undergraduate degree-seeking students who are non-resident aliens
    1361 UGDS_UNKN Total share of enrollment of undergraduate degree-seeking students whose race is unknown
    1361 UGDS_WHITE Total share of enrollment of undergraduate degree-seeking students who are white
    1361 UNITID Unit ID for institution
    1361 UNKN_2YR_TRANS_YR2_RT Percent who transferred to a 2-year institution and whose status is unknown within 2 years
    1361 UNKN_2YR_TRANS_YR3_RT Percent who transferred to a 2-year institution and whose status is unknown within 3 years
    1354 UNKN_2YR_TRANS_YR4_RT Percent who transferred to a 2-year institution and whose status is unknown within 4 years
    1351 UNKN_2YR_TRANS_YR6_RT Percent who transferred to a 2-year institution and whose status is unknown within 6 years
    1348 UNKN_2YR_TRANS_YR8_RT Percent who transferred to a 2-year institution and whose status is unknown within 8 years
    1361 UNKN_4YR_TRANS_YR2_RT Percent who transferred to a 4-year institution and whose status is unknown within 2 years
    1361 UNKN_4YR_TRANS_YR3_RT Percent who transferred to a 4-year institution and whose status is unknown within 3 years
    1354 UNKN_4YR_TRANS_YR4_RT Percent who transferred to a 4-year institution and whose status is unknown within 4 years
    1351 UNKN_4YR_TRANS_YR6_RT Percent who transferred to a 4-year institution and whose status is unknown within 6 years
    1348 UNKN_4YR_TRANS_YR8_RT Percent who transferred to a 4-year institution and whose status is unknown within 8 years
    1361 UNKN_ORIG_YR2_RT Percent with status unknown within 2 years at original institution
    1361 UNKN_ORIG_YR3_RT Percent with status unknown within 3 years at original institution
    1354 UNKN_ORIG_YR4_RT Percent with status unknown within 4 years at original institution
    1351 UNKN_ORIG_YR6_RT Percent with status unknown within 6 years at original institution
    1348 UNKN_ORIG_YR8_RT Percent with status unknown within 8 years at original institution
    1361 WDRAW_2YR_TRANS_YR2_RT Percent who transferred to a 2-year institution and withdrew within 2 years 
    1361 WDRAW_2YR_TRANS_YR3_RT Percent who transferred to a 2-year institution and withdrew within 3 years
    1354 WDRAW_2YR_TRANS_YR4_RT Percent who transferred to a 2-year institution and withdrew within 4 years
    1351 WDRAW_2YR_TRANS_YR6_RT Percent who transferred to a 2-year institution and withdrew within 6 years
    1348 WDRAW_2YR_TRANS_YR8_RT Percent who transferred to a 2-year institution and withdrew within 8 years
    1361 WDRAW_4YR_TRANS_YR2_RT Percent who transferred to a 4-year institution and withdrew within 2 years 
    1361 WDRAW_4YR_TRANS_YR3_RT Percent who transferred to a 4-year institution and withdrew within 3 years
    1354 WDRAW_4YR_TRANS_YR4_RT Percent who transferred to a 4-year institution and withdrew within 4 years
    1351 WDRAW_4YR_TRANS_YR6_RT Percent who transferred to a 4-year institution and withdrew within 6 years
    1348 WDRAW_4YR_TRANS_YR8_RT Percent who transferred to a 4-year institution and withdrew within 8 years
    1358 WDRAW_DEBT_MDN The median debt for students who have not completed
    1358 WDRAW_DEBT_N The number of students in the median debt withdrawn cohort
    1361 WDRAW_ORIG_YR2_RT Percent withdrawn from original institution within 2 years 
    1361 WDRAW_ORIG_YR3_RT Percent withdrawn from original institution within 3 years
    1354 WDRAW_ORIG_YR4_RT Percent withdrawn from original institution within 4 years
    1351 WDRAW_ORIG_YR6_RT Percent withdrawn from original institution within 6 years
    1348 WDRAW_ORIG_YR8_RT Percent withdrawn from original institution within 8 years
    1361 WOMENONLY Flag for women-only college
    1361 ZIP ZIP code
    1346 count_nwne_p10 Number of students not working and not enrolled 10 years after entry
    1351 count_nwne_p6 Number of students not working and not enrolled 6 years after entry
    1349 count_nwne_p8 Number of students not working and not enrolled 8 years after entry
    1346 count_wne_inc1_p10 Number of students working and not enrolled 10 years after entry in the lowest income tercile
    1351 count_wne_inc1_p6 Number of students working and not enrolled 6 years after entry in the lowest income tercile
    1346 count_wne_inc2_p10 Number of students working and not enrolled 10 years after entry in the middle income tercile
    1351 count_wne_inc2_p6 Number of students working and not enrolled 6 years after entry in the middle income tercile
    1346 count_wne_inc3_p10 Number of students working and not enrolled 10 years after entry in the highest income tercile
    1351 count_wne_inc3_p6 Number of students working and not enrolled 6 years after entry in the highest income tercile
    1346 count_wne_indep0_inc1_p10 Number of dependent students working and not enrolled 10 years after entry in the lowest income tercile
    1351 count_wne_indep0_inc1_p6 Number of dependent students working and not enrolled 6 years after entry in the lowest income tercile
    1346 count_wne_indep0_p10 Number of dependent students working and not enrolled 10 years after entry
    1351 count_wne_indep0_p6 Number of dependent students working and not enrolled 6 years after entry
    1346 count_wne_indep1_p10 Number of independent students working and not enrolled 10 years after entry
    1351 count_wne_indep1_p6 Number of independent students working and not enrolled 6 years after entry
    1346 count_wne_male0_p10 Number of female students working and not enrolled 10 years after entry
    1351 count_wne_male0_p6 Number of female students working and not enrolled 6 years after entry
    1346 count_wne_male1_p10 Number of male students working and not enrolled 10 years after entry
    1351 count_wne_male1_p6 Number of male students working and not enrolled 6 years after entry
    1346 count_wne_p10 Number of students working and not enrolled 10 years after entry
    1351 count_wne_p6 Number of students working and not enrolled 6 years after entry
    1349 count_wne_p8 Number of students working and not enrolled 8 years after entry
    1346 gt_25k_p10 Share of students earning over $25,000/year (threshold earnings) 10 years after entry
    1351 gt_25k_p6 Share of students earning over $25,000/year (threshold earnings) 6 years after entry
    1349 gt_25k_p8 Share of students earning over $25,000/year (threshold earnings) 8 years after entry
    1361 main Flag for main campus
    1346 md_earn_wne_p10 Median earnings of students working and not enrolled 10 years after entry
    1351 md_earn_wne_p6 Median earnings of students working and not enrolled 6 years after entry
    1349 md_earn_wne_p8 Median earnings of students working and not enrolled 8 years after entry
    1346 mn_earn_wne_inc1_p10 Mean earnings of students working and not enrolled 10 years after entry in the lowest income tercile
    1351 mn_earn_wne_inc1_p6 Mean earnings of students working and not enrolled 6 years after entry in the lowest income tercile
    1346 mn_earn_wne_inc2_p10 Mean earnings of students working and not enrolled 10 years after entry in the middle income tercile
    1351 mn_earn_wne_inc2_p6 Mean earnings of students working and not enrolled 6 years after entry in the middle income tercile
    1346 mn_earn_wne_inc3_p10 Mean earnings of students working and not enrolled 10 years after entry in the highest income tercile
    1351 mn_earn_wne_inc3_p6 Mean earnings of students working and not enrolled 6 years after entry in the highest income tercile
    1346 mn_earn_wne_indep0_inc1_p10 Mean earnings of dependent students working and not enrolled 10 years after entry in the lowest income tercile
    1351 mn_earn_wne_indep0_inc1_p6 Mean earnings of dependent students working and not enrolled 6 years after entry in the lowest income tercile
    1346 mn_earn_wne_indep0_p10 Mean earnings of dependent students working and not enrolled 10 years after entry
    1351 mn_earn_wne_indep0_p6 Mean earnings of dependent students working and not enrolled 6 years after entry
    1346 mn_earn_wne_indep1_p10 Mean earnings of independent students working and not enrolled 10 years after entry
    1351 mn_earn_wne_indep1_p6 Mean earnings of independent students working and not enrolled 6 years after entry
    1346 mn_earn_wne_male0_p10 Mean earnings of female students working and not enrolled 10 years after entry
    1351 mn_earn_wne_male0_p6 Mean earnings of female students working and not enrolled 6 years after entry
    1346 mn_earn_wne_male1_p10 Mean earnings of male students working and not enrolled 10 years after entry
    1351 mn_earn_wne_male1_p6 Mean earnings of male students working and not enrolled 6 years after entry
    1346 mn_earn_wne_p10 Mean earnings of students working and not enrolled 10 years after entry
    1351 mn_earn_wne_p6 Mean earnings of students working and not enrolled 6 years after entry
    1349 mn_earn_wne_p8 Mean earnings of students working and not enrolled 8 years after entry
    1361 opeid6 6-digit OPE ID for institution
    1346 pct10_earn_wne_p10 10th percentile of earnings of students working and not enrolled 10 years after entry
    1351 pct10_earn_wne_p6 10th percentile of earnings of students working and not enrolled 6 years after entry
    1349 pct10_earn_wne_p8 10th percentile of earnings of students working and not enrolled 8 years after entry
    1346 pct25_earn_wne_p10 25th percentile of earnings of students working and not enrolled 10 years after entry
    1351 pct25_earn_wne_p6 25th percentile of earnings of students working and not enrolled 6 years after entry
    1349 pct25_earn_wne_p8 25th percentile of earnings of students working and not enrolled 8 years after entry
    1346 pct75_earn_wne_p10 75th percentile of earnings of students working and not enrolled 10 years after entry
    1351 pct75_earn_wne_p6 75th percentile of earnings of students working and not enrolled 6 years after entry
    1349 pct75_earn_wne_p8 75th percentile of earnings of students working and not enrolled 8 years after entry
    1346 pct90_earn_wne_p10 90th percentile of earnings of students working and not enrolled 10 years after entry
    1351 pct90_earn_wne_p6 90th percentile of earnings of students working and not enrolled 6 years after entry
    1349 pct90_earn_wne_p8 90th percentile of earnings of students working and not enrolled 8 years after entry
    1260 poolyrs Years used for rolling averages of completion rate C150_[4/L4]_POOLED
    1217 poolyrs200 None
    1361 region Region (IPEDS)
    1361 sch_deg Predominant degree awarded (recoded 0s and 4s)
    1346 sd_earn_wne_p10 Standard deviation of earnings of students working and not enrolled 10 years after entry
    1351 sd_earn_wne_p6 Standard deviation of earnings of students working and not enrolled 6 years after entry
    1349 sd_earn_wne_p8 Standard deviation of earnings of students working and not enrolled 8 years after entry
    1361 st_fips FIPS code for state
    


```python
trim_3.shape

```




    (1361, 1615)



### Categorize the remaining variables


```python


## Variable categories:

#### General
Special_mission = ["AANAPII", "ANNHI", "HBCU", "HSI", "MENONLY", "NANTI", "PBI", "TRIBAL", "WOMENONLY"]
print "Special_mission: ", Special_mission

Carnegie_info = ["CCBASIC", "CCSIZSET", "CCUGPROF"]
print "\nCarnegie classification:", Carnegie_info
School_info = ["CONTROL", "HIGHDEG", "PREDEG"]
print "\nSchool_info:",School_info
Dependence = [name for name in trim_3.columns if name[0:6] in ["DEP_ST", ]]
print "\nDepencence", Dependence
Location = ["CITY", "LATTITUDE", "LONGITUDE", "LOCALE", "STABBR", "region"]
print "\nLocation", Location
# Student composition
Parent_ed = [name for name in trim_3.columns if name[0:6] in ["PAR_ED", ]]
Older_students = [name for name in trim_3.columns if name[0:4] == "UG25"]

Program_vars = [name for name in trim_3.columns if name[0:3] == "CIP"]
Program_percent = [name for name in trim_3.columns if name[0:4] in ["PCIP", ]]

Full_vs_part = [name for name in trim_3.columns if name[0:3] in ["PFT","PPT" ]]

Test_scores = [name for name in trim_3.columns if name[0:3] in ["ACT", "SAT"]]
print "Test scores: ", Test_scores


###### Academic trajectory
Undergraduate_enrollment = [name for name in trim_3.columns if name[0:4] == "UDGS"]
# conditioned on race
Admissions_rate = [name for name in trim_3.columns if name[0:3] == "ADM"]
print "Admissions: ", Admissions_rate
Still_enrolled = [name for name in trim_3.columns if "ENRL_ORIG" in name]
# conditioned on Dependent, gender, firstgen, income level, loan received, pell received
Transfer_rate = [name for name in trim_3.columns if "TRANS_" in name]
# Conditioned on dependent, gender
Unknown_status = [name for name in trim_3.columns if "UNKN_ORIG" in name]
# Conditioned on dependent, gender
Withdrawn = [name for name in trim_3.columns if "WDRAW_ORIG" in name]
Retention_rate = [name for name in trim_3.columns if name[0:3] == "RET"]

Completion_rate = [name for name in trim_3.columns if (
        name[0:4] in ["C150", "C200", "D150", "D200"]) or (
        "COMP_ORIG" in name) or (("_YR" in name) and ("_N" in name))]
print "Completion: ", Completion_rate
# C150 Conditioned on race. gender, and dependent status and pooled for 2 yr rolling avg
    # Races: American Indian/Alaska Native, Asian, black, Hispanic, unknown, white
# Need to merge the C150_4 variables and the C150_L4 variables


#### Financial impact
Cost = [name for name in trim_3.columns if name[0:4] in ["COST", "TUIT"]]
Avg_Price = [name for name in trim_3.columns if (name[0:3] == "NPT") and (name not in ["NPT4_PRIV","NPT4_PUB"])]
Title_4 = [name for name in trim_3.columns if ((name[0:3] == "NUM") and name != "NUMBRANCH") or (name in ["NPT4_PRIV","NPT4_PUB"])]
# Split public/private and conditioned on income    
Debt = ([name for name in trim_3.columns if name[0:4] in ["CUML", "DEBT"]] +
        [name for name in trim_3.columns if name[0:9] in ["GRAD_DEBT"]])
# DEBT conditioned on dependent, gender
Income = [name for name in trim_3.columns if "_INC_" in name]
# conditioned on Dependent
Death = [name for name in trim_3.columns if "DEATH" in name]
# conditioned on Dependent, gender
Repayment_rate = [name for name in trim_3.columns if ("RPY_" in name) or (name[0:5] == "REPAY")]
# conditioned on Dependent, gender, completion
print "Repayment: ", Repayment_rate
Default_rate = ["CDR2", "CDR3"]
Employment_status = [name for name in trim_3.columns if name[0:5] == "count"]
Earnings = [name for name in trim_3.columns if name[0:3] in ["gt", "md", "mn", "pct", "sd"]]
            
###### Financial Aid
FAFSA_applications = [name for name in trim_3.columns if name[0:4] == "APPL"]
print "FAFSA_applications: ", FAFSA_applications

Aided_percentiles = [name for name in trim_3.columns if name[0:3] in ["INC", "PCT"]]
print "Aided_percentiles: ", Aided_percentiles


```

    Special_mission:  ['AANAPII', 'ANNHI', 'HBCU', 'HSI', 'MENONLY', 'NANTI', 'PBI', 'TRIBAL', 'WOMENONLY']
    
    Carnegie classification: ['CCBASIC', 'CCSIZSET', 'CCUGPROF']
    
    School_info: ['CONTROL', 'HIGHDEG', 'PREDEG']
    
    Depencence ['DEP_STAT_PCT_IND', 'DEP_STAT_N']
    
    Location ['CITY', 'LATTITUDE', 'LONGITUDE', 'LOCALE', 'STABBR', 'region']
    Test scores:  ['SATVR25', 'SATVR75', 'SATMT25', 'SATMT75', 'SATVRMID', 'SATMTMID', 'ACTCM25', 'ACTCM75', 'ACTEN25', 'ACTEN75', 'ACTMT25', 'ACTMT75', 'ACTCMMID', 'ACTENMID', 'ACTMTMID', 'SAT_AVG', 'SAT_AVG_ALL']
    Admissions:  ['ADM_RATE', 'ADM_RATE_ALL']
    Completion:  ['C150_4', 'C150_L4', 'C150_4_POOLED', 'C150_L4_POOLED', 'D150_4', 'D150_L4', 'D150_4_POOLED', 'D150_L4_POOLED', 'C150_4_WHITE', 'C150_4_BLACK', 'C150_4_HISP', 'C150_4_ASIAN', 'C150_4_AIAN', 'C150_4_NRA', 'C150_4_UNKN', 'C150_L4_WHITE', 'C150_L4_BLACK', 'C150_L4_HISP', 'C150_L4_ASIAN', 'C150_L4_AIAN', 'C150_L4_UNKN', 'C200_4', 'C200_L4', 'D200_4', 'D200_L4', 'C200_4_POOLED', 'C200_L4_POOLED', 'D200_4_POOLED', 'D200_L4_POOLED', 'COMP_ORIG_YR2_RT', 'LO_INC_COMP_ORIG_YR2_RT', 'MD_INC_COMP_ORIG_YR2_RT', 'HI_INC_COMP_ORIG_YR2_RT', 'DEP_COMP_ORIG_YR2_RT', 'IND_COMP_ORIG_YR2_RT', 'FEMALE_COMP_ORIG_YR2_RT', 'MALE_COMP_ORIG_YR2_RT', 'PELL_COMP_ORIG_YR2_RT', 'NOPELL_COMP_ORIG_YR2_RT', 'LOAN_COMP_ORIG_YR2_RT', 'NOLOAN_COMP_ORIG_YR2_RT', 'FIRSTGEN_COMP_ORIG_YR2_RT', 'NOT1STGEN_COMP_ORIG_YR2_RT', 'COMP_ORIG_YR3_RT', 'LO_INC_COMP_ORIG_YR3_RT', 'MD_INC_COMP_ORIG_YR3_RT', 'HI_INC_COMP_ORIG_YR3_RT', 'DEP_COMP_ORIG_YR3_RT', 'IND_COMP_ORIG_YR3_RT', 'FEMALE_COMP_ORIG_YR3_RT', 'MALE_COMP_ORIG_YR3_RT', 'PELL_COMP_ORIG_YR3_RT', 'NOPELL_COMP_ORIG_YR3_RT', 'LOAN_COMP_ORIG_YR3_RT', 'NOLOAN_COMP_ORIG_YR3_RT', 'FIRSTGEN_COMP_ORIG_YR3_RT', 'NOT1STGEN_COMP_ORIG_YR3_RT', 'COMP_ORIG_YR4_RT', 'LO_INC_COMP_ORIG_YR4_RT', 'MD_INC_COMP_ORIG_YR4_RT', 'HI_INC_COMP_ORIG_YR4_RT', 'DEP_COMP_ORIG_YR4_RT', 'IND_COMP_ORIG_YR4_RT', 'FEMALE_COMP_ORIG_YR4_RT', 'MALE_COMP_ORIG_YR4_RT', 'PELL_COMP_ORIG_YR4_RT', 'NOPELL_COMP_ORIG_YR4_RT', 'LOAN_COMP_ORIG_YR4_RT', 'NOLOAN_COMP_ORIG_YR4_RT', 'FIRSTGEN_COMP_ORIG_YR4_RT', 'NOT1STGEN_COMP_ORIG_YR4_RT', 'COMP_ORIG_YR6_RT', 'LO_INC_COMP_ORIG_YR6_RT', 'MD_INC_COMP_ORIG_YR6_RT', 'HI_INC_COMP_ORIG_YR6_RT', 'DEP_COMP_ORIG_YR6_RT', 'IND_COMP_ORIG_YR6_RT', 'FEMALE_COMP_ORIG_YR6_RT', 'MALE_COMP_ORIG_YR6_RT', 'PELL_COMP_ORIG_YR6_RT', 'NOPELL_COMP_ORIG_YR6_RT', 'LOAN_COMP_ORIG_YR6_RT', 'NOLOAN_COMP_ORIG_YR6_RT', 'FIRSTGEN_COMP_ORIG_YR6_RT', 'NOT1STGEN_COMP_ORIG_YR6_RT', 'COMP_ORIG_YR8_RT', 'LO_INC_COMP_ORIG_YR8_RT', 'MD_INC_COMP_ORIG_YR8_RT', 'HI_INC_COMP_ORIG_YR8_RT', 'DEP_COMP_ORIG_YR8_RT', 'IND_COMP_ORIG_YR8_RT', 'FEMALE_COMP_ORIG_YR8_RT', 'MALE_COMP_ORIG_YR8_RT', 'PELL_COMP_ORIG_YR8_RT', 'NOPELL_COMP_ORIG_YR8_RT', 'LOAN_COMP_ORIG_YR8_RT', 'NOLOAN_COMP_ORIG_YR8_RT', 'FIRSTGEN_COMP_ORIG_YR8_RT', 'NOT1STGEN_COMP_ORIG_YR8_RT', 'OVERALL_YR2_N', 'LO_INC_YR2_N', 'MD_INC_YR2_N', 'HI_INC_YR2_N', 'DEP_YR2_N', 'IND_YR2_N', 'FEMALE_YR2_N', 'MALE_YR2_N', 'PELL_YR2_N', 'NOPELL_YR2_N', 'LOAN_YR2_N', 'NOLOAN_YR2_N', 'FIRSTGEN_YR2_N', 'NOT1STGEN_YR2_N', 'OVERALL_YR3_N', 'LO_INC_YR3_N', 'MD_INC_YR3_N', 'HI_INC_YR3_N', 'DEP_YR3_N', 'IND_YR3_N', 'FEMALE_YR3_N', 'MALE_YR3_N', 'PELL_YR3_N', 'NOPELL_YR3_N', 'LOAN_YR3_N', 'NOLOAN_YR3_N', 'FIRSTGEN_YR3_N', 'NOT1STGEN_YR3_N', 'OVERALL_YR4_N', 'LO_INC_YR4_N', 'MD_INC_YR4_N', 'HI_INC_YR4_N', 'DEP_YR4_N', 'IND_YR4_N', 'FEMALE_YR4_N', 'MALE_YR4_N', 'PELL_YR4_N', 'NOPELL_YR4_N', 'LOAN_YR4_N', 'NOLOAN_YR4_N', 'FIRSTGEN_YR4_N', 'NOT1STGEN_YR4_N', 'OVERALL_YR6_N', 'LO_INC_YR6_N', 'MD_INC_YR6_N', 'HI_INC_YR6_N', 'DEP_YR6_N', 'IND_YR6_N', 'FEMALE_YR6_N', 'MALE_YR6_N', 'PELL_YR6_N', 'NOPELL_YR6_N', 'LOAN_YR6_N', 'NOLOAN_YR6_N', 'FIRSTGEN_YR6_N', 'NOT1STGEN_YR6_N', 'OVERALL_YR8_N', 'LO_INC_YR8_N', 'MD_INC_YR8_N', 'HI_INC_YR8_N', 'DEP_YR8_N', 'IND_YR8_N', 'FEMALE_YR8_N', 'MALE_YR8_N', 'PELL_YR8_N', 'NOPELL_YR8_N', 'LOAN_YR8_N', 'NOLOAN_YR8_N', 'FIRSTGEN_YR8_N', 'NOT1STGEN_YR8_N', 'C150_L4_POOLED_SUPP', 'C150_4_POOLED_SUPP', 'C200_L4_POOLED_SUPP', 'C200_4_POOLED_SUPP']
    Repayment:  ['RPY_1YR_RT', 'COMPL_RPY_1YR_RT', 'NONCOM_RPY_1YR_RT', 'LO_INC_RPY_1YR_RT', 'MD_INC_RPY_1YR_RT', 'HI_INC_RPY_1YR_RT', 'DEP_RPY_1YR_RT', 'IND_RPY_1YR_RT', 'PELL_RPY_1YR_RT', 'NOPELL_RPY_1YR_RT', 'FEMALE_RPY_1YR_RT', 'MALE_RPY_1YR_RT', 'FIRSTGEN_RPY_1YR_RT', 'NOTFIRSTGEN_RPY_1YR_RT', 'RPY_3YR_RT', 'COMPL_RPY_3YR_RT', 'NONCOM_RPY_3YR_RT', 'LO_INC_RPY_3YR_RT', 'MD_INC_RPY_3YR_RT', 'HI_INC_RPY_3YR_RT', 'DEP_RPY_3YR_RT', 'IND_RPY_3YR_RT', 'PELL_RPY_3YR_RT', 'NOPELL_RPY_3YR_RT', 'FEMALE_RPY_3YR_RT', 'MALE_RPY_3YR_RT', 'FIRSTGEN_RPY_3YR_RT', 'NOTFIRSTGEN_RPY_3YR_RT', 'RPY_5YR_RT', 'COMPL_RPY_5YR_RT', 'NONCOM_RPY_5YR_RT', 'LO_INC_RPY_5YR_RT', 'MD_INC_RPY_5YR_RT', 'HI_INC_RPY_5YR_RT', 'DEP_RPY_5YR_RT', 'IND_RPY_5YR_RT', 'PELL_RPY_5YR_RT', 'NOPELL_RPY_5YR_RT', 'FEMALE_RPY_5YR_RT', 'MALE_RPY_5YR_RT', 'FIRSTGEN_RPY_5YR_RT', 'NOTFIRSTGEN_RPY_5YR_RT', 'RPY_7YR_RT', 'COMPL_RPY_7YR_RT', 'NONCOM_RPY_7YR_RT', 'LO_INC_RPY_7YR_RT', 'MD_INC_RPY_7YR_RT', 'HI_INC_RPY_7YR_RT', 'DEP_RPY_7YR_RT', 'IND_RPY_7YR_RT', 'PELL_RPY_7YR_RT', 'NOPELL_RPY_7YR_RT', 'FEMALE_RPY_7YR_RT', 'MALE_RPY_7YR_RT', 'FIRSTGEN_RPY_7YR_RT', 'NOTFIRSTGEN_RPY_7YR_RT', 'REPAY_DT_MDN', 'REPAY_DT_N', 'RPY_1YR_N', 'COMPL_RPY_1YR_N', 'NONCOM_RPY_1YR_N', 'LO_INC_RPY_1YR_N', 'MD_INC_RPY_1YR_N', 'HI_INC_RPY_1YR_N', 'DEP_RPY_1YR_N', 'IND_RPY_1YR_N', 'PELL_RPY_1YR_N', 'NOPELL_RPY_1YR_N', 'FEMALE_RPY_1YR_N', 'MALE_RPY_1YR_N', 'FIRSTGEN_RPY_1YR_N', 'NOTFIRSTGEN_RPY_1YR_N', 'RPY_3YR_N', 'COMPL_RPY_3YR_N', 'NONCOM_RPY_3YR_N', 'LO_INC_RPY_3YR_N', 'MD_INC_RPY_3YR_N', 'HI_INC_RPY_3YR_N', 'DEP_RPY_3YR_N', 'IND_RPY_3YR_N', 'PELL_RPY_3YR_N', 'NOPELL_RPY_3YR_N', 'FEMALE_RPY_3YR_N', 'MALE_RPY_3YR_N', 'FIRSTGEN_RPY_3YR_N', 'NOTFIRSTGEN_RPY_3YR_N', 'RPY_5YR_N', 'COMPL_RPY_5YR_N', 'NONCOM_RPY_5YR_N', 'LO_INC_RPY_5YR_N', 'MD_INC_RPY_5YR_N', 'HI_INC_RPY_5YR_N', 'DEP_RPY_5YR_N', 'IND_RPY_5YR_N', 'PELL_RPY_5YR_N', 'NOPELL_RPY_5YR_N', 'FEMALE_RPY_5YR_N', 'MALE_RPY_5YR_N', 'FIRSTGEN_RPY_5YR_N', 'NOTFIRSTGEN_RPY_5YR_N', 'RPY_7YR_N', 'COMPL_RPY_7YR_N', 'NONCOM_RPY_7YR_N', 'LO_INC_RPY_7YR_N', 'MD_INC_RPY_7YR_N', 'HI_INC_RPY_7YR_N', 'DEP_RPY_7YR_N', 'IND_RPY_7YR_N', 'PELL_RPY_7YR_N', 'NOPELL_RPY_7YR_N', 'FEMALE_RPY_7YR_N', 'MALE_RPY_7YR_N', 'FIRSTGEN_RPY_7YR_N', 'NOTFIRSTGEN_RPY_7YR_N', 'RPY_3YR_RT_SUPP', 'LO_INC_RPY_3YR_RT_SUPP', 'MD_INC_RPY_3YR_RT_SUPP', 'HI_INC_RPY_3YR_RT_SUPP', 'COMPL_RPY_3YR_RT_SUPP', 'NONCOM_RPY_3YR_RT_SUPP', 'DEP_RPY_3YR_RT_SUPP', 'IND_RPY_3YR_RT_SUPP', 'PELL_RPY_3YR_RT_SUPP', 'NOPELL_RPY_3YR_RT_SUPP', 'FEMALE_RPY_3YR_RT_SUPP', 'MALE_RPY_3YR_RT_SUPP', 'FIRSTGEN_RPY_3YR_RT_SUPP', 'NOTFIRSTGEN_RPY_3YR_RT_SUPP']
    FAFSA_applications:  ['APPL_SCH_PCT_GE2', 'APPL_SCH_PCT_GE3', 'APPL_SCH_PCT_GE4', 'APPL_SCH_PCT_GE5', 'APPL_SCH_N']
    Aided_percentiles:  ['PCTPELL', 'PCTFLOAN', 'INC_PCT_LO', 'INC_PCT_M1', 'INC_PCT_M2', 'INC_PCT_H1', 'INC_PCT_H2', 'INC_N']
    


```python
# Program names
Program_vars = [name for name in trim_3.columns if name[0:3] == "CIP"]
Program_names = []
for var in Program_vars:
    program = map_variables[var].split(" in ")[1].strip()
    Program_names.append((program, var[3:5]))
Program_names = sorted(list(set(Program_names)), key = lambda x: x[1])
print len(Program_names)
for program_tuple in Program_names:
    print program_tuple
```

    38
    ('Agriculture, Agriculture Operations, And Related Sciences.', '01')
    ('Natural Resources And Conservation.', '03')
    ('Architecture And Related Services.', '04')
    ('Area, Ethnic, Cultural, Gender, And Group Studies.', '05')
    ('Communication, Journalism, And Related Programs.', '09')
    ('Communications Technologies/Technicians And Support Services.', '10')
    ('Computer And Information Sciences And Support Services.', '11')
    ('Personal And Culinary Services.', '12')
    ('Education.', '13')
    ('Engineering.', '14')
    ('Engineering Technologies And Engineering-Related Fields.', '15')
    ('Foreign Languages, Literatures, And Linguistics.', '16')
    ('Family And Consumer Sciences/Human Sciences.', '19')
    ('Legal Professions And Studies.', '22')
    ('English Language And Literature/Letters.', '23')
    ('Liberal Arts And Sciences, General Studies And Humanities.', '24')
    ('Library Science.', '25')
    ('Biological And Biomedical Sciences.', '26')
    ('Mathematics And Statistics.', '27')
    ('Military Technologies And Applied Sciences.', '29')
    ('Multi/Interdisciplinary Studies.', '30')
    ('Parks, Recreation, Leisure, And Fitness Studies.', '31')
    ('Philosophy And Religious Studies.', '38')
    ('Theology And Religious Vocations.', '39')
    ('Physical Sciences.', '40')
    ('Science Technologies/Technicians.', '41')
    ('Psychology.', '42')
    ('Homeland Security, Law Enforcement, Firefighting And Related Protective Services.', '43')
    ('Public Administration And Social Service Professions.', '44')
    ('Social Sciences.', '45')
    ('Construction Trades.', '46')
    ('Mechanic And Repair Technologies/Technicians.', '47')
    ('Precision Production.', '48')
    ('Transportation And Materials Moving.', '49')
    ('Visual And Performing Arts.', '50')
    ('Health Professions And Related Programs.', '51')
    ('Business, Management, Marketing, And Related Support Services.', '52')
    ('History.', '54')
    

## Data clean-up steps
- Need to merge the C150_4 variables and the C150_L4 variables

- merge the columns that express values separately for public and private schools





```python
public = [name for name in trim_3.columns if "_PUB" in name]
print public
private = [name for name in trim_3.columns if "_PRIV" in name]
print private
```

    ['NPT4_PUB', 'NPT41_PUB', 'NPT42_PUB', 'NPT43_PUB', 'NPT44_PUB', 'NPT45_PUB', 'NPT4_048_PUB', 'NPT4_3075_PUB', 'NPT4_75UP_PUB', 'NUM4_PUB', 'NUM41_PUB', 'NUM42_PUB', 'NUM43_PUB', 'NUM44_PUB', 'NUM45_PUB']
    ['NPT4_PRIV', 'NPT41_PRIV', 'NPT42_PRIV', 'NPT43_PRIV', 'NPT44_PRIV', 'NPT45_PRIV', 'NPT4_048_PRIV', 'NPT4_3075_PRIV', 'NPT4_75UP_PRIV', 'NUM4_PRIV', 'NUM41_PRIV', 'NUM42_PRIV', 'NUM43_PRIV', 'NUM44_PRIV', 'NUM45_PRIV']
    


```python
# Merge columns
print trim_3.shape
for pub_name in public:
    print pub_name[:-3], map_variables[pub_name]
    priv_name = pub_name[:-3] + "PRIV"
    combined = pub_name[:-3] + "COMB"
    print "   Public", trim_3[pub_name].count()
    print "   Private", trim_3[priv_name].count()
    trim_3.loc[:,combined] = trim_3[pub_name].add(trim_3[priv_name] , fill_value = 0)
    print "   Combined:", trim_3[combined].count()
    map_variables[combined] = "Average net price for Title IV institutions"
    
```

    (1361, 1630)
    NPT4_ Average net price for Title IV institutions (public institutions)
       Public 516
       Private 841
       Combined: 1357
    NPT41_ Average net price for $0-$30,000 family income (public institutions)
       Public 516
       Private 836
       Combined: 1352
    NPT42_ Average net price for $30,001-$48,000 family income (public institutions)
       Public 514
       Private 831
       Combined: 1345
    NPT43_ Average net price for $48,001-$75,000 family income (public institutions)
       Public 513
       Private 828
       Combined: 1341
    NPT44_ Average net price for $75,001-$110,000 family income (public institutions)
       Public 508
       Private 817
       Combined: 1325
    NPT45_ Average net price for $110,000+ family income (public institutions)
       Public 485
       Private 793
       Combined: 1278
    NPT4_048_ Average net price for $0-$48,000 family income (public institutions)
       Public 516
       Private 838
       Combined: 1354
    NPT4_3075_ Average net price for $30,001-$75,000 family income (public institutions)
       Public 516
       Private 837
       Combined: 1353
    NPT4_75UP_ Average net price for $75,000+ family income (public institutions)
       Public 508
       Private 821
       Combined: 1329
    NUM4_ Number of Title IV students (public institutions)
       Public 518
       Private 842
       Combined: 1360
    NUM41_ Number of Title IV students, $0-$30,000 family income (public institutions)
       Public 517
       Private 841
       Combined: 1358
    NUM42_ Number of Title IV students, $30,001-$48,000 family income (public institutions)
       Public 517
       Private 841
       Combined: 1358
    NUM43_ Number of Title IV students, $48,001-$75,000 family income (public institutions)
       Public 517
       Private 841
       Combined: 1358
    NUM44_ Number of Title IV students, $75,001-$110,000 family income (public institutions)
       Public 517
       Private 841
       Combined: 1358
    NUM45_ Number of Title IV students, $110,000+ family income (public institutions)
       Public 517
       Private 841
       Combined: 1358
    


```python
trim_4 = trim_3.drop(public + private, axis = 1)
```


```python
trim_4.shape
```




    (1361, 1600)




```python
trim_4.head()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>UNITID</th>
      <th>OPEID</th>
      <th>opeid6</th>
      <th>INSTNM</th>
      <th>CITY</th>
      <th>STABBR</th>
      <th>ZIP</th>
      <th>sch_deg</th>
      <th>main</th>
      <th>NUMBRANCH</th>
      <th>...</th>
      <th>NPT45_COMB</th>
      <th>NPT4_048_COMB</th>
      <th>NPT4_3075_COMB</th>
      <th>NPT4_75UP_COMB</th>
      <th>NUM4_COMB</th>
      <th>NUM41_COMB</th>
      <th>NUM42_COMB</th>
      <th>NUM43_COMB</th>
      <th>NUM44_COMB</th>
      <th>NUM45_COMB</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>100654</td>
      <td>100200</td>
      <td>1002</td>
      <td>Alabama A &amp; M University</td>
      <td>Normal</td>
      <td>AL</td>
      <td>35762</td>
      <td>3.0</td>
      <td>1</td>
      <td>1</td>
      <td>...</td>
      <td>13892.0</td>
      <td>7944.0</td>
      <td>9986.0</td>
      <td>12422.0</td>
      <td>644.0</td>
      <td>381.0</td>
      <td>118.0</td>
      <td>82.0</td>
      <td>41.0</td>
      <td>22.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>100663</td>
      <td>105200</td>
      <td>1052</td>
      <td>University of Alabama at Birmingham</td>
      <td>Birmingham</td>
      <td>AL</td>
      <td>35294-0110</td>
      <td>3.0</td>
      <td>1</td>
      <td>1</td>
      <td>...</td>
      <td>19440.0</td>
      <td>11547.0</td>
      <td>14760.0</td>
      <td>19339.0</td>
      <td>907.0</td>
      <td>288.0</td>
      <td>162.0</td>
      <td>177.0</td>
      <td>144.0</td>
      <td>136.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>100706</td>
      <td>105500</td>
      <td>1055</td>
      <td>University of Alabama at Huntsville</td>
      <td>Huntsville</td>
      <td>AL</td>
      <td>35899</td>
      <td>3.0</td>
      <td>1</td>
      <td>1</td>
      <td>...</td>
      <td>12551.0</td>
      <td>7397.0</td>
      <td>10517.0</td>
      <td>12219.0</td>
      <td>303.0</td>
      <td>102.0</td>
      <td>48.0</td>
      <td>53.0</td>
      <td>48.0</td>
      <td>52.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>100724</td>
      <td>100500</td>
      <td>1005</td>
      <td>Alabama State University</td>
      <td>Montgomery</td>
      <td>AL</td>
      <td>36104-0271</td>
      <td>3.0</td>
      <td>1</td>
      <td>1</td>
      <td>...</td>
      <td>9281.0</td>
      <td>5098.0</td>
      <td>6911.0</td>
      <td>9709.0</td>
      <td>639.0</td>
      <td>460.0</td>
      <td>103.0</td>
      <td>39.0</td>
      <td>26.0</td>
      <td>11.0</td>
    </tr>
    <tr>
      <th>5</th>
      <td>100751</td>
      <td>105100</td>
      <td>1051</td>
      <td>The University of Alabama</td>
      <td>Tuscaloosa</td>
      <td>AL</td>
      <td>35487-0166</td>
      <td>3.0</td>
      <td>1</td>
      <td>1</td>
      <td>...</td>
      <td>20429.0</td>
      <td>14417.0</td>
      <td>16911.0</td>
      <td>19818.0</td>
      <td>1373.0</td>
      <td>498.0</td>
      <td>247.0</td>
      <td>226.0</td>
      <td>241.0</td>
      <td>161.0</td>
    </tr>
  </tbody>
</table>
<p>5 rows × 1600 columns</p>
</div>




```python
trim_4.to_csv("Scorecard_v1.csv")
dict_file = open("Scorecard_dict.txt", "w")
for key, value in map_variables.iteritems():
    dict_file.write("%10s|%s\n" %(key, str(value).strip()))
dict_file.close()

```


```python

```
