
/////熵权法计算数字经济发展水平digital_e
////原始数据集来自名为`independent V'的excel的子表格中，子表格名为"panel data"
tsset id year

global xlist1 "x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22"

**step 1:标准化
**①正向指标
foreach x of global xlist1{
egen min`x'=min (`x')
egen max`x'=max (`x')
gen standard`x'=(`x'-min`x')/(max`x'-min`x')
}

**step 2:计算第i年变量j的权重
**正向指标
foreach x of global xlist1 {
	egen sum`x' =total(standard`x')
	gen w1`x'=standard`x' /sum`x'
}


**step 3：信息熵与冗余度
**正向指标
by id, sort: egen m1 =count (year)
foreach x of global xlist1{
	**（归一化处理）
	gen w`x'=w1`x'+0.0000000001  
	egen e1`x'=total (w`x' * log(w`x'))
	gen d`x'=1+1/log(m1)*e1`x'
}



**step 4:权重
gen sumd1 =dx1+dx2+dx3+dx4+dx5+dx6+dx7+dx8+dx9+dx10+dx11+dx12+dx13+dx14+dx15+dx16+dx17+dx18+dx19+dx20+dx21+dx22

foreach x of global xlist1{
	gen w2`x'=d`x' /sumd1
}
/////在熵权法ewm回归结果中，w2打头的变量是x的权重

***step 5:总指标
foreach x of global xlist1{
    gen score_`x'=standard`x' * w2`x'
}


gen score=score_x1+score_x2+score_x3+score_x4+score_x5+score_x6+score_x7+score_x8+score_x9+score_x10+score_x11+score_x12+score_x13+score_x14+score_x15+score_x16+score_x17+score_x18+score_x19+score_x20+score_x21+score_x22
