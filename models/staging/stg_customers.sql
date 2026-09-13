-- Grain: one row per tenant and customer.
-- Direct identifiers (email and full_name) are deliberately not exposed because
-- they are not required for the revenue use case.

with source as (
    select * from {{ ref('raw_customers') }}
),

cleaned as (
    select
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(tenant_id), '') as tenant_id,
        upper(nullif(trim(country), '')) as country_code,
        cast(created_at_utc as timestamp) as created_at_utc
    from source
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by tenant_id, customer_id
            order by created_at_utc desc
        ) as record_recency_rank
    from cleaned
)

select
    customer_id,
    tenant_id,
    country_code,
    created_at_utc,
    {{ dbt_audit_columns() }}
from deduplicated
where record_recency_rank = 1
