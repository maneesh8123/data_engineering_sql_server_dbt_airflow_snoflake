{% set sql_header %}
SET IDENTITY_INSERT [fa9710018].[asset_tracking].[rfid_data] ON;
{% endset %}


    {#
        merge_exclude_columns=['ID'] prevents ID updates
        sql_header enables IDENTITY_INSERT ON before merge
        post_hook disables IDENTITY_INSERT OFF after merge
     #}

{{ 
    config(
    materialized='incremental',
    unique_key='ID',
    merge_exclude_columns=['ID'],
    sql_header=sql_header,
    post_hook="SET IDENTITY_INSERT [fa9710018].[asset_tracking].[rfid_data] OFF;"
) }}


SELECT
    {# ID,
    ScannedTime,
    EpcHex,
    AntennaPort,
    AntennaName #}
    *
FROM {{ source('dbo','tbl_rfid_data') }}

{% if is_incremental() %}
    WHERE ID > (
        SELECT COALESCE(MAX(ID), 0)
        FROM {{ this }}
    )
{% endif %}