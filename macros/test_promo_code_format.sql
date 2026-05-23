{% test promo_code_format(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} !~ '^[A-Za-z0-9]+$'

{% endtest %}
