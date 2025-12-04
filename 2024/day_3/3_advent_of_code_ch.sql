WITH instructions AS (
        SELECT 
            arrayJoin(extractAll(instruction, 'mul(d+,d+)|do()|don''t()')) AS instruction
        FROM file('./3_input.txt', 'LineAsString', 'instruction String')
    )

    , labels AS (
        SELECT
            instruction,
            CASE
                WHEN instruction LIKE 'do()' THEN 'do()'
                WHEN instruction LIKE 'dont()' THEN 'dont()'
                ELSE NULL
            END AS marker
        FROM instructions
    )

    , complete_insturctions AS (
        SELECT 
            instruction,
            marker,
            LAST_VALUE(marker) OVER (ORDER BY rowNumberInAllBlocks()) AS do_or_dont
        FROM labels
    )

    , factors AS (
        SELECT 
            *,
            extractAll(instruction, 'd+')[1] AS factor_1,
            extractAll(instruction, 'd+')[2] AS factor_2
        FROM complete_insturctions        
    )

    -- PART 1
    SELECT sum(toInt32OrZero(factor_1) * toInt32OrZero(factor_2)) FROM factors 
    

    -- PART 2
    SELECT sum(toInt32OrZero(factor_1) * toInt32OrZero(factor_2)) FROM factors
    WHERE do_or_dont IS NULL OR do_or_dont = 'do()'
