{% snapshot orders_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='order_id',
        strategy='check',
        check_cols=['order_status', 'order_delivered_date'],
    )
}}

select * from {{ ref('stg_orders') }}

{% endsnapshot %}
