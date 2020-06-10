using SparseArrays
using LinearAlgebra
using StatsBase
using JuMP
using Gurobi
using Random
using Statistics
using DelimitedFiles
using Dates
include("fair-categorical-edge-clustering-optimal.jl")

gurobi_env = Gurobi.Env()


function RegularFairEdgeCatClusGeneral2(EdgeList::Vector{Vector{Int64}},EdgeColors::Array{Int64,1},n::Int64,β::Float64,optimalflag::Bool= false,outputflag::Int64=0)

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
    Y=JuMP.value.(y)
    LPval= JuMP.objective_value(m)
    for i in 1:n; append!(Y,X[i,:]);end
    return Y,rowmin(X)[:,2]
end

## Solver to find the beta hat value
function βfind(edges::Union{Array{Int64,2},Vector{Vector{Int64}}},colors::Array{Int64,1})
    EdgeList=deepcopy(edges)
    EdgeColors=deepcopy(colors)
    M = length(EdgeList)
    author_map = Dict{Int64, Int64}()
    cats_map = Dict{Int64, Int64}()
    for i in 1:M
        for j in 1:length(EdgeList[i])
            EdgeList[i][j]=get_val(author_map,EdgeList[i][j])
        end
    end
    for i in 1:M; EdgeColors[i]=get_val(cats_map,EdgeColors[i]); end
    n=maximum([maximum(EdgeList[i]) for i in 1:M])
    k=maximum(EdgeColors)
    start=time()
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end
    println("dminsum=",sum(rowmin(1.0*d)[:,1]))
    outputflag=false
    optimalflag=false
    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))
    β0=10000.25
    x0=othersolve(EdgeList,EdgeColors,β0)
    dvector=Int64[]
    [append!(dvector,d[i,:]) for i in 1:n]
    c=ones(Float64,M); append!(c,-β0*dvector)
    Δc=zeros(Int64,M);append!(Δc,-dvector)
    totallength=0;
    for i in 1:M;totallength+=length(EdgeList[i]); end
    b=zeros(Int64,totallength);append!(b,(k-1)*ones(Int64,n));append!(b,-(k-1)*ones(Int64,n));append!(b,-1*ones(Int64,M));append!(b,-1*ones(Int64,n*k))
    @variable(m, y[1:totallength+(k+2)*n+M])
    @variable(m, θ)
    Q=spzeros(Int64,M+(k)*n,totallength+(k+2)*n+M)
    j= 0
    for i in 1:M
        h=length(EdgeList[i])
        Q[i,j+1:j+h].=1
        p= 0
        for v in EdgeList[i]
            [Q[M+k*(v-1)+l,j+p+1]=-1 for l in EdgeColors[i]:EdgeColors[i]]
            p+=1
        end
        j=j+h
    end
    for i in 1:n; Q[M+1+(i-1)*k:M+(i-1)*k+k,j+i].=1;end
    for i in 1:n; Q[M+1+(i-1)*k:M+(i-1)*k+k,j+i+n].=-1;end
    for i=1:M; Q[i,j+2*n+i]=-1;end
    for i=1:k*n;Q[M+i,j+2*n+M+i]=-1;end
    @constraint(m,y.>=0)
    @constraint(m,θ>=0)
    dotprod=(Δc' * x0)
    @constraint(m,(1.0*b)' * y == c' * x0 - (θ) * dotprod)
    @constraint(m,Q*y .<= c-θ.*Δc)
    @objective(m,Max,θ)
    JuMP.optimize!(m)
    θstar = JuMP.value.(θ)
    ystar = JuMP.value.(y)
    times=time()-start
    return β0-θstar, times
end

## Alternate solver using full the constraint matrix instead of explicit constraint statements
function othersolve(edges::Union{Array{Int64,2},Vector{Vector{Int64}}},colors::Array{Int64,1},β0::Float64)
    EdgeList=deepcopy(edges)
    EdgeColors=deepcopy(colors)
    M = length(EdgeList)
    author_map = Dict{Int64, Int64}()
    cats_map = Dict{Int64, Int64}()
    for i in 1:M
        for j in 1:length(EdgeList[i])
            EdgeList[i][j]=get_val(author_map,EdgeList[i][j])
        end
    end
    for i in 1:M; EdgeColors[i]=get_val(cats_map,EdgeColors[i]); end
    n=maximum([maximum(EdgeList[i]) for i in 1:M])
    k=maximum(EdgeColors)
    start=time()
    d=zeros(Int64,n,k)
    for h in 1:M; d[EdgeList[h],EdgeColors[h]].+=1; end
    println("dminsum=",sum(rowmin(1.0*d)[:,1]))
    outputflag=false
    optimalflag=false
    m = Model(with_optimizer(Gurobi.Optimizer,OutputFlag=outputflag, gurobi_env))
    dvector=Int64[]
    [append!(dvector,d[i,:]) for i in 1:n]
    c=ones(Float64,M); append!(c,-β0*dvector)
    Δc=zeros(Int64,M);append!(Δc,-dvector)
    totallength=0;
    for i in 1:M;totallength+=length(EdgeList[i]); end
    b=zeros(Int64,totallength);append!(b,(k-1)*ones(Int64,n));append!(b,-(k-1)*ones(Int64,n));append!(b,-1*ones(Int64,M));append!(b,-1*ones(Int64,n*k))
    @variable(m, x[1:(k)*n+M])
    Q=spzeros(Int64,M+(k)*n,totallength+(k+2)*n+M)
    j= 0
    for i in 1:M
        h=length(EdgeList[i])
        Q[i,j+1:j+h].=1
        p= 0
        for v in EdgeList[i]
            [Q[M+k*(v-1)+l,j+p+1]=-1 for l in EdgeColors[i]:EdgeColors[i]]
            p+=1
        end
        j=j+h
    end
    for i in 1:n; Q[M+1+(i-1)*k:M+(i-1)*k+k,j+i].=1;end
    for i in 1:n; Q[M+1+(i-1)*k:M+(i-1)*k+k,j+i+n].=-1;end
    for i=1:M; Q[i,j+2*n+i]=-1;end
    for i=1:k*n;Q[M+i,j+2*n+M+i]=-1;end
    @constraint(m,x.>=0)
    @constraint(m,Q'*x .>= b)
    @objective(m,Min,c'*x+β0*sum(d))
    JuMP.optimize!(m)
    xstar = JuMP.value.(x)
    Y=xstar[1:M]
    return xstar
end

## Facilitates printing the results
function betafinder(Data::AbstractString)
    data=readdlm("text/$Data.txt",Float64)
    authors=data[:,1]
    authors=convert(Vector{Int64},authors)
    tags=data[:,2]
    tags=convert(Vector{Int64},tags)
    k=length(unique(tags))
    colors=Int64[]
    edges=[Int64[]]
    t=data[:,3]
    t=[Dates.unix2datetime(t[i]) for i in 1:length(t)]
    y=[Dates.year(t[i]) for i in 1:length(t)]
    m=[Dates.month(t[i]) for i in 1:length(t)]
    years=sort(unique(y))
    months=sort(unique(m))
    for yr in years
        for mn in months
            for i in 1:k
                good_years=findall(y.==yr)
                indices=findall(m[good_years].==mn)
                auth=authors[indices]
                tg=tags[indices]
                k_index=findall(tg.==i)
                h=unique(sort(auth[k_index]))
                if length(h)>1
                    push!(edges,h)
                    push!(colors,i)
                end
            end
        end
    end
    edges=edges[2:end]
    n=maximum([maximum(edges[i]) for i in 1:length(edges)])
    k = maximum(colors)
    M = length(edges)
    beta,time=βfind(edges,colors)
    return beta,time,n,k,M
end

## Final wrap to run everything
function getbetas(Datasets::Array{String,1})
    betas=Float64[]
    times=Float64[]
    ns=Int64[]
    ks=Int64[]
    Ms=Int64[]
    for dataset in Datasets
        println(dataset);beta,time,n,k,M=betafinder(dataset)
        push!(times,time);push!(betas,beta);push!(ns,n);push!(Ms,M);push!(ks,k)
    end
    lines=String[]
    for (a,b,c,d,e) in zip(ns,Ms,ks,betas,times)
        push!(lines,"$a $b $c $d $e\n")

    end
    open("text/results-β.txt", "w") do f
        for line in lines
            write(f, line)
        end
    end
end


Datasets=["algebra-Posts","geometry-Posts","yelpLas VegasBarsFull","yelpMadison","amazon_music"]
getbetas(Datasets)
