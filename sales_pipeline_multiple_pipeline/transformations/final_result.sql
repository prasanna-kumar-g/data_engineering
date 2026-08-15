create or replace materialized view city_wise_sales
select c.city,sum(o.total_amount) as total_sales
from live.orders_silver o join live.customer_silver c
on o.customer_id=c.customer_id
group by city;