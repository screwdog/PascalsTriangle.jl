# Defines the types Centre, LazyCentre, and associated
# functions. These represent a sequence of elements at
# the middle of each row and are zero-indexed. That is,
# if c is a Centre, then c[i] is the value of the middle
# element(s) of row i.

# LazyCentre calculates only the elements actually
# requested, Centre calculates all the requested elements
# up front.

# Center and LazyCenter are accepted aliases.
const Center = Centre
const LazyCenter = LazyCentre

"""
    AbstractCentre <: AbstractVector

Supertype of all types representing the central elements
of Pascal's triangle.
"""
abstract type AbstractCentre <: AbstractVector end
Base.IndexStyle(::AbstractCentre) = IndexLinear()

"""
    Centre(data)
    Centre(c::Centre)
    Centre{V}(maxrow)
    Centre(maxrow)
    Centre(l::LazyCentre)

Represents a finite sequence of central elements of Pascal's
triangle. That is, the middle value(s) in each row, starting
from row 0 and up to `maxrow`.

`Center` is an alias for `Centre`.
"""
struct Centre{V <: Real} <: AbstractCentre
    data::Vector{V}
end
Centre(c::Centre) = Centre(copy(c))
function Centre{V}(maxrow::Integer) where {V <: Number}
    maxrow ≥ 0 || throw(DomainError("maxrow must be non-negative, maxrow: $maxrow"))
    data = ones(v, maxrow+1)
    if maxrow ≥ 2
        e = Entry(2, 1, V(2))
        for i ∈ 3:2:maxrow-1
            data[i] = e.val
            down!(e)
            data[i+1] = e.val
            e.n += 1
            e.k += 1
            e.val *= 2
        end
        if isodd(maxrow)
            down!(e)
            data[maxrow+1] = e.val
        end
    end
    return Centre{V}(data)
end
Centre(maxrow::Integer) = Centre{BigInt}(maxrow)
function Centre(c::LazyCentre)
    data = eltype(c)[]
    i = 0
    while haskey(c.data, i)
        push!(data, c.data[i])
        i += 1
    end
    return Centre(data)
end

value(c::Centre) = c.data
Base.values(c::Centre) = value(c)

Base.axes(c::Centre) = (ZeroRange(length(c.data)-1),)
Base.axes1(c::Centre) = ZeroRange(length(c.data)-1)
Base.LinearIndices(c::Centre) = ZeroRange(length(c.data)-1)
Base.size(c::Centre) = (length(c.data),)
Base.IndexStyle(::Type{<:Row}) = IndexLinear()
function Base.getindex(c::Centre, i::Int)
    0 ≤ i < length(c.data) || throw(BoundsError(c, i))
    return c.data[i+1]
end
Base.getindex(c::Centre, ::Colon) = value(c)
Base.getindex(c::Centre, I) = [c[i] for i ∈ I]
Base.firstindex(c::Centre) = 0
Base.lastindex(c::Centre) = length(c.data)-1
function toarray(c::Centre, leftbias=true)
    rm = leftbias ? RoundDown : RoundUp
    ns = axes1(c)
    ks = div.(ns, 2, rm)
    return Entry.(ns, ks, c.data)
end

function isvalid(c::Centre)
    ns = big(0):length(c.data)
    ks = ns .÷ 2
    return value(c) == binomial.(ns, ks)
end

"""
    LazyCentre(data)
    LazyCentre(l::LazyCentre)
    LazyCentre{V}()
    LazyCentre()
    LazyCentre(c::Centre)

Represents the central elements of Pascal's triangle but
lazily evaluated. `data` can be supplied as a dictionary
mapping a row number to a value. `V` is a data type for
the values.

`LazyCenter` is an alias for `LazyCentre`.
"""
struct LazyCentre{V <: Real} <: AbstractCentre
    data::Dict{Int,V}
end
LazyCentre(c::LazyCentre) = LazyCentre(copy(c))
LazyCentre{V <: Real}() = LazyCentre{V}(Dict{Int,V}(0 => 1, 1 => 1))
LazyCentre() = LazyCentre{BigInt}()
LazyCentre(c::Centre) = LazyCentre(axes1(c) .=> values(c))

const PRECALC_NUMBER = 5
function Base.getindex(c::LazyCentre, i::Int)
    0 ≤ i || throw(BoundsError(c, i))
    if haskey(c.data, i)
        return c.data[i]
    end
    # Calculating adjacent entries is ≈ 10x faster than calculating
    # isolated entries using binomial, so when calculating a new
    # value we do several either side of it.
    e = Entry{valtype(c.data)}(i, i÷2)
    uprange = (i-1):-1:max(2,i-PRECALC_NUMBER)
    a = Entry(e)
    for j ∈ uprange
        up!(a)
        isodd(a.n) && a.k -= 1
        !haskey(c.data, j) && c.data[j] = a.val
    end
    downrange = (i+1):(i+PRECALC_NUMBER)
    a = Entry(e)
    for j ∈ downrange
        down!(a)
        isodd(a.n) && a.k += 1
        !haskey(c.data, j) && c.data[j] = a.val
    end
    return e.val
end
Base.getindex(c::LazyCentre, I) = [c[i] for i ∈ I]
Base.firstindex(c::LazyCentre) = 0
Base.IteratorSize(::LazyCentre) = Base.IsInfinite()
eltype(::LazyCentre{V}) where {V <: Real} = V

function toarray(c::LazyCentre, leftbias=true)
    rm = leftbias ? RoundDown : RoundUp
    ns = keys(c.data)
    ks = div.(ns, 2, rm)
    return Entry.(ns, ks, values(a))
end

function isvalid(c::LazyCentre)
    return all(p -> binomial(big(first(p)), first(p)÷2) == last(p), c.data)
end