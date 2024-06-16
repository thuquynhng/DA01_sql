/* 1. Doanh thu theo từng ProductLine, Year  và DealSize? 
Output: PRODUCTLINE, YEAR_ID, DEALSIZE, REVENUE*/
select productline, year_id, dealsize,
sum(sales) as revenue
from public.sales_dataset_rfm_prj_clean
group by productline, year_id, dealsize
order by year_id, revenue desc
;

/* 2. Đâu là tháng có bán tốt nhất mỗi năm? 
Output: MONTH_ID, REVENUE, ORDER_NUMBER */ --tháng 11/2003, tháng 11/2004, tháng 5/2005
select month_id, year_id, revenue,
order_number
from (
select month_id, year_id,
sum(sales) as revenue,
count(quantityordered) as order_number,
rank() over(partition by year_id order by sum(sales) desc) as revenue_ranking
from public.sales_dataset_rfm_prj_clean
group by month_id, year_id) as a
where a.revenue_ranking =1
order by year_id, month_id
;
/* 3. Product line nào được bán nhiều ở tháng 11? --Classic Cars
Output: MONTH_ID, REVENUE, ORDER_NUMBER */
select month_id, year_id, 
productline,
order_number
from (
select month_id,
year_id,
productline,
count(quantityordered) as order_number,
rank() over(partition by year_id order by count(quantityordered) desc) 
	as productline_ranking
from public.sales_dataset_rfm_prj_clean
group by month_id, year_id, productline) as a
where a.productline_ranking =1
and month_id =11
order by year_id, month_id
;
/* 4. Đâu là sản phẩm có doanh thu tốt nhất ở UK mỗi năm? 
Xếp hạng các các doanh thu đó theo từng năm.
Output: YEAR_ID, PRODUCTLINE,REVENUE, RANK */
select year_id, productline, revenue, rank 
from (
select year_id, 
productline,
sum(sales) as revenue,
rank() over(partition by year_id order by sum(sales) desc) as rank
from public.sales_dataset_rfm_prj_clean
where country ='UK'
group by year_id, productline) 
order by year_id
;
/*5. Ai là khách hàng tốt nhất, phân tích dựa vào RFM 
(sử dụng lại bảng customer_segment ở buổi học 23) */

with customer_rfm as (
select customername,
current_date-max(orderdate) as r,
count(distinct ordernumber) as f,
sum(sales) as m
from public.sales_dataset_rfm_prj_clean
group by customername)

, rfm_score as (
select customername,
ntile(5) over(order by R desc) as R_score, 
ntile(5) over(order by F) as F_score,
ntile(5) over(order by M) as M_score
from customer_rfm)

, rfm_final as (
select customername,
cast(R_score as varchar)||cast(F_score as varchar)||cast(M_score as varchar) as rfm_score
from rfm_score)

select segment, customer
from (
select a.customername as customer,
b.segment,
a.rfm_score as score
from rfm_final a
join segment_score b on a.rfm_score=b.scores) a
group by segment, customer, score 
order by score desc
