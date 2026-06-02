with product_performance as (
    select * from {{ ref('int_product_performance') }}
),

final as (
    select
        product_id,
        product_category,
        total_revenue,
        total_units_sold,
        avg_review_score,
        return_rate,
        {{ performance_tier('total_revenue') }}  as performance_tier
    from product_performance
)

select * from final
