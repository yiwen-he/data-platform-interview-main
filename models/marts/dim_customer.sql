-- Grain: one row per tenant and customer.

select * 
from {{ ref('int_customer') }}
