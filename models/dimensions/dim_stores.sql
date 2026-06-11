{{
    config(
        materialized='table'
    )
}}

with staged as (
    select * from {{ ref('stg_stores') }}
)

select
    store_id,
    store_name,
    store_type,
    city,
    state,
    country,
    opened_date
from staged
