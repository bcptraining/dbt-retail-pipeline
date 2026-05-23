{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('customers_seed') }}
)

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    state,
    country,                                        -- kept uppercase: ISO geographic code (USA, UK)
    signup_date,
    lower(customer_segment)                         as customer_segment  -- 'premium' | 'standard' | 'budget'
from source
