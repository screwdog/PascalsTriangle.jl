using PascalsTriangle
const PT = PascalsTriangle
using DataStructures

function checkrows(N)
    collisions = []
    c = Column(BigFloat, 2, N-1)
    table = toarray(c)
    queue = BinaryMinHeap((=>).(table, 1:length(table)))
    while !isempty(queue)
        e, i = pop!(queue)
        if !isempty(queue) && value(e) ≈ value(first(first(queue)))
            top = first(first(queue))
            if rownumber(e) > rownumber(top)
                p = e => top
            else
                p = top => e
            end
            push!(collisions, p)
        end
        n = rownumber(e)
        k = rowposition(e)
        if 2k < n && n < N
            if 2k + 1 == n
                e += Entry(e.n, e.k + 1, e.val)
            else
                e += table[i-1]
            end
            push!(queue, e => i)
            table[i] = e
        end
    end
    return collisions
end

bigbinomial(e::Entry) = binomial(BigInt(e.n), BigInt(e.k))
iscollision(p) = bigbinomial(p.first) == bigbinomial(p.second)
function checkcollisions!(cols)
    return filter!(iscollision, cols)
end