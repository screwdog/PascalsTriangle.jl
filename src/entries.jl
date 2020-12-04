# Defines the Entry type and associated methods. Entry Represents
# a single entry in Pascal's triangle - a location (n,k) and and
# associated value = binomial(n,k). 

"""
    Entry(n, k, val)
    Entry(n, k)
    Entry(n => k)
    Entry(V::Type, n, k)
    Entry(e::Entry)

Represents a single entry in Pascal's triangle. The supplied `val` is not checked for
correctness but arguments that only specify `n` and `k` must satisfy 0 ≤ k ≤ n and must
both be integer types. The argument `V` specifies a type for the value field.

# Examples
```jldoctest
julia> Entry(6,2)
Entry{Int64,Int64}(6, 2, 15)

julia> Entry(Float64, 6, 2)
Entry{Int64,Float64}(6, 2, 15.0)

julia> Entry(6,2,10) # incorrect value not checked
Entry{Int64,Int64}(6, 2, 10)
```
"""
struct Entry{I <: Integer, V <: Real}
    n::I
    k::I
    val::V
    function Entry(n,k,val)
        0 ≤ k ≤ n || throw(ArgumentError("Entry requires 0 ≤ k ≤ n but n:$n, k:$k"))
        return new{typeof(n), typeof(val)}(n,k,val)
    end
end
Entry(e::Entry) = Entry(e.n, e.k, e.val)
Entry(n,k) = Entry(n,k,binomial(n,convert(typeof(n),k)))
Entry(p::Pair) = Entry(first(p),last(p))
Entry(V::Type,n,k) = Entry(n,k,V(binomial(n,k)))

rownumber(e::Entry) = e.n
rowposition(e::Entry) = e.k
value(e::Entry) = e.val

Base.show(io::IO, ::MIME"text/plain", e::Entry) = print(io, "$(typeof(e).name)($(e.n), $(e.k), $(e.val))")
Base.show(io::IO, e::Entry) = print(io, "($(e.n), $(e.k), $(e.val))")

"""
    ==(a::Entry, b::Entry)

Two entries are equal if they represent the same entry in Pascal's triangle. That is,
they are from the same row, row position and have the same value, although the types 
need not match. 
"""
Base.:(==)(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && a.val == b.val

"""
    isless(a::Entry, b::Entry)

Entries are ordered only by their value, ignoring their rows and row positions.
"""
Base.isless(a::Entry, b::Entry) = a.val < b.val

"""
    ≈(a::Entry, b::Entry)

Entries are approximately equal if they represent the same location within Pascal's
triangle and their values are approximately equal.
"""
Base.isapprox(a::Entry, b::Entry) = a.n == b.n && a.k == b.k && isapprox(a.val, b.val)

"""
    +(a::Entry, b::Entry)

Adding adjacent entries gives the entry directly beneath the two.
"""
function Base.:+(a::Entry, b::Entry)
    isadjacent(a,b) || throw(NonAdjacentError())
    return Entry(a.n+1, max(a.k, b.k), a.val + b.val)
end

"""
    -(a::Entry, b::Entry)

Subtracting two entries that are directly above each other gives the entry directly
adjacent to the upper one, utilising the well-known relation on Pascal's triangle.
"""
function Base.:-(a::Entry, b::Entry)
    issubtractable(a,b) || throw(NonAdjacentError())
    return Entry(b.n, 2a.k - b.k - 1, a.val - b.val)
end

isfirst(a::Entry) = a.n == 0 && a.k == 0
isatleft(a::Entry) = a.k ≤ 0
isatright(a::Entry) = a.k ≥ a.n
isadjacent(a::Entry, b::Entry) = a.n == b.n && abs(a.k - b.k) == 1
isinterior(a::Entry) = a.n ≥ 2 && a.k ≥ 1 && a.k < a.n
issubtractable(a::Entry, b::Entry) = a.n == b.n + 1 && isinterior(a) && 0 ≤ a.k - b.k ≤ 1
isvalid(a::Entry) = 0 ≤ a.n && 0 ≤ a.k ≤ a.n && binomial(a.n, a.k) == a.val