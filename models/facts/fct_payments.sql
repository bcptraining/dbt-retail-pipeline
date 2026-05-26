{{
    config(
        materialized='table'
    )
}}

with payments as (
    select * from {{ ref('stg_payments') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
)

select
    -- keys
    p.payment_id,
    p.order_id,
    o.customer_id,
    o.store_id,
    p.payment_date                                          as date_key,

    -- degenerate dimensions
    p.payment_method,
    p.payment_status,
    o.channel,

    -- descriptive context
    c.customer_segment,

    -- measures
    p.payment_amount,
    p.payment_date - o.order_date::date                     as days_to_payment

from payments p
inner join orders    o on p.order_id    = o.order_id
inner join customers c on o.customer_id = c.customer_id
