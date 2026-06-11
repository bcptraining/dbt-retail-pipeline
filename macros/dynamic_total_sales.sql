{% macro
dynamic_total_sales(column_name='1',
alias='total_sales') %}
sum({{ column_name }}) as {{alias }}
{% endmacro %}
