-- EXAMPLE MODEL — provided so the project builds out of the box.
-- It demonstrates the dbt + DuckDB setup working against the seed data.
-- Replace or delete it; you are not expected to keep this structure.

select
    tenant_id,
    tenant_name,
    cast(created_at_utc as timestamp) as created_at_utc
from {{ ref('raw_tenants') }}
