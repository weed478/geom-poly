module Geometry

export orient3x3,
       orient2x2,
       ismonotone

using GeometryBasics

include("orient.jl")
include("monotone.jl")

end # module
