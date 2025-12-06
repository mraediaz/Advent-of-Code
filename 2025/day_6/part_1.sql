-- ~/.duckdb/cli/latest/duckdb < part_1.sql
-- part 1

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
        unnest(string_split_regex(line, '\s+')) as op,
        unnest(range(1, length(string_split_regex(line, '\s+')) + 1)) as col_num
    FROM input_lines
    WHERE row_num = (SELECT max(row_num) FROM input_lines)
)
, number_lines AS (
    SELECT
        row_num,
        num,
        row_number() OVER (partition by row_num order BY row_num) as col_num
    FROM (
        SELECT row_num, line,
        unnest(string_split_regex(line, '\s+')) as num
        FROM input_lines
        WHERE row_num < (SELECT max(row_num) FROM input_lines)
    )
    where num is not null
    and num <> ''
    order by row_num, col_num
)
, column_sub_totals as (
SELECT
    c.col_num,
    o.op,
    list(c.num ORDER BY c.row_num) as numbers,
    CASE o.op
    WHEN '*' then product(c.num::int)
    WHEN '+' then sum(c.num::int)
    END AS result
FROM number_lines c
LEFT JOIN operations o ON c.col_num = o.col_num
GROUP BY c.col_num, o.op
ORDER BY c.col_num
)

SELECT sum(result) FROM column_sub_totals
;
-- part one answer : 4405895212738
