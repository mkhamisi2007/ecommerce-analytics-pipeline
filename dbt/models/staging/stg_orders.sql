with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        ORDER_ID                                        as order_id,
        CUSTOMER_ID                                     as customer_id,
        lower(ORDER_STATUS)                             as order_status,
        TO_DATE(ORDER_PURCHASE_TIMESTAMP)               as order_purchase_date,
        TO_DATE(ORDER_DELIVERED_CUSTOMER_DATE)          as order_delivered_date,
        TO_DATE(ORDER_ESTIMATED_DELIVERY_DATE)          as order_estimated_delivery_date,
        current_timestamp()                             as _loaded_at
    from source
)

select * from renamed
