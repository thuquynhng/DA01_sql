--Exercise 1
select name from city
where countrycode ='USA' and population >120000 
;
--Excercise 2
select * from city 
where countrycode ='JPN'
;
--Exercise 3
select city, state from station
;
--Exercise 4
select distinct city from station
where city like 'a%' or city like 'e%' or city like 'i%' or city like 'o%' or city like 'u%'
;
--Excercise 5
select distinct city from station
where city like '%a' or city like '%e' or city like '%i' or city like '%o' or city like '%u'
;
--Exercise 6
select distinct city from station
where city not like 'a%' and city not like 'e%' and city not like 'i%' and city not like 'o%' and city not like 'u%'
;
--Excercise 7
select name from Employee
order by name asc
;
--Excercise 8
select name from Employee
where salary >2000 and months <10
order by employee_id asc
;
--Excercise 9
select product_id from Products
where low_fats ='Y' and recyclable ='Y'
;
--Excercise 10
select name from Customer
where referee_id !=2 or  referee_id is null
;
--Excercise 11
select name, population, area from World
where area >=3000000 or population >=25000000
;
--Excercise 12
select distinct author_id as id from Views
where author_id =viewer_id
order by author_id asc
;
--Excercise 13
select part, assembly_step from parts_assembly
where finish_date is NULL
;
--Excercise 14
select * from lyft_drivers
where yearly_salary <=30000 or yearly_salary >=70000
;
--Excercise 15
select advertising_channel from uber_advertising
where money_spent >100000 and year =2019

