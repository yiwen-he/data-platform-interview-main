-- Grain: one row per tenant.

with tenants as (
    select * from {{ ref('stg_tenants') }}
),

tenant_currency as (
    select * from {{ ref('int_tenant_currency') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['tenants.tenant_id']) }} as tenant_key,
    tenants.tenant_id,
    tenants.tenant_name,
    tenant_currency.home_currency,
    tenants.created_at_utc
from tenants
inner join tenant_currency
    on tenants.tenant_id = tenant_currency.tenant_id
