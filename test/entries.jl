# Tests for Entry type and associated methods

@testset "Entry" begin
    @testset "Constructors" begin
        @test_throws ArgumentError Entry(-5, 10)
        @test_throws ArgumentError Entry(10, -5)
        @test_throws ArgumentError Entry(15, 20)

        @test_throws TypeError Entry(2.5, 1.0, 4)
        @test_throws TypeError Entry(2.0, 1.5, 4)

        @test Entry(4,2,6) == Entry(4,2)

        a = Entry(6,5)
        b = Entry(a)
        c = Entry(6 => 5)
        d = Entry(Integer, 6, 5)
        e = Entry(Int32(6), Int64(5))
        f = Entry(UInt(6), Int(5))
        @test a == b == c == d == e == f

        g = Entry(6,5,6.0)
        h = Entry(Float64, 6, 5)
        @test g == h
    end

    @testset "Accessors" begin
        a = Entry(15,6)
        @test rownumber(a) == 15
        @test rowposition(a) == 6
        @test value(a) == 5005
    end

    @testset "Comparators" begin
        a = Entry(4,1)
        b = Entry(Float64, 4, 1)
        c = Entry(Float64, 10, 5)
        d = Entry(12, 6)
        e = Entry(14, 7)
        @test a ≤ b < c < d < e

        @test a ≈ b
    end

    @testset "Operators" begin
        a = Entry(7,3,35)
        b = Entry(7,4,35.0)
        c = Entry(8,4,70)
        @test a + b == c
        @test_throws NonAdjacentError a + c
        @test c - a == b
        @test_throws NonAdjacentError a - b
    end

    @testset "Checks" begin
        a = Entry(0,0)
        b = Entry(9,0)
        c = Entry(9,9)
        d = Entry(15,3)
        e = Entry(15,4)
        f = Entry(16,4)
        @test isfirst(a)
        @test isatleft(a)
        @test isatleft(b)
        @test !isatleft(c)
        @test isatright(c)
        @test !isatright(b)
        @test isadjacent(d, e)
        @test !isadjacent(a, b)
        @test isinterior(d)
        @test !isinterior(c)
        @test issubtractable(f, d)
        @test issubtractable(f, e)
        @test !issubtractable(d, e)
        @test PT.isvalid(d)
        @test !PT.isvalid(Entry(15,3,0))
    end

    @testset "Movement" begin
        a = Entry(0,0)
        b = Entry(20,20)
        c = Entry(21,0)
        d = Entry(30,10)
        e = Entry(30,11)
        f = Entry(30,12)
        g = Entry(29,11)
        h = Entry(31,11)

        @test_throws OutOfBoundsError prev(a)
        @test_throws OutOfBoundsError up(a)
        @test_throws OutOfBoundsError left(a)
        @test_throws OutOfBoundsError right(a)
        @test down(a) == Entry(1,0)

        @test next(b) == c
        @test b == prev(c)

        @test left(e) == prev(e) == d
        @test right(e) == next(e) == f
        @test up(e) == g
        @test down(e) == h
    end
end