-- Grain: one row per tenant and venue.

with venues as (
    select * from {{ ref('stg_venues') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['venues.tenant_id', 'venues.venue_id']) }} as venue_key,
    venues.venue_id,
    tenants.tenant_key,
    venues.tenant_id,
    venues.venue_name,
    venues.city,
    venues.timezone,
    venues.capacity
from venues
inner join tenants
    on venues.tenant_id = tenants.tenant_id
