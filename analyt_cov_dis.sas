*this code compute 3 company��s analyst forecast characteristics;
*N, coverage;
*forecast error by each analyst;
*average forecast error by all analyst;
*forecast dispersion;


*First clear the log and output for this program;*************************;
dm ��out;clear;log;clear;��;
*setup the output format for easier reading;
options ls = 78 ps = 66;
**************************************************************************;


******************tell sas where to put data files;***********************;
libname myLib6 ��C:\Users\Zenghui\Dropbox\01 accounting research\01 SAS\sas learning\forecast error��;
********************connect to WRDs;***************************************;
%let wrds = wrds.wharton.upenn.edu 4016;options comamid = TCP remote=WRDS;
signon username=_prompt_;
*************************************************************************;

rsubmit;
libname ibes ��/wrds/ibes/sasdata��;

PROC SQL;
create table ibesdata as
select a.* 
from ibes.DET_EPSUS a
where 
a.oftic in (��GOOG��,��AAPL��,��MSFT��)
and a.MEASURE= ��EPS��
and a.FPI in (��6��,��7��,��8��,��9��)  /*Control FPI to select only the quarter forecasts*/

/* the following 3 lines mabye useful in event study like ERC example on wrds.us */
/*and a.rdq - 90 < b.REVDATS < a.rdq -1*/ 
/*review date within two month of annoucement of actual EPS*/
/*and a.datadate -5 <= b.FPEDATS <= a.datadate +5*/  
;
quit;

/*download data to local computer*/
proc download data=ibesdata out=myLib6.z_google;
run;

endrsubmit;

����ĸ����ı����������б� 
# ���� ���� ���� �����ʽ �����ʽ ��ǩ 
13 ANANM �ַ� 50 $50. $50. ANANM 
22 BROKERCD �ַ� 10 $10. $10. BROKERCD 
14 BROKERN �ַ� 50 $50. $50. BROKERN 
2 DDATE �ַ� 10 $10. $10. DDATE =date(my calc)
21 FCFPS ��ֵ 8 20.5 20.5 FCFPS 
18 FEBIT ��ֵ 8 20.5 20.5 FEBIT 
19 FEBITDA ��ֵ 8 20.5 20.5 FEBITDA 
12 FENDDT �ַ� 10 $10. $10. FENDDT 
15 FEPS ��ֵ 8 20.5 20.5 FEPS 
17 FNETPRO ��ֵ 8 20.5 20.5 FNETPRO 
16 FPE ��ֵ 8 20.5 20.5 FPE 
20 FTURNOVER ��ֵ 8 20.5 20.5 FTURNOVER 
9 MCFPS ��ֵ 8 20.5 20.5 MCFPS 
6 MEBIT ��ֵ 8 20.5 20.5 MEBIT 
7 MEBITDA ��ֵ 8 20.5 20.5 MEBITDA 
3 MEPS ��ֵ 8 20.5 20.5 MEPS 
5 MNETPRO ��ֵ 8 20.5 20.5 MNETPRO 
4 MPE ��ֵ 8 20.5 20.5 MPE 
8 MTURNOVER ��ֵ 8 20.5 20.5 MTURNOVER 
11 RPTDT �ַ� 10 $10. $10. RPTDT 
1 STKCD �ַ� 6 $6. $6. STKCD 
10 date ��ֵ 8 YYMMDD10.     


proc sort data = myLib6.z_google ; by cusip FPEDATS ANALYS descending REVDATS ;
run;
/*only keep the last forecast of each analyst*/
proc sort data = myLib6.z_google nodupkey out = myLib6.z_google2 dupout=myLib6.z_google_dropped;
by cusip FPEDATS ANALYS ;
run;

data myLib6.z_google3;
set myLib6.z_google2;
if ACTUAL ne .; /*drop missing actual value obs*/
forecast_error = ACTUAL - value; /*Calculate forecast error by each analyst*/
run;


proc sort 
data = myLib6.z_google3 
out = myLib6.z_google4; 
by cusip FPEDATS;
run;
proc means data = myLib6.z_google4 mean median maxdec=5 std N noprint;
OUTPUT OUT = myLib6.z_google5 N(value)= coverage mean(value)= avgforecast std(value)= dispersionforecast median(value)= medianofforecast mean(forecast_error) = aveforecasterror ; 
var value forecast_error; /*calculate average forecast error for a perticular firm and perticular quarter*/
by cusip FPEDATS;
run;

proc print 
data=myLib6.z_google5 (obs=10);
run;
