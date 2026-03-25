-- Staging: light cleanup and typing of the raw customers feed.
-- One row per customer. No business logic here — just standardisation.

with source as (

    select * from {{ ref('raw_customers') }}

)

select
    cast(customer_id   as varchar) as customer_id,
    trim(customer_name)            as customer_name,
    upper(trim(country))           as country_code,
    cast(signup_date as date)      as signup_date,
    lower(trim(segment))           as segment
from source
