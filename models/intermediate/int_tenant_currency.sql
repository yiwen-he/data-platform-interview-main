-- Grain: one row per tenant with its configured home currency.
-- These mappings are supplied by docs/BUSINESS_CONTEXT.md.

select
    'T1' as tenant_id,
    'USD' as home_currency

union all

select
    'T2' as tenant_id,
    'GBP' as home_currency
