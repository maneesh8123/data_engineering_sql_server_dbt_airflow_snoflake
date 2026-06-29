{% set sql_header %}
SET IDENTITY_INSERT [fa9710018].[asset_tracking].[assets] ON;
{% endset %}

{{
  config(
    materialized='incremental',
    unique_key='asset_code',
    merge_exclude_columns=['TagCode'],
    sql_header=sql_header,
    post_hook="SET IDENTITY_INSERT [fa9710018].[asset_tracking].[assets] OFF;",
    as_columnstore=false  )
}}


SELECT
    *
FROM {{ source('dbo','tbl_fa_asset') }}
{% if is_incremental() %}
    WHERE updated_date > (
        SELECT MAX(updated_date)
        FROM {{ this }}
    )
{% endif %}