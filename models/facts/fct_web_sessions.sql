{{
    config(
        materialized='table'
    )
}}

with web_activity as (
    select * from {{ ref('stg_web_activity') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

products as (
    select * from {{ ref('dim_products') }}
)

select
    -- keys
    w.session_id,
    w.customer_id,                                          -- nullable: null for unauthenticated sessions
    w.product_id_viewed,
    w.session_date                                          as date_key,

    -- degenerate dimensions
    w.channel,
    w.device_type,

    -- descriptive context
    c.customer_segment,                                     -- null for unauthenticated sessions
    p.category                                              as product_category_viewed,
    p.subcategory                                           as product_subcategory_viewed,
    p.brand                                                 as product_brand_viewed,

    -- measures
    w.pages_viewed,
    w.converted,
    w.converted::int                                        as converted_flag  -- 1/0 for easy aggregation

from web_activity w
left join customers c on w.customer_id     = c.customer_id  -- left: unauthenticated sessions have no customer
left join products  p on w.product_id_viewed = p.product_id -- left: not all sessions view a product
