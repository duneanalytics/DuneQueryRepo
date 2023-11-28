SELECT
  project,
  DATE_TRUNC('week', block_time),
  SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
FROM
   dex_aggregator.trades AS t /* AND block_time < date_trunc('week', Now()) -- Add this line to see stats from current week */
WHERE
 block_time > NOW() - INTERVAL '365' day
GROUP BY
  1,
  2
-- Weekly DEX Aggregator volume
SELECT
  project,
  DATE_TRUNC('week', block_time),
  SUM(CAST(amount_usd AS DOUBLE)) AS usd_volume
FROM
   dex_aggregator.trades AS t /* AND block_time < date_trunc('week', Now()) -- Add this line to see stats from current week */
WHERE
 block_time > NOW() - INTERVAL '365' day
GROUP BY
  1,
  2