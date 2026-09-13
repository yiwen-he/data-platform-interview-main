{% snapshot snap_refund_status %}

{{
    config(
        target_schema='snapshots',
        unique_key='refund_key',
        strategy='check',
        check_cols=['refund_status'],
        invalidate_hard_deletes=True
    )
}}

select
    refund_key,
    refund_id,
    tenant_key,
    tenant_id,
    order_id,
    refund_created_date_key,
    refund_status,
    created_at_utc
from {{ ref('int_refund') }}

{% endsnapshot %}
