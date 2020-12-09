package main

import (
	"advent/utils"
	"fmt"
	"strconv"
	"strings"
)

var OpDisptach = map[string]func(instr Instruction, accumulator *int, index *int){
	"nop": func(instr Instruction, accumulator *int, index *int) {
		*index += 1
	},

	"acc": func(instr Instruction, accumulator *int, index *int) {
		*index += 1
		*accumulator += instr.argument
	},

	"jmp": func(instr Instruction, accumulator *int, index *int) {
		*index += instr.argument
	},
}

type Instruction struct {
	operation string
	argument  int
}

type OperationResult struct {
	accumulator    int
	next_operation int
}

func LineToInstruction(line string) Instruction {
	splitLine := strings.Split(line, " ")

	argument, _ := strconv.Atoi(splitLine[1])

	return Instruction{
		splitLine[0],
		argument,
	}
}

func ExecuteInstruction(instruction Instruction, accumulator *int, index *int) {
	OpDisptach[instruction.operation](instruction, accumulator, index)
}

type void struct{}

var member void

func IsLoopedInstructions(instructions []Instruction) (bool, int) {
	visited := make(map[int]interface{})

	accumulator := 0
	index := 0

	prevIndex := -1
	for {
		_, hasVisited := visited[index]
		if hasVisited {
			return true, prevIndex
		}

		if index < 0 {
			return true, prevIndex
		}

		if index >= len(instructions) {
			break
		}

		prevIndex = index

		visited[index] = member
		ExecuteInstruction(instructions[index], &accumulator, &index)
	}

	return false, accumulator
}

func GetExecutedInstructions(instructions []Instruction) []int {
	executed := []int{}

	visited := make(map[int]interface{})

	accumulator := 0
	index := 0

	for {
		_, hasVisited := visited[index]
		if hasVisited {
			break
		}

		if index < 0 {
			break
		}

		if index >= len(instructions) {
			break
		}

		executed = append(executed, index)

		visited[index] = member
		ExecuteInstruction(instructions[index], &accumulator, &index)
	}

	return executed
}

func FlipInstruction(instr Instruction) Instruction {
	fmt.Println("Flipping insrt:", instr)
	if instr.operation == "nop" {
		return Instruction{"jmp", instr.argument}
	} else {
		return Instruction{"nop", instr.argument}
	}
}

func main() {
	// lines, _ := utils.ReadLines("./08/example.txt")
	lines, _ := utils.ReadLines("./08/test.txt")

	instructions := []Instruction{}
	for _, line := range lines {
		instructions = append(instructions, LineToInstruction(line))
	}

	newInstructions := make([]Instruction, len(instructions))

	executed := GetExecutedInstructions(instructions)
	for i := len(executed) - 1; i >= 0; i-- {
		indexToFlip := executed[i]
		instructionToFlip := newInstructions[indexToFlip]
		if instructionToFlip.operation == "acc" {
			continue
		}

		copy(newInstructions, instructions)
		newInstructions[indexToFlip] = FlipInstruction(instructionToFlip)
		isLoop, acc := IsLoopedInstructions(newInstructions)

		if !isLoop {
			fmt.Println("Last Flipped Index: ", indexToFlip, " // ", acc)
			break
		}
	}
}
