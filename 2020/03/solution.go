package main

import (
	"bufio"
	"fmt"
	"os"
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

const Safe = '.'
const Tree = '#'

type Position struct {
	x int
	y int
}

func IsOnTree(m []string, mWidth int, pos Position) int {
	if len(m) < pos.y {
		return 0
	} else if m[pos.y][pos.x%mWidth] == Safe {
		return 0
	}

	return 1
}

// Next level solution:
//	Use a waitgroup. With the WaitGroup, then you can maybe make this nicer.
func GetSmashedTrees(m []string, slopeRight, slopeDown int) int {
	mWidth := len(m[0])

	treeSmashChan := make(chan int)
	safeChecker := func(i int) {
		treeSmashChan <- IsOnTree(m, mWidth, Position{slopeRight * i, slopeDown * i})
	}

	for i := range m {
		go safeChecker(i)
	}

	treesSmashed := 0
	for range m {
		treesSmashed += <-treeSmashChan
	}

	fmt.Println("For Slope: ", slopeRight, " ", slopeDown, " // Count was: ", treesSmashed)
	return treesSmashed
}

func main() {
	// lines, _ := ReadLines("./small.txt")
	lines, _ := ReadLines("./test.txt")

	// slopeRight := 3
	// slopeDown := 1
	// treesTest := GetSmashedTrees(lines, slopeRight, slopeDown)
	// fmt.Println("Trees Smashed:", treesTest)

	// treesLong := GetSmashedTrees(longLines, slopeRight, slopeDown)
	// fmt.Println("Trees Smashed:", treesLong)

	// Right 1, down 1.
	// Right 3, down 1. (This is the slope you already checked.)
	// Right 5, down 1.
	// Right 7, down 1.
	// Right 1, down 2.
	slopesToTest := [][]int{
		{1, 1},
		{3, 1},
		{5, 1},
		{7, 1},
		{1, 2},
	}

	treeCalculatorChan := make(chan int)
	treeGetter := func(slopes []int) {
		treeCalculatorChan <- GetSmashedTrees(lines, slopes[0], slopes[1])
	}

	for _, slope := range slopesToTest {
		go treeGetter(slope)
	}

	product := 1
	for range slopesToTest {
		product *= <-treeCalculatorChan
	}

	fmt.Println("PRODUCT:", product)

}
