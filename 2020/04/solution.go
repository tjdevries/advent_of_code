package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
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

func LineSplitter(m map[string]string, line string) {
	key, value := "", ""

	parsing_key := true

	for _, v := range line {
		letter := string(v)
		if letter == " " {
			if key != "" && value != " " {
				m[key] = value
			}

			key = ""
			value = ""

			parsing_key = true
		} else if letter == ":" {
			parsing_key = false
		} else if parsing_key {
			key += letter
		} else {
			value += letter
		}
	}

	if key != "" && value != " " {
		m[key] = value
	}
}

func contains(slice []string, item string) bool {
	set := make(map[string]struct{}, len(slice))
	for _, s := range slice {
		set[s] = struct{}{}
	}

	_, ok := set[item]
	return ok
}

var passPortChecker = map[string]func(string) bool{
	"byr": func(val string) bool {
		i_val, err := strconv.Atoi(val)
		if err != nil {
			return false
		}

		return len(val) == 4 && i_val >= 1920 && i_val <= 2002
	},

	"iyr": func(val string) bool {
		i_val, err := strconv.Atoi(val)
		if err != nil {
			return false
		}

		return len(val) == 4 && i_val >= 2010 && i_val <= 2020
	},

	"eyr": func(val string) bool {
		i_val, err := strconv.Atoi(val)
		if err != nil {
			return false
		}

		return len(val) == 4 && i_val >= 2020 && i_val <= 2030
	},

	"hgt": func(val string) bool {
		inch_index := strings.Index(val, "in")
		cm_index := strings.Index(val, "cm")

		if inch_index > -1 && cm_index > -1 {
			fmt.Println("both cm and in", val)
			return false
		} else if inch_index == -1 && cm_index == -1 {
			fmt.Println("No cm or in", val)
			return false
		}

		if cm_index > -1 {
			i_val, err := strconv.Atoi(val[:cm_index])
			if err != nil {
				fmt.Println("Failed to convert cm:", val, val[:cm_index])
				return false
			}

			return i_val >= 150 && i_val <= 193
		} else {
			i_val, err := strconv.Atoi(val[:inch_index])
			if err != nil {
				fmt.Println("Failed to convert in:", val, val[:inch_index])
				return false
			}

			return i_val >= 59 && i_val <= 76
		}
	},

	"hcl": func(value string) bool {
		if len(value) != 7 {
			return false
		}

		if value[0] != '#' {
			return false
		}

		r, err := regexp.Compile(`[0-9a-f]*`)
		if err != nil {
			return false
		}

		if !r.MatchString(value[1:]) {
			fmt.Println("Failed to match for hcl:", value)
			return false
		}

		return true
	},

	"ecl": func(value string) bool {
		valid_strings := []string{"amb", "blu", "brn", "gry", "grn", "hzl", "oth"}
		return contains(valid_strings, value)
	},

	"pid": func(value string) bool {
		r, _ := regexp.Compile(`^\d{9}$`)
		return r.MatchString(value)
	},

	"cid": func(value string) bool { return true },
}

func IsValidPassport(m map[string]string) bool {
	for key, checker := range passPortChecker {
		value, prs := m[key]
		if !prs {
			if key != "cid" {
				fmt.Println("Missing key:", key)
				return false
			}
			continue
		}

		if !checker(value) {
			fmt.Println("BAD:", key, value)
			return false
		}
	}

	for key := range m {
		if key == "" {
			fmt.Println(m)
			panic("Yo, we bad")
		}

		_, prs := passPortChecker[key]
		if !prs {
			fmt.Println("Failed on key:", key)
			return false
		}
	}

	return true
}

func main() {
	example, _ := ReadLines("./puzzle.txt")
	// example, _ := ReadLines("./test_2.txt")
	// example, _ := ReadLines("./example.txt")

	passports := []map[string]string{}
	p := make(map[string]string)

	for _, line := range example {
		if line == "" {
			passports = append(passports, p)
			p = make(map[string]string)
		}

		LineSplitter(p, line)
	}

	fmt.Println("Num Maps: ", len(passports))

	validPassports := 0
	for _, pass := range passports {
		if IsValidPassport(pass) {
			validPassports += 1
		}
	}

	fmt.Println(validPassports)
}
