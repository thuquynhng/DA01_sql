--Exercise 1
SELECT 
sum(case 
when device_type ='laptop' then 1 else 0
end) as laptop_views,
sum(case 
when device_type in('tablet', 'phone') then 1 else 0
end) as mobile_views
FROM viewership
--Exercise 2
select *,
case
when x+y >z and z+x >y and y+z >x then 'Yes' 
else 'No'
end as triangle
from Triangle
--Exercise 3
SELECT count(case_id) as uncategorised_calls
FROM callers
where call_category is NULL 
or call_category ='n/a')
select
round((uncategorised_calls/(select(count(*) from callers))*100, 1) as uncategorised_call_pct
from callers
--Exercise 4
select name from Customer
where referee_id !=2 or  referee_id is null
--Exercise 5
select survived,
sum(case
when pclass =1 then 1 else 0 end) as first_class,
sum(case 
when pclass =2 then 1 else 0 end) as second_class,
sum(case
when pclass =3 then 1 else 0 end) as third_class
from titanic
group by survived
