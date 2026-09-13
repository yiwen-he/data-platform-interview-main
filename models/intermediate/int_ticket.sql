-- Grain: one current row per tenant and ticket.

with tickets as (
    select * from {{ ref('stg_tickets') }}
),

orders as (
    select * from {{ ref('int_order') }}
),

events as (
    select * from {{ ref('int_event') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['tickets.tenant_id', 'tickets.ticket_id']) }} as ticket_key,
    tickets.ticket_id,
    orders.tenant_key,
    tickets.tenant_id,
    orders.order_key,
    tickets.order_id,
    events.event_key,
    tickets.event_id,
    tickets.price,
    orders.currency,
    tickets.ticket_status
from tickets
inner join orders
    on tickets.tenant_id = orders.tenant_id
    and tickets.order_id = orders.order_id
    and tickets.event_id = orders.event_id
inner join events
    on tickets.tenant_id = events.tenant_id
    and tickets.event_id = events.event_id
