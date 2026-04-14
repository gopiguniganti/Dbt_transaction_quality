-- Singular test: source-to-mart reconciliation.
-- Asserts that the transaction fact table preserves BOTH the row count and
-- the total amount of the raw source feed. This is a balance-and-control
-- check: if the pipeline silently drops, duplicates, or misstates rows, the
-- counts or sums diverge and this test returns a row (which fails the test).
--
-- A singular dbt test passes when it returns zero rows.

with source_totals as (

    select
        count(*)     as source_row_count,
        sum(amount)  as source_total_amount
    from {{ ref('stg_transactions') }}

),

mart_totals as (

    select
        count(*)     as mart_row_count,
        sum(amount)  as mart_total_amount
    from {{ ref('fct_transactions') }}

)

select
    s.source_row_count,
    m.mart_row_count,
    s.source_total_amount,
    m.mart_total_amount
from source_totals s
cross join mart_totals m
where s.source_row_count   <> m.mart_row_count
   or s.source_total_amount <> m.mart_total_amount
