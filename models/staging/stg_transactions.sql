-- Staging: type-cast and standardise the raw transactions feed.
-- One row per transaction. Every raw row is preserved (no filtering),
-- so downstream totals must reconcile back to source.

with source as (

    select * from {{ ref('raw_transactions') }}

)

select
    cast(transaction_id as varchar)   as transaction_id,
    cast(customer_id    as varchar)   as customer_id,
    cast(transaction_date as date)    as transaction_date,
    cast(amount as decimal(18, 2))    as amount,
    upper(trim(currency))             as currency,
    lower(trim(status))               as status
from source
