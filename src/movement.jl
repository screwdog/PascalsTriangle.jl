# Defines various functions for "moving" around
# Pascal's triangle.

_upval(a::Entry{<: Integer}) = a.val*(a.n - a.k)÷a.n
_upval(a::Entry{<: AbstractFloat}) = a.val*(a.n - a.k)/a.n
function up!(a::Entry)
    if isatright(a) || isfirst(a)
        throw(OutOfBoundsError("no entry above"))
    end
    a.val = _upval(a)
    a.n -= 1
    return a
end

up(a::Entry) = up!(Entry(a))

up!(r::Row) = prev!(r)
up(r::Row) = prev(r)

_downval(a::Entry{<: Integer}) = a.val*(a.n + 1)÷(a.n - a.k + 1)
_downval(a::Entry{<: AbstractFloat}) = a.val*(a.n + 1)/(a.n - a.k + 1)
function down!(a::Entry)
    a.val = _downval(a)
    a.n += 1
    return a
end

down(a::Entry) = down!(Entry(a))

down!(r::Row) = next!(r)
down(r::Row) = next(r)

_leftval(a::Entry{<: Integer}) = a.val*a.k÷(a.n - a.k + 1)
_leftval(a::Entry{<: AbstractFloat}) = a.val*a.k/(a.n - a.k + 1)
function _left!(a)
    a.val = _leftval(a)
    a.k -= 1
    return a
end

function left!(a::Entry)
    isatleft(a) && throw(OutOfBoundsError("no entry to the left"))
    return _left!(a)
end
left(a::Entry) = left!(Entry(a))

left!(c::Column) = prev!(c)
left(c::Column) = prev(c)
left!(c::LazyColumn) = prev!(c)
left(c::LazyColumn) = prev(c)

_rightval(a::Entry{<: Integer}) = a.val*(a.n - a.k)÷(a.k + 1)
_rightval(a::Entry{<: AbstractFloat}) = a.val*(a.n - a.k)/(a.k + 1)
function _right!(a::Entry)
    a.val = _rightval(a)
    a.k += 1
    return a
end

function right!(a::Entry)
    isatright(a) && throw(OutOfBoundsError("no entry to the right"))
    return _right!(a)
end
right(a::Entry) = right!(Entry(a))

right!(c::Column) = next!(c)
right(c::Column) = next(c)
right!(c::LazyColumn) = next!(c)
right(c::LazyColumn) = next(c)

function prev!(a::Entry)
    isfirst(a) && throw(OutOfBoundsError("no previous entry"))
    if !isatleft(a)
        return _left!(a)
    else
        a.n -= 1
        a.k = a.n
        a.val = one(a.val)
        return a
    end
end
prev(a::Entry) = prev!(Entry(a))

function prev!(r::Row)
    isfirst(r) && throw(OutOfBoundsError("no previous row"))
    r.rownum -= 1
    datalength = numelements(r.rownum)
    if datalength ≥ 1
        r.data[1] -= r.rownum
        for i ∈ 2:datalength
            r.data[i] -= r.data[i-1]
        end
    end
    return r
end

function prev(r::Row)
    newrow = Row(r)
    return prev!(newrow)
end

function prev!(c::Column)
    isfirst(c) && throw(OutOfBoundsError("no previous column"))
    c.colnum -= 1
    for i ∈ length(c.data):-1:2
        c.data[i] -= c.data[i-1]
    end
    return c
end

function prev(c::Column)
    newcol = Column(c)
    return prev!(newcol)
end

function prev!(c::LazyColumn)
    isfirst(c) && throw(OutOfBoundsError("no previous column"))
    c.colnum -= 1
    for (r, val) ∈ c.data
        c.data[r] = value(up!(Entry(r + c.colnum, r - 1, val)))
    end
    return c
end

function prev(c::LazyColumn)
    newcol = LazyColumn(c)
    return prev!(newcol)
end

function next!(a::Entry)
    if !isatright(a)
        return _right!(a)
    else
        a.n += 1
        a.k = zero(a.k)
        a.val = one(a.val)
        return a
    end
end
next(a::Entry) = next!(Entry(a))

function next!(r::Row)
    datalength = numelements(r.rownum)
    if isodd(r.rownum) && r.rownum ≥ 3
        if r.rownum == 3
            newdata = one(eltype(r.data))*6
        else
            newdata = r.data[datalength]
        end
        if length(r.data) > datalength
            r.data[datalength+1] = newdata
        else
            push!(r.data, newdata)
        end
        datalength += 1
    end
    if datalength ≥ 1
        for i ∈ datalength:-1:2
            r.data[i] += r.data[i-1]
        end
        r.data[1] += r.rownum
    end
    r.rownum += 1
    return r
end

function next(r::Row)
    newrow = Row(r)
    return next!(newrow)
end

function next!(c::Column)
    c.colnum += 1
    for i ∈ 2:length(c.data)
        c.data[i] += c.data[i-1]
    end
    return c
end

function next(c::Column)
    newcol = Column(c)
    return next!(newcol)
end

function _downright!(e::Entry)
    if isatright(e)
        e.n += 1
        e.k += 1
        return e
    end
    a = right(e)
    e += a
    return e
end

function next!(c::LazyColumn)
    for (r, val) ∈ c.data
        e = Entry(r + c.colnum - 1, c.colnum, val)
        _downright!(e)
        c.data[r] = value(e)
    end
    c.colnum += 1
    return c
end

function next(c::LazyColumn)
    newcol = LazyColumn(c)
    return next!(newcol)
end