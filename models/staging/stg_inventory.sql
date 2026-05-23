{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('inventory_seed') }}
)

select
    inventory_id,
    product_id,
    store_id,
    quantity_on_hand,
    reorder_level,
    restock_date
from source
