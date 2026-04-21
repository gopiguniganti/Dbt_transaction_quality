# Transaction Data Quality — dbt Project

A small but production-shaped [dbt](https://www.getdbt.com/) project that models raw
transaction data into analytics-ready marts and enforces **data quality and
source-to-target reconciliation** with dbt tests.

The theme is deliberate: it mirrors the balance-and-control discipline used in
regulated financial-services reporting, where every curated feed has to tie back
to its source exactly — no rows silently dropped, duplicated, or misstated.

Runs fully locally on [DuckDB](https://duckdb.org/) with no cloud account, so the
whole thing can be cloned and reproduced in one command.

## Architecture

```
seeds (raw)            staging (views)              marts (tables)
─────────────          ─────────────────            ──────────────────────────────
raw_customers    ──►   stg_customers        ──►     dim_customers
raw_transactions ──►   stg_transactions     ──►     fct_transactions
                                             ──►     fct_daily_transaction_summary
```

- **staging** — type-casting and standardisation only, one row per entity, no
  business logic. Every raw transaction row is preserved.
- **marts** — `dim_customers` (customer dimension with lifetime activity),
  `fct_transactions` (transaction grain), and `fct_daily_transaction_summary`
  (daily settled / pending / cancelled amounts per currency — the kind of curated
  feed a reporting or AML/fraud scenario layer would consume).

## Data quality & reconciliation

Tests run automatically as part of `dbt build`:

- **Schema tests** — `unique` and `not_null` on all keys, `relationships`
  (referential integrity) from transactions to customers, and `accepted_values`
  on `status`, `currency`, `country_code`, and `segment`.
- **Custom reconciliation test** —
  [`assert_source_to_mart_reconciliation`](tests/assert_source_to_mart_reconciliation.sql)
  asserts that `fct_transactions` preserves **both the row count and the total
  amount** of the raw source feed. If the pipeline ever drops, duplicates, or
  misstates a row, the counts or sums diverge and the test fails.

## Run it

```bash
pip install dbt-duckdb
dbt build --profiles-dir .      # seed, run, and test everything
```

Explore the lineage graph and model docs:

```bash
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

## Adapting to a real warehouse

The models are standard SQL and portable. To point the same project at PostgreSQL
(e.g. a self-hosted instance) instead of DuckDB, swap the adapter in
`profiles.yml` for `dbt-postgres` and supply connection details — the models,
tests, and reconciliation logic are unchanged.

## Stack

dbt Core · DuckDB · SQL
