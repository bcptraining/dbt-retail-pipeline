{% test phone_format(model, column_name) %}

select *
from {{ model }}
where {{ column_name }} is not null
  and {{ column_name }} !~ '^\d{3}-\d{3}-\d{4}$'

{% endtest %}
