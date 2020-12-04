# Tests for Row type and associated methods

@testset "Row" begin
    @testset "Constructors" begin
        @test_throws DomainError Row(-1, [])

        a = Row(0, [1])
        b = Row(a)
        c = Row(0)
        d = Row{Int}(0, 10)
        @test a == b == c == d

        a = Row(3, [1.0,3.0,3.0,1.0])
        b = Row(a)
        c = Row(3) # different data type
        d = Row{Float64}(3, 10)
        @test a == b == c == d

        a = Row(10)
        b = Row(a)
        b.data[2] = 4
        @test a != b
    end

    @testset "Accessors" begin
        a = Row(5)
        @test rownumber(a) == 5
        @test value(a) == [1,5,10,10,5,1]
    end

    @testset "Array functions" begin
        a = Row(7)
        b = Row{Float64}(7, 8)
        @test sum(a) == 128
        @test sum(x -> x^2, a) == 3432
        @test sum(b) == 128.0
        @test sum(x -> x^2, b) == 3432.0

        @test axes(a) == axes(b) == (0:1:7,)
        @test size(a) == size(b) == (8,)

        @testset "Data access $i" for i ∈ 0:7
            @test a[i] == b[i]
        end

        @test_throws BoundsError a[-1]
        @test_throws BoundsError a[10]

        @test firstindex(a) == firstindex(b) == 0
        @test lastindex(a) == lastindex(b) == 7
    end

    @testset "Checks" begin
        a = Row(0)
        b = Row(4)
        c = Row(4, [7]) # bad data
        d = Row(4, [6.0])

        @test isfirst(a)
        @test !isfirst(b)

        @test PT.isvalid(a)
        @test !PT.isvalid(c)

        @test toarray(b) == toarray(d)
    end

    @testset "Movement" begin
        a = Row(0)
        b = Row(8)
        c = Row(9)
        d = Row(10)

        @test_throws OutOfBoundsError up!(a)
        @test_throws OutOfBoundsError up(a)
        @test_throws OutOfBoundsError prev!(a)
        @test_throws OutOfBoundsError prev(a)

        @test up(c) == prev(c) == b
        @test down(c) == next(c) == d

        e = Row(b)
        f = Row(d)

        down!(b)
        next!(e)
        up!(d)
        prev!(f)
        @test b == c == d == e == f
    end
end