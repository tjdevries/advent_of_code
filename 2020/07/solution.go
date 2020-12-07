package main

import (
	"fmt"
	"strings"

	"advent_base/utils"
)

func CanContainGoldBag(bag string, rules map[string]func(string) bool) bool {
	return true
}

// TODO: We could probably turn this into a map of the counts...?
type StringSet = map[string]int

func AddLineToRules(rules map[string]StringSet, line string) {
	splitLine := strings.Split(line, " ")

	bagName := strings.Join(splitLine[0:1], " ")
	fmt.Println(bagName)
}

func main() {
	// Part 1, parse input -> map
	utils.ReadLines()

	// Depth first search problem?
	fmt.Println("WOW COOL")
}
