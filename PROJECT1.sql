select * from SALES_DATASET_RFM_PRJ
	;
--1.Chuyển đổi kiểu dữ liệu phù hợp cho các trường 

alter table SALES_DATASET_RFM_PRJ
alter column priceeach type numeric using (trim(priceeach)::numeric),
alter column ordernumber type bigint using (trim(ordernumber)::bigint),
alter column quantityordered type int using (trim(quantityordered)::int),
alter column orderlinenumber type int using (trim(orderlinenumber)::int),
alter column sales type decimal using (trim(sales)::decimal),
alter column orderdate type timestamp using (trim(orderdate)::timestamp),
alter column msrp type int using (trim(msrp)::int),
alter column productcode type char(8) using (trim(productcode)::char(8)),
alter column addressline1 type varchar(100) using (trim(addressline1)::varchar(100)),
alter column postalcode type char(10) using (trim(postalcode)::char(10))
;
/*2.Check NULL/BLANK (‘’)  ở các trường: 
ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, ORDERDATE */

select *
from SALES_DATASET_RFM_PRJ
where ordernumber is null
or quantityordered is null
or priceeach is null
or orderlinenumber is null
or sales is null
or orderdate is null
;
/* 3. Thêm cột CONTACTLASTNAME, CONTACTFIRSTNAME được tách ra từ CONTACTFULLNAME . 
Chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME theo định dạng chữ cái đầu tiên 
viết hoa, chữ cái tiếp theo viết thường. Gợi ý: ( ADD column sau đó UPDATE)*/

alter table SALES_DATASET_RFM_PRJ
add column contactlastname varchar(50);
alter table SALES_DATASET_RFM_PRJ
add column contactfirstname varchar(50);

--tách contactfullname
update SALES_DATASET_RFM_PRJ
set contactlastname=substring(contactfullname from 1 for position('-' in contactfullname)-1),  
contactfirstname=substring(contactfullname from position('-' in contactfullname)+1 
	for length(contactfullname)-length(substring(contactfullname from 1 for position('-' in contactfullname)-1)))
  
--chuẩn hóa CONTACTLASTNAME, CONTACTFIRSTNAME 
update SALES_DATASET_RFM_PRJ
set contactlastname =upper(left(contactlastname,1))||lower(right(contactlastname, length(contactlastname)-1)),
contactfirstname =upper(left(contactfirstname,1))||lower(right(contactfirstname, length(contactfirstname)-1))


/* 4. Thêm cột QTR_ID, MONTH_ID, YEAR_ID lần lượt là Qúy, tháng, 
năm được lấy ra từ ORDERDATE */

alter table SALES_DATASET_RFM_PRJ
add column qtr_id int;
alter table SALES_DATASET_RFM_PRJ
add column month_id int;
alter table SALES_DATASET_RFM_PRJ
add column year_id int;

--Quý
update SALES_DATASET_RFM_PRJ
set qtr_id =case 
	when extract(month from orderdate) in(1,2,3) then 1
	when extract(month from orderdate) in(4,5,6) then 2
	when extract(month from orderdate) in(7,8,9) then 3
	when extract(month from orderdate) in(10,11,12) then 4
end; 

--Tháng
update SALES_DATASET_RFM_PRJ
set month_id =extract(month from orderdate) 

--Năm
update SALES_DATASET_RFM_PRJ
set year_id =extract(year from orderdate) 

/* 5.	Hãy tìm outlier (nếu có) cho cột QUANTITYORDERED 
và hãy chọn cách xử lý cho bản ghi đó (2 cách)*/ --chưa chạy câu lệnh
--Cách 1: IQR/Box Plot
with minmax_cte as (
select Q1-1.5*IQR as min_value, Q3+1.5*IQR as max_value
from (
select 
percentile_cont(0.25) within group (order by quantityordered) as Q1,
percentile_cont(0.75) within group (order by quantityordered) as Q3,
percentile_cont(0.75) within group (order by quantityordered) -percentile_cont(0.25) within group (order by quantityordered) 
as IQR
from SALES_DATASET_RFM_PRJ) as A)

select * from SALES_DATASET_RFM_PRJ
where quantityordered <(select min_value from minmax_cte)
or quantityordered >(select max_value from minmax_cte)

--Cách 2: Z-score
select avg(quantityordered),
stddev(quantityordered)
from SALES_DATASET_RFM_PRJ

with cte as (
select quantityordered,
(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) as avg,
(select stddev(quantityordered) from SALES_DATASET_RFM_PRJ) as stddev
from SALES_DATASET_RFM_PRJ),
outliers_cte as
(select quantityordered,
(quantityordered - avg)/stddev as z_score
from cte
where abs((quantityordered - avg)/stddev) >3 )
--update các giá trị outliers (thay bằng mean)
update SALES_DATASET_RFM_PRJ
set quantityordered =(select avg(quantityordered) from SALES_DATASET_RFM_PRJ) --đặt bằng mean
where quantityordered in (select quantityordered from outliers_cte) --chỉ update ở những chỗ có outliers

/* 6. Lưu vào bảng mới tên là SALES_DATASET_RFM_PRJ_CLEAN */
create table  SALES_DATASET_RFM_PRJ_CLEAN AS
select * from SALES_DATASET_RFM_PRJ



