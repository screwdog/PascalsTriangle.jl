# Tests for Centre and LazyCentre types, and associated methods

@testset "Centre" begin
    @testset "Constructors" begin
        @test_throws DomainError Centre(-1)

        a = Centre([1,1,2,3,6])
        b = Centre(a)
        c = Centre{Integer}(4)
        d = Centre(4)
        e = Centre(LazyCentre(d))

        @test a == b == c == d == e

        b.data[2] = 4
        @test a != b

        a = Centre([1.0, 1.0, 2.0, 3.0, 6.0])
        b = Centre(a)
        c = Centre{Float64}(4)
        d = Centre(4) # different data type
        @test a == b == c == d
    end

    @testset "Accessors" begin
        a = Centre(4)
        @test values(a) == [1, 1, 2, 3, 6]
    end

    @testset "Array functions" begin
        a = Centre(8)
        b = Centre{Float64}(8)
        @test axes(a) == axes(b) == (ZeroRange(8),)

        @testset "Data access $i" for i ∈ 0:8
            @test a[i] == b[i]
        end

        @test_throws BoundsError a[-1]
        @test_throws BoundsError a[10]

        @test firstindex(a) == firstindex(b) == 0
        @test lastindex(a) == lastindex(b) == 8
    end

    @testset "Checks" begin
        a = Centre(4)
        b = Centre([1, 1, 2, 3, 6])
        c = Centre([1, 5, 15, 35, 80])

        @test PT.isvalid(a)
        @test !PT.isvalid(c)

        @test toarray(a) == toarray(b)
    end
end

@testset "LazyCentre" begin
    @testset "Constructors" begin
        a = LazyCentre(0 => 1, 1 => 1)
        b = LazyCentre(a)
        c = LazyCentre{Integer}()
        d = LazyCentre()
        e = LazyCentre(Centre(1))
        @test a == b == c == d == e

        b.data[1] = 2
        @test a != b

        a = LazyCentre([0 => 1.0, 1 => 1.0])
        b = LazyCentre(a)
        c = LazyCentre{Float64}()
        d = LazyCentre() # different data type
        e = LazyCentre(Centre{Float64}(1))
        @test a == b == c == d == e
    end

    @testset "Accessors" begin
        a = LazyCentre(4)
        @test values(a) == [1, 1, 2, 3, 6]
    end

    @testset "Array functions" begin
        a = Centre(8)
        b = Centre{Float64}(8)
        @test axes(a) == axes(b) == (ZeroRange(8),)

        @testset "Data access $i" for i ∈ 0:8
            @test a[i] == b[i]
        end

        @test_throws BoundsError a[-1]
        @test_throws BoundsError a[10]

        @test firstindex(a) == firstindex(b) == 0
    end

    @testset "Checks" begin
        a = Centre(4)
        b = Centre([1, 1, 2, 3, 6])
        c = Centre([1, 5, 15, 35, 80])

        @test PT.isvalid(a)
        @test !PT.isvalid(c)

        @test toarray(a) == toarray(b)
    end
end