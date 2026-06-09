{{
  config(
    materialized='table',
    as_columnstore=false  )
}}


SELECT
    *
FROM {{ source('dbo','tbl_fa_asset') }}