-- Grain: one current row per tenant and order.

with orders as (
    select * from {{ ref('stg_orders') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
),

events as (
    select * from {{ ref('int_event') }}
),

customers as (
    select * from {{ ref('int_customer') }}
),

dates as (
    select * from {{ ref('int_date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['orders.tenant_id', 'orders.order_id']) }} as order_key,
    orders.order_id,
    tenants.tenant_key,
    orders.tenant_id,
    events.event_key,
    orders.event_id,
    customers.customer_key,
    orders.customer_id,
    dates.date_key as order_created_date_key,
    orders.gross_amount,
    orders.fee_amount,
    orders.tax_amount,
    orders.currency,
    orders.order_status,
    orders.created_at_utc
from orders
inner join tenants
    on orders.tenant_id = tenants.tenant_id
inner join events
    on orders.tenant_id = events.tenant_id
    and orders.event_id = events.event_id
inner join customers
    on orders.tenant_id = customers.tenant_id
    and orders.customer_id = customers.customer_id
inner join dates
    on cast(orders.created_at_utc as date) = dates.date_day
