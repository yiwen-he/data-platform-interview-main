{{ config(severity='warn') }}

-- Refund and order IDs are tenant-scoped, so both identifiers are required in
-- the join. Any returned row is a refund timestamped before its parent order.
select
    refunds.tenant_id,
    refunds.refund_id,
    refunds.order_id,
    refunds.created_at_utc as refund_created_at_utc,
    orders.created_at_utc as order_created_at_utc
from {{ ref('stg_refunds') }} as refunds
inner join {{ ref('stg_orders') }} as orders
    on refunds.tenant_id = orders.tenant_id
    and refunds.order_id = orders.order_id
where refunds.created_at_utc < orders.created_at_utc
