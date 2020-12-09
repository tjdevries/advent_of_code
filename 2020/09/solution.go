package main

import (
	"advent/utils"
	"fmt"
	"math"
	"strconv"
)

//
// 35
//  | 20	| 15
//  > 55	> 50
//
//	20
//	| 35
//	> 55

type PreambleMap map[int]int
type Set map[int]void
type void struct{}

var member void

type PreambleValue struct {
	base     int
	children Set
}

func addValueToPreamble(base int, preamble []PreambleValue, cached map[int]int) {
	for _, pre := range preamble {
		validValue := pre.base + base

		// Add to our children's set
		pre.children[validValue] = member

		// Keep our lookup quick
		cached[validValue] += 1
	}
}

func shiftPreamble(preamble []PreambleValue, cached map[int]int) []PreambleValue {
	shifted := preamble[0]
	for value := range shifted.children {
		// Make sure tj didn't do bad code
		if cached[value] == 0 {
			panic(value)
		}

		cached[value] -= 1
	}

	return preamble[1:]
}

// Ok, how does this work???
//
// Walk the lines.
// As you walk them, create a new "PreambleValue"
//    Preamble values can hold their base and valid children.
//        We keep their valid children around, so that we can
//        easily remove them when this node "falls off" or is shifted
//        off of the valid nodes (remember, you can only have X number
//        of things in the preamble).
//
//    We also update a lookup (cached) that contains the count of variables that
//    are valid.
//        When adding a new node, we increment the count in our map.
//        When shifting a node, we decrement the count in our map.
//
//    This allows us to have O(1) lookup if the next value is valid or not!
//    It also means we only calculate the additions of numbers once
func FindBrokenXMAS(lines []int, preambleLength int) int {
	preamble := []PreambleValue{}

	// { $sum: $count, $sum: $count, ... }
	cached := map[int]int{}

	for i, base := range lines {
		if i >= preambleLength {
			// Is the next base valid??
			//		We've been updating cached to keep track of valid counts!
			if cached[base] == 0 {
				fmt.Println("Found the broken:", base)
				return base
			}

			preamble = shiftPreamble(preamble, cached)
		}

		addValueToPreamble(base, preamble, cached)

		preamble = append(preamble, PreambleValue{
			base:     base,
			children: make(Set),
		})
	}

	fmt.Println("Unable to find bad")
	fmt.Println(preamble)
	fmt.Println(cached)

	return -1
}

// bad way
//
// start at 1, you add 2, then 3, then ...
// start at 2, then you add 3, then 4, then...
// Quit as soon as we get over our target value

func IsItBad(numbers []int, target int) int {
	for i, start := range numbers {
		sum := start

		min := float64(start)
		max := float64(start)

		for _, end := range numbers[i+1:] {
			sum += end

			min = math.Min(min, float64(end))
			max = math.Max(max, float64(end))

			if sum > target {
				break
			} else if sum == target {
				return int(min + max)
			}
		}
	}

	return -1
}

func MinMaxSlice(numbers []int) (int, int) {
	min := float64(numbers[0])
	max := float64(numbers[0])

	for _, v := range numbers {
		min = math.Min(min, float64(v))
		max = math.Max(max, float64(v))
	}

	return int(min), int(max)
}

func IsItNotAsBad(numbers []int, target int) int {
	startIndex := 0
	endIndex := 0

	currentSum := 0
	for i, v := range numbers {
		endIndex = i
		currentSum += v

		for currentSum >= target && endIndex > startIndex {
			currentSum -= numbers[startIndex]
			startIndex += 1

			if currentSum == target {
				min, max := MinMaxSlice(numbers[startIndex:endIndex])
				return min + max
			}
		}
	}

	return -1
}

func main() {
	lines, _ := utils.ReadLines("./09/example.txt")
	numbers := []int{}
	for _, line := range lines {
		num, _ := strconv.Atoi(line)
		numbers = append(numbers, num)
	}
	broken := FindBrokenXMAS(numbers, 5)
	fmt.Println(IsItBad(numbers, broken))
	fmt.Println(IsItNotAsBad(numbers, broken))

	testLines, _ := utils.ReadLines("./09/test.txt")
	testNumbers := []int{}
	for _, line := range testLines {
		num, _ := strconv.Atoi(line)
		testNumbers = append(testNumbers, num)
	}
	testBroken := FindBrokenXMAS(testNumbers, 25)
	fmt.Println(IsItBad(testNumbers, testBroken))
	fmt.Println(IsItNotAsBad(testNumbers, testBroken))
}
