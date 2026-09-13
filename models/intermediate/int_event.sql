-- Grain: one row per tenant and event.

with events as (
    select * from {{ ref('stg_events') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
),

venues as (
    select * from {{ ref('int_venue') }}
),

dates as (
    select * from {{ ref('int_date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['events.tenant_id', 'events.event_id']) }} as event_key,
    events.event_id,
    tenants.tenant_key,
    events.tenant_id,
    venues.venue_key,
    events.venue_id,
    dates.date_key as event_date_key,
    events.event_name,
    events.event_start_utc
from events
inner join tenants
    on events.tenant_id = tenants.tenant_id
inner join venues
    on events.tenant_id = venues.tenant_id
    and events.venue_id = venues.venue_id
inner join dates
    on cast(events.event_start_utc as date) = dates.date_day
