--Ad-hoc tasks
--1. Số lượng đơn hàng và số lượng khách hàng mỗi tháng
--output: month_year ( yyyy-mm) , total_user, total_order
select * from bigquery-public-data.thelook_ecommerce.order_items
;
select extract(year from created_at)||'-'||extract(month from created_at) as month_year,
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
extract(year from created_at)||'-'||extract(month from created_at) as month_year,
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

with youngest as (
select first_name,
last_name, 
age, gender,
min(age) over(partition by gender) as youngest
from bigquery-public-data.thelook_ecommerce.users 
where created_at between '2019-01-01' AND '2022-04-30'
order by age),
oldest as (
select first_name,
last_name, 
age, gender,
max(age) over(partition by gender) as oldest
from bigquery-public-data.thelook_ecommerce.users 
where created_at between '2019-01-01' AND '2022-04-30'
order by age)
;
--4.Top 5 sản phẩm mỗi tháng
/* Thống kê top 5 sản phẩm có lợi nhuận cao nhất từng tháng (xếp hạng cho từng sản phẩm). 
Output: month_year ( yyyy-mm), product_id, product_name, sales, cost, profit, rank_per_month */

select * from 
(select extract(year from c.created_at)||'-'||extract(month from c.created_at) as month_year,
b.id as product_id,
b.name as product_name,
b.cost,
b.retail_price-b.cost as sales,
(b.retail_price-b.cost)-b.cost as profit,
dense_rank() over(partition by extract(year from c.created_at)||'-'||extract(month from c.created_at) order by (b.retail_price-b.cost)-b.cost desc) as rank_per_month
from bigquery-public-data.thelook_ecommerce.products b
join bigquery-public-data.thelook_ecommerce.order_items c on b.id=c.product_id
where created_at between '2019-01-01' and '2022-04-30') as a
where a.rank_per_month <=5
;

--5.Doanh thu tính đến thời điểm hiện tại trên mỗi danh mục
/*Thống kê tổng doanh thu theo ngày của từng danh mục sản phẩm (category) trong 3 tháng qua ( giả sử ngày hiện tại là 15/4/2022)
Output: dates (yyyy-mm-dd), product_categories, revenue */

