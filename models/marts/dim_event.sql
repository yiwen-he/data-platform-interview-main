-- Grain: one row per tenant and event.

select * 
from {{ ref('int_event') }}
