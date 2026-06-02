-- Fails if any order line item has a zero or negative price
select *
from {{ ref('stg_order_items') }}
where item_price <= 0
