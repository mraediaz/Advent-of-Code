WITH report AS (
        SELECT 
           line,
           arrayMap(line -> toInt32(line), splitByWhitespace(line)) as arr
            
        FROM file('./2_advent_of_code.txt', 'CSV', 'line String')
    )

    , differences_0 AS (
        SELECT
            arrayDifference(arr) AS diff
        FROM report
    ),

    differences AS (
        SELECT
            arraySlice(diff, 2, length(diff) - 1) as diff
        FROM differences_0
    )

    , safe_inc_or_dec AS (
        SELECT
            diff,
            xor(
                arrayAll(x -> x < 0, diff),  --decreasing
                arrayAll(x -> x > 0, diff)  -- increasing
            ) as condition_1
        FROM differences 
    )

    , safe_between AS (
        SELECT
            diff,
            arrayAll(x -> abs(x) BETWEEN 1 AND 3, diff) AS condition_2
        FROM safe_inc_or_dec
        WHERE condition_1 = 1
    )

    , safe_between_any AS (
        SELECT
            diff,
            arrayExists(
                i -> arrayAll(
                    x -> abs(x) BETWEEN 1 AND 3, 
                    arrayFilter((element, index) -> index <> i , diff, arrayEnumerate(diff))
                ), 
                arrayEnumerate(diff)
            ) AS condition_3
        FROM safe_inc_or_dec
    )
    
    
    -- part 1 
    SELECT COUNT(*) from safe_between WHERE condition_2 = 1

    -- part 2 -- not correct, need to check increasing/decreasing
    SELECT COUNT(*) from safe_between_any WHERE condition_3 = 1
