drop table bps_cleaned; 

create external table bps_cleaned (

store string,
co string,
num string,
fname string,
lname string,
dte string,
price string,
prod string
 
)
location '/user/tom/bigpetstore_cleaned/';

select count(*) from bps_cleaned;
