# Defines the Column type and associated methods. Consistent
# with the rest of this package a column is a sequence of values
# from Pascal's triangle (n, k) where n ranges from k upwards.

abstract type AbstractColumn{V} <: AbstractVector{V} end
Base.IteratorEltype(::Type{<:AbstractColumn}) = Base.HasEltype()
Base.IndexStyle(::Type{<:AbstractColumn}) = IndexLinear()
isatleft(c::AbstractColumn) = isfirst(c)

"""
    Column(colnum, data)
    Column(colnum, datasize)
    Column(V::Type, colnum, datasize)
    Column(c::Column)

Represents a column of Pascal's triangle. That is, the top-most
`datasize` elements of `binomial(n,colnum)` where `n ≥ colnum`,
but this is calculated more efficiently. As with all types in this
package, columns are numbered from 0.

# Examples
```jldoctest
julia> Column(2, 3)
3-element Column{Integer}:
 1
 3
 6

julia> Column(Float64, 2, 3)
3-element Column{Float64}:
 1.0
 3.0
 6.0
```
"""
mutable struct Column{V} <: AbstractColumn{V}
    colnum::Int
    data::Array{V,1}
    function Column(colnum::Integer, data::Array)
        colnum ≥ 0 || throw(DomainError("colnum must be nonnegative"))
        return new{eltype(data)}(colnum, data)
    end
end 
Column(c::Column) = Column(c.colnum, deepcopy(c.data))
function Column{V}(colnum, datasize) where {V <: Real}
    datasize ≥ 0 || throw(DomainError("datasize must be nonnegative"))
    arr = ones(V,datasize)
    entry = Entry(colnum,colnum,one(V))
    for i ∈ 2:datasize
        down!(entry)
        arr[i] = entry.val
    end
    return Column(colnum, arr)
end
Column(colnum::Integer, datasize::Integer) = Column{Int}(colnum, datasize)

colnumber(c::Column) = c.colnum
value(c::Column) = c.data
Base.values(c::Column) = value(c)

Base.length(c::Column) = length(c.data)
Base.size(c::Column) = (length(c),)
Base.getindex(c::Column, i::Int) = c.data[i-c.colnum+1]
Base.firstindex(c::Column) = c.colnum
Base.lastindex(c::Column) = c.colnum + length(c.data) - 1
Base.eltype(c::Column) = eltype(c.data)
Base.axes(c::Column) = (firstindex(c):lastindex(c),)

isfirst(c::Column) = c.colnum == 0
isvalid(c::Column) = c.colnum ≥ 0 && c.data == Column(c.colnum, length(c.data)).data
toarray(c::Column) = Entry.(firstindex(c):lastindex(c), c.colnum, c.data)

mutable struct LazyColumn{V} <: AbstractColumn{V}
    colnum::Int
    data::Dict{Int, V}
    function LazyColumn(colnum::Integer, data::Dict)
        colnum ≥ 0 || throw(DomainError("colnum must be nonnegative"))
        return new{valtype(data)}(colnum, data)
    end
end 
LazyColumn(c::LazyColumn) = LazyColumn(c.colnum, copy(c.data))
LazyColumn(c::Column) = LazyColumn(c.colnum, 1:length(c) .=> c.data)
LazyColumn{V}(colnum) where {V <: Real} = LazyColumn(colnum, Dict{Int,V}(1 => 1))
LazyColumn(colnum::Integer) = LazyColumn{Int}(colnum)

function Column(c::LazyColumn)
    data = eltype(c)
    i = c.colnum
    while haskey(c.data, i)
        push!(data, c.data[i])
        i += 1
    end
    return Column(c.colnum, data)
end

colnumber(c::LazyColumn) = c.colnum
function Base.getindex(c::LazyColumn, i::Int)
    c.colnum ≤ i || throw(BoundsError(c, i))
    c.colnum == 0 && return one(valtype(c.data))
    j = i - c.colnum + 1
    if haskey(c.data, j)
        return c.data[j]
    end
    e = Entry{valtype(c.data)}(i, c.colnum)
    uprange = (j-1):-1:max(1,j-PRECALC_NUMBER)
    a = Entry(e)
    for k ∈ uprange
        up!(a)
        if !haskey(c.data, k)
            c.data[k] = a.val
        end
    end
    downrange = (j+1):(j+PRECALC_NUMBER)
    a = Entry(e)
    for k ∈ downrange
        down!(a)
        if !haskey(c.data, k)
            c.data[k] = a.val
        end
    end
    return e.val
end
Base.getindex(c::LazyColumn, I) = [c[i] for i ∈ I]
Base.firstindex(c::LazyColumn) = c.colnum
Base.IteratorSize(::LazyColumn) = Base.IsInfinite()
Base.eltype(::LazyColumn{V}) where {V <: Real} = V
Base.keys(c::LazyColumn) = (c.colnum - 1) .+ keys(c.data)

function Base.show(io::IO, ::MIME"text/plain", c::LazyColumn)
    print(io, "$(typeof(c).name){$(valtype(c.data).name)}")
    print(io, "($(c.colnum))\n")
    print(io, "($(length(c.data)) elements precalculated, ")
    print(io, "up to row $(maximum(keys(c.data))+c.colnum-1))")
end
function Base.show(io::IO, c::LazyColumn)
    print(io, "$(typeof(c).name)")
    print(io, "($(c.colnum))")
end

Base.:(==)(a::LazyColumn, b::LazyColumn) = a.colnum == b.colnum &&
    isvalid(a) && isvalid(b)

isfirst(c::LazyColumn) = c.colnum == 0
function isvalid(c::LazyColumn)
    c.colnum < 0 && return false
    for (r, val) ∈ c.data
        if binomial(big(c.colnum + r - 1), big(c.colnum)) ≠ val
            return false
        end
    end
    return true
end

toarray(c::LazyColumn) = Entry.(keys(c), c.colnum, values(c.data))