package main

import (
	"advent/utils"
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

type MemOperation struct {
	address int64
	value   int64
}

func ParseLine(line string) MemOperation {
	r, _ := regexp.Compile(`mem\[(\d*)\] = (\d*)`)
	matches := r.FindStringSubmatch(line)

	location, _ := strconv.Atoi(matches[1])
	value, _ := strconv.Atoi(matches[2])

	return MemOperation{int64(location), int64(value)}
}

func GetValue(mask string, value int64) int64 {
	base2Value := fmt.Sprintf("%036s", strconv.FormatInt(value, 2))

	result := []rune(fmt.Sprintf("%036s", ""))
	for i, r := range mask {
		if r == 'X' {
			result[i] = rune(base2Value[i])
		} else {
			result[i] = rune(r)
		}
	}

	parsed, _ := strconv.ParseInt(string(result), 2, 64)
	return parsed
}

func main() {
	// lines, _ := utils.ReadLines("./14/example.txt")
	lines, _ := utils.ReadLines("./14/test.txt")

	mask := strings.Split(lines[0], " = ")[1]

	memory := map[int64]int64{}

	for _, line := range lines[1:] {
		if strings.HasPrefix(line, "mask") {
			mask = strings.Split(line, " = ")[1]
		} else {
			parsedLine := ParseLine(line)
			fmt.Println(line, " -> ", parsedLine)
			memory[parsedLine.address] = GetValue(mask, parsedLine.value)
		}
	}

	fmt.Println(memory)

	total := int64(0)
	for _, val := range memory {
		total += val
	}
	fmt.Println("Final Sum: ", total)

	// TODO: Part 2
}
