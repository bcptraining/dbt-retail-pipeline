{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('orders_seed') }}
)

select
    order_id,
    customer_id,
    store_id,
    order_date,
    lower(order_status)                             as order_status,     -- 'completed' | 'shipped' | 'cancelled' | 'returned'
    channel,                                        -- already lowercase: 'web' | 'store' | 'mobile'
    promo_code
from source
