package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
	"sort"
)

func ReadLines(path string) ([]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	return lines, scanner.Err()
}

func BinarySearch(lower bool, s []int) []int {
	middle := len(s) / 2
	if lower {
		return s[:middle]
	} else {
		return s[middle:]
	}
}

func ProcessFB(fbs string, lowerChar rune) int {
	numbers := make([]int, int(math.Pow(2, float64(len(fbs)))))
	for i := range numbers {
		numbers[i] = i
	}

	for _, v := range fbs {
		if v == lowerChar {
			numbers = BinarySearch(true, numbers)
		} else {
			numbers = BinarySearch(false, numbers)
		}
	}

	return numbers[0]
}

func ProcessRow(boardingPass string) int {
	row := ProcessFB(boardingPass[:7], 'F')
	seat := ProcessFB(boardingPass[7:], 'L')

	return 8*row + seat
}

func MaxSeatID(boardingPasses []string) int {
	maxSeat := 0
	for _, pass := range boardingPasses {
		seatID := ProcessRow(pass)
		fmt.Println(seatID)
		if seatID > maxSeat {
			maxSeat = seatID
		}
	}

	return maxSeat
}

func GetAllSeats(boardingPasses []string) []int {
	// Improvements include:
	//	Inserting these in order
	seats := make([]int, len(boardingPasses))
	for i, pass := range boardingPasses {
		seats[i] = ProcessRow(pass)
	}

	sort.Ints(seats)
	return seats
}

func GetMissingSeat(seats []int) int {
	for i, v := range seats {
		if i == 0 {
			continue
		} else if i == len(seats) {
			continue
		}

		if v != seats[i+1]-1 {
			return v + 1
		}
	}

	return -1
}

func pop(m map[int]struct{}) int {
	for k := range m {
		return k
	}

	return -1
}

// Make a set of all the possible boarding passes
// Go through all the boarding passes, remove the ones you found in the set
// Return the only thing left.
func SetStyle(boardingPasses []string) int {
	seatSet := make(map[int]struct{})

	var exists = struct{}{}
	for i := 100; i <= 861; i++ {
		seatSet[i] = exists
	}

	for _, pass := range boardingPasses {
		delete(seatSet, ProcessRow(pass))
	}

	return pop(seatSet)
}

func main() {
	// fmt.Println(numbers)
	// fmt.Println(BinarySearch(true, numbers))

	// "0101100" -> binary

	// fmt.Println(ProcessRow("FBFBBFFRLR"))
	// fmt.Println(ProcessFB("RLR", 'L'))

	// seats, _ := ReadLines("./example.txt")
	// fmt.Println(MaxSeatID(seats))

	seats, _ := ReadLines("./test.txt")
	// fmt.Println(MaxSeatID(seats))
	// fmt.Println(GetAllSeats(seats))
	fmt.Println(GetMissingSeat(GetAllSeats(seats)))
	fmt.Println(SetStyle(seats))
}
