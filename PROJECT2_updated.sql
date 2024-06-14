--Ad-hoc tasks
--1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
--output: month_year ( yyyy-mm) , total_user, total_order
select * from bigquery-public-data.thelook_ecommerce.order_items
;
select format_date('%Y-%m', created_at)  as month_year,
count(distinct user_id) as total_user,
count(order_id) as total_order
from bigquery-public-data.thelook_ecommerce.order_items 
where created_at between '2019-01-01' and '2022-04-30'
and status ='Complete'
group by 1
order by 1
--Insights: Từ tháng 1/2019 đến tháng 4/2022, số lượng đơn hàng và khách hàng đều tăng dần theo thời gian, cho thấy business đang phát triển tốt. 
Sự tăng số lượng đơn hàng và khách hàng đạt đỉnh vào khoảng tháng 3/2022 với gần 660 khách hàng và 451 đơn hàng hoàn thành. Ngoài ra còn có xu hướng 
tăng vào các tháng cuối năm, đặc biệt là tháng 11 và 12. 
;
--2. Giá trị đơn hàng trung bình (AOV) và số lượng khách hàng mỗi tháng
/*Thống kê giá trị đơn hàng trung bình và tổng số người dùng khác nhau mỗi tháng 
(Từ 1/2019-4/2022)
Output: month_year (yyyy-mm), distinct_users, average_order_value */

select count(distinct user_id) as distinct_users,
format_date('%Y-%m', created_at) as month_year,
sum(sale_price)/count(order_id) as average_order_value
from bigquery-public-data.thelook_ecommerce.order_items
where created_at between '2019-01-01' and '2022-04-30'
group by 2
order by 1, 2

--Insights: Từ tháng 1/2019 đến tháng 4/2022, số lượng khách hàng khác nhau tăng liên tục qua các tháng, với tốc độ tăng khá ổn định, mỗi năm tăng 
xấp xỉ 400-500 khách hàng. Về giá trị đơn hàng trung bình, có mức biến động nhất định qua các tháng, không có xu hướng tăng/giảm rõ rệt theo thời gian 
nhưng duy trì ở mức ổn định (~58-62) --> sự tăng trưởng về số lượng người dùng không đi kèm với việc tăng giá trị đơn hàng trung bình.
;

--3. Nhóm khách hàng theo độ tuổi
/* Tìm các khách hàng trẻ tuổi nhất và lớn tuổi nhất theo từng giới tính ( Từ 1/2019-4/2022)
Output: first_name, last_name, gender, age, tag (hiển thị youngest nếu trẻ tuổi nhất, oldest nếu lớn tuổi nhất) */

with male_youngest as (
select first_name,
last_name,
age,
gender,
case when age =(select min(age) from bigquery-public-data.thelook_ecommerce.users) then 'youngest'
else 'unknown'
end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender ='M'
and created_at between '2019-01-01' and '2022-04-30'),

female_youngest as (
select first_name,
last_name,
age,
gender,
case when age =(select min(age) from bigquery-public-data.thelook_ecommerce.users) then 'youngest'
else 'unknown'
end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender ='F'
and created_at between '2019-01-01' and '2022-04-30'),

male_oldest as (
select first_name,
last_name,
age,
gender,
case when age =(select max(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest'
else 'unknown'
end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender ='M'
and created_at between '2019-01-01' and '2022-04-30'),

female_oldest as (
select first_name,
last_name,
age,
gender,
case when age =(select min(age) from bigquery-public-data.thelook_ecommerce.users) then 'oldest'
else 'unknown'
end as tag
from bigquery-public-data.thelook_ecommerce.users
where gender ='F'
and created_at between '2019-01-01' and '2022-04-30')

select * from male_youngest
where tag ='youngest'
union all
select * from female_youngest
where tag ='youngest'
union all
select * from male_oldest
where tag ='oldest'
union all
select * from female_oldest
where tag ='oldest'


;
--4.Top 5 sản phẩm mỗi tháng
/* Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). 
Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month */

select * from 
format_date('%Y-%m', c.created_at) as month_year,
b.id as product_id,
b.name as product_name,
b.cost,
b.retail_price as sales,
b.retail_price-b.cost as profit,
dense_rank() over(partition by format_date('%Y-%m', c.created_at) order by (b.retail_price-b.cost)-b.cost desc) as rank_per_month
from bigquery-public-data.thelook_ecommerce.products b
join bigquery-public-data.thelook_ecommerce.order_items c on b.id=c.product_id
where created_at between '2019-01-01' and '2022-04-30') as a
where a.rank_per_month <=5
;

--5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục --chạy câu lệnh còn lỗi: Star expansion expression references column product_categories which is neither grouped nor aggregated at [9:8] 
/*Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
Output: dates (yyyy-mm-dd), product_categories, revenue */

with quantity_sold_cte as
(select format_date('%Y-%m-%d', b.created_at) as dates,
a.category as product_categories,
count(b.order_id) as quantity_sold
from bigquery-public-data.thelook_ecommerce.products a
join bigquery-public-data.thelook_ecommerce.order_items b on a.id=b.product_id
group by 1, 2
order by 1)
select *,
sum(quantity_sold*p.retail_price) over(partition by format_date('%Y-%m-%d', oi.created_at) order by sum(q.quantity_sold*p.retail_price) desc) as revenue
from quantity_sold_cte as q
join bigquery-public-data.thelook_ecommerce.products p on q.product_categories=p.category
join bigquery-public-data.thelook_ecommerce.order_items oi on p.id=oi.product_id
where q.dates <='2022-04-15'
group by 1
order by 1

--Tạo metric trước khi dựng dashboard
--1. Tạo dataset như mô tả và lưu vào bảng ảo view
create view bigquery-public-data.thelook_ecommerce.vw_ecommerce_analyst as 
( 
with revenue_cte as (
select format_date('%Y-%m', created_at) as month,
sum(sale_price) as curr_revenue,
count(order_id) as curr_order_count
from bigquery-public-data.thelook_ecommerce.order_items
group by format_date('%Y-%m', created_at) 
) 
select distinct c.category as product_category,
a.month, 
extract(year from b.created_at) as year,
round((lead(a.curr_revenue) over(order by a.month)-a.curr_revenue)*100.00/a.curr_revenue, 2) as revenue_growth,
round((lead(a.curr_order_count) over(order by a.month)-a.curr_order_count)*100.00/a.curr_order_count, 2) as order_growth,
sum(b.sale_price) over(partition by a.month, c.category) as tpv,
count(b.order_id) over(partition by a.month, c.category) as tpo,
sum(c.cost) over(partition by a.month, c.category) as total_cost,
sum(b.sale_price) over(partition by a.month, c.category)-sum(c.cost) over(partition by a.month, c.category) as total_profit,
(sum(b.sale_price) over(partition by a.month, c.category)-sum(c.cost) over(partition by a.month, c.category))/sum(c.cost) over(partition by a.month, c.category) as profit_to_cost_ratio
from revenue_cte as a
join bigquery-public-data.thelook_ecommerce.order_items as b on a.month=format_date('%Y-%m', b.created_at)
join bigquery-public-data.thelook_ecommerce.products as c on b.product_id=c.id
order by a.month)
;

--2.Tạo retention cohort analysis
with first_orders as (
select user_id,
format_date('%Y-%m', created_at) as invoicedate,
min(format_date('%Y-%m', created_at)) as first_order_date
from bigquery-public-data.thelook_ecommerce.order_items
group by 1, 2)

, cohort_index as (
select a.user_id, b.invoicedate,
b.first_order_date as cohort_date,
(extract(year from b.invoicedate)-extract(year from b.first_purchase_date))*12 
	+ (extract(month from b.invoicedate)-extract(month from b.first_purchase_date))+1 as index,
sum(a.sale_price) as revenue
from bigquery-public-data.thelook_ecommerce.order_items as a
join first_orders as b on a.user_id=b.user_id)

, xxx as (
select cohort_date, index,
count(distinct user_id) as no_of_customer,
revenue
from cohort_index
group by 1, 2)

, customer_cohort as (
select cohort_date,
sum(case when index =1 then no_of_customer else 0 end) as m1,
sum(case when index =2 then no_of_customer else 0 end) as m2, 
sum(case when index =3 then no_of_customer else 0 end) as m3,
sum(case when index =4 then no_of_customer else 0 end) as m4
from xxx
group by 1
order by 1)

,retention_cohort as (
select cohort_date,
round(100.00*m1/m1, 2)|| '%' as m1,
round(100.00*m2/m1, 2)|| '%' as m2,
round(100.00*m3/m1, 2) || '%' as m3,
round(100.00*m4/m1, 2) || '%' as m4
from customer_cohort)
select * from retention_cohort;
