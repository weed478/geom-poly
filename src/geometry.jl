module Geometry

export mkorient,
       mkverttypes,
       ismonotone

using GeometryBasics

include("orient.jl")
include("verttypes.jl")
include("monotone.jl")

end # module
