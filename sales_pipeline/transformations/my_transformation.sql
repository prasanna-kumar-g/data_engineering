create streaming table orders_bronze as 
select *,_metadata.file_path as file_name,current_timestamp() as load_time
from cloud_files('/Volumes/workspace/default/orders_datasets/orders/','csv',
map('cloud_files.inferColumnTypes','True'));

create streaming table orders_silver(
  constraint order_id_con expect(order_id is not null) on violation drop row
)as 
select * from stream(live.orders_bronze);

create streaming table orders_silver_cleaned;
apply changes into live.orders_silver_cleaned
from stream(live.orders_silver)
keys(order_id)
sequence by load_time
stored as  SCD TYPE 2;

create materialized view  orders_gold_complete
as 
select * from live.orders_silver_cleaned
where order_status='COMPLETE';