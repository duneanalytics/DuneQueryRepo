-- already part of a query repo
-- query name: Sudoswap V2 Collections Summary
-- query link: https://dune.com/queries/2615781


WITH 
    pairs_created as (
        SELECT 
        *
        FROM query_2615780
    ),
    
    --we also need to get token balance of each pair currently
    erc721_balances as (
        SELECT
            contract_address as nft_contract_address
            -- , array_agg(tokenId) as tokenids_held
            , count(*) as tokens_held
        FROM (
            SELECT 
                row_number() OVER (partition by contract_address, tokenId order by evt_block_number desc, evt_index desc) as last_held
                , *
            FROM erc721_ethereum.evt_Transfer tr
            where tr.contract_address IN (select distinct nft_contract_address from pairs_created) --get last holders for all nft contracts (need to include erc1155 later)
            ) a 
        WHERE last_held = 1
        AND a.to IN (SELECT pool_address FROM pairs_created) --keep only tokens held by pairs
        GROUP BY 1
    ),
    
    erc1155_balances as (
        with t_in as (
            SELECT
                to as pool
                , contract_address
                , token_id
                , sum(amount) as transferred_in
            FROM nft.transfers 
            WHERE blockchain = 'ethereum'
            and token_standard = 'erc1155'
            and to IN (SELECT pool_address FROM pairs_created)
            group by 1,2,3
        )
        
        , t_out as (
            SELECT
                "from" as pool
                , contract_address
                , token_id
                , sum(amount) as transferred_out
            FROM nft.transfers 
            WHERE blockchain = 'ethereum'
            and token_standard = 'erc1155'
            and "from" IN (SELECT pool_address FROM pairs_created)
            group by 1,2,3
        )
        
        SELECT 
            pc.nft_contract_address
            , sum(t_in.transferred_in - COALESCE(t_out.transferred_out,cast(0 as uint256))) as tokens_held
        FROM t_in 
        LEFT JOIN t_out ON t_in.pool = t_out.pool AND t_in.contract_address = t_out.contract_address AND t_in.token_id = t_out.token_id
        JOIN pairs_created pc ON pc.pool_address = t_in.pool
        group by 1
    ),
    
    --we need eth_balances for liquidity tracking purposes
    eth_balances as (
        WITH eth_in as ( 
            SELECT 
                tr.to as holder_address
                , SUM(tr.value/1e18) as eth_funded
            FROM ethereum.traces tr
            WHERE tr.block_time > timestamp '2022-04-23'
                AND tr.success=true
                AND tr.type='call'
                AND (tr.call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR tr.call_type IS null)
                AND tr.to IN (SELECT pool_address FROM pairs_created)
            GROUP BY 1
        ),
        
        eth_out as (
            SELECT 
                tr."from" as holder_address
                , SUM(tr.value/1e18) as eth_spent
            FROM ethereum.traces tr
            WHERE tr.block_time > timestamp '2022-04-23'
                AND tr.success=true
                AND tr.type='call'
                AND (tr.call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR tr.call_type IS null)
                AND tr."from" IN (SELECT pool_address FROM pairs_created)
            GROUP BY 1
        )
        
        SELECT 
            pc.nft_contract_address
            , SUM(COALESCE(eth_funded,0) - COALESCE(eth_spent, 0)) as eth_balance
        FROM eth_in
        LEFT JOIN eth_out ON eth_in.holder_address = eth_out.holder_address
        JOIN pairs_created pc ON pc.pool_address = eth_in.holder_address
        WHERE COALESCE(eth_funded,0) - COALESCE(eth_spent, 0) > 0 --for some reason some balances are calculated negative.
        GROUP BY 1
    ),
    
     erc20_balances as (
        WITH erc20_in as ( 
            SELECT 
                tr.to as holder
                , contract_address
                , SUM(cast(tr.value as double)) as token_funded
            FROM erc20_ethereum.evt_Transfer tr
            WHERE tr.to IN (SELECT pool_address FROM pairs_created)
            -- AND contract_address IN (SELECT address FROM valid_tokens)
            GROUP BY 1,2
        ),
        
        erc20_out as (
            SELECT  
                tr."from" as holder
                , contract_address
                , SUM(cast(tr.value as double)) as token_spent
            FROM erc20_ethereum.evt_Transfer tr
            WHERE tr."from" IN (SELECT pool_address FROM pairs_created)
            -- AND contract_address IN (SELECT address FROM valid_tokens)
            GROUP BY 1,2
        )
        
        , contract_balance_sum as (
            SELECT
                pc.nft_contract_address
                , tk.symbol as symbol
                , erc20_in.contract_address
                , sum(token_funded/pow(10,COALESCE(tk.decimals,18)) - COALESCE(token_spent, 0)/pow(10,COALESCE(tk.decimals,18))) as tokens_held
            FROM erc20_in
            LEFT JOIN erc20_out ON erc20_in.holder = erc20_out.holder
            LEFT JOIN tokens.erc20 tk ON tk.contract_address = erc20_in.contract_address
            JOIN pairs_created pc ON pc.pool_address = erc20_in.holder
            WHERE COALESCE(token_funded,0) - COALESCE(token_spent, 0) > 0 --due to overflow, some balances are calculated negative.
            AND blockchain = 'ethereum'
            group by 1,2,3
        )
        
        SELECT 
            nft_contract_address
            , array_agg(json_object('token':COALESCE(symbol,cast(contract_address as varchar)), 'balance': round(tokens_held,4))) as tokens_held
        FROM contract_balance_sum
        group by 1
    ),

    trading_totals as (
        SELECT 
            nft_contract_address
            , nft_name
            , sum(amount_usd) as usd_volume
            -- get 7 day volume 
            , sum(number_of_items) as nfts_traded
            , sum(trade_fee_amount_usd) as trade_fee_amount_usd
            , sum(case when block_time >= now() - interval '7' day then amount_usd else 0 end) as last_7_days
            , sum(case when block_time >= now() - interval '7' day then trade_fee_amount_usd else 0 end) as last_7_days_fees
            , sum(protocol_fee_amount_usd) as protocol_fee_amount_usd
        FROM dune.dune.result_sudoswap_v_2_trades
        GROUP BY 1,2
    ),
    
    last_price as (
        SELECT 
            nft_contract_address
            , amount_usd
        FROM (
            SELECT 
                *
                , row_number() OVER (partition by nft_contract_address order by block_time desc) as rn
            FROM dune.dune.result_sudoswap_v_2_trades
            WHERE amount_usd is not null
        ) a
        WHERE rn = 1
    ),
    
    all_collections_cleaned as (
        SELECT 
            pc.*
            , nft.name as nft_name
            , COALESCE(bal_721.tokens_held,0) as nfts_721 --buyable liquidity
            , COALESCE(bal_1155.tokens_held,cast(0 as uint256)) as nfts_1155 --buyable liquidity
            , COALESCE(bal_20.tokens_held,array['0']) as erc20_balances --fix logic using transform agg later
            , COALESCE(eth_bal.eth_balance,0) as eth_liq --sellable liquidity
        FROM (
            SELECT
                nft_contract_address
                , count(distinct pool_address) as num_pairs
            FROM pairs_created
            GROUP BY 1
        ) pc
        LEFT JOIN erc721_balances bal_721 ON bal_721.nft_contract_address = pc.nft_contract_address
        LEFT JOIN erc1155_balances bal_1155 ON bal_1155.nft_contract_address = pc.nft_contract_address
        LEFT JOIN erc20_balances bal_20 ON bal_20.nft_contract_address = pc.nft_contract_address
        LEFT JOIN eth_balances eth_bal ON eth_bal.nft_contract_address = pc.nft_contract_address
        LEFT JOIN tokens.nft nft ON nft.blockchain = 'ethereum' and nft.contract_address = pc.nft_contract_address
    )
    
SELECT
    CONCAT('<a href="https://sudoswap.xyz/#/browse/buy/', cast(acc.nft_contract_address as varchar), '" target="_blank"> swap now! </a>') as s_link
    , CONCAT('<a href="https://sudoswap.xyz/#/browse/buy/', cast(acc.nft_contract_address as varchar), '" target="_blank">',COALESCE(acc.nft_name, cast(acc.nft_contract_address as varchar),'</a>')) as collection
    , num_pairs
    , '||' as split
    , spot.amount_usd as last_spot
    , COALESCE(trade.last_7_days, 0) as last_7_days
    , COALESCE(trade.usd_volume, 0) as usd_volume
    , COALESCE(trade.nfts_traded, cast(0 as uint256)) as nfts_traded
    , COALESCE(trade.trade_fee_amount_usd, 0) as trade_fee_amount_usd
    , COALESCE(trade.protocol_fee_amount_usd, 0) as protocol_fee_amount_usd
    , '||' as split_2
    , nfts_721
    , nfts_1155
    , erc20_balances
    , eth_liq
FROM all_collections_cleaned acc
LEFT JOIN trading_totals trade ON trade.nft_contract_address = acc.nft_contract_address
LEFT JOIN last_price spot ON spot.nft_contract_address = acc.nft_contract_address
ORDER BY last_7_days DESC