using SparseArrays
using LinearAlgebra
using StatsBase
using JuMP
using Gurobi


gurobi_env = Gurobi.Env()

## The main regularized LP solver used in the paper. Returns an array of the node-color variables for the clustering of the nodes.
function RegularFairEdgeCatClusGeneral(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,β::Float64,optimalflag::Bool= false,outputflag::Int64=0)

    k = maximum(EdgeColors)
    M = length(EdgeList)
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end
    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))

    @variable(m, y[1:M])

    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end
    @objective(m, Min, sum(y[i] for i=1:M)+β*sum(sum(d[i,j]*(1-x[i,j]) for j in 1:k) for i in 1:n))
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    LPval= JuMP.objective_value(m)

    return LPval, X, runtime
end




## A specialized solver used in one of the experiments and to generate dmax values for the datasets
function RegularFairEdgeCatClusGeneralDmax(edges::Vector{Vector{Int64}},colors::Array{Int64,1},n::Int64,β::Float64,optimalflag::Bool= false,outputflag::Int64=0)
    EdgeList=deepcopy(edges)
    EdgeColors=deepcopy(colors)
    k = maximum(EdgeColors)
    M = length(EdgeList)
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end
    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))

    @variable(m, y[1:M])

    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for j = 1:k; @constraint(m, sum(1-x[i,j] for i = 1:n) >= 1); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end

    @objective(m, Min, sum(y[i] for i=1:M)+β*sum(sum(d[i,j]*(1-x[i,j]) for j in 1:k) for i in 1:n))
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    Y = JuMP.value.(y)
    xround=SimpleRound(EdgeList,EdgeColors,X,1.0)
    xround=convert(Array{Int64,1},xround)
    xinteger=ones(Int64, n,k)
    for i in 1:n; xinteger[i,xround[i]]=0;end
    nodecost=sum(sum(d[i,j]*(1-xinteger[i,j]) for j in 1:k) for i in 1:n)
    edgecost=EdgeCatClusObj(EdgeList,EdgeColors,xround)
    roundlp=β*nodecost+edgecost
    ed=sum(Y[i] for i=1:M)
    ip,xx,runtime=RegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,true)
    return ed, roundlp, ip, X, maximum(sum(d,dims=2)),xx
end

function RegularFairEdgeCatClusGeneralDmaxD(edges::Vector{Vector{Int64}},colors::Array{Int64,1},n::Int64,β::Float64,optimalflag::Bool= false,outputflag::Int64=0)
    EdgeList=deepcopy(edges)
    EdgeColors=deepcopy(colors)
    k = maximum(EdgeColors)
    M = length(EdgeList)
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end
    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))

    @variable(m, y[1:M])

    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for j = 1:k; @constraint(m, sum(1-x[i,j] for i = 1:n) >= 1); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end

    @objective(m, Min, sum(y[i] for i=1:M)+β*sum(sum(d[i,j]*(1-x[i,j]) for j in 1:k) for i in 1:n))
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    Y = JuMP.value.(y)
    xround=SimpleRound(EdgeList,EdgeColors,X,1.0)
    xround=convert(Array{Int64,1},xround)
    xinteger=ones(Int64, n,k)
    for i in 1:n; xinteger[i,xround[i]]=0;end
    nodecost=sum(sum(d[i,j]*(1-xinteger[i,j]) for j in 1:k) for i in 1:n)
    edgecost=EdgeCatClusObj(EdgeList,EdgeColors,xround)
    roundlp=β*nodecost+edgecost
    ed=sum(Y[i] for i=1:M)
    ip,xx,runtime=RegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,true)
    return ed, roundlp, ip, X, maximum(sum(d,dims=2)),xx,d
end
## Use this solver if you want at least a fraction spread[c] of all nodes to be clustered into color c.
function ConstrainedRegularFairEdgeCatClusGeneral(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,β::Float64,spread::Array{Float64,1},optimalflag::Bool= false,outputflag::Int64=0)

    k = maximum(EdgeColors)
    M = length(EdgeList)
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end

    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))

    @variable(m, y[1:M])


    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    @objective(m, Min, sum(y[i] for i=1:M)+β*sum(sum(d[i,j]*(1-x[i,j]) for j in 1:k) for i in 1:n))

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for j = 1:k; @constraint(m, sum(1-x[i,j] for i = 1:n) >= n*spread[k]); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    LPval= JuMP.objective_value(m)

    return LPval, X, runtime
end

## Use this solver if you want at least one node in every cluster generated
function AtLeastRegularFairEdgeCatClusGeneral(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,β::Float64,optimalflag::Bool= false,outputflag::Int64=0)

    k = maximum(EdgeColors)
    M = length(EdgeList)
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end

    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))


    @variable(m, y[1:M])


    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    @objective(m, Min, sum(y[i] for i=1:M)+β*sum(sum(d[i,j]*(1-x[i,j]) for j in 1:k) for i in 1:n))

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for j = 1:k; @constraint(m, sum(1-x[i,j] for i = 1:n) >= 1); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    LPval= JuMP.objective_value(m)

    return LPval, X, runtime
end

## Returns a vector contaning the category numbers assigned to every node given an input of the array X containing a solution to the LP
function SimpleRound(EdgeList::Union{Array{Int64,2},Vector{Vector{Int64}}},EdgeColors::Array{Int64,1},X::Array{Float64,2},LPval::Float64)

    C = rowmin(X)

    c = C[:,2]

    return c
end

## Some self-explanatory functions for finding the minimum and maximum values in the rows of a matrix input
function rowmin(X::Array{Float64,2})
    n = size(X,1); Y = zeros(n,2)
    for i = 1:n
        g = findmin(X[i,:])
        Y[i,1] = g[1]; Y[i,2] = g[2]
    end
    return Y
end

function rowmax(X::Array{Float64,2})
    n = size(X,1)
    Y = zeros(n,2)
    for i = 1:n
        g = findmax(X[i,:])
        Y[i,1] = g[1]
        Y[i,2] = g[2]
    end
    return Y
end

## The original categorical edge clustering solver taken from the repository source in that paper. All solvers presented here are a variation on this theme.
function EdgeCatClusGeneral(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,optimalflag::Bool= false,outputflag::Int64=0)

    k = maximum(EdgeColors)
    M = length(EdgeList)

    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))

    @variable(m, y[1:M])

    @objective(m, Min, sum(y[i] for i=1:M))

    if optimalflag
        @variable(m, x[1:n,1:k],Bin)
    else
        @variable(m, x[1:n,1:k])
        @constraint(m,x .<= ones(n,k))
        @constraint(m,x .>= zeros(n,k))
        @constraint(m,y .<= ones(M))
        @constraint(m,y .>= zeros(M))
    end

    for i = 1:n; @constraint(m, sum(x[i,j] for j = 1:k) == k-1); end

    for e = 1:M
        color = EdgeColors[e]
        edge = EdgeList[e]
        for v = edge
            @constraint(m, y[e] >= x[v,color])

        end
    end
    start = time()
    JuMP.optimize!(m)
    runtime = time()-start

    X = JuMP.value.(x)
    LPval= JuMP.objective_value(m)

    return LPval, X, runtime
end

## Calculate the number of violated edges given a clustering c
function EdgeCatClusObj(EdgeList::Union{Array{Int64,2},Vector{Vector{Int64}}},EdgeColors::Array{Int64,1},c::Vector)
    n = length(c); Mistakes = 0
    for i = 1:size(EdgeList,1)
        if size(EdgeList,2) == 2
            edge = EdgeList[i,:]
        else
            edge = EdgeList[i]
        end
        for v in edge
            if c[v] != EdgeColors[i]
                Mistakes += 1
                break
            end
        end
    end
    return Mistakes
end

# majority vote simple algorithms
function MajorityVote(EdgeList::Array{Int64,2},EdgeColors::Array{Int64,1},n::Int64,k::Int64)
    return NaiveLabel(EdgeList,EdgeColors,n,k)
end

function MajorityVote(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,k::Int64)
    return NaiveLabel(EdgeList,EdgeColors,n,k)
end

# This assumes every edge has only one color
function NaiveLabel(EdgeList::Array{Int64,2},EdgeColors::Array{Int64,1},n::Int64,k::Int64)
    naive_c = zeros(Int64,n)
    A = sparse(EdgeList[:,1],EdgeList[:,2],EdgeColors,n,n)
    @assert(istriu(A))
    A = A+A'
    for i = 1:n
        cneighbs = nonzeros(A[i,:])
        if length(cneighbs) > 0
            color = round(Int64,StatsBase.mode(cneighbs))
            if color > 10
                @show color, cneighbs
            end
            naive_c[i] = color
        else
            naive_c[i] = rand(1:k)
        end
    end

    return naive_c
end

function NaiveLabel(EdgeList::Vector{Vector{Int64}},EdgeColors::Vector{Int64},n::Int64,k::Int64,default::Int64=1)
    ColorDegree = zeros(k,n)
    M = length(EdgeList)
    for t = 1:length(EdgeList)
        edge = EdgeList[t]
        color = EdgeColors[t]
        for node in edge
            ColorDegree[color,node] += 1
        end
    end

    naive_c = zeros(Int64,n)
    for i = 1:n
        colorvec = ColorDegree[:,i]
        if maximum(colorvec) > 0
            naive_c[i] = round(Int64,argmax(colorvec)[1])
        else
            naive_c[i] = rand(1:default)
        end
    end
    return naive_c
end
