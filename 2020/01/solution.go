package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"

	"github.com/logic-building/functional-go/fp"
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

func sumInt(x, y int) int { return x + y }
func mulInt(x, y int) int { return x * y }

func FindAddersRecursive(targetValue int, currentItems []int, items []int, remaining_adders int) (bool, []int) {
	currentSum := fp.ReduceInt(sumInt, currentItems)

	if remaining_adders == 1 {
		for _, item := range items {
			if currentSum+item == targetValue {
				return true, append(currentItems, item)
			}
		}
	} else {
		for index, item := range items {
			new_items := append(currentItems, item)
			found, resulting_items := FindAddersRecursive(targetValue, new_items, items[index+1:], remaining_adders-1)
			if found {
				return true, resulting_items
			}
		}
	}

	return false, nil

}

func FindAdders(targetValue int, items []int, adder_count int) (bool, []int) {
	for index, item := range items {
		found, resulting_items := FindAddersRecursive(targetValue, []int{item}, items[index+1:], adder_count-1)
		if found {
			return true, resulting_items
		}
	}

	return false, []int{}
}

func DisplayAdders(targetValue int, items []int, adder_count int) {
	fmt.Println("======================")
	fmt.Printf("Number of counters : %v\n", adder_count)

	success, results := FindAdders(targetValue, items, adder_count)
	if success {
		fmt.Printf("Test Values are: %v\n", results)
		fmt.Printf("Sumation       : %v\n", fp.ReduceInt(sumInt, results))
		fmt.Printf("Product        : %v\n", fp.ReduceInt(mulInt, results))
	} else {
		fmt.Printf(":( %v %v", success, results)
	}

}

func main() {
	raw_lines, err := ReadLines("./input.txt")
	if err != nil {
		fmt.Println("Hey, you broke the files")
		return
	}

	var lines []int
	for _, raw_line := range raw_lines {
		line, err := strconv.Atoi(raw_line)
		if err != nil {
			return
		}

		lines = append(lines, line)
	}

	targetValue := 2020
	testValues := []int{
		1721,
		979,
		366,
		299,
		675,
		1456,
	}

	DisplayAdders(targetValue, testValues, 2)
	DisplayAdders(targetValue, lines, 2)

	DisplayAdders(targetValue, testValues, 3)
	DisplayAdders(targetValue, lines, 3)
}
