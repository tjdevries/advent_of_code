import { Match, Schema } from "effect";
import { file } from "bun";


class Instruction extends Schema.Class<Instruction>("Instruction")({
    direction: Schema.Union(Schema.Literal("L"), Schema.Literal("R")),
    steps: Schema.Number,
}) {
    static parse(input: string): Instruction {
        const direction = input[0] as "L" | "R"
        const steps = parseInt(input.slice(1))
        return Instruction.make({ direction, steps })

    }

    static evaluate(instruction: Instruction, position: number): number {
        return Match.value(instruction.direction).pipe(
            Match.when("L", () => position - instruction.steps),
            Match.when("R", () => position + instruction.steps),
            Match.exhaustive
        )
    }
}

// const data = await file("data/day-01-test.txt").text()
const data = await file("data/day-01-prod.txt").text()
const instructions = data.split("\n").map((line) => Instruction.parse(line))
// console.log(instructions[0])

let start = 50;
let zeroCount = 0;
let zeroTouched = 0;

let position = start;
for (const rawInstruction of instructions) {
    const prevPosition = position;

    zeroTouched += Math.floor(Math.abs(rawInstruction.steps) / 100);
    const instruction = Instruction.make({ direction: rawInstruction.direction, steps: rawInstruction.steps % 100 })

    position = Instruction.evaluate(instruction, position)


    // Check if we crossed a zero, going from positive to negative or vice versa
    if (prevPosition > 0 && position < 0) {
        zeroTouched++
    } else if (prevPosition < 0 && position > 0) {
        zeroTouched++
    }

    // We may have added enough to go around a circle
    if (position > 100) {
        zeroTouched++
    }

    // May have ended at a zero or negative position, so we need to wrap around
    position = (position + 100) % 100;
    if (position === 0) {
        zeroCount++
        zeroTouched++
    }
}

console.log({ position, zeroCount, zeroTouched })