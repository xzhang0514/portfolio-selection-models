# Introduction
  Markets evolve through various statistical regimes, sometimes calmly and sometimes agitatedly. A common approach to address this issue is GARCH models. While they can capture "volatility clustering", it fails at producing abruptly changes, especially from calm to agitated periods. 
  The Hidden Markov Model approach relies on a hidden feature, that is the parameters of a multivariate Gaussian distribution. Drifts and covariances vary through time in a purely discontinuous manner, jumping from one value to another. This structure enables HMM to reproduce jump processes.  
# Usage
  * Start a brand new kdb instance (with a database and qml loaded).
  * Load the script using: `system"l /path/to/HMM.q"`.
  * Call: `(forwardBackward[data;]/)[constraint[tol;maxIter;];iniPara]`
# Example
 * Load qml:
  `\l qml.q`
  
 * Import data:
 ```
 sprtn:select date, total_return from asset_price_usfast where date within (2018.07.06; 2020.07.06), sym in `SPY, country in `US;
 dat: log[1+sprtn`total_return];
 ```
 
 * Test case 1:
```
iniPara:xRandomInit[dat; nStates],d:`logLikelihood`counter!(iniLL;0);
(forwardBackward[dat;])/[constraint[tol;maxIter;]; iniPara]
```
 
 * Test case 2:
```
iniPara:xInitialTest[dat];
(forwardBackward[dat;])/[constraint[tol;maxIter;]; iniPara]
```

* Visualize the results:
```
sprtn,'flip`probabilityInStateA`probabilityInStateB!flip .1*-.5+res[`gamma]
```

![alt text][logo]

[logo]: https://github.com/xzhang0514/portfolio-selection-models/blob/main/Hidden-Markov-Models/results-visualization "Regime-Switching"

*Remarks:* The results capture the transition of market between calm states and agitated states very well. Calm states are characterized by low volatility vs. agitated states by high volatility.    

