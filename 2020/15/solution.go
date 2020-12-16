package main

import (
	"advent/utils"
	"fmt"
	"strconv"
	"strings"
)

func StartNumbersToMap(numbers []int) GameState {
	numbersToTurn := map[int]int{}
	numberReferences := map[int][]int{}

	for turn, number := range numbers {
		numbersToTurn[number] = turn + 1
		numberReferences[number] = append(numberReferences[number], turn+1)
	}

	return GameState{
		numbersToTurn:    numbersToTurn,
		numberReferences: numberReferences,
	}
}

type GameState struct {
	numbersToTurn map[int]int
	// Smart thing to do would be to just have some list of two here.
	// and you just replace them...
	numberReferences map[int][]int
}

func GetNextTurn(gameState GameState, turnNumber int, prevTurn int) int {
	// fmt.Println("TURN: ", turnNumber, "prevTurn", prevTurn)

	prevReferences := gameState.numberReferences[prevTurn]

	val := -1
	if len(prevReferences) == 1 {
		// fmt.Println("New value:", prevTurn)
		val = 0
	} else {
		val = prevReferences[len(prevReferences)-1] - prevReferences[len(prevReferences)-2]
		// fmt.Println("Getting diff", turnNumber, gameState.numbersToTurn[prevTurn], "->", val)
	}

	gameState.numberReferences[val] = append(gameState.numberReferences[val], turnNumber)

	// fmt.Println("\tRESULT:", val)
	return val
}

func main() {
	// 0,3,1,6,7,5
	lines, _ := utils.ReadLines("./15/example.txt")
	startingNumberStrs := strings.Split(lines[0], ",")

	startingNumbers := make([]int, len(startingNumberStrs))
	for i, v := range startingNumberStrs {
		intValue, _ := strconv.Atoi(v)
		startingNumbers[i] = intValue
	}

	startingNumbers = []int{0, 3, 6}
	startingNumbers = []int{0, 3, 1, 6, 7, 5}
	gameState := StartNumbersToMap(startingNumbers)
	fmt.Println(gameState)

	nextTurn := startingNumbers[len(startingNumbers)-1]
	fmt.Println("First next turn: ", nextTurn)
	for turn := len(startingNumbers) + 1; turn < 30000001; turn++ {
		nextTurn = GetNextTurn(gameState, turn, nextTurn)

		// if turn == 10 {
		// 	break
		// }
	}
	fmt.Println(nextTurn)
}
