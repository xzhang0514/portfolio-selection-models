# Introduction
# Usage
  * Start a brand new kdb instance (with a database and qml loaded).
  * Load the script using: `system"l /path/to/HMM.q"`.
  * Call: `(forwardBackward[data;]/)[constraint[tol;maxIter;];iniPara]`
# Example
 * Load qml
  `\l qml.q`
  
 * Import data
 ```
 sprtn:select date, total_return from asset_price_usfast where date within (2018.07.06; 2020.07.06), sym in `SPY, country in `US;
 dat: log[1+sprtn`total_return];
 ```
 
 * Test case 1
```
iniPara:xRandomInit[dat; nStates],d:`logLikelihood`counter!(iniLL;0);
(forwardBackward[dat;])/[constraint[tol;maxIter;]; iniPara]
```
 
 * Test case 2
```
iniPara:xInitialTest[dat];
(forwardBackward[dat;])/[constraint[tol;maxIter;]; iniPara]
```

