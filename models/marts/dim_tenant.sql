-- Grain: one row per tenant.

select * 
from {{ ref('int_tenant') }}
