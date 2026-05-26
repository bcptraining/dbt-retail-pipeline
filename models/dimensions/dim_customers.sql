{{
    config(
        materialized='table'
    )
}}

with staged as (
    select * from {{ ref('stg_customers') }}
)

select
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    state,
    country,
    signup_date,
    customer_segment
from staged
