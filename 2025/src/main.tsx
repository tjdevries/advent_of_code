import { Effect, Console } from "effect"

const program = Console.log("hello from effect")

Effect.runPromise(program)
