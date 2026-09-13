-- Grain: one row per trusted tenant-scoped event-entry scan attempt.

select *
from {{ ref('int_scan') }}
