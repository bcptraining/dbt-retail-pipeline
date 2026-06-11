{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('order_items_seed') }}
)

select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price::numeric(10,2)                        as unit_price,       -- transaction price at time of sale
    discount_amount::numeric(10,2)                  as discount_amount
from source
