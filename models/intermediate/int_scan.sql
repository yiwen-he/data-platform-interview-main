-- Grain: one row per trusted tenant-scoped scan attempt.

with scans as (
    select * from {{ ref('stg_scans') }}
),

tenants as (
    select * from {{ ref('int_tenant') }}
),

tickets as (
    select * from {{ ref('int_ticket') }}
),

dates as (
    select * from {{ ref('int_date') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['scans.tenant_id', 'scans.scan_id']) }} as scan_key,
    scans.scan_id,
    tenants.tenant_key,
    scans.tenant_id,
    tickets.ticket_key,
    scans.ticket_id,
    tickets.order_key,
    tickets.order_id,
    tickets.event_key,
    tickets.event_id,
    dates.date_key as scan_date_key,
    scans.scanned_at_utc,
    scans.gate
from scans
inner join tenants
    on scans.tenant_id = tenants.tenant_id
inner join tickets
    on scans.tenant_id = tickets.tenant_id
    and scans.ticket_id = tickets.ticket_id
inner join dates
    on cast(scans.scanned_at_utc as date) = dates.date_day
