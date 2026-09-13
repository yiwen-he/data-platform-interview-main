-- Grain: one row per trusted, current tenant-scoped refund.

select *
from {{ ref('int_refund') }}
