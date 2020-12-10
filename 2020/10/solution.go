package main

import (
	"advent/utils"
	"fmt"
	"sort"
)

func CountDifferences(sortedNumbers []int) map[int]int {
	m := map[int]int{
		3: 1,
	}

	lastNum := 0
	for _, v := range sortedNumbers {
		m[v-lastNum] += 1
		lastNum = v
	}

	return m
}

// We could tryand make basically a tree style where we look at these numbers
// then we memorize how many combination each number can have.
//	So if we find out that 25 -> 80232 combinations, then we can remember that.
//	and then we can count backwards...

func Part1(path string) {
	numbers := utils.ReadLinesToInts(path)

	sort.Ints(numbers)
	fmt.Println(numbers)

	differences := CountDifferences(numbers)
	fmt.Println(differences)
	fmt.Println(differences[1] * differences[3])
}

type Child struct {
	index int
	value int
}

// TODO: Memoize
func PossibleChildren(index, value int, numbers []int) []Child {
	possible := make([]Child, 0, 3)

	startIndex := index + 1
	finalIndex := startIndex + 3
	if finalIndex >= len(numbers)-1 {
		finalIndex = len(numbers)
	}

	for i, v := range numbers[startIndex:finalIndex] {
		if v <= value+3 {
			possible = append(possible, Child{startIndex + i, v})
		} else {
			break
		}
	}

	return possible
}

func CountPaths(index, value int, numbers []int, counted map[int]int) int {
	children := PossibleChildren(index, value, numbers)
	// fmt.Println("Start Path Counts:")
	// fmt.Println("	Index, Value: ", index, ", ", value)
	// fmt.Println("	Children:", children)

	// Yo, you got to the end...
	// You count as a path.
	if value == numbers[len(numbers)-1] {
		return 1
	}

	pathCount := 0
	for _, child := range children {
		// fmt.Println(child)

		if val, prs := counted[child.value]; prs {
			pathCount += val
		} else {
			childCount := CountPaths(child.index, child.value, numbers, counted)

			counted[child.value] = childCount
			pathCount += childCount
		}
	}

	return pathCount
}

func Part2(path string) {
	rawNumbers := utils.ReadLinesToInts(path)
	numbers := []int{0}
	numbers = append(numbers, rawNumbers...)
	sort.Ints(numbers)
	numbers = append(numbers, numbers[len(numbers)-1]+3)
	fmt.Println("Numbers:", numbers)

	counted := map[int]int{}
	fmt.Println(CountPaths(0, numbers[0], numbers, counted))
}

// TODO: Can I do something tricky while I'm walking the tree?...
//     1  +   3    +  2
//  1  -> 4  -> 5  -> 6
//                 -> 7
//           -> 6
//           -> 7

func main() {
	// Part1("./10/example_1.txt")
	// Part1("./10/example_2.txt")
	// Part1("./10/test.txt")

	Part2("./10/example_1.txt")
	Part2("./10/example_2.txt")
	Part2("./10/test.txt")
}
