CREATE OR REPLACE STREAMING TABLE ORDERS_BRONZE_RAW
COMMENT "LOADING ORDERS DATA FROM VOLUME to bronze layer"
AS 
SELECT * ,
_METADATA.file_name AS FILE_NAME,
CURRENT_TIMESTAMP AS INGEST_TIME
FROM CLOUD_FILEs('/Volumes/dlt/dlt_practice/dlt_data/orders/','CSV',MAP("cloudfiles.inferColumnTypes","True"));

CREATE OR REPLACE STREAMING TABLE orders_silver_cleaned(
  constraint valid_order expect (order_id is not null)ON VIOLATION drop row,
  constraint valid_customerid expect (customer_id is not null)ON VIOLATION drop row)
as select orderid as order_id,
customerid as customer_id,
orderdate as order_date,
totalamount as total_amount,
status,
file_name,
ingest_time
from stream(live.ORDERS_BRONZE_RAW);

create or replace streaming table orders_silver;
apply changes into orders_silver
from stream(live.orders_silver_cleaned)
keys(order_id)
sequence by ingest_time;
