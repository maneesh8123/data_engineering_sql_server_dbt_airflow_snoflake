{{ config(materialized='table') }}


SELECT
    *
FROM {{ source('dbo','tbl_rfid_data') }}