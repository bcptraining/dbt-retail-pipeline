{{
    config(
        materialized='table'
    )
}}

with inventory as (
    select * from {{ ref('stg_inventory') }}
),

products as (
    select * from {{ ref('dim_products') }}
),

stores as (
    select * from {{ ref('dim_stores') }}
)

select
    inv.inventory_id,
    inv.product_id,
    inv.store_id,
    inv.restock_date                                                     as date_key,

    -- denormalized product attributes
    p.product_name,
    p.category                                                           as product_category,
    p.subcategory                                                        as product_subcategory,
    p.brand                                                              as product_brand,
    p.cost_price,

    -- denormalized store attributes
    s.store_name,
    s.store_type,
    s.city                                                               as store_city,
    s.state                                                              as store_state,

    -- measures
    inv.quantity_on_hand,
    inv.reorder_level,

    -- derived
    case when inv.quantity_on_hand < inv.reorder_level then 1 else 0 end as below_reorder_flag,
    greatest(inv.reorder_level - inv.quantity_on_hand, 0)               as units_needed,
    inv.quantity_on_hand * p.cost_price                                  as inventory_value

from inventory inv
inner join products p
    on inv.product_id = p.product_id
inner join stores s
    on inv.store_id = s.store_id
