{% snapshot snap_order_status %}

{{
    config(
        target_schema='snapshots',
        unique_key='order_key',
        strategy='check',
        check_cols=['order_status'],
        invalidate_hard_deletes=True
    )
}}

select
    order_key,
    order_id,
    tenant_key,
    tenant_id,
    event_key,
    event_id,
    customer_key,
    customer_id,
    order_created_date_key,
    order_status,
    created_at_utc
from {{ ref('int_order') }}

{% endsnapshot %}
