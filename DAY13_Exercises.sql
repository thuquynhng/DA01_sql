--Exercise 1
with jobs_count as ( --tạo CTE để gom nhóm các cty và tên công việc + số lượng cv
SELECT company_id, title, description,
count(job_id) as jobs_count 
FROM job_listings  
group by company_id, title, description)
select count(distinct company_id) as duplicate_companies --chọn ra các hàng có job_count lớn hơn 1
from jobs_count 
where jobs_count >1
;
--Exercise 3
with policy_holders as
(select policy_holder_id,
count(case_id) as count 
FROM callers
group by policy_holder_id
having count(case_id) >=3)
select count(policy_holder_id) as policy_holder_count
from policy_holders
;
--Exercise 4
select page_id
from pages as A
where page_id not in
(select page_id from page_likes as B
where A.page_id=B.page_id) --xem bảng A có id nào ko trùng với bảng B hay ko, đó là những trang ko có lượt like
;
--Exercise 5 (*)
with july as (
SELECT user_id,
count(user_id),
extract(month from event_date) as month
from user_actions
where event_type in ('sign-in','like','comment')
group by user_id, month)
select month,
count(user_id) as monthly_active_users
from july 
where month = 7
group by month
having count(user_id) >1
;
--Exercise 6
select to_char(trans_date,'yyyy-mm') as month,
country,
count(id) as trans_count,
sum(case
	when state='approved' then 1 else 0
end) as approved_count,
sum(amount) as trans_total_amount,
sum(case
	when state='approved' THEN amount else 0
end) as approved_total_amount
from Transactions
group by to_char(trans_date,'yyyy-mm'), country
;
--Exercise 7
with firstyear_cte as
(select product_id, min(year) as minyear from Sales
group by product_id)
select A.product_id, A.year as first_year, A.quantity, A.price
from Sales as A
join firstyear_cte as B
on A.product_id=B.product_id
and A.year=B.minyear
;
--Exercise 8
select customer_id from Customer
group by customer_id
having count(distinct product_key) = (select count(*) from Product)
;
--Exercise 9
select emp.employee_id
from Employees as emp
left join Employees as mng on emp.manager_id= mng.employee_id
where emp.manager_id not in 
(select employee_id from Employees)
and emp.salary <30000
order by emp.employee_id 
;
--Exercise 11
(select Users.name as results from Users 
join MovieRating on Users.user_id=MovieRating.user_id
group by Users.name
order by count(MovieRating.movie_id) desc, Users.name asc
limit 1)
union all
(select Movies.title as results from Movies 
join MovieRating on Movies.movie_id=MovieRating.movie_id
where MovieRating.created_at between '2020-02-01' and '2020-02-29'
group by Movies.title
order by avg(MovieRating.rating) desc, Movies.title asc
limit 1)
;
--Exercise 12
with friends_count as (
select requester_id as id 
from RequestAccepted
union all 
select accepter_id as id
from RequestAccepted) --list tất cả các người dùng kể cả requesters và accepters
select id, count(*) as num from friends_count --đếm số bạn bè 
group by id
order by count(*) desc
limit 1

