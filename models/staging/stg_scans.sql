-- Grain: one row per tenant and scan attempt.

with source as (
    select * from {{ ref('raw_scans') }}
)

select
    nullif(trim(scan_id), '') as scan_id,
    nullif(trim(ticket_id), '') as ticket_id,
    nullif(trim(tenant_id), '') as tenant_id,
    cast(scanned_at_utc as timestamp) as scanned_at_utc,
    nullif(trim(gate), '') as gate,
    {{ dbt_audit_columns() }}
from source
