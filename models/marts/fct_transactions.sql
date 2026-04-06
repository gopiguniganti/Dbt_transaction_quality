-- Mart: transaction fact table. One row per transaction, every raw row
-- preserved so that SUM(amount) reconciles exactly back to the source feed.
-- A derived flag marks which transactions count toward settled revenue.

with transactions as (

    select * from {{ ref('stg_transactions') }}

)

select
    transaction_id,
    customer_id,
    transaction_date,
    amount,
    currency,
    status,
    case when status = 'completed' then true else false end as is_settled
from transactions
