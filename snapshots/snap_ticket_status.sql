{% snapshot snap_ticket_status %}

{{
    config(
        target_schema='snapshots',
        unique_key='ticket_key',
        strategy='check',
        check_cols=['ticket_status'],
        invalidate_hard_deletes=True
    )
}}

select
    ticket_key,
    ticket_id,
    tenant_key,
    tenant_id,
    order_key,
    order_id,
    event_key,
    event_id,
    ticket_status
from {{ ref('int_ticket') }}

{% endsnapshot %}
