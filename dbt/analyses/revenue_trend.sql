-- Ad-hoc revenue trend analysis (not compiled into production runs)
select
    month,
    total_revenue,
    total_orders,
    average_order_value,
    lag(total_revenue) over (order by month)    as prev_month_revenue,
    total_revenue
        - lag(total_revenue) over (order by month)  as revenue_delta
from {{ ref('mart_sales') }}
order by month
