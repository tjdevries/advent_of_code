package main

import (
	"fmt"
	"strconv"
	"strings"

	"advent/utils"
)

// TODO: We could probably turn this into a map of the counts...?
type ValidBagCounts = map[string]int

func parseSubRule(words []string) (int, string) {
	num, _ := strconv.Atoi(words[0])
	return num, strings.Join(words[1:3], " ")
}

func AddLineToRules(rules map[string]ValidBagCounts, line string) {
	splitLine := strings.Split(line, " ")

	bagName := strings.Join(splitLine[0:2], " ")

	rules[bagName] = make(ValidBagCounts)

	// Check for "no other bags"
	if strings.Index(line, "no other bags") != -1 {
		return
	} else {
		for i := 4; i < len(splitLine); i = i + 4 {
			num, name := parseSubRule(splitLine[i:])
			rules[bagName][name] = num

			// println(i, num, name)
		}
	}
}

// Solution 1: Just search LUL
// Solution 2: Search, but remember what you've found so far. Lookup if you already know this one. Memoization

func CanBagBeInBag(bag string, target string, rules map[string]ValidBagCounts, visited map[string]int) {
	_, alreadyVisited := visited[bag]
	if alreadyVisited {
		fmt.Println("Yo, we been here", alreadyVisited)
		return
	}

	bagRules := rules[bag]
	_, present := bagRules[target]
	if present {
		visited[bag] = 1
	} else {
		// visited[target] = GetCountOfOtherBags(rules, target, visited)
		fmt.Println(bag, bagRules)
	}
}

func GetCountOfOtherBags(rules map[string]ValidBagCounts, target string) int {
	visited := make(map[string]int)

	for name := range rules {
		if name == target {
			// Skip doing the same bag. That's NO GOOD
			continue
		}

		CanBagBeInBag(name, target, rules, visited)
	}

	countOfValidBags := 0
	for _, v := range visited {
		countOfValidBags += v
	}

	return countOfValidBags
}

func GetCountOfBags(rules map[string]ValidBagCounts, target string) int {
	known := make(map[string]bool)
	known[target] = false

	countOfBags := 0
	for bag := range rules {
		if CanBagHoldBag(bag, target, rules, known) {
			countOfBags += 1
		}
	}

	// fmt.Println("All Known:", known)
	return countOfBags
}

var CalledCount int = 0

func CanBagHoldBag(bag, target string, rules map[string]ValidBagCounts, known map[string]bool) bool {
	CalledCount += 1

	knownValue, prs := known[bag]
	if prs {
		return knownValue
	}

	result := false

	bagCounts := rules[bag]
	for validName := range bagCounts {
		if validName == target {
			result = true
			break
		}

		if CanBagHoldBag(validName, target, rules, known) {
			result = true
			break
		}
	}

	known[bag] = result
	return result
}

func GetBagsInBag(rules map[string]ValidBagCounts, target string) int {
	bagsInBag := 0

	bagsInSingleBag := make(map[string]int)

	for name, bagCounts := range rules[target] {
		fmt.Println(name, bagCounts)
		bagsInBag += bagCounts * findBagInSingleBag(name, rules, bagsInSingleBag)
	}

	return bagsInBag
}

func findBagInSingleBag(bag string, rules map[string]ValidBagCounts, bagsInSingleBag map[string]int) int {
	CalledCount += 1

	known, prs := bagsInSingleBag[bag]
	if prs {
		return known
	}

	bagCount := 1
	for name, bagCounts := range rules[bag] {
		bagCount += bagCounts * findBagInSingleBag(name, rules, bagsInSingleBag)
	}

	bagsInSingleBag[bag] = bagCount
	return bagCount
}

func main() {
	// Part 1, parse input -> map
	// lines, _ := utils.ReadLines("./07/example.txt")
	lines, _ := utils.ReadLines("./07/test.txt")
	// lines, _ := utils.ReadLines("./07/example_2.txt")

	rules := make(map[string]ValidBagCounts)
	for _, line := range lines {
		AddLineToRules(rules, line)
	}

	// Depth first search problem?
	// fmt.Println(GetCountOfBags(rules, "shiny gold"))
	// fmt.Println(rules)

	fmt.Println(GetBagsInBag(rules, "shiny gold"))
	fmt.Println("Called:", CalledCount)
}
