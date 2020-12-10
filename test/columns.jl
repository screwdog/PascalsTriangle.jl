# Tests for Column and LazyColumn types, and associated methods

@testset "Column" begin
    @testset "Constructors" begin
        @test_throws DomainError Column(-1, [])

        a = Column(0, [1,1,1,1])
        b = Column(a)
        c = Column{Integer}(0, 4)
        d = Column(0, 4)
        @test a == b == c == d

        b.data[2] = 4
        @test a != b

        a = Column(3, [1.0, 4.0, 10.0, 20.0])
        b = Column(a)
        c = Column{Float64}(3, 4)
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
        b = Column{Float64}(7, 8)
        @test size(a) == size(b) == (8,)

        @testset "Data access $i" for i ∈ 7:14
            @test a[i] == b[i]
        end

        @test_throws BoundsError a[6]
        @test_throws BoundsError a[15]

        @test firstindex(a) == firstindex(b) == 7
        @test lastindex(a) == lastindex(b) == 14
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

@testset "LazyColumn" begin
    @testset "Constructors" begin
        @test_throws DomainError LazyColumn(-1, Dict{Int,Int}())

        a = LazyColumn(0, Dict(1 => 1))
        b = LazyColumn(a)
        c = LazyColumn{Integer}(0)
        d = LazyColumn(0)
        @test a == b == c == d

        b.data[2] = 4
        @test a != b

        a = LazyColumn(3, Dict(1 => 1.0))
        b = LazyColumn(a)
        c = LazyColumn{Float64}(3)
        d = LazyColumn(3) # different data type
        @test a == b == c == d
    end

    @testset "Accessors" begin
        a = LazyColumn(5)
        @test colnumber(a) == 5
    end

    @testset "Array functions" begin
        a = LazyColumn(7)
        b = LazyColumn{Float64}(7)

        @testset "Data access $i" for i ∈ 7:14
            @test a[i] == b[i]
        end

        @test_throws BoundsError a[-1]

        @test firstindex(a) == firstindex(b) == 7
    end

    @testset "Checks" begin
        a = LazyColumn(0)
        b = LazyColumn(4,
            Dict(1 => 1, 2 => 5, 3 => 15, 4 => 35, 5 => 70))
        c = LazyColumn(4,
            Dict(1 => 1, 2 => 5, 3 => 15, 4 => 35, 5 => 80))
        d = LazyColumn(4,
            Dict(1 => 1.0, 2 => 5.0, 3 => 15.0, 4 => 35.0, 5 => 70.0))

        @test isfirst(a)
        @test !isfirst(b)

        @test PT.isvalid(a)
        @test !PT.isvalid(c)

        @test toarray(b) == toarray(d)
    end

    @testset "Movement" begin
        a = LazyColumn(0)
        b = LazyColumn(8)
        c = LazyColumn(9)
        d = LazyColumn(10)

        @test_throws OutOfBoundsError left!(a)
        @test_throws OutOfBoundsError left(a)
        @test_throws OutOfBoundsError prev!(a)
        @test_throws OutOfBoundsError prev(a)

        @test left(c) == prev(c) == b
        @test right(c) == next(c) == d

        e = LazyColumn(b)
        f = LazyColumn(d)

        right!(b)
        next!(e)
        left!(d)
        prev!(f)
        @test b == c == d == e == f
    end
end