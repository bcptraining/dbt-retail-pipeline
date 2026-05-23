{{ config(materialized='table') }}

with date_spine as (
    select generate_series(
        '2020-01-01'::date,
        '2030-12-31'::date,
        '1 day'::interval
    )::date as date_day
)

select
    date_day                                                                as date_key,
    extract(year from date_day)::int                                        as year,
    extract(quarter from date_day)::int                                     as quarter,
    'Q' || extract(quarter from date_day)::int                             as quarter_name,
    extract(month from date_day)::int                                       as month,
    to_char(date_day, 'Month')                                             as month_name,
    to_char(date_day, 'Mon')                                               as month_short,
    extract(week from date_day)::int                                        as week_of_year,
    extract(day from date_day)::int                                         as day_of_month,
    extract(doy from date_day)::int                                         as day_of_year,
    extract(dow from date_day)::int                                         as day_of_week,
    to_char(date_day, 'Day')                                               as day_name,
    to_char(date_day, 'Dy')                                                as day_short,
    case when extract(dow from date_day) in (0, 6) then true else false end as is_weekend,
    extract(year from date_day)::int * 100
        + extract(month from date_day)::int                                 as year_month_key,
    to_char(date_day, 'YYYY-MM')                                           as year_month,
    extract(year from date_day)::int * 100
        + extract(quarter from date_day)::int                               as year_quarter_key,
    'Q' || extract(quarter from date_day)::int
        || ' ' || extract(year from date_day)::int                         as year_quarter

from date_spine
