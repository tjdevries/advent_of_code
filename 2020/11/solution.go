package main

import (
	"advent/utils"
	"fmt"
	"strings"
)

func rowsAreEqual(expected, actual []string) bool {
	for index, row := range actual {
		if row != expected[index] {
			// fmt.Println(
			// 	"Error in row:", index,
			// 	"\n\tExpected: ", expected[index],
			// 	"\n\tActual  :", row)
			return false
		}
	}

	return true
}

const empty = 'L'
const occupied = '#'
const floor = '.'

func CountSurrounding(x, y int, rows []string) map[rune]int {
	counts := make(map[rune]int)

	for _, x_offset := range []int{-1, 0, 1} {
		for _, y_offset := range []int{-1, 0, 1} {
			if x_offset == 0 && y_offset == 0 {
				continue
			}
			new_x := x + x_offset
			new_y := y + y_offset

			if new_x >= len(rows) || new_x < 0 {
				continue
			}

			if new_y >= len(rows[new_x]) || new_y < 0 {
				continue
			}

			value := rune(rows[new_x][new_y])
			counts[value] += 1
		}
	}

	return counts
}

func SeeSurrounding(x, y int, rows []string) map[rune]int {
	counts := make(map[rune]int)
	for _, x_dir := range []int{-1, 0, 1} {
		for _, y_dir := range []int{-1, 0, 1} {
			if x_dir == 0 && y_dir == 0 {
				continue
			}

			counts[GetNextVisibleSeat(x, y, Direction{x_dir, y_dir}, rows)] += 1
		}
	}

	return counts
}

func ApplyOnce(rows []string, part_1 bool) []string {
	newRows := make([]string, len(rows))

	occupiedCutoff := 4
	if !part_1 {
		occupiedCutoff = 5
	}

	finder := CountSurrounding
	if !part_1 {
		finder = SeeSurrounding
	}

	for i, row := range rows {
		// Make a string builder of the length of the row
		var rowBuilder strings.Builder
		rowBuilder.Grow(len(row))

		for j, r := range row {
			if r == empty {
				var surrounding map[rune]int = finder(i, j, rows)
				if surrounding[occupied] == 0 {
					fmt.Fprintf(&rowBuilder, "%s", string(occupied))
				} else {
					fmt.Fprintf(&rowBuilder, "%s", string(empty))
				}
			} else if r == occupied {
				var surrounding map[rune]int = finder(i, j, rows)
				if surrounding[occupied] >= occupiedCutoff {
					fmt.Fprintf(&rowBuilder, "%s", string(empty))
				} else {
					fmt.Fprintf(&rowBuilder, "%s", string(occupied))
				}
			} else {
				fmt.Fprintf(&rowBuilder, "%s", string(r))
			}
		}

		newRows[i] = rowBuilder.String()
	}

	return newRows
}

func CountOccupied(rows []string) int {
	count := 0
	for _, row := range rows {
		for _, r := range row {
			if r == occupied {
				count += 1
			}
		}
	}
	return count
}

type Direction struct {
	x int
	y int
}

var count int = 0

// 3, 3 -> 0, 1
//
func GetNextVisibleSeat(x, y int, d Direction, rows []string) rune {
	new_x, new_y := x, y
	for {
		count += 1

		new_x, new_y = new_x+d.x, new_y+d.y

		if new_x >= len(rows) || new_x < 0 {
			// fmt.Println("OOB X", x, y, d)
			return empty
		}

		if new_y >= len(rows[new_x]) || new_y < 0 {
			// fmt.Println("OOB Y")
			return empty
		}

		new_value := rune(rows[new_x][new_y])
		if new_value != floor {
			return new_value
		}
	}
}

func main() {
	// lines, _ := utils.ReadLines("./11/example.txt")
	lines, _ := utils.ReadLines("./11/test.txt")

	// fmt.Println(lines)
	// expectedOnce, _ := utils.ReadLines("./11/2_example_1.txt")
	// expectedTwice, _ := utils.ReadLines("./11/2_example_2.txt")
	// if !rowsAreEqual(expectedOnce, ApplyOnce(lines, false)) {
	// 	fmt.Println("You failed....")
	// 	return
	// }

	// if !rowsAreEqual(expectedTwice, ApplyOnce(expectedOnce, false)) {
	// 	fmt.Println("You failed x 2....")
	// 	return
	// }

	prevLines := lines
	for {
		nextLines := ApplyOnce(prevLines, false)
		if rowsAreEqual(nextLines, prevLines) {
			break
		}

		prevLines = nextLines
	}

	fmt.Println("Occupied ", CountOccupied(prevLines))
	fmt.Println("Called seeing:", count)
	// fmt.Println("Next Visible: ", string(GetNextVisibleSeat(0, 3, Direction{0, 1}, []string{".L.L.#.#.#.#."})))
}
