CREATE OR REPLACE STREAMING TABLE customer_bronze
comment "load data from csv file to customer bronze layer"
AS
select *,_metadata.file_name as file_name,current_timestamp as ingest_time
from cloud_files("/Volumes/dlt/dlt_practice/dlt_data/customer/","csv",map("cloudFiles.inferColumnTypes","true"));


CREATE OR REPLACE STREAMING TABLE CUSTOMER_SILVER_CLEANED
(constraint customer_valid expect(customer_id is not null)on violation drop row)
comment "load the data from bronze layer to silver cleaned data harmonization and DQ will be handled in this layer"
as 
select customerid as customer_id,customername as customer_name,address as city,dateofbirth as dob,registrationdate as customer_since,file_name,ingest_time
from stream(live.customer_bronze);

CREATE OR REPLACE STREAMING TABLE CUSTOMER_SILVER;
apply changes into customer_silver 
from stream(live.CUSTOMER_SILVER_CLEANED)
keys(customer_id)
sequence by(ingest_time)
stored as scd type 2;
