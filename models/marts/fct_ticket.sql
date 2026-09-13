-- Grain: one row per trusted, current tenant-scoped ticket.

select *
from {{ ref('int_ticket') }}
