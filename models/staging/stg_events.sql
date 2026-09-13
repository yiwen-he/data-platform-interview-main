-- Grain: one row per tenant and event.

with source as (
    select * from {{ ref('raw_events') }}
)

select
    nullif(trim(event_id), '') as event_id,
    nullif(trim(tenant_id), '') as tenant_id,
    nullif(trim(venue_id), '') as venue_id,
    nullif(trim(event_name), '') as event_name,
    cast(event_start_utc as timestamp) as event_start_utc,
    {{ dbt_audit_columns() }}
from source
