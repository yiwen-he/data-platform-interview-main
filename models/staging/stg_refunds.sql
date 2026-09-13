-- Grain: one row per tenant and logical refund.

with source as (
    select * from {{ ref('raw_refunds') }}
),

cleaned as (
    select
        nullif(trim(refund_id), '') as refund_id,
        nullif(trim(order_id), '') as order_id,
        nullif(trim(tenant_id), '') as tenant_id,
        cast(refund_amount as decimal(18, 2)) as refund_amount,
        lower(nullif(trim(refund_status), '')) as refund_status,
        cast(created_at_utc as timestamp) as created_at_utc
    from source
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by tenant_id, refund_id, order_id
            order by created_at_utc desc
        ) as record_recency_rank
    from cleaned
)

select
    refund_id,
    order_id,
    tenant_id,
    refund_amount,
    refund_status,
    created_at_utc,
    {{ dbt_audit_columns() }}
from deduplicated
where record_recency_rank = 1
