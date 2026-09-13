-- Grain: one row per tenant and order.

with source as (
    select * from {{ ref('raw_orders') }}
),

cleaned as (
    select
        nullif(trim(order_id), '') as order_id,
        nullif(trim(tenant_id), '') as tenant_id,
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(event_id), '') as event_id,
        lower(nullif(trim(order_status), '')) as order_status,
        cast(gross_amount as decimal(18, 2)) as gross_amount,
        cast(fee_amount as decimal(18, 2)) as fee_amount,
        cast(tax_amount as decimal(18, 2)) as tax_amount,
        upper(nullif(trim(currency), '')) as currency,
        cast(created_at_utc as timestamp) as created_at_utc
    from source
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by tenant_id, order_id
            order by created_at_utc desc
        ) as record_recency_rank
    from cleaned
)

select
    order_id,
    tenant_id,
    customer_id,
    event_id,
    order_status,
    gross_amount,
    fee_amount,
    tax_amount,
    currency,
    created_at_utc,
    {{ dbt_audit_columns() }}
from deduplicated
where record_recency_rank = 1
