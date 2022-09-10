# stanCodes
**Stan codes** and corresponding **R scripts** accompanying the online lecture notes on Inductive Statistical Inference (version 3) at https://arxiv.org/abs/1808.10173.

**A: Fixed effects generalised linear models**

(i) *linRegNormFixed.stan* [Linear regression]: See also the Stan User's Guide (Version 2.30), Sec. 1.1, URL (cited on
August 19, 2022): https://mc-stan.org/docs/stan-users-guide/linear-regression.html.

(ii) *anovaRegNormFixed.stan* [ANOVA-like regression]:

(iii) *logistRegBernFixed.stan* [Logistic regression]: See also the Stan User's Guide (Version 2.30), Sec. 1.5, URL (cited on
August 19, 2022): https://mc-stan.org/docs/stan-users-guide/logistic-probit-regression.html.

(iv) *poisRegFixed.stan* [Poisson regression]:

(v) *expRegFixed.stan* [Exponential regression]:

**B: Varying effects generalised linear models**

(vi) *linRegNormVarying.stan* [Multi-level linear regression]:
 See also the Stan User's Guide (Version 2.30), Sec. 1.13, URL (cited on August 20,
 2022): https://mc-stan.org/docs/stan-users-guide/multivariate-hierarchical-priors.html.
 
 (vii) *anovaRegNormVarying.stan* [Multi-level ANOVA-like regression]:
 
 (viii) *logistRegBernVarying.stan* [Multi-level logistic regression]: See also the Stan User's Guide (Version 2.30), Secs. 1.9 and 1.13, URLs (cited
on August 21, 2022): https://mc-stan.org/docs/stan-users-guide/hierarchical-logistic-regression.html,
https://mc-stan.org/docs/stan-users-guide/multivariate-hierarchical-priors.html.

(ix) *poisRegVarying.stan* [Multi-level Poisson regression]:

(x): *expRegVarying.stan* [Multi-level exponential regression]

**C: Time series analysis**

(xi) *AR_p_NormFixed.stan* [Stationary linear AR(p)-model (fixed effects)]: See also the Stan User's Guide (Version 2.30), Sec. 2.1, URL (cited on
August 27, 2022): https://mc-stan.org/docs/stan-users-guide/autoregressive.html, and
Ali (2017), URL (cited on August 27, 2022): https://imadali.net/projects/bsss/rstan/generated-quantities/.

(xii) *GARCH_1_1_NormFixed.stan* [Stationary linear GARCH(1,1)-model(fixed effects)]: See also the Stan User's Guide (Version 2.30), Sec. 2.2, URL (cited on
August 22, 2022): https://mc-stan.org/docs/stan-users-guide/modeling-temporal-heteroscedasticity.html.

**D: Sample data sets**

(i) ashenfelter.RData (Ashenfelter, Ashmore and Lalonde, http://www.liquidasset.com/) [Linear regression (fixed effects)]:
    y: standardised logarithm of average vintage wine price relative to 1961 vintage [1];
    x1: standardised winter (October-March) rain [ml];
    x2: standardised average temperature April-September [°C];
    x3: standardised harvest (August and September) rain [ml];
    x4: standardised time since vintage [yr] (zero-point year: 1983)

(ii) massMonitoring.csv [ANOVA-like regression]:
    y: body mass [kg];
    gp: year of observation

(iii) data set "urine" from R package boot [Logistic regression (fixed effects)]:

(iv) poissonData.RData [Poisson regression]:
    y: count of planes touching down inside of a 15 min observation interval [1];
    x1: standardised start of 15 min observation interval [h];
    x2: standardised estimated Beaufort wind force scale number [1];
    x3: standardised wind direction [1];
    gp: day-of-week ID: Monday (1) to Sunday (7)

(v) tramWait.RData [Exponential regression]:
    y: waiting time [min] for tram to arrive at stop;
    x1: standardised number of tram conductors [1] available on tram line on day of observation;
    x2: standardised number of passengers [1] having left or entered tram at previous stops;
    gp: tram line number (1 to 10)

(vi) data set "iris" from R package datasets [Linear regression (varying effects)]:

(vii) bankloan.RData (IBM SPSS tutorial binary logistic regression, https://www.ibm.com/support/knowledgecenter/en/SSLVMB_sub/statistics_casestudies_project_ddita/spss/tutorials/log_bankloan_intro.html) [Logistic regression (varying effects)]:
    y: previously defaulted {0, 1};
    x1: standardised age [yr];
    x2: standardised years with current employer [yr];
    x3: standardised years at current address [yr];
    x4: standardised household income [$ 10³];
    x5: standardised debt to income ratio [%];
    x6: standardised credit card debt [$ 10³];
    x7: standardised other debt [$ 10³];
    gp: level of education: "did not complete high school" (1), "high school degree" (2), "some college" (3), "college degree" (4), "doctorate" (5)

(viii) USGDPpc.RData (raw USGDP data from the Federal Reserve of St. Louis website, URL: https://fred.stlouisfed.org/series/GDPC1#0) [Stationary linear AR(p)-model (fixed effects)]:
    y: quarterly percentage change of USGDP [%]

(ix) massChangeData.RData [Stationary linear GARCH(1,1)-model (fixed effects)]:
    y: mass change between two successive measurements [kg]
