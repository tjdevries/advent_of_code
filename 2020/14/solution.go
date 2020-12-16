package main

import (
	"advent/utils"
	"fmt"
	"math"
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

func GetMask(line string) string {
	return strings.Split(line, " = ")[1]
}

func Part1(lines []string) {
	mask := GetMask(lines[0])

	memory := map[int64]int64{}
	for _, line := range lines[1:] {
		if strings.HasPrefix(line, "mask") {
			mask = GetMask(line)
		} else {
			parsedLine := ParseLine(line)
			// fmt.Println(line, " -> ", parsedLine)
			memory[parsedLine.address] = GetValue(mask, parsedLine.value)
		}
	}

	// fmt.Println(memory)

	total := int64(0)
	for _, val := range memory {
		total += val
	}
	fmt.Println("Final Sum: ", total)
}

func TurnMaskIntoMemMasks(mask string) [][]rune {
	fmt.Println(
		"Making address with length:",
		int(math.Pow(2.0, float64(strings.Count(mask, "X")))))

	addresses := make([][]rune, int(math.Pow(2.0, float64(strings.Count(mask, "X")))))
	for i := range addresses {
		addresses[i] = []rune(fmt.Sprintf("%036s", ""))
	}

	combinations := 1

	for i, r := range mask {
		if r == 'X' {
			combinations *= 2

			// First combination
			// Copy just the first line to the second
			split_location := combinations / 2
			for comb := 0; comb < split_location; comb++ {
				// Copy the original combinations into new combinations
				//     They will have 0s where this X is.
				copy(addresses[comb+split_location], addresses[comb])

				// Make the location of the X become a 1
				addresses[comb+split_location][i] = '1'
			}
		} else if r == '1' {
			for j := 0; j < combinations; j++ {
				addresses[j][i] = r
			}
		}
	}

	return addresses

	// fmt.Println(mask)
	// result := make([]int64, len(addresses))
	// for i, val := range addresses {
	// 	fmt.Println("Address:", string(val))
	// 	res, err := strconv.ParseInt(string(val), 2, 64)
	// 	if err != nil {
	// 		panic(err)
	// 	}

	// 	result[i] = res
	// }

	// return result
}

func GetMemoryAddressAfterMask(ogMask string, memMasks [][]rune, address int64) []int64 {
	base2Results := make([][]rune, len(memMasks))
	for i, mask := range memMasks {
		// Now we've got the copy of our value.
		base2Results[i] = []rune(fmt.Sprintf("%036s", strconv.FormatInt(address, 2)))

		// So now we can apply our mask
		for j, r := range ogMask {
			if r == '0' {
				continue
			} else if r == '1' {
				base2Results[i][j] = r
			} else {
				base2Results[i][j] = mask[j]
			}
		}
	}

	results := make([]int64, len(base2Results))
	for i, v := range base2Results {
		val, _ := strconv.ParseInt(string(v), 2, 64)
		results[i] = val
	}

	return results
}

func Part2(lines []string) {
	mask := GetMask(lines[0])
	memAdresses := TurnMaskIntoMemMasks(mask)

	memory := map[int64]int64{}
	for _, line := range lines[1:] {
		if strings.HasPrefix(line, "mask") {
			mask = GetMask(line)
			memAdresses = TurnMaskIntoMemMasks(mask)
		} else {
			parsedLine := ParseLine(line)
			// fmt.Println(line, " -> ", parsedLine)
			for _, addr := range GetMemoryAddressAfterMask(mask, memAdresses, parsedLine.address) {
				memory[addr] = parsedLine.value
			}
		}
	}

	fmt.Println(memory)

	total := int64(0)
	for _, val := range memory {
		total += val
	}
	fmt.Println("Final Sum: ", total)

}

func main() {
	// lines, _ := utils.ReadLines("./14/example.txt")
	lines, _ := utils.ReadLines("./14/test.txt")
	// lines, _ := utils.ReadLines("./14/example_2.txt")

	// Part1(lines)
	Part2(lines)

	// TODO: Part 2
}
