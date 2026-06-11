{{
    config(
        materialized='table'
    )
}}

with staged as (
    select * from {{ ref('stg_products') }}
)

select
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    unit_price,
    cost_price
from staged
