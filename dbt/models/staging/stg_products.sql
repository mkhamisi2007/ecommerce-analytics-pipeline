with source as (
    select * from {{ source('raw', 'products') }}
),

renamed as (
    select
        PRODUCT_ID                                      as product_id,
        lower(PRODUCT_CATEGORY_NAME)                    as product_category,
        cast(PRODUCT_WEIGHT_G as numeric(10, 2))        as product_weight_g,
        cast(PRODUCT_LENGTH_CM as numeric(10, 2))       as product_length_cm,
        current_timestamp()                             as _loaded_at
    from source
)

select * from renamed
