-- Grain: one row per tenant and customer.

with customers as (
    select * from {{ ref('stg_customers') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
),

dates as (
    select * from {{ ref('int_date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customers.tenant_id', 'customers.customer_id']) }} as customer_key,
    customers.customer_id,
    tenants.tenant_key,
    customers.tenant_id,
    dates.date_key as customer_created_date_key,
    customers.country_code,
    customers.created_at_utc
from customers
inner join tenants
    on customers.tenant_id = tenants.tenant_id
inner join dates
    on cast(customers.created_at_utc as date) = dates.date_day
