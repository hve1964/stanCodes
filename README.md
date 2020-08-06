# stanCodes
Stan codes accompanying online lecture notes on Inductive Statistical Inference (version 2).

Sample data sets:

(i) ashenfelter.RData (Ashenfelter, Ashmore and Lalonde, http://www.liquidasset.com/) [Linear regression (fixed effects)]
    y: standardised logarithm of average vintage wine price relative to 1961 vintage [1];
    x1: standardised winter (October-March) rain [ml];
    x2: standardised average temperature April-September [°C];
    x3: standardised harvest (August and September) rain [ml];
    x4: standardised time since vintage [yr] (zero-point year: 1983)

(ii) massMonitoring.csv [ANOVA-like regression]
    y: body mass [kg];
    gp: year of observation

(iii) data set "urine" from R package boot [Logistic regression (fixed effects)]

(iv) poissonData.RData [Poisson regression]
    y: count of planes touching down inside of a 15 min observation interval [1];
    x1: standardised start of 15 min observation interval [h];
    x2: standardised estimated Beaufort wind force scale number [1];
    x3: standardised wind direction [1];
    gp: day-of-week ID: Monday (1) to Sunday (7)

(v) tramWait.RData [Exponential regression]
    y: waiting time [min] for tram to arrive at stop;
    x1: standardised number of tram conductors [1] available on tram line on day of observation;
    x2: standardised number of passengers [1] having left or entered tram at previous stops;
    gp: tram line number (1 to 10)

(vi) data set "iris" from R package datasets [Linear regression (varying effects)]

(vii) bankloan.RData [Logistic regression (varying effects)]
    y: previously defaulted {0, 1};
    x1: standardised age [yr];
    x2: standardised years with current employer [yr];
    x3: standardised years at current address [yr];
    x4: standardised household income [$ 10³];
    x5: standardised debt to income ratio [%];
    x6: standardised credit card debt [$ 10³];
    x7: standardised other debt [$ 10³]
    gp: level of education: "did not complete high school" (1), "high school degree" (2), "some college" (3), "college degree" (4), "doctorate" (5)
