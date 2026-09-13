-- Grain: one row per calendar date.
-- This is a shared, non-tenant dimension: a date contains no tenant-owned data.

select * 
from {{ ref('int_date') }}
