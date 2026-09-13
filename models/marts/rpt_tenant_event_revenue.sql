-- Grain: one row per tenant, event, and currency.

with revenue as (
    select * from {{ ref('fct_order_revenue') }}
),

tenants as (
    select * from {{ ref('dim_tenant') }}
),

events as (
    select * from {{ ref('dim_event') }}
)

select
    revenue.tenant_key,
    revenue.tenant_id,
    tenants.tenant_name,
    revenue.event_key,
    revenue.event_id,
    events.event_name,
    revenue.currency,
    count(*) as completed_order_count,
    sum(revenue.gross_revenue_amount) as gross_revenue_amount,
    sum(revenue.tax_amount) as tax_amount,
    sum(revenue.completed_refund_amount) as completed_refund_amount,
    sum(revenue.net_revenue_amount) as net_revenue_amount
from revenue
inner join tenants
    on revenue.tenant_key = tenants.tenant_key
inner join events
    on revenue.event_key = events.event_key
group by
    revenue.tenant_key,
    revenue.tenant_id,
    tenants.tenant_name,
    revenue.event_key,
    revenue.event_id,
    events.event_name,
    revenue.currency
