CREATE TABLE rules ENGINE = Log AS (
    SELECT 
        arr[1] as X,
        arr[2] as Y
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
    
CREATE TABLE updates ENGINE = Log AS (
    SELECT 
        arrayMap(
            instruction -> toInt32(instruction), splitByChar(',', instruction)
        ) as page_list
    FROM file('./5_input.txt', 'LineAsString', 'instruction String')
    where instruction like '%,%'
);

-- valid updates
WITH valid_updates AS (
    SELECT
        page_list,
        arrayAll(
            (x, y) -> indexOf(page_list, x) < indexOf(page_list, y),
            arrayFilter(
                (x, y) -> has(page_list, x) AND has(page_list, y),
                arrayZip((SELECT groupArray(X) FROM rules), (SELECT groupArray(Y) FROM rules))
            )
        ) AS is_valid
     FROM updates
    ) 

, middle_page AS (
SELECT
    page_list,
    is_valid,
    arrayElement(page_list, intDiv(length(page_list) + 1, 2)) AS middle_page
FROM valid_updates
WHERE is_valid = 1
)

SELECT 
    sum(middle_page) AS total_middle_sum
FROM middle_page
WHERE is_valid = 1;