with source as (
    select * from {{ source('raw', 'order_items') }}
),

renamed as (
    select
        ORDER_ID                                        as order_id,
        PRODUCT_ID                                      as product_id,
        SELLER_ID                                       as seller_id,
        cast(PRICE as numeric(10, 2))                   as item_price,
        cast(FREIGHT_VALUE as numeric(10, 2))           as freight_value,
        cast(PRICE + FREIGHT_VALUE as numeric(10, 2))   as total_item_price,
        current_timestamp()                             as _loaded_at
    from source
)

select * from renamed
