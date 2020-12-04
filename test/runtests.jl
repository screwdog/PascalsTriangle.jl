using PascalsTriangle
const PT = PascalsTriangle
using Test

@testset "PascalsTriangle.jl" begin

    include("entries.jl")
    include("zerorange.jl")
    include("rows.jl")
    include("columns.jl")

end