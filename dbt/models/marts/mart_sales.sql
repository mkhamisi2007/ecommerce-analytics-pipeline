with orders as (
    select *
    from {{ ref('int_orders_with_customers') }}
    where order_purchase_date >= '{{ var("start_date", "2017-01-01") }}'
),

monthly as (
    select
        DATE_TRUNC('month', order_purchase_date)                as month,
        cast(sum(order_total) as numeric(14, 2))                as total_revenue,
        count(distinct order_id)                                as total_orders,
        cast(avg(order_total) as numeric(10, 2))                as average_order_value,
        cast(
            sum(case when is_late = false then 1 else 0 end)
            / nullif(count(case when is_late is not null then 1 end), 0)
            as numeric(5, 4)
        )                                                       as on_time_delivery_rate,
        count(distinct customer_id)                             as new_customers
    from orders
    group by DATE_TRUNC('month', order_purchase_date)
),

final as (
    select
        {{ generate_surrogate_key(['month']) }}  as sales_id,
        month,
        total_revenue,
        total_orders,
        average_order_value,
        on_time_delivery_rate,
        new_customers
    from monthly
)

select * from final
