package main

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

type Status struct {
	boatLocation  Location
	pointLocation Location
}

var waypointDispatch = map[string]func(wayStatus Status, amount int) Status{
	"N": func(wayStatus Status, amount int) Status {
		wayStatus.pointLocation.y += amount
		return wayStatus
	},
	"S": func(wayStatus Status, amount int) Status {
		wayStatus.pointLocation.y -= amount
		return wayStatus
	},
	"E": func(wayStatus Status, amount int) Status {
		wayStatus.pointLocation.x += amount
		return wayStatus
	},
	"W": func(wayStatus Status, amount int) Status {
		wayStatus.pointLocation.x -= amount
		return wayStatus
	},
	"L": func(wayStatus Status, amount int) Status {
		amount = (360 + amount) % 360
		switch amount {
		case 0:
			break
		case 90:
			wayStatus.pointLocation.x, wayStatus.pointLocation.y = -wayStatus.pointLocation.y, wayStatus.pointLocation.x
		case 180:
			wayStatus.pointLocation.x, wayStatus.pointLocation.y = -wayStatus.pointLocation.x, -wayStatus.pointLocation.y
		case 270:
			wayStatus.pointLocation.x, wayStatus.pointLocation.y = wayStatus.pointLocation.y, -wayStatus.pointLocation.x
		}
		return wayStatus
	},
	"F": func(wayStatus Status, amount int) Status {
		wayStatus.boatLocation.x += amount * wayStatus.pointLocation.x
		wayStatus.boatLocation.y += amount * wayStatus.pointLocation.y
		return wayStatus
	},
}

func ApplyWaypoint(wayStatus Status, instruction Instruction) Status {
	return waypointDispatch[instruction.code](wayStatus, instruction.amount)
}

func main() {
	// HAX
	waypointDispatch["R"] = func(wayStatus Status, amount int) Status {
		return waypointDispatch["L"](wayStatus, -amount)
	}

	// lines, _ := utils.ReadLines("./12/example.txt")
	lines, _ := utils.ReadLines("./12/test.txt")

	wayStatus := Status{
		Location{0, 0},
		Location{10, 1},
	}

	instructions := TransformLines(lines)
	for _, instr := range instructions {
		fmt.Println("Applying instr:", instr)
		wayStatus = ApplyWaypoint(wayStatus, instr)
		fmt.Println("  Result:", wayStatus)
	}

	fmt.Println(wayStatus)
	fmt.Println("Final:", math.Abs(float64(wayStatus.boatLocation.x))+math.Abs(float64(wayStatus.boatLocation.y)))

}
