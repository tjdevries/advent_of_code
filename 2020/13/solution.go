package main

import (
	"advent/utils"
	"fmt"
	"strconv"
	"strings"
)

type Congruence struct {
	a int
	n int
}

// I didn't know this, for sure.
// a^(n-2) % n
func safeInverse(a, n int) int {
	result := 1
	for i := 0; i < n-2; i++ {
		result *= a % n
		result %= n
	}

	return result
}

// PS Thanks twitch chat for the recommendation
func ChineseRemainderTherorem(congruences []Congruence) int {
	N := 1
	for _, c := range congruences {
		N *= c.n
	}

	for c, _ := range congruences {
		fmt.Println("Hello?", c)
	}

	ys := make([]int, len(congruences))
	for i, cong := range congruences {
		ys[i] = N / cong.n
	}

	zs := make([]int, len(congruences))
	for i, cong := range congruences {
		zs[i] = safeInverse(ys[i], cong.n)
	}

	result := 0
	for i, cong := range congruences {
		result += cong.a * ys[i] * zs[i]
		result %= N
	}

	return result
}

func main() {
	// lines, _ := utils.ReadLines("./13/example.txt")
	lines, _ := utils.ReadLines("./13/test.txt")

	// departureTime, _ := strconv.Atoi(lines[0])

	congruences := []Congruence{}
	for i, v := range strings.Split(lines[1], ",") {
		if v == "x" {
			continue
		}

		busIdNumber, _ := strconv.Atoi(v)
		congruences = append(congruences, Congruence{
			(busIdNumber - (i % busIdNumber)) % busIdNumber,
			busIdNumber,
		})
	}
	fmt.Println(congruences)
	fmt.Println(ChineseRemainderTherorem(congruences))

	// min := busIds[0] - departureTime%busIds[0]
	// minIndex := 0
	// for i, id := range busIds {
	// 	waitTime := id - departureTime%id
	// 	if waitTime < min {
	// 		min = waitTime
	// 		minIndex = i
	// 	}
	// }
	// fmt.Println(min, minIndex)
	// fmt.Println("Result:", min*busIds[minIndex])

	// fmt.Println(ChineseRemainderTherorem([]Congruence{
	// 	{0, 17},
	// 	{11, 13},
	// 	{16, 19},
	// }))

	// fmt.Println(ChineseRemainderTherorem([]Congruence{
	// 	{0, 67},
	// 	{6, 7},
	// 	{57, 59},
	// 	{58, 61},
	// }))

	// 791t % 4199 = 2890 % 4199
	// 791t === 2890

	// multiplicate inverse of a mod p (a % p), a^(p-2) % p
	// 2890 ** (4199 - 2) % 4199
}

// 7 * (t %  7) = 7 * (0)
// t % 13 = 13 - 1
// t % 59 = 59 - 4
// t % 31 = 31 - 6
// t % 19 = 19 - 7

// 7 x - 0 = t
// 13y - 1 = t
// 59z - 4 = t
// 31a - 6 = t
// 19b - 7 = t

// 7x = 13y - 1
// 7x = 59z - 4

// t % 17 = 0
// t % 13 = 11
// t % 19 = 16

// t = 0  mod 17
// t = 11 mod 13
// t = 16 mode 19
//
// 17 * 13 * 19 = 4199
//
// y0 = 4199 / 17
// y1 = 4199 / 13
// y2 = 4199 / 19
//
// x = sum(p(i)*r(i)*(the inverse of p(i) modulo n(i)))
//
// 17, 34, 51, ...
//
// t % 13 = 11
// (t + 2) % 13 = 0
//
// 11, 24, 37, ...
//
// t % 19 = 16
// (t + 3) % 19 = 0
// 16, 35, 54, ...

// (t % 17) + (t % 13) + (t % 19) = 0 + 11 + 16
//                                = 27

// (t * (t + 2) * (t + 3)) % (17 * 13 * 19) = 0
// t^3 * 5t^2 + 6t

//
// t % 17 = 0
// (t + 2) % 13 = 0
// (t + 3) % 19 = 0

// (13 * 19)t       % (17 * 13 * 19) = 0
// (17 * 19)(t + 2) % (17 * 13 * 19) = 0
// (13 * 17)(t + 3) % (17 * 13 * 19) = 0

// 247t       % 4199 = 0
// 323t + 646 % 4199 = 0
// 221t + 663 % 4199 = 0

// 247t + 323t + 646 + 221t + 663 % 4199 = 0

// 791t + 1309 % 4199 = 0

// ???
// 791t % 4199 = 4199 - 1309

// 791t % 4199 = 2890 % 4199
// 791t === 2890

// multiplicate inverse of a mod p (a % p), a^(p-2) % p
// 2890 ** (4199 - 2) % 4199

// 247t, 323t + 646, 221t + 663
