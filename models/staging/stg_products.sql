{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('products_seed') }}
)

select
    product_id,
    product_name,
    lower(category)                                 as category,         -- 'electronics' | 'apparel' | 'footwear' | etc.
    lower(subcategory)                              as subcategory,
    brand,
    unit_price::numeric(10,2)                        as unit_price,       -- catalog retail price
    cost_price::numeric(10,2)                       as cost_price
from source
