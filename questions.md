## Go Questions

- What is up with `go mod init advent/m/v2`
    - What are the other options?
- Is it the gopher way to always return `val, err`?
- Does anyone do functional style programming in Go?
    - My guess is one of the problems is that with no generics, functional feels impossible.
    - Ten billion combinations of all the different funcstions
    - `fp.ReduceInt(sumInt, items)` vs `fp.Reduce(sum, items)`
        - I much prefer the sedcond way

## Go notes

When I'm writing go routines and I think "TJ, You race conditions probably deadlocks can't async write things"
then I should try and do something like `go run -race my_thing.go`.


	// make([]int, 0, len(numbers)) which would make len() return 0
	// so append would put the first item at index 0,
	// but the underlying array is preallocated to the correct size
	// contiguousSums := make([]int, 0, len(numbers))
