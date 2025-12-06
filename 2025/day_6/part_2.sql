-- ~/.duckdb/cli/latest/duckdb < part_2.sql
-- part 2

WITH input_lines AS (
    SELECT
        row_number() OVER () as row_num,
        column0 as line
    -- FROM read_csv('example_input.txt',
    FROM read_csv('input.txt',
                  delim='\x01',
                  header=false,
                  quote='',
                  columns={'column0': 'VARCHAR'})
),
operations AS (
    SELECT
        row_number() OVER () AS pos,
        unnest(string_split_regex(line, '\s+')) as op,
        unnest(range(1, length(string_split_regex(line, '\s+')) + 1)) as col_num
    FROM input_lines
    WHERE row_num = (SELECT max(row_num) FROM input_lines)
)
, number_lines AS (
    SELECT
        row_num,
        line,
        length(line) as len
    FROM input_lines
    WHERE row_num < (SELECT max(row_num) FROM input_lines)
)
,chars_by_position as (
    SELECT
        row_num,
        line,
        pos,
        substr(line, pos, 1) as char
    FROM number_lines
    CROSS JOIN (
        SELECT unnest(range(1, (SELECT max(len) FROM number_lines) + 1)) as pos
    )
)
, cephalopod_numbers as (
    SELECT
        pos,
        string_agg(char, '' ORDER BY row_num) as num
    FROM chars_by_position
    WHERE char ~ '[0-9]+'
    GROUP BY pos
)
, cephalopod_columns as (
    SELECT
        pos,
        SUM(is_new_group) OVER (ORDER BY pos) as group_number
    FROM (
        SELECT
            pos,
            CASE
                WHEN LAG(pos) OVER (ORDER BY pos) IS NULL
                    OR pos != LAG(pos) OVER (ORDER BY pos) + 1
                THEN 1
                ELSE 0
            END as is_new_group
        FROM cephalopod_numbers
    ) subquery
)
, column_sub_totals as (
SELECT
    cc.group_number,
    list(c.num) as numbers,
    CASE o.op
        WHEN '*' then product(c.num::int)
        WHEN '+' then sum(c.num::int)
    END AS result
FROM cephalopod_numbers c
JOIN cephalopod_columns cc using (pos)
LEFT JOIN operations o ON cc.group_number = o.col_num
GROUP BY cc.group_number, o.op
ORDER BY 1 desc
)

SELECT sum(result) FROM column_sub_totals
;
