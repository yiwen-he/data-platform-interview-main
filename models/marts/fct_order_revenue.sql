-- Grain: one row per trusted, currently completed tenant order.

with orders as (
    select * from {{ ref('int_order') }}
),


completed_refunds as (
    select * from {{ ref('int_completed_refunds_by_order') }}
)

select
    orders.order_key,
    orders.order_id,
    orders.tenant_key,
    orders.tenant_id,
    orders.event_key,
    orders.event_id,
    orders.customer_key,
    orders.customer_id,
    orders.order_created_date_key as order_date_key,
    orders.currency,
    orders.created_at_utc as order_created_at_utc,
    orders.gross_amount as gross_revenue_amount,
    orders.fee_amount as platform_fee_amount,
    orders.tax_amount as tax_amount,
    coalesce(completed_refunds.completed_refund_count, 0) as completed_refund_count,
    coalesce(completed_refunds.completed_refund_amount, 0) as completed_refund_amount,
    orders.gross_amount - orders.tax_amount as gross_less_tax_amount,
    orders.gross_amount - orders.tax_amount - coalesce(completed_refunds.completed_refund_amount, 0) as net_revenue_amount
from orders
left join completed_refunds
    on orders.tenant_id = completed_refunds.tenant_id
    and orders.order_id = completed_refunds.order_id
where orders.order_status = 'completed'
