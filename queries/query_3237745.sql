-- already part of a query repo
-- query name: EVM DEX Traders by Bucket
-- query link: https://dune.com/queries/3237745


with 
    all_traders as (
        SELECT 
            date_trunc('week',block_time) as week
            , tx_from
            , sum(amount_usd) as volume
        FROM (SELECT 
                block_time
                , tx_hash
                , tx_from
                , max(amount_usd) as amount_usd
                FROM dex.trades
                group by 1,2,3
            )
        WHERE amount_usd is not null
        group by 1,2
    )
    
SELECT 
week
, case 
    when volume < 1e2 then '< $100'
    when volume >= 1e2 and volume < 1e3 then '< $1,000'
    when volume >= 1e3 and volume < 1e4 then '< $10,000'
    when volume >= 1e4 and volume < 1e5 then '< $100,000'
    when volume >= 1e5 and volume < 1e6 then '< $1,000,000'
    when volume >= 1e6 then '$1m+'
end as trader_bucket
, count(*)
FROM all_traders
WHERE week >= NOW() - INTERVAL '365' day
group by 1,2