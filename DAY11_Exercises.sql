--PRACTICE 5
--Exercise 1
select COUNTRY.Continent, floor(avg(CITY.Population))
from city as CITY
inner join country as COUNTRY
on CITY.CountryCode=COUNTRY.Code
group by COUNTRY.Continent
	;
--Exercise 2
SELECT round(count(B.email_id)::decimal/count(distinct A.email_id), 2) as activation_rate
FROM emails as A
left join texts as B
on A.email_id=B.email_id
and B.signup_action='Confirmed'
	;
--Exercise 3
with snaps_timespending as (
SELECT B.age_bucket,
sum(case 
	when A.activity_type ='send' then A.time_spent else 0
end) as send,
sum(case 
	when A.activity_type ='open' then A.time_spent else 0
end) as open,
sum(A.time_spent) as total_timespent
FROM activities as A
inner join age_breakdown as B
on A.user_id=B.user_id
where A.activity_type in ('send', 'open')
group by B.age_bucket
)

select age_bucket,
round((send/total_timespent)*100.0, 2) as send_perc,
round((open/total_timespent)*100.0, 2) as open_perc
from snaps_timespending
	;
--Exercise 4
with supercloud_customer as (
SELECT customers.customer_id, count(distinct products.product_category) as product	
FROM customer_contracts as customers
left join products 
on customers.product_id=products.product_id
group by customers.customer_id
)
select customer_id from supercloud_customer
where product= (select count(distinct product_category) 
from products)
order by customer_id
	;
--Exercise 5
select mng.employee_id, mng.name as name, count(mng.employee_id) as reports_count, 
round(avg(emp.age)) as average_age
from Employees as emp
left join Employees as mng
on emp.reports_to=mng.employee_id
where emp.reports_to is not null
group by mng.employee_id, mng.name
order by mng.employee_id
	;
--Exercise 6
select A.product_name, sum(B.unit) as unit
from Products as A
join Orders as B
on A.product_id=B.product_id
and order_date between '2020-02-01' and '2020-02-29'
group by B.product_id
having sum(B.unit) >=100
	;
--Exercise 7 
SELECT A.page_id
FROM pages as A
left join page_likes as B
on A.page_id=B.page_id
where B.page_id is null
group by A.page_id
order by A.page_id

;
--MID-COURSE TEST

