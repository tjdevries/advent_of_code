package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
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

type PasswordInfo struct {
	min  int
	max  int
	char rune
}

func CountOfRune(str string, character rune) int {
	count := 0
	for _, part := range str {
		if part == character {
			count += 1
		}
	}

	return count
}

func ValidPasswords(lines []string) {
	r, _ := regexp.Compile("(\\d+)-(\\d+) ([a-z]): ([a-z]+)")

	valid_passwords := 0
	for _, line := range lines {
		matches := r.FindStringSubmatch(line)

		min, _ := strconv.Atoi(matches[1])
		max, _ := strconv.Atoi(matches[2])
		char := rune(matches[3][0])

		count := CountOfRune(matches[4], char)
		if count >= min && count <= max {
			valid_passwords += 1
		}
	}

	fmt.Printf("Total Matches %d\n", valid_passwords)
}

func ValidPasswordsPartTwo(lines []string) {
	r, _ := regexp.Compile("(\\d+)-(\\d+) ([a-z]): ([a-z]+)")

	valid_passwords := 0
	for _, line := range lines {
		matches := r.FindStringSubmatch(line)

		first, _ := strconv.Atoi(matches[1])
		second, _ := strconv.Atoi(matches[2])

		first -= 1
		second -= 1

		char := matches[3][0]

		password := matches[4]
		if second >= len(password) {
			continue
		}

		matches_first := char == password[first]
		matches_second := char == password[second]

		if (matches_first || matches_second) && !(matches_first && matches_second) {
			valid_passwords += 1
		}
	}

	fmt.Printf("Total Matches %d\n", valid_passwords)
}

func main() {
	lines, _ := ReadLines("./small_input.txt")
	ValidPasswordsPartTwo(lines)

	all_lines, _ := ReadLines("./large_input.txt")
	ValidPasswordsPartTwo(all_lines)
}
