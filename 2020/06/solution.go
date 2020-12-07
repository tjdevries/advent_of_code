package main

import (
	"advent/utils"
	"fmt"
	"strings"
)

var member struct{}

func ProcessGroup(group []string) map[rune]interface{} {
	m := make(map[rune]interface{})

	for _, r := range group[0] {
		m[r] = member
	}

	for _, s := range group[1:] {
		for _, r := range s {
			_, prs := m[r]
			if !prs {
				delete(m, r)
			}
		}

		for r := range m {
			if strings.IndexRune(s, r) == -1 {
				delete(m, r)
			}
		}
	}

	return m
}

func main() {

	// lines, _ := utils.ReadLines("./06/example.txt")
	lines, _ := utils.ReadLines("./06/test.txt")
	fmt.Println(lines)

	groups := [][]string{}

	currentGroup := []string{}
	for _, line := range lines {
		if line != "" {
			currentGroup = append(currentGroup, line)
		} else {
			groups = append(groups, currentGroup)
			currentGroup = []string{}
		}
	}

	groups = append(groups, currentGroup)

	count := 0
	for _, g := range groups {
		count += len(ProcessGroup(g))
		// fmt.Println(g, ))
	}

	// fmt.Println(groups)
	fmt.Println(count)
}
