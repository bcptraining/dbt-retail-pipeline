{{
    config(
        materialized='view'
    )
}}

with source as (
    select * from {{ ref('web_activity_seed') }}
)

select
    session_id,
    customer_id,                                    -- null for unauthenticated sessions
    session_date,
    pages_viewed,
    product_id_viewed,
    channel,                                        -- already snake_case: 'organic_search' | 'direct' | 'email' | 'paid_search' | 'social_media'
    device_type,                                    -- already lowercase: 'desktop' | 'mobile' | 'tablet'
    converted::boolean                              as converted         -- cast from varchar 'true'/'false'
from source
