--Exercise 1
with current_spend as (
SELECT extract(year from transaction_date) as year,
product_id, spend as curr_year_spend
FROM user_transactions)
select year, product_id,
curr_year_spend,
lag(curr_year_spend) over(partition by product_id order by year) as prev_year_spend,
round((curr_year_spend-lag(curr_year_spend) over(partition by product_id order by year))
*100/lag(curr_year_spend) over(partition by product_id order by year),2) as yoy_rate
from current_spend
;
--Exercise 2
with card_issuing as (
SELECT card_name, issued_amount,
row_number() over(partition by card_name order by issue_year, issue_month) as thứ_tự
FROM monthly_cards_issued)
select card_name, issued_amount
from card_issuing
where thứ_tự =1
order by issued_amount desc
;
--Exercise 3
SELECT user_id, spend, transaction_date from 
(SELECT user_id, spend, transaction_date,
row_number() over(partition by user_id order by transaction_date) as thứ_tự
FROM transactions) as transaction
where transaction.thứ_tự =3
;
--Exercise 4
select transaction_date, user_id,
count(product_id) as purchase_count from
(select transaction_date, user_id, product_id, 
rank() over(partition by user_id order by transaction_date desc) as transaction_order
from user_transactions) as A
where A.transaction_order =1
group by transaction_date, user_id
order by transaction_date
;
--Exercise 5
with avg_rolling as
(SELECT user_id, tweet_date, 
(tweet_count+lead(tweet_count,1) over(partition by user_id order by tweet_date)
+lead(tweet_count,2) over(partition by user_id order by tweet_date))/3 as rolling_3d
from tweets)
select user_id, tweet_date,
round(rolling_3d, 2) as rolling_avg_3d
from avg_rolling
order by user_id, tweet_date
;
--Exercise 6
with payment_count as (
SELECT merchant_id, credit_card_id, amount,
extract(minute from transaction_timestamp - lag(transaction_timestamp) over(partition by merchant_id, credit_card_id, amount 
order by transaction_timestamp)) as minute_diff
FROM transactions)
select count(*) as payment_count
from payment_count
where minute_diff < 10
;
--Exercise 7
with total_spend as (
SELECT category, product,
sum(spend) as grossing,
rank() over(partition by category order by sum(spend) desc) as ranking
FROM product_spend
where extract(year from transaction_date) = '2022'
group by category, product
)
select category, product, grossing
from total_spend A
where A.ranking <= 2
order by category, ranking
;
--Exercise 8
with top10_ranking as 
(SELECT A.artist_name,
dense_rank() over(order by count(B.song_id) desc) as artist_rank
FROM artists as A
join songs as B on A.artist_id=B.artist_id
join global_song_rank as C on B.song_id=C.song_id
where C.rank <=10 --chỉ lấy các bài hát trong top 10 (ở bảng C là cột rank)
group by A.artist_name)
select artist_name, artist_rank
from top10_ranking
where artist_rank <=5
