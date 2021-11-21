module Geometry

export mkorient,
       mkverttypes,
       ismonotone,
       mktriangulate

using GeometryBasics

include("orient.jl")
include("verttypes.jl")
include("monotone.jl")
include("triangulate.jl")

end # module
