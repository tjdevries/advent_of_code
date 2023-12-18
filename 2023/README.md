```
$ opam switch create . 5.1.0~rc3

# Might need to do this, depends on your env
$ eval $(opam env)

$ opam install . --deps-only

$ dune exec day03 --profile=release
