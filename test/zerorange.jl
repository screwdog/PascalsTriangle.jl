# Tests for ZeroRange type and associated methods

@testset "ZeroRange" begin
    @test_throws ArgumentError PascalsTriangle.ZeroRange(-1)
    a = PascalsTriangle.ZeroRange(0)
    b = PascalsTriangle.ZeroRange(5)

    @test axes(a) == (Base.OneTo(1),)

    @test length(a) == 1
    @test length(b) == 6

    @test first(b) == 0
    @test last(b) == 5

    @testset "Values $i" for i ∈ 1:6
        @test b[i] == i-1
    end
end