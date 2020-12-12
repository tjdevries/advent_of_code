package part1

import (
	"advent/utils"
	"fmt"
	"math"
	"strconv"
)

type Location struct {
	x int
	y int
}

type Status struct {
	location  Location
	direction int
}

type Instruction struct {
	code   string
	amount int
}

func TransformLines(lines []string) []Instruction {
	instructions := make([]Instruction, len(lines))
	for i, line := range lines {
		code := string(line[0])
		amount, _ := strconv.Atoi(line[1:])
		instructions[i] = Instruction{
			code, amount,
		}
	}

	return instructions
}

var instructionDispatch = map[string]func(status Status, amount int) Status{
	"F": func(status Status, amount int) Status {
		direction := (360 + status.direction) % 360
		switch direction {
		case 0:
			status.location.x += amount
		case 90:
			status.location.y += amount
		case 180:
			status.location.x -= amount
		case 270:
			status.location.y -= amount
		default:
			panic("Unable to complete")
		}

		return status
	},
	"R": func(status Status, amount int) Status {
		status.direction -= amount
		return status
	},
	"L": func(status Status, amount int) Status {
		status.direction += amount
		return status
	},
	"N": func(status Status, amount int) Status {
		status.location.y += amount
		return status
	},
	"S": func(status Status, amount int) Status {
		status.location.y -= amount
		return status
	},
	"E": func(status Status, amount int) Status {
		status.location.x += amount
		return status
	},
	"W": func(status Status, amount int) Status {
		status.location.x -= amount
		return status
	},
}

func ApplyInstruction(status Status, instruction Instruction) Status {
	return instructionDispatch[instruction.code](status, instruction.amount)
}

func blah() {
	// lines, _ := utils.ReadLines("./12/example.txt")
	lines, _ := utils.ReadLines("./12/test.txt")
	instructions := TransformLines(lines)

	status := Status{
		Location{0, 0},
		0,
	}

	for _, instr := range instructions {
		fmt.Println("Applying instr:", instr)
		status = ApplyInstruction(status, instr)
		fmt.Println("  Result:", status)
	}
	fmt.Println(status)
	fmt.Println("Final:", math.Abs(float64(status.location.x))+math.Abs(float64(status.location.y)))

}
