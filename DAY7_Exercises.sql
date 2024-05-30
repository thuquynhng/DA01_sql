--Excercise 1
select name from STUDENTS
where marks >75
order by right(name, 3), id
--Excercise 2
select user_id, 
concat(upper(left(name,1)),lower(substring(name from 2))) as name
from Users
order by user_id
--Excercise 3
SELECT manufacturer,
'$' || round((sum(total_sales)/1000000),0) || ' ' || 'million' as drug_sales
FROM pharmacy_sales
group by manufacturer
order by drug_sales desc, manufacturer 
--Excercise 4
SELECT extract(month from submit_date) as mth,
product_id as product,
round(avg(stars),2) as avg_rating
FROM reviews
group by mth, product
order by mth, product
--Excercise 5
SELECT sender_id,
count(message_id) as message_count
FROM messages
where extract(year from sent_date) ='2022' and extract(month from sent_date) ='08'
group by sender_id
order by message_count desc
limit 2
--Exercise 6
select tweet_id
from Tweets
where length(content) >15
--Exercise 7
select 
activity_date as day,
count(distinct user_id) as active_users
from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date
--Exercise 8
select 
count(id) as employees_hired
from employees
where extract(month from joining_date) between '01' and '07'
and extract(year from joining_date) =2022
--Exercise 9
select first_name,
position('a' in first_name)
from worker
where first_name ='Amitah'
--Exercise 10
select title,
substring(title from length(winery) +2 for 4) --độ dài kí tự đứng trước năm + dấu cách
from winemag_p2
where country ='Macedonia'

