-- Grain: one row per tenant and ticket.

with source as (
    select * from {{ ref('raw_tickets') }}
)

select
    nullif(trim(ticket_id), '') as ticket_id,
    nullif(trim(order_id), '') as order_id,
    nullif(trim(tenant_id), '') as tenant_id,
    nullif(trim(event_id), '') as event_id,
    lower(nullif(trim(ticket_status), '')) as ticket_status,
    cast(price as decimal(18, 2)) as price,
    {{ dbt_audit_columns() }}
from source
