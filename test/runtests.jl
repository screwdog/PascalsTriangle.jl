using PascalsTriangle
const PT = PascalsTriangle
using Test

@testset "PascalsTriangle.jl" begin
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

    @testset "ZeroRange" begin
        @test_throws ArgumentError PascalsTriangle.ZeroRange(-1)
        a = PascalsTriangle.ZeroRange(0)
        b = PascalsTriangle.ZeroRange(5)

        @test axes(a) == (a,)

        @test length(a) == 1
        @test length(b) == 6

        @test first(b) == 0
        @test last(b) == 5

        @testset "Values $i" for i ∈ 1:6
            @test b[i] == i-1
        end
    end

    @testset "Row" begin
        @testset "Constructors" begin
            @test_throws DomainError Row(-1, [])

            a = Row(0, [1])
            b = Row(a)
            c = Row(0)
            d = Row(Integer, 0, 10)
            @test a == b == c == d

            a = Row(3, [1.0,3.0,3.0,1.0])
            b = Row(a)
            c = Row(3) # different data type
            d = Row(Float64, 3, 10)
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
            b = Row(Float64, 7, 8)
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

    @testset "Column" begin
        @testset "Constructors" begin
            @test_throws DomainError Column(-1, [])

            a = Column(0, [1,1,1,1])
            b = Column(a)
            c = Column(Integer, 0, 4)
            d = Column(0, 4)
            @test a == b == c == d

            b.data[2] = 4
            @test a != b

            a = Column(3, [1.0, 4.0, 10.0, 20.0])
            b = Column(a)
            c = Column(Float64, 3, 4)
            d = Column(3, 4) # different data type
            @test a == b == c == d
        end

        @testset "Accessors" begin
            a = Column(5,4)
            @test colnumber(a) == 5
            @test value(a) == [1, 6, 21, 56]
        end

        @testset "Array functions" begin
            a = Column(7, 8)
            b = Column(Float64, 7, 8)
            @test size(a) == size(b) == (8,)

            @testset "Data access $i" for i ∈ 1:8
                @test a[i] == b[i]
            end

            @test_throws BoundsError a[-1]
            @test_throws BoundsError a[10]

            @test firstindex(a) == firstindex(b) == 1
            @test lastindex(a) == lastindex(b) == 8
        end

        @testset "Checks" begin
            a = Column(0, 5)
            b = Column(4, 5)
            c = Column(4, [1, 5, 15, 35, 80])
            d = Column(4, [1.0, 5.0, 15.0, 35.0, 70.0])

            @test isfirst(a)
            @test !isfirst(b)

            @test PT.isvalid(a)
            @test !PT.isvalid(c)

            @test toarray(b) == toarray(d)
        end

        @testset "Movement" begin
            a = Column(0, 4)
            b = Column(8, 4)
            c = Column(9, 4)
            d = Column(10, 4)

            @test_throws OutOfBoundsError left!(a)
            @test_throws OutOfBoundsError left(a)
            @test_throws OutOfBoundsError prev!(a)
            @test_throws OutOfBoundsError prev(a)

            @test left(c) == prev(c) == b
            @test right(c) == next(c) == d

            e = Column(b)
            f = Column(d)

            right!(b)
            next!(e)
            left!(d)
            prev!(f)
            @test b == c == d == e == f
        end
    end
end