with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        CUSTOMER_ID                             as customer_id,
        lower(CUSTOMER_CITY)                    as customer_city,
        upper(CUSTOMER_STATE)                   as customer_state,
        CUSTOMER_ZIP_CODE_PREFIX                as customer_zip_code,
        current_timestamp()                     as _loaded_at
    from source
)

select * from renamed
