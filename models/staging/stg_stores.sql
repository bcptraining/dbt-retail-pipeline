{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('stores_seed') }}
)

select
    store_id,
    store_name,
    store_type,                                     -- already lowercase: 'physical' | 'online' | 'mobile'
    city,                                           -- null for online/mobile stores
    state,                                          -- null for online/mobile stores; kept uppercase: ISO state code
    country,                                        -- kept uppercase: ISO geographic code (USA)
    opened_date
from source
