-- Grain: one row per tenant and venue.

select * 
from {{ ref('int_venue') }}
