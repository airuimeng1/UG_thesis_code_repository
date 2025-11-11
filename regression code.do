clear
import excel "/Users/ray/Desktop/DT数据/regression data.xlsx", sheet("panel data") firstrow

xtest id year

gen digital_e2 = digital_e^2
gen digital_p2 = digital_p^2

/////计算工具变量
gen iv = (1/Terrain_undulation)*internet_user
gen ivv = log(iv)


//////hausman检验

xtreg low_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , fe
est store fe
xtreg low_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , re
est store re
hausman fe re


xtreg mid_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , fe
est store fe
xtreg mid_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , re
est store re
hausman fe re

xtreg high_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , fe
est store fe
xtreg high_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry , re
est store re
hausman fe re

/////描述性统计
sum low_skill_pct mid_skill_pct high_skill_pct digital_e digital_e2 digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry
/////描述性结果导出
asdoc sum low_skill_pct mid_skill_pct high_skill_pct digital_e digital_e2 digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry


///////共线性，vif检验
reg low_skill_pct digital_e human_capital rd_intensity digitalization gov_intervention industry 
estat vif



/////相关性分析导出结果
logout, save (correlation)word replace:pwcorr_a  low_skill_pct mid_skill_pct high_skill_pct digital_e digital_e2 digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry, star1(0.01) star5(0.05) star10(0.1)



/////基准回归

xtreg low_skill_pct digital_e human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a1
xtreg low_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a2
xtreg mid_skill_pct digital_e human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a3
xtreg mid_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a4
xtreg high_skill_pct digital_e human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a5
xtreg high_skill_pct digital_e digital_e2 human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store a6
//////基准回归导出结果
esttab a1 a2 a3 a4 a5 a6  using 基准回归benchmark.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("low" "low" "mid" "mid" "high" "high") title("基准回归")///////导出regression结果


//////robustness test///替换变量法substitution variable method
xtreg low_skill_pct digital_p human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store s1
xtreg low_skill_pct digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store s2
xtreg mid_skill_pct digital_p human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store s3
xtreg mid_skill_pct digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store s4
xtreg high_skill_pct digital_p human_capital rd_intensity digitalization gov_intervention industry i.year,fe
est store s5
xtreg high_skill_pct digital_p digital_p2 human_capital rd_intensity digitalization gov_intervention industry  i.year,fe
est store s6
/////稳健型检验导出结果
esttab s1 s2 s3 s4 s5 s6  using robustness.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("low" "low" "mid" "mid" "high" "high") title("robustness")




//////////异质性分析///本来异质性想研究东西中东北四部的异质性，数据也找得差不多了，但结果始终不稳健
xtreg low_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if inland_province == 1,fe
est store c1
xtreg mid_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if inland_province == 1,fe
est store c2
xtreg high_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if inland_province == 1,fe
est store c3

xtreg low_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if coastal_province == 1,fe
est store c4
xtreg mid_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if coastal_province_province == 1,fe
est store c5
xtreg high_skill_pct digital_a human_capital rd_intensity digitalization gov_intervention industry i.year if coastal_province_province == 1,fe
est store c6

/////异质性分析导出结果)
esttab c1 c2 c3 c4 c5 c6  using 异质性.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("low" "mid" "high" "low" "mid" "high") title("heterogenity ")





//////2sls第一阶段：检验工具变量与解释变量是否相关
xtreg  digital_e ivv  i.year  human_capital rd_intensity digitalization gov_intervention industry i.year , fe
est store v1
xtivreg2 low_skill_pct digital_e2 human_capital rd_intensity digitalization gov_intervention industry (digital_e = ivv), fe robust
est store v2
xtivreg2 mid_skill_pct digital_e2 human_capital rd_intensity digitalization gov_intervention industry (digital_e = ivv), fe robust
est store v3
xtivreg2 high_skill_pct digital_e2 human_capital rd_intensity digitalization gov_intervention industry (digital_e = ivv), fe robust
est store v4

2sls导出结果
esttab v1 v2 v3 v4  using 2sls.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("digital_e" "low_skill_pct" "mid_skill_pct" "high_skill_pct") title("2SLS")


***********************************************************************************************************************************
**********************************************************************************************************************************
************************************************************************************************************************************
/////////////////////////////////////以下代码与本次回归无关，是我在论文期间学习stata时整理的笔记////////////////////////////////////////////


xtset id year

xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity,fe


reg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity
///最小二乘法回归
estat vif
///检验共线性，vif因子<10则说明没用共线性


///稳健型检验检验三种方法
///替换变量法，取log再次回归消除量纲影响，考虑极端值的影响掐头去尾再次回归

///hausman检验
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity,fe
est store fe ///我们先跑了一个fe模型，并把这个模型保存为fe，名字可更换，此时为单向固定效应模型，只控制了个体效应
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity,re
est store re///再跑一个re模型，并把这个模型保存为，名字可更换
hausman fe re 
///fe，re 顺序不能反，结果中卡方检验p值小于0.05说明存在个体异质性，需要用固定效应模型


ssc install estout
esttab fe using reg1.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("model1" ) title("Table1基准回归1")
/// 输出结果
///若把，.rtf变为doc则可以直接导入到word里，但容易乱码


xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year,fe
////加入了i.year之后是双向固定效应模型，控制了年份
///此时可以在回归表格之中，即N的上方多插入一行写"个体-年份  yes" 说明


///一致就是稳健型
///有差别就是异质性分析


////先来控制东西中东北区域后跑回归
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if west_area ==1 ,fe
est store m1
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if east_area ==1 ,fe
est store m2
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if middle_area ==1 ,fe
est store m3
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if north_east_area ==1 ,fe
est store m4
esttab m1 m2 m3 m4 using reg2.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("west" "east" "middle" "northeast") title("Table1稳健性分析")
///不显著也算是异质性


////再来控制时间发展阶段
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if year >= 2015,fe
xtreg male_pct ewm gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year if year < 2015,fe


gen lnemp=log(emp) /// 稳健性检验的方法其一，将emp取对数之后再次回归


///内生性gmm模型
ssc install xtabond2
///有差分和系统gmm，一般跑系统gmm效率更高数据集利用更为完整
xtabond2 y L.y x1 x2 x3 x4 i.year, gmmstyle(x2 x3,lag(2 3)) ivstyle(x1) twostep robust
///y的滞后一期一般是会影响当期的，必须放入模型作为控制变量，x1到x4就是我们的就是解释变量和控制变量，i.year控制年份，
////最重要的部分参数设定gmmstyle(x2 x3,lag(2 3)) ivstyle(x1) twostep robust
////后缀为noleveleq是差分gmm，进行了一节差分，会消除个体固定效应，会使用滞后的解释变量为工具变量
///后缀为twostep robust是系统gmm
///gmmstyle(x2 x3,lag(2 3)) 
///ivstyle(x1) 



est store gmm
esttab gmm using reg3.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("model1" ) title("gmm")



sysdir///安装外部命令方法，识别命令安装路径
ssc install xtiverg2///两阶段最小二乘

///2sls第二阶段
xtivreg2 y gdp_pc1 investment_gap_ratiao gov_investment rd_intensity mounts_area_pct (x = iv), fe robust
///（解释变量 = 严格外生工具变量）
///蓝色字体，三种检验：
///under欠识别检验p要<0.05表示拒绝原假设，外生工具变量与解释变量是有相关性的
///weak弱识别检验：F值远高于10%的临界值，表明工具变量不是弱工具。
///hansen：工具变量的数量正好等于内生变量的数量，因此无需进行过度识别限制检验，如果我们放了多个工具变量时，就需要看hansen


///2sls第一阶段：检验工具变量与解释变量是否相关
xtreg ewm urban_rate gdp_pc1 investment_gap_ratiao gov_investment rd_intensity i.year, fe
xtreg ewm urban_rate gdp_pc1 investment_gap_ratiao gov_investment rd_intensity , fe ///不固定年份时，显著


///导出2sls结果
xtreg ewm urban_rate gdp_pc1 investment_gap_ratiao gov_investment rd_intensity , fe
est store iv1

xtivreg2 male_pct gdp_pc1 investment_gap_ratiao gov_investment rd_intensity (ewm = urban_rate), fe robust
est store iv2

esttab iv1 iv2 using reg3.rtf, replace b(%6.3f) se(%6.3f) se ar2(3) star(* 0.1 ** 0.05 *** 0.01) compress nogap  mtitles("ewm" "male_pct") title("2SLS")

///描述性统计
sum male_pct low_skill_pct low_skill_pct mid_skill_pct

///描述性结果导出
ssc install asdoc
asdoc sum male_pct low_skill_pct low_skill_pct mid_skill_pct

ssc install pwcorr_a
logout, save (相关性分析)word replace:pwcorr_a y x, star1(0.01) star5(0.05) star10(0.1)
