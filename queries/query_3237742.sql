-- already part of a query repo
-- query name: Weekly DEX Aggregator volume
-- query link: https://dune.com/queries/3237742

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