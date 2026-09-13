-- Grain: one row per tenant and order with at least one completed refund.

with completed_refunds as (
    select *
    from {{ ref('int_refund') }}
    where refund_status = 'completed'
)

select
    tenant_id,
    order_id,
    count(*) as completed_refund_count,
    sum(refund_amount) as completed_refund_amount
from completed_refunds
group by tenant_id, order_id
