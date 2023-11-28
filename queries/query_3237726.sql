-- Aggregator by volume 📢
-- https://dune.com/queries/3237726


WITH
  seven_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '7' day
    GROUP BY
      1
  ),
  one_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '1' day
    GROUP BY
      1
  )
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      SUM(seven.usd_volume) DESC NULLS FIRST
  ) AS "Rank",
  seven."Project",
  SUM(seven.usd_volume) AS "7 Days Volume",
  SUM(one.usd_volume) AS "24 Hours Volume"
FROM
  seven_day_volume AS seven
  LEFT JOIN one_day_volume AS one ON seven."Project" = one."Project"
GROUP BY
  2
ORDER BY
  3 DESC NULLS FIRST
-- Aggregator by volume 📢
WITH
  seven_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '7' day
    GROUP BY
      1
  ),
  one_day_volume AS (
    SELECT
      project AS "Project",
      SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
    FROM
      dex_aggregator.trades AS t
    WHERE
      block_time > CURRENT_TIMESTAMP - INTERVAL '1' day
    GROUP BY
      1
  )
SELECT
  ROW_NUMBER() OVER (
    ORDER BY
      SUM(seven.usd_volume) DESC NULLS FIRST
  ) AS "Rank",
  seven."Project",
  SUM(seven.usd_volume) AS "7 Days Volume",
  SUM(one.usd_volume) AS "24 Hours Volume"
FROM
  seven_day_volume AS seven
  LEFT JOIN one_day_volume AS one ON seven."Project" = one."Project"
GROUP BY
  2
ORDER BY
  3 DESC NULLS FIRST