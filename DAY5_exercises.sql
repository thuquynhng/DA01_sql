--Exercise 1
select distinct city from station
where id like '%0' or  id like '%2'  or id like '%4' or id like '%6' or id like '%8'
--or
select distinct city from station
where id%2=0
;
--Exercise 2
select count(city) - count(distinct city) from station 
;
--Exercise 3 (notyetfinished)
--Exercise 4
SELECT ROUND(CAST(sum(order_occurrences*item_count)/sum(order_occurrences)as decimal),1) as mean --chuyển int thành decimal
FROM items_per_order
;
--Exercise 5
SELECT candidate_id FROM candidates
where skill in ('Python', 'Tableau', 'PostgreSQL')
group by candidate_id --tương ứng với số ứng viên đó thì số skill là bao nhiêu
having count(skill) =3 --tìm ra ứng viên có cả 3 skill
order by candidate_id asc
;
--Exercise 6
SELECT user_id,
max(date(post_date)) - min(date(post_date))
FROM posts
where post_date >=2021-01-01 and post_date <2022-01-01
group by user_id
having count(post_id)>1 --loại trừ những người dùng chỉ đăng 1 lần trong năm
;
--Exercise 7
--how many credit cards were issued each month
SELECT card_name,
max(issued_amount) - min(issued_amount) as disparity
FROM monthly_cards_issued
group by card_name
order by disparity desc
;
--Exercise 8
--doanh thu - chi phí âm
SELECT manufacturer,
count (drug) as drug_count,
abs(sum(cogs - total_sales)) as losses
FROM pharmacy_sales
where total_sales <cogs
group by manufacturer
order by losses desc
;
--Exercise 9
select * from Cinema
where ID%2=1
and description !='boring'
order by rating desc
;
--Exercise 10
select teacher_id,
count(distinct subject_id) as cnt
from Teacher
group by teacher_id
;
--Exercise 11
select user_id,
count(follower_id) as followers_count
from Followers
group by user_id
order by user_id asc
;
--Exercise 12
select class from Courses
group by class
having count(student) >=5

