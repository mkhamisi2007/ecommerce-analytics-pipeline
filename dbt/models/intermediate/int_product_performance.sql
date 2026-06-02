with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

reviews as (
    select * from {{ ref('stg_reviews') }}
),

items_with_reviews as (
    select
        oi.order_id,
        oi.product_id,
        oi.total_item_price,
        r.review_score
    from order_items oi
    left join reviews r using (order_id)
),

aggregated as (
    select
        iwr.product_id,
        p.product_category,
        cast(sum(iwr.total_item_price)      as numeric(10, 2))  as total_revenue,
        count(distinct iwr.order_id)                            as total_units_sold,
        cast(avg(iwr.review_score)          as numeric(4, 2))   as avg_review_score,
        cast(
            sum(case when iwr.review_score <= 2 then 1 else 0 end)
            / nullif(count(*), 0)
            as numeric(5, 4)
        )                                                       as return_rate
    from items_with_reviews iwr
    left join products p using (product_id)
    group by iwr.product_id, p.product_category
)

select * from aggregated
