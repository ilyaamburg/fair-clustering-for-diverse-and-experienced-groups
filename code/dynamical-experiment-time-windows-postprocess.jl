using DelimitedFiles
using Dates
using Random
using Statistics
using Combinatorics

using IterTools
include("fair-categorical-edge-clustering-optimal.jl")

function get_val(dict::Dict{Int64,Int64}, key::Int64)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end

#Constrained to have at lesst one node in every cluster
function constrained_dynamical(edges::Union{Array{Int64,2},Vector{Vector{Int64}}},colors::Array{Int64,1},β::Float64,iter::Int64,spread::Array{Float64,1},windows::Int64,t::Bool)
    EdgeList=deepcopy(edges)
    EdgeColors=deepcopy(colors)
    author_map = Dict{Int64, Int64}()
    cats_map = Dict{Int64, Int64}()
    for i in 1:length(EdgeList)
        for j in 1:length(EdgeList[i])
            EdgeList[i][j]=get_val(author_map,EdgeList[i][j])
        end
    end
    for i in 1:length(EdgeColors); EdgeColors[i]=get_val(cats_map,EdgeColors[i]); end
    n=maximum([maximum(EdgeList[i]) for i in 1:length(EdgeList)])
    k=maximum(EdgeColors)
    n_exchange=Int64[]
    n_clusters=Int64[]
    size_ratio=Float64[]
    largest_size=Int64[]
    maximum_n_of_cl=Int64[]
    minimum_n_of_cl=Int64[]
    sd_cl=Float64[]
    size_disappear=Int64[]
    node_ex=Int64[]
    l=Int64[]
    Y=Any[]
    for i in 1:windows
        LPval, X, runtime=AtLeastRegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,t)
        Y=SimpleRound(EdgeList,EdgeColors,X,LPval)
        Y=convert(Vector{Int64},Y)
        append!(l,length(unique(Y)))
        for c in sort(unique(Y))
            h=findall(Y.==c)
            if length(h)>0
                push!(EdgeList,h)
                push!(EdgeColors,c)
            end

        end
    end
    ls = sum(l[end-windows+1:end])
    EdgeList=EdgeList[end-ls+1:end]
    EdgeColors=EdgeColors[end-ls+1:end]
    for i in 1:iter
        if i % 10 ==0; println(i); end
        Yold=deepcopy(Y)
        LPval, X, runtime=AtLeastRegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,t)
        Y=SimpleRound(EdgeList,EdgeColors,X,LPval)
        Y=convert(Vector{Int64},Y)
        append!(l,length(unique(Y)))
        for c in sort(unique(Y))
            h=findall(Y.==c)
            if length(h)>0
                push!(EdgeList,h)
                push!(EdgeColors,c)
            end
        end
        ls = sum(l[end-windows+1:end])
        EdgeList=EdgeList[end-ls+1:end]
        EdgeColors=EdgeColors[end-ls+1:end]
        push!(n_exchange,sum(Y.!=Yold))
        push!(n_clusters,length(intersect(Y,[j for j in 1:k])) )
        d=sort(sort(countmap(Y)).vals,rev=true)
        push!(size_ratio,d[end]/d[1])
        push!(largest_size,d[1])
        append!(node_ex,findall(Y.!=Yold))
        append!(size_disappear,intersect(Y,[q for q in 1:k]))
    end
    percent_never_ex_nodes=1-length(unique(node_ex))/n
    percent_never_ap_cluster=1-length(unique(size_disappear))/k
    return n_clusters, n_exchange, size_ratio, largest_size, percent_never_ex_nodes, percent_never_ap_cluster, n, k
end

function dorun(iter::Int64,steps::Int64,mesh::Float64,constrain::Float64,windows::Int64,Data::AbstractString,tr::Bool)
    global Numbers=Int64[]
    global AvgNumbers=Float64[]
    global Exchanges=Int64[]
    global AvgExchanges=Float64[]
    global Ratio=Float64[]
    global AvgRatio=Float64[]
    global Size=Int64[]
    global AvgSize=Float64[]
    global Never_ex=Float64[]
    global Never_ap=Float64[]
    global nlist=Int64[]
    global klist=Int64[]
    global minimum_cl=Int64[]
    global maximum_cl=Int64[]
    global sd_cl=Float64[]
    for β in [mesh*t for t in 0:iter]
        println(β)
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
        d=zeros(Int64,n,k)
        for h in 1:M; d[edges[h],colors[h]].+=1; end
        spread=vec(sum(d,dims=1)/sum(d))
        numbers, exchanges, ratio, largest, never_ex, never_ap, n, k =constrained_dynamical(edges,colors,β,steps,constrain*spread,windows,tr)
        push!(Numbers,numbers[end])
        push!(AvgNumbers,mean(numbers))
        push!(Exchanges,exchanges[end])
        push!(AvgExchanges,mean(exchanges))
        push!(Ratio,ratio[end])
        push!(AvgRatio,mean(ratio))
        push!(Size,largest[end])
        push!(AvgSize,mean(largest))
        push!(Never_ex,never_ex)
        push!(Never_ap,never_ap)
        push!(nlist,n)
        push!(klist,k)
        push!(minimum_cl,minimum(numbers))
        push!(maximum_cl,maximum(numbers))
        push!(sd_cl,std(numbers))
    end
    lines=String[]
    for (a,b,c,d,e,f,g,h,i,j,k,l,m,n,o) in zip(Numbers,AvgNumbers,Exchanges,AvgExchanges,Ratio,AvgRatio,Size,AvgSize,Never_ex,Never_ap,nlist,klist,minimum_cl,maximum_cl,sd_cl)
        push!(lines,"$a $b $c $d $e $f $g $h $i $j $k $l $m $n $o\n")

    end
    open("text/resultspost-windows-constrained-$constrain-$Data.txt", "w") do f
        for line in lines

            write(f, line)
        end
    end
end

function post(edges::Union{Array{Int64,2},Vector{Vector{Int64}}},colors::Array{Int64,1}, Y::Array{Int64,1},k::Int64)
    nocluster=setdiff([i for i in 1:k],Y)
    nk=length(nocluster)
    n=length(Y)
    perms=permutations([i for i in 1:n],nk)
    Ynew=deepcopy(Y)
    cost=Int64[]
    for perm in perms
        Ynew[perm]=nocluster
        push!(cost,EdgeCatClusObj(edges,colors,Ynew))

        Ynew=deepcopy(Y)
    end
    perm=findmin(cost)[2]
    perm=nth(perms,perm)
    Ynew=deepcopy(Y)
    Ynew[perm]=nocluster
    return Ynew
end

datasets=["algebra-Posts"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun(50,50,0.0025,constrain,10,dataset,true)
    end
end
datasets=["geometry-Posts"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun(50,50,0.0025,constrain,10,dataset,true)
    end
end
datasets=["yelpMadison"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun(50,50,0.0025,constrain,10,dataset,true)
    end
end
datasets=["yelpLas VegasBarsFull"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun(50,50,0.0025,constrain,10,dataset,true)
    end
end
datasets=["amazon_music"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun(50,50,0.0025,constrain,10,dataset,true)
    end
end
