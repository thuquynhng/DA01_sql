--Exercise 1
with immediate_order as (
select delivery_id, customer_id, order_date,
customer_pref_delivery_date,
row_number() over(partition by customer_id order by order_date) AS order_rank
from Delivery)
select
round(100.0 * sum(case when order_date = customer_pref_delivery_date then 1 else 0 end) / 
count(*), 2) AS immediate_order_percentage
FROM immediate_order
WHERE order_rank = 1;
