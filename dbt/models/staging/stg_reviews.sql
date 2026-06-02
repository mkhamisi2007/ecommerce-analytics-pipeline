with source as (
    select * from {{ source('raw', 'reviews') }}
),

renamed as (
    select
        REVIEW_ID                               as review_id,
        ORDER_ID                                as order_id,
        cast(REVIEW_SCORE as integer)           as review_score,
        TO_DATE(REVIEW_CREATION_DATE)           as review_creation_date,
        current_timestamp()                     as _loaded_at
    from source
)

select * from renamed
