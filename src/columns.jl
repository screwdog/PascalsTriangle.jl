# Defines the Column type and associated methods. Consistent
# with the rest of this package a column is a sequence of values
# from Pascal's triangle (n, k) where n ranges from k upwards.

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
mutable struct Column{V} <: AbstractVector{V}
    colnum::Integer
    data::Array{V,1}
    function Column(colnum::Integer, data::Array)
        colnum ≥ 0 || throw(DomainError("colnum must be nonnegative"))
        return new{eltype(data)}(colnum, data)
    end
end 
Column(c::Column) = Column(c.colnum, deepcopy(c.data))
function Column(V::Type, colnum, datasize)
    datasize ≥ 0 || throw(DomainError("datasize must be nonnegative"))
    arr = ones(V,datasize)
    entry = Entry(colnum,colnum,one(V))
    for i ∈ 2:datasize
        entry = down(entry)
        arr[i] = entry.val
    end
    return Column(colnum, arr)
end
Column(colnum, datasize) = Column(Integer, colnum, datasize)

colnumber(c::Column) = c.colnum
value(c::Column) = c.data
Base.values(c::Column) = value(c)

Base.size(c::Column) = (length(c.data),)
Base.IndexStyle(::Type{<:Column}) = IndexLinear()
Base.getindex(c::Column, i::Int) = c.data[i]
Base.firstindex(c::Column) = 1
Base.lastindex(c::Column) = length(c.data)

isfirst(c::Column) = c.colnum == 0
isatleft(c::Column) = isfirst(c)
isvalid(c::Column) = c.colnum ≥ 0 && c.data == Column(c.colnum, length(c.data)).data
toarray(c::Column) = Entry.(c.colnum:(c.colnum+length(c.data)-1), c.colnum, c.data)