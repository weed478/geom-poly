import Pkg
Pkg.activate("$(@__DIR__)/..")
Pkg.instantiate()

cd("$(@__DIR__)/..")
include("poly.jl")
poly.main()
@info "Press Enter to quit"
read(stdin, Char)
