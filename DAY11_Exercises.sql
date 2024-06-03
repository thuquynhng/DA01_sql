--Exercise 1
select COUNTRY.Continent, floor(avg(CITY.Population))
from city as CITY
inner join country as COUNTRY
on CITY.CountryCode=COUNTRY.Code
group by COUNTRY.Continent
--Exercise 2
SELECT round(count(B.email_id)::decimal/count(distinct A.email_id), 2) as activation_rate
FROM emails as A
left join texts as B
on A.email_id=B.email_id
and B.signup_action='Confirmed'
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
--Exercise 5
