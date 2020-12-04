# Defines the Row type and associated types and methods.
# Represents a row of Pascal's triangle in an efficient manner.
# Each Row presents a zero indexed array of values.

"""
    ZeroRange(max::Integer)

Represents the integer range 0:max.
"""
struct ZeroRange <: AbstractUnitRange{Integer}
    max::Integer
    function ZeroRange(max)
        max ≥ 0 || throw(ArgumentError("end of range must be nonnegative"))
        new(max)
    end
end
Base.length(z::ZeroRange) = z.max + 1
Base.first(z::ZeroRange) = 0
Base.last(z::ZeroRange) = z.max
Base.iterate(z::ZeroRange, i = 0) = i > z.max ? nothing : (i, i+1)
function Base.getindex(z::ZeroRange, i::Integer)
    1 ≤ i ≤ z.max+1 || throw(BoundsError("index out of bounds"))
    return i-1
end
function Base.convert(::Type{AbstractUnitRange{T}}, z::ZeroRange) where {T}
    return 0:z.max
end
Base.show(io::IO, z::ZeroRange) = print(io, typeof(z).name, "(", z.max, ")")

"""
    numelements(rownum)

A utility function to return the number of elements that need to be
stored in order to represent row `rownum`. This is two less than half
the entries in the row so as to reduce redundancy.
"""
numelements(rownum) = rownum ≤ 3 ? 0 : (rownum-2)÷2

"""
    Row(rownum, data)
    Row(rownum)
    Row(V::Type, rownum, datasize)
    Row(r::Row)

Represents a single row of Pascal's triangle. Supplied `data` is not checked
for correctness, and since `Row`s are mutable storage can be pre-allocated to
ensure enough storage for up to row `datasize`. Constructing with just the
`rownum` will efficiently calculate the row entries. In all cases, `rownum`
must be nonnegative.

Note: Row uses an internal data structure that reduces redundant data storage.
Directly supplying a `data` argument is not recommended.

# Examples
```jldoctest
julia> Row(2)
3-element Row{Integer} with indices PascalsTriangle.ZeroRange(2):
 1
 2
 1

julia> Row(Float64, 2, 10)
3-element Row{Float64} with indices PascalsTriangle.ZeroRange(2):
 1.0
 2.0
 1.0
```
"""
mutable struct Row{V} <: AbstractVector{V}
    rownum::Integer
    data::Vector{V}
    function Row(rownum,data)
        rownum ≥ 0 || throw(DomainError(rownum,"rownum must be nonnegative"))
        return new{eltype(data)}(rownum,data)
    end
end
Row(r::Row) = Row(r.rownum, copy(r.data))
Row(rownum) = Row(Integer, rownum, rownum)
Row(V::Type, rownum) = Row(V, rownum, rownum)
function Row(V::Type, rownum, datasize)
    rownum ≥ 0 || throw(DomainError(rownum,"rownum must be nonnegative"))
    datasize ≥ rownum || throw(ArgumentError("datasize specified is not enough to store the row"))
    arr = Vector{V}(undef, numelements(datasize))
    datalength = numelements(rownum)
    if datalength ≥ 1
        entry = Entry(rownum,1,rownum*one(V))
        for i ∈ 1:datalength
            entry = right(entry)
            arr[i] = entry.val
        end
    end
    return Row(rownum, arr)    
end

rownumber(r::Row) = r.rownum
function value(r::Row)
    arr = ones(eltype(r.data), r.rownum+1)
    for i ∈ 1:(r.rownum-1)
        arr[i+1] = r[i]
    end
    return arr
end
Base.values(r::Row) = value(r)

const THRESHOLD = 10
const HALF = 4
function tostring(r::Row)
    v = values(r)
    s = "<"
    if r.rownum < THRESHOLD
        s *= join(v, ", ") 
    else
        s *= join(v[1:HALF], ", ")
        s *= ", ..., "
        s *= join(v[end-HALF+1:end], ", ")
    end
    s *= ">"
    return s
end
function Base.show(io::IO, ::MIME"text/plain", r::Row)
    print(io, "$(typeof(r).name)")
    print(io, tostring(r))
end
function Base.show(io::IO, r::Row)
    print(io, tostring(r))
end

function Base.sum(f, r::Row)
    if r.rownum == 0
        return f(1)
    elseif r.rownum == 1
        return 2f(1)
    elseif r.rownum == 2
        return 2f(1) + f(2)
    end
    unit = one(eltype(r.data))
    s = 2f(unit) + 2f(unit*r.rownum)
    datalength = numelements(r.rownum)
    if datalength > 0
        for i ∈ 1:(datalength-1)
            s += 2f(r.data[i])
        end
        if iseven(r.rownum)
            s += f(r.data[datalength])
        else
            s += 2f(r.data[datalength])
        end
    end
    return s
end
Base.sum(r::Row) = 2^r.rownum
Base.axes(r::Row) = (ZeroRange(r.rownum),)
Base.axes1(r::Row) = ZeroRange(r.rownum)
Base.LinearIndices(r::Row) = ZeroRange(r.rownum)
Base.size(r::Row) = (r.rownum + 1,)
Base.IndexStyle(::Type{<:Row}) = IndexLinear()
function Base.getindex(r::Row, i::Int)
    0 ≤ i ≤ r.rownum || throw(BoundsError(r, i))
    index = i > r.rownum÷2 ? r.rownum - i : i
    if index == 0
        return one(eltype(r.data))
    end
    if index == 1
        return one(eltype(r.data))*r.rownum
    end
    return r.data[index-1]
end
Base.getindex(r::Row, ::Colon) = value(r)
Base.getindex(r::Row, I) = [r[i] for i ∈ I]
Base.firstindex(r::Row) = 0
Base.lastindex(r::Row) = r.rownum

Base.:(==)(a::Row, b::Row) = a.rownum == b.rownum &&
    a.data[1:numelements(a.rownum)] == b.data[1:numelements(b.rownum)]

isfirst(r::Row) = r.rownum == 0
isvalid(r::Row) = r.rownum ≥ 0 &&
    length(r.data) ≥ numelements(r.rownum) && 
    r.data[1:numelements(r.rownum)] == Row(r.rownum).data
toarray(r::Row) = Entry.(r.rownum,0:r.rownum,value(r))