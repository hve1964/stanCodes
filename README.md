# stanCodes
Stan codes accompanying online lecture notes on Inductive Statistical Inference.

Sample data sets:

(i) ashenfelter.RData (Ashenfelter, Ashmore and Lalonde, http://www.liquidasset.com/) [linear regression]
    y: standardised logarithm of average vintage wine price relative to 1961 vintage [1]
    x1: standardised winter (October-March) rain [ml]
    x2: standardised average temperature April-September [°C]
    x3: standardised harvest (August and September) rain [ml]
    x4: standardised time since vintage [yr] (zero-point year: 1983)

(ii) massMonitoring.csv [ANOVA-like regression]
    y: body mass [kg]
    gp: year of observation

(iii) data set "urine" from R package boot [logistic regression]

(iv) poissonData.RData [Poisson regression]
    y: count of planes touching down inside of a 15 min observation interval [1]
    x1: standardised start of 15 min observation interval [h]
    x2: standardised estimated Beaufort wind force scale number [1]
    x3: standardised wind direction [1]
    gp: day-of-week ID: Monday (1) to Sunday (7)
