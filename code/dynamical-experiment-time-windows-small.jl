using DelimitedFiles
using Dates
using Random
using Statistics

include("fair-categorical-edge-clustering-optimal.jl")
function get_val(dict::Dict{Int64,Int64}, key::Int64)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end


#Code to get the data for figures 2 in paper

function constrained_dynamical(edges::Union{Array{Int64,2},Vector{Vector{Int64}}},colors::Array{Int64,1},β::Float64,iter::Int64,windows::Int64,spread::Float64)
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
    array=zeros(Int64,n,iter)
        l=Int64[]
    for i in 1:windows
        LPval, X, runtime=ConstrainedRegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,spread*[j for j in 1:k])
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
    for i in 0:iter-1
        if i % 10 ==0; println(i); end
        LPval, X, runtime=ConstrainedRegularFairEdgeCatClusGeneral(EdgeList,EdgeColors,n,β,spread*[j for j in 1:k])
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
        array[:,i+1]=Y
    end
    return array
end

function dorun(betas::Array{Float64,1},iter::Int64,constrain::Float64,windows::Int64,Data::AbstractString)
    for β in betas
        println(β)
        data=readdlm("text/$Data.txt",Float64)
        authors=data[:,1]
        authors=convert(Vector{Int64},authors)
        tags=data[:,2]
        tags=convert(Vector{Int64},tags)
        author_map = Dict{Int64, Int64}()
        cats_map = Dict{Int64, Int64}()
        for i in 1:length(authors); authors[i]=get_val(author_map,authors[i]); end
        for i in 1:length(tags); tags[i]=get_val(cats_map,tags[i]); end
        k=length(unique(tags))
        colors=Int64[]
        edges=[Int64[]]
        t=data[:,3]
        println(length(t))
        t=[Dates.unix2datetime(t[i]) for i in 1:length(t)]
        y=[Dates.year(t[i]) for i in 1:length(t)]
        m=[Dates.month(t[i]) for i in 1:length(t)]
        years=sort(unique(y))
        months=sort(unique(m))
        for yr in years
            #for mn in months
            for i in 1:k
                good_years=findall(y.==yr)
                indices=good_years
                auth=authors[indices]
                tg=tags[indices]
                k_index=findall(tg.==i)
                h=unique(sort(auth[k_index]))
                if length(h)>1
                    push!(edges,h)
                    push!(colors,i)
                end
            end
            #end
        end
        edges=edges[2:end]
        println(length(edges))
        n=maximum([maximum(edges[i]) for i in 1:length(edges)])
        k = maximum(colors)
        M = length(edges)
        author_map = Dict{Int64, Int64}()
        cats_map = Dict{Int64, Int64}()
        for i in 1:length(edges)
            for j in 1:length(edges[i])
                edges[i][j]=get_val(author_map,edges[i][j])
            end
        end
        for i in 1:length(colors); colors[i]=get_val(cats_map,colors[i]); end
        n=maximum([maximum(edges[i]) for i in 1:length(edges)])
        list =constrained_dynamical(edges,colors,β,iter,windows,constrain)
        open("text/results-betatable-dynamical-$β.txt", "w") do q
            for (a,b,c,d,e,f,g,h,i,j) in zip(list[:,1],list[:,2],list[:,3],list[:,4],list[:,5],list[:,6],list[:,7],list[:,8],list[:,9],list[:,10])
                write(q, "{$a, $b, $c, $d, $e, $f, $g, $h, $i, $j},\n")
            end
        end
    end
end


datasets=["geometry-smallPosts"]
Const=[0.0]
for dataset in datasets
    for constrain in Const
        dorun([0.0,0.07,0.1,0.2,0.4,0.055,0.7],10,constrain,10,dataset)
    end
end
