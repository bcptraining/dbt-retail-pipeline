{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('payments_seed') }}
)

select
    payment_id,
    order_id,
    payment_date,
    payment_method,                                 -- already snake_case: 'credit_card' | 'debit_card' | 'cash' | 'paypal' | 'store_credit'
    lower(payment_status)                           as payment_status,   -- 'pending' | 'completed' | 'refunded' | 'voided'
    amount::numeric(10,2)                           as payment_amount    -- renamed: 'amount' was too generic
from source
