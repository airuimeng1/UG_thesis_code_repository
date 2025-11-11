

/////Principal Component Analysis (PCA) code, calculating the development level of the digital economy
////The original belongs still from the excle subtable named "independent V", and the subtable is named "panel data".

* Pre-use definition: Package all variables that require PCA
global pca_var = "x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22"
///Twenty-two third-level variables were used to calculate the development level of the digital economy.
///The variable names in the 'panel data' subtable are consistent with the above

* 1：test-KMO and Bartlett
factortest $pca_var   //If the P-value is significant and KMO=0.9>0.6, the correlation between variables is strong, making it suitable for factor analysis
	
* 2：PCA
pca $pca_var  //Based on a Cumulative contribution rate greater than 80% and an Eigenvalue greater than 1, three principal components are selected

* 3：Calculate the principal component score
predict c1 c2 c3 c4

* 4：Calculate the comprehensive indicators of the digital economy
gen Di_eco_PC=(0.5340*c1+0.1744*c2+0.0742*c3+0.0447*c4)/0.8274
//The principal component is multiplied by the corresponding contribution rate and then divided by the cumulative contribution rate. 
//The coefficient is obtained from the previous pca result


*5：//The final calculated comprehensive score often shows negative values. 
   //To compare the size of the indicators more intuitively, we draw on the practice of Han Xianfeng et al. (2014) to standardize the digital economy
foreach v  in Di_eco_PC {
	sum `v'
	replace `v' =  (`v' / (r(max) - r(min))) * 0.4  +0.6
}

foreach v in Di_eco_PC {
    sum `v'
    gen `v'_norm = (`v' / (r(max) - r(min))) * 0.4 + 0.6
}


save,replace
