WITH columns AS ( 
        SELECT 
            splitByWhitespace(line)[1] as col_1, 
            row_number() OVER (ORDER BY splitByWhitespace(line)[1]) as rn_1, 
            splitByWhitespace(line)[2] as col_2, 
            row_number() OVER (ORDER BY splitByWhitespace(line)[2]) as rn_2 
        FROM file('./Downloads/1_advent_of_code.csv', 
                 'CSVWithNames', 
                 'line String')
    ) 
    SELECT sum(abs(a.col_1::int - b.col_2::int))
    FROM columns a INNER JOIN columns b ON a.rn_1 = b.rn_2

--part 2
WITH left AS ( 
        SELECT 
            splitByWhitespace(line)[1] as col_1 
        FROM file('./Downloads/1_advent_of_code.csv', 
                 'CSVWithNames', 
                 'line String')
    ) 
    ,right AS ( 
        SELECT 
            splitByWhitespace(line)[2] as col_2, 
            count(*) as rcount
        FROM file('./Downloads/1_advent_of_code.csv', 
                 'CSVWithNames', 
                 'line String')
        GROUP BY 1
    ) 
    SELECT sum(col_1::int * rcount::int)
    FROM left INNER JOIN right ON col_1 = col_2
    