{{ config(tags=["aws_usage", "azure_usage", "snowflake_usage", "cloud_usage", "daily"]) }}

WITH

AWS_COSTS AS (
  SELECT
    START_DATE_CENTRAL_TIME AS DATETIME_CENTRAL_TIME,
    COST                    AS COST,
    'AWS'                   AS CLOUD
  FROM  
    {{ ref('hashmap_aws_costs') }}
),

AZURE_COSTS AS (
  SELECT
    DATE        AS DATETIME_CENTRAL_TIME,
    COST_IN_USD AS COST,
    'Azure'     AS CLOUD
  FROM  
    {{ ref('hashmap_azure_costs') }}
),

COSTS AS (
  SELECT * FROM AWS_COSTS
  UNION ALL
  SELECT * FROM AZURE_COSTS
  )

SELECT * FROM COSTS