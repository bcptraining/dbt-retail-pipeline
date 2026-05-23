{% macro generate_schema_name(custom_schema_name, node) -%}

  {%- set default_schema = target.schema -%}

  {%- if custom_schema_name is none -%}

    {{ default_schema }}

  {%- elif target.name == 'prod' or target.name == 'qa' -%}

    {#- prod and qa: use clean layer names with no prefix -#}
    {{ custom_schema_name | trim }}

  {%- else -%}

    {#- dev: prefix with personal sandbox schema so developers don't collide -#}
    {{ default_schema }}_{{ custom_schema_name | trim }}

  {%- endif -%}

{%- endmacro %}
