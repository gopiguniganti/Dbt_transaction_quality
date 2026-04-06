-- Mart: one row per transaction day, split by settled vs. total.
-- The kind of curated feed a reporting or fraud/AML scenario layer consumes.

with fct as (

    select * from {{ ref('fct_transactions') }}

)

select
    transaction_date,
    currency,
    count(*)                                                    as transaction_count,
    sum(amount)                                                 as total_amount,
    sum(case when is_settled then amount else 0 end)            as settled_amount,
    sum(case when status = 'pending'   then amount else 0 end)  as pending_amount,
    sum(case when status = 'cancelled' then amount else 0 end)  as cancelled_amount
from fct
group by 1, 2
order by 1, 2
