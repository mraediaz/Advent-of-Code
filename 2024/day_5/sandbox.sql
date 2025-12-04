~/clickhouse local -q "
    CREATE TABLE ordering_rules ENGINE = Log AS (
        SELECT 
            -- *,
            arr[1] as first_item,
            arr[2] as second_item
        FROM (
            SELECT 
                instruction,
                arrayMap(
                instruction -> toInt32(instruction), splitByChar('|', instruction)
                ) as arr
            FROM file('./5_input.txt', 'LineAsString', 'instruction String')
            where instruction like '%|%'
        ) prep
    );
    
    CREATE TABLE pages ENGINE = Log AS (
        SELECT 
            --instruction,
            arrayMap(
                instruction -> toInt32(instruction), splitByChar(',', instruction)
            ) as arr
        FROM file('./5_input.txt', 'LineAsString', 'instruction String')
        where instruction like '%,%'
    );


    WITH RECURSIVE 
    -- check each array against each rule
    array_rule_checks AS (
    SELECT 
        pages.arr,
        ordering_rules.first_item,
        ordering_rules.second_item,
        -- For each rule, check if both items exist in the array
        arrayExists(x -> x = first_item, arr) AND 
        arrayExists(x -> x = second_item, arr) AS both_items_exist,
        -- If both exist, check if they're in the correct order
        arrayFirstIndex(x -> x = first_item, arr) < 
        arrayFirstIndex(x -> x = second_item, arr) as correct_order
    FROM pages
    CROSS JOIN ordering_rules
    )

    , array_checks AS (
        SELECT
            arr,
            both_items_exist,
            correct_order
            
            -- An array is valid if:
            -- 1. For rules where both items exist in the array (both_items_exist = true)
            -- 2. All such rules have correct_order = true
            ,or(NOT both_items_exist, correct_order) as is_valid
        FROM array_rule_checks
        
        GROUP BY arr,2,3
    )

    ,valid_arrays AS (
        SELECT * FROM array_checks where arr not in 
            (select arr from array_checks where is_valid = 0)
    )

    
    ,middle AS (
        SELECT 
            arr,
            arrayElement(
                arr
                ,intDiv(length(arr), 2) + 1
            ) AS middle
        FROM valid_arrays
    )
    
    select sum(middle) from middle
    "