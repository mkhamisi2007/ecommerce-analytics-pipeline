with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select
        order_id,
        sum(total_item_price) as order_total
    from {{ ref('stg_order_items') }}
    group by order_id
),

customers as (
    select * from {{ ref('stg_customers') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_date,
        o.order_delivered_date,
        o.order_estimated_delivery_date,
        coalesce(oi.order_total, 0)                                             as order_total,
        c.customer_city,
        c.customer_state,
        c.customer_zip_code,
        DATEDIFF('day', o.order_purchase_date, o.order_delivered_date)          as days_to_deliver,
        case
            when o.order_delivered_date is null                               then null
            when o.order_delivered_date > o.order_estimated_delivery_date     then true
            else false
        end                                                                     as is_late
    from orders o
    left join order_items oi using (order_id)
    left join customers   c  using (customer_id)
)

select * from joined
