{{
    config(
        materialized='table'
    )
}}

with order_items as (
    select * from {{ ref('order_items_seed') }}
),

orders as (
    select * from {{ ref('orders_seed') }}
),

customers as (
    select * from {{ ref('customers_seed') }}
),

products as (
    select * from {{ ref('products_seed') }}
),

stores as (
    select * from {{ ref('stores_seed') }}
)

select
    -- keys
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    oi.product_id,
    o.store_id,
    o.order_date                                                        as date_key,

    -- degenerate dimensions (transaction attributes, no separate dim needed)
    o.order_status,
    o.channel,
    o.promo_code,

    -- descriptive context (avoid joins in downstream queries)
    c.customer_segment,
    p.category                                                          as product_category,
    p.subcategory                                                       as product_subcategory,
    p.brand                                                             as product_brand,
    s.store_type,
    s.country                                                           as store_country,

    -- measures
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    (oi.quantity * oi.unit_price)                                       as gross_amount,
    (oi.quantity * oi.unit_price) - oi.discount_amount                  as net_amount,
    (oi.unit_price - p.cost_price)                                      as unit_margin,
    (oi.quantity * (oi.unit_price - p.cost_price)) - oi.discount_amount as net_margin

from order_items oi
inner join orders     o  on oi.order_id   = o.order_id
inner join customers  c  on o.customer_id = c.customer_id
inner join products   p  on oi.product_id = p.product_id
inner join stores     s  on o.store_id    = s.store_id
