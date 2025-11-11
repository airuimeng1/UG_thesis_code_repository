

/////主成分分析法PCA代码，算数字经济发展水平
////原始属于依旧来自于名为“independent V”的excle的子表格中，子表格名为“panel data””


* 使用前定义：打包需要PCA的所有变量
global pca_var = "x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22"
///计算数字经济发展水平使用到了22个三级变量，‘panel data’子表格中变量名字与上述一致

* 1：检验-KMO和Bartlett
factortest $pca_var   //若P值显著，KMO=0.9>0.6 ，变量之间相关性较强，适合做因子分析
	
* 2：主成分分析
pca $pca_var  //根据累计贡献率大于(Cumulative)80%，特征值(Eigenvalue)大于1，选取3个主成分

* 3：计算主成分得分
predict c1 c2 c3 c4

* 4：计算数字经济综合指标
gen 数字经济_主成分=(0.5340*c1+0.1744*c2+0.0742*c3+0.0447*c4)/0.8274
//主成分乘以对应贡献率再除以累计贡献率，系数是前面pca结果里获取的

*5：最后算出来的综合得分经常会出现负值，为了更直观地比较指标大小，借鉴韩先锋等（2014）的做法，标准化数字经济
foreach v  in 数字经济_主成分{
	sum `v'
	replace `v' =  (`v' / (r(max) - r(min))) * 0.4  +0.6
}

foreach v in 数字经济_主成分 {
    sum `v'
    gen `v'_norm = (`v' / (r(max) - r(min))) * 0.4 + 0.6
}


save,replace
