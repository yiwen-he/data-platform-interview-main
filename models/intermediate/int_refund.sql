-- Grain: one current row per tenant and refund.

with refunds as (
    select * from {{ ref('stg_refunds') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
),

dates as (
    select * from {{ ref('int_date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['refunds.tenant_id', 'refunds.refund_id']) }} as refund_key,
    refunds.refund_id,
    tenants.tenant_key,
    refunds.tenant_id,
    refunds.order_id,
    dates.date_key as refund_created_date_key,
    refunds.refund_amount,
    orders.currency,
    refunds.refund_status,
    refunds.created_at_utc
from refunds
inner join orders
    on refunds.tenant_id = orders.tenant_id
    and refunds.order_id = orders.order_id
inner join tenants
    on refunds.tenant_id = tenants.tenant_id
inner join dates
    on cast(refunds.created_at_utc as date) = dates.date_day
