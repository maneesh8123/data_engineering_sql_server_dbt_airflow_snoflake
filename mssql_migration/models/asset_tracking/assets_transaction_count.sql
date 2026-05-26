WITH base AS (
                SELECT
                    a.asset_code,
                    a.asset_name,
                    a.Udf01,
                    a.Udf04,
                    a.Udf05,
                    rf.EpcHex,
                    rf.AntennaPort,
                    rf.ScannedTime,
                    CASE 
                        WHEN rf.AntennaPort IN (1,2) THEN 'IN'
                        WHEN rf.AntennaPort IN (3,4) THEN 'OUT'
                    END AS Direction
                FROM {{ ref('assets') }} a
                JOIN {{ ref('rfid_data') }} rf
                    ON a.RFID = rf.EpcHex
),
ordered AS (
    SELECT *,
        LAG(ScannedTime) OVER (
            PARTITION BY EpcHex, Direction
            ORDER BY ScannedTime
        ) AS PrevTime
    FROM base
),
filtered AS (
    SELECT *
    FROM ordered
    WHERE PrevTime IS NULL
       OR DATEDIFF(MINUTE, PrevTime, ScannedTime) >= 10
)
SELECT
    asset_code AS [Asset Code],
    asset_name AS [Asset Name],
    Udf01 AS 'SAP Code',
    SUM(CASE WHEN Direction = 'IN' THEN 1 ELSE 0 END) AS InCount,
    SUM(CASE WHEN Direction = 'OUT' THEN 1 ELSE 0 END) AS OutCount,
    Udf04 AS PlateNo,
    Udf05 AS ChassisNo
FROM filtered
GROUP BY 
    asset_code,
    asset_name,
    Udf01,
    Udf04,
    Udf05
-- ORDER BY 
--     InCount DESC,OutCount DESC 
    
