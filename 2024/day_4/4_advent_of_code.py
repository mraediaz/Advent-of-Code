def find_xmas_part_1(grid):
    rows = len(grid)
    cols = len(grid[0]) - 1
    results = []
    
    # right, left, down, up, and all diagonals
    directions = [
        (0, 1, "right"),   # →
        (0, -1, "left"),   # ←
        (1, 0, "down"),    # ↓
        (-1, 0, "up"),     # ↑
        (1, 1, "diagonal right-down"),    # ↘
        (-1, -1, "diagonal left-up"),     # ↖
        (-1, 1, "diagonal right-up"),     # ↗
        (1, -1, "diagonal left-down")     # ↙
    ]
    
    def check_pattern(row, col, delta_row, delta_col):
        word = ""
        current_row, current_col = row, col
        
        # Try to build a 4-letter word in the current direction
        for _ in range(4):
            if not (0 <= current_row < rows and 0 <= current_col < cols):
                return False
            word += grid[current_row][current_col]
            current_row += delta_row
            current_col += delta_col
            
        return word == "XMAS"
    
    # Check every starting position in every direction
    for row in range(rows):
        for col in range(cols):
            for delta_row, delta_col, direction in directions:
                if check_pattern(row, col, delta_row, delta_col):
                    results.append({
                        'start': (row, col),  
                        'direction': direction
                    })
    
    return results


def find_xmas_part_2(grid):
    rows = len(grid)
    cols = len(grid[0]) - 1
    results = []
    
    # right, left, down, up, and all diagonals
    directions = [
        (1, 1, "diagonal right-down"),    # ↘
        (-1, -1, "diagonal left-up"),     # ↖
        (-1, 1, "diagonal right-up"),     # ↗
        (1, -1, "diagonal left-down")     # ↙
    ]
    
    def check_pattern(row, col, delta_row, delta_col):
        word = ""
        current_row, current_col = row, col
        
        # Try to build a 4-letter word in the current direction
        for _ in range(3):
            if not (0 <= current_row < rows and 0 <= current_col < cols):
                return False
            letter = grid[current_row][current_col]
            word += letter
            current_row += delta_row
            current_col += delta_col
            
        return word == "MAS"
    
    # Check every starting position in every direction
    for row in range(rows):
        for col in range(cols):
            for delta_row, delta_col, direction in directions:
                if check_pattern(row, col, delta_row, delta_col):
                    results.append((row + delta_row, col + delta_col), # position of A 
                        )
                    
    # Count how many times these coordinates were found
    count_dict = {}
    for counter in results:
        if counter in count_dict:
            count_dict[counter] += 1
        else:
            count_dict[counter] = 1

    # Count how many were there twice
    doubles_count = sum(1 for count in count_dict.values() if count == 2)
    return doubles_count


grid = open('./4_input.txt', 'r').readlines()
print(len(find_xmas_part_1(grid)))
print(find_xmas_part_2(grid))
