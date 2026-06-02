-- Fails if any order has a purchase date in the future
select *
from {{ ref('stg_orders') }}
where order_purchase_date > current_date()
