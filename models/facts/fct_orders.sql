{{
    config(
        materialized='view'
    )
}}

with order_items as (
    select * from {{ ref('fct_order_items') }}
)

select
    -- keys
    order_id,
    customer_id,
    store_id,
    date_key,

    -- degenerate dimensions
    order_status,
    channel,
    promo_code,

    -- descriptive context
    customer_segment,
    store_type,
    store_country,

    -- measures (aggregated from line items)
    count(order_item_id)        as line_item_count,
    sum(quantity)               as total_quantity,
    sum(gross_amount)           as total_gross_amount,
    sum(discount_amount)        as total_discount_amount,
    sum(net_amount)             as total_net_amount,
    sum(net_margin)             as total_net_margin

from order_items
group by
    order_id,
    customer_id,
    store_id,
    date_key,
    order_status,
    channel,
    promo_code,
    customer_segment,
    store_type,
    store_country
