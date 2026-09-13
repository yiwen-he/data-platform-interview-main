-- Grain: one row per tenant and venue.

with source as (
    select * from {{ ref('raw_venues') }}
)

select
    nullif(trim(venue_id), '') as venue_id,
    nullif(trim(tenant_id), '') as tenant_id,
    nullif(trim(venue_name), '') as venue_name,
    nullif(trim(city), '') as city,
    nullif(trim(timezone), '') as timezone,
    cast(capacity as integer) as capacity,
    {{ dbt_audit_columns() }}
from source
