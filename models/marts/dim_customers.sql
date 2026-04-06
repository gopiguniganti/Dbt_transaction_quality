-- Mart: customer dimension enriched with transaction activity.

with customers as (

    select * from {{ ref('stg_customers') }}

),

transactions as (

    select * from {{ ref('stg_transactions') }}

),

customer_activity as (

    select
        customer_id,
        count(*)                              as transaction_count,
        sum(amount)                           as lifetime_amount,
        min(transaction_date)                 as first_transaction_date,
        max(transaction_date)                 as last_transaction_date
    from transactions
    group by 1

)

select
    c.customer_id,
    c.customer_name,
    c.country_code,
    c.segment,
    c.signup_date,
    coalesce(a.transaction_count, 0)          as transaction_count,
    coalesce(a.lifetime_amount, 0)            as lifetime_amount,
    a.first_transaction_date,
    a.last_transaction_date
from customers c
left join customer_activity a
    on c.customer_id = a.customer_id
