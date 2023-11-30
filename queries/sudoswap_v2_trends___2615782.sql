-- part of a query repo
-- query name: Sudoswap V2 Trends
-- query link: https://dune.com/queries/2615782


SELECT
date_trunc('week', block_time) as week 
, pool_type as col
, count(*) as trades
, sum(amount_usd) as usd_volume
, count(distinct tx_from) as traders
, sum(protocol_fee_amount_usd + trade_fee_amount_usd + royalty_fee_amount_usd) as all_fees
FROM dune.dune.result_sudoswap_v_2_trades
group by 1,2