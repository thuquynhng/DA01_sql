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
--Exercise 5


