

```python
import libpgm
import os
import pandas as pd
print os.getcwd()
print os.listdir("./")
```

    C:\Users\Marissa\Documents\Portfolio\Education project
    ['.ipynb_checkpoints', 'adm2014.csv', 'CollegeScorecardDataDictionary-09-08-2015.csv', 'CollegeScorecard_Raw_Data (2)', 'CollegeScorecard_Raw_Data (2).zip', 'data-sources', 'exploring_scorecard_data.md', 'First libpgm.ipynb', 'firstgraph.txt', 'g20145ak.txt', 'Integrated_Postsecondary_Education_Data_System_20132014.csv', 'merged_2011_PP.csv', 'merged_2012_PP.csv', 'merged_2013_PP.csv', 'Objective Hypothesis.docx', 'Scorecard_dict.csv', 'Scorecard_dict.txt', 'Scorecard_v1.csv', 'Second pgm.ipynb', 'US Zip Codes from 2013 Government Data']
    


```python
## Get clean data
map_variables = {}
clean = pd.read_csv("Scorecard_v1.csv")
dict_file = open("Scorecard_dict.txt", "r")
for line in dict_file:
    test = line.split("|")
    try:
        map_variables[test[0]] = test[1]
    except:
        print test
dict_file.close()

```

    ['0        Non-degree-granting\n']
    ['1        Certificate degree\n']
    ['2        Associate degree\n']
    ["3        Bachelor's degree\n"]
    ['4        Graduate degree\n']
    ['0        Not classified\n']
    ['1        Predominantly certificate-degree granting\n']
    ["2        Predominantly associate's-degree granting\n"]
    ["3        Predominantly bachelor's-degree granting\n"]
    ['4        Entirely graduate-degree granting\n']
    


```python
## Choose university as the first row of clean data

data = clean.ix[1,]
print "Name:", data["INSTNM"]
print "Admissions:", data["ADM_RATE"]
for var in sorted(data.index):
    if "SAT" in var:
        print var, data[var.strip()]
    if "ACT" in var:
        print var, data[var.strip()]
```

    Name: University of Alabama at Birmingham
    Admissions: 0.7223
    ACTCM25 21.0
    ACTCM75 27.0
    ACTCMMID 24.0
    ACTEN25 21.0
    ACTEN75 28.0
    ACTENMID 25.0
    ACTMT25 20.0
    ACTMT75 26.0
    ACTMTMID 23.0
    SATMT25 500.0
    SATMT75 640.0
    SATMTMID 570.0
    SATVR25 500.0
    SATVR75 630.0
    SATVRMID 565.0
    SAT_AVG 1107.0
    SAT_AVG_ALL 1107.0
    


```python
## Read in SAT distributions
SAT = pd.read_csv("data-sources/SAT_scores.csv")
```


```python
## Calculate conditional probabilities
# Split into quantiles - "A", "B", "C", "D"
P = {}
P["quant | admit"] = 0.25
P["admit"] = data["ADM_RATE"]
d_cut = data["SATMT25"] + data["SATVR25"]
c_cut = data["SATMTMID"] + data["SATVRMID"]
b_cut = data["SATMT75"] + data["SATVR75"]

def find_percentile(cutoff, dataframe, scores_column = "New SAT Score", percentiles_column = "Percentile"):
    min_val = min(abs(dataframe[scores_column] - cutoff))
    temp = dataframe[abs((dataframe[scores_column] - cutoff)) <= min_b][percentiles_column]
    if(len(temp) == 1):    
        P = float(temp)/100
    else:
        P = float(sum(temp)/2.0)/100
    return P


P["D"] = find_percentile(d_cut, SAT)
print "D", P["D"]

P["C"] = find_percentile(c_cut, SAT) - P["D"]
print "C", P["C"]

P["B"] = find_percentile(b_cut, SAT)   - P["D"] - P["C"]
print "B", P["B"]
P["A"] = 1.0 - P["B"] - P["C"] - P["D"]
print "A", P["A"]
```

    D 0.521009
    C 0.213985
    B 0.150654
    A 0.114352
    


```python
## Apply Bayes rule

P["admit|A"] = min(P["quant | admit"] * P["admit"] / P["A"], 0.999)
print "admit | A = ", P["admit|A"]
P["admit|B"] = min(P["quant | admit"] * P["admit"] / P["B"], 0.999)
print "admit | B = ", P["admit|B"]
P["admit|C"] = min(P["quant | admit"] * P["admit"] / P["C"], 0.999)
print "admit | C = ", P["admit|C"]
P["admit|D"] = min(P["quant | admit"] * P["admit"] / P["D"], 0.999)
print "admit | D = ", P["admit|D"]
```

    admit | A =  0.999
    admit | B =  0.999
    admit | C =  0.84386756081
    admit | D =  0.346587103102
    


```python

```


```python

from libpgm.nodedata import NodeData
from libpgm.graphskeleton import GraphSkeleton
from libpgm.discretebayesiannetwork import DiscreteBayesianNetwork

rate = 0.5
filename = "firstgraph.txt"



myfile = open(filename, "w")
ftext = '''{
	"V": ["SAT_quant", "Admitted"],
	"E": [["SAT_quant", "Admitted"]],
	"Vdata": {
		"Admitted": {
			"ord": 1,
			"numoutcomes": 2,
			"vals": ["yes", "no"],
			"parents": ["SAT_quant"],
			"children": None,
			"cprob": {
				"['A']": [''' + str(P["admit|A"]) + "," + str(1.0 - P["admit|A"]) + '''],
				"['B']": ['''  + str(P["admit|B"]) + "," +str(1.0 - P["admit|B"]) + '''],
				"['C']": [''' + str(P["admit|C"]) + "," + str(1.0 - P["admit|C"]) + '''],
				"['D']": [''' + str(P["admit|D"]) + "," +str(1.0 - P["admit|D"]) + ''']
			}
		},
		"SAT_quant": {
			"ord": 0,
			"numoutcomes": 4,
			"vals": ["A", "B", "C", "D"],
			"parents": None,
			"children": ["Admitted"],
			"cprob":  [''' + str(P["A"]) +"," + str(P["B"])  +"," + str(P["C"])  +"," + str(P["D"]) + ''']
		}
    }
}'''
ftext = ftext.replace('\t\n ', '')
ftext = ftext.replace(':', ': ')
ftext = ftext.replace(',', ', ')
ftext = ftext.replace('None', 'null')

# load nodedata and graphskeleton
nd = NodeData()
skel = GraphSkeleton()

myfile.write(ftext)
myfile.close()


nd.load(filename)
skel.load(filename)

# topologically order graphskeleton
skel.toporder()
print skel.E
print skel.V
# load bayesian network
bn = DiscreteBayesianNetwork(skel, nd)

# sample 
result = bn.randomsample(10000)

#print result
df = pd.DataFrame.from_dict(result)
print df[df["Admitted"] == "yes"].count()
print ""
print df.pivot_table(index = ["Admitted"], columns = ["SAT_quant"], aggfunc = len)
```

    [[u'SAT_quant', u'Admitted']]
    [u'SAT_quant', u'Admitted']
    Admitted     6244
    SAT_quant    6244
    dtype: int64
    
    SAT_quant       A       B       C       D
    Admitted                                 
    no            NaN     2.0   354.0  3400.0
    yes        1108.0  1491.0  1829.0  1816.0
    


```python

```
