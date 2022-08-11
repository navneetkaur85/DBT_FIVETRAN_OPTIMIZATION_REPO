WITH TRAFFIC AS (
  SELECT
    TRAFFIC_TIME_CT,
    REPLACE(TRAFFIC_HOSTNAME, 'www.', '') AS TRAFFIC_HOSTNAME,
    TRAFFIC_CAMPAIGN,
    REPLACE(TRAFFIC_PAGE_PATH, 'datarebels', 'hashmap') AS TRAFFIC_PAGE_PATH_RAW,
    TRAFFIC_SOURCE_MEDIUM,
    TRAFFIC_TOTAL_USERS_CNT,
    TRAFFIC_NEW_USERS_CNT,
    TRAFFIC_PAGEVIEWS_CNT,
    TRAFFIC_SESSION_DURATION_AVG
  
  FROM
    {{ ref('stg_ga_hourly_traffic') }}
)

SELECT
  *,

  -- clean traffic metadata
  SPLIT_PART(TRAFFIC_PAGE_PATH_RAW, '?', 1)     AS TRAFFIC_PAGE_BASE_PATH,
  SPLIT_PART(TRAFFIC_SOURCE_MEDIUM, '/', 1)     AS TRAFFIC_SOURCE,
  SPLIT_PART(TRAFFIC_SOURCE_MEDIUM, '/', 2)     AS TRAFFIC_MEDIUM,

  -- Prepend hostname to page path when hostname is not the main hashmap site
  CASE 
    WHEN TRAFFIC_HOSTNAME = 'hashmapinc.com' THEN TRAFFIC_PAGE_BASE_PATH
    ELSE TRAFFIC_HOSTNAME || TRAFFIC_PAGE_BASE_PATH
  END AS TRAFFIC_PAGE

FROM
  TRAFFIC

WHERE 
  -- only include traffic from production hostnames - this excludes `localhost`, `0.0.0.0`, etc...
  TRAFFIC_HOSTNAME IN {{ hashmap_google_analytics_production_hostnames() }}