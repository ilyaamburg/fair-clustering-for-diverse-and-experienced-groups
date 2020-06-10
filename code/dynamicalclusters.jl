using Dates
using DelimitedFiles

#Code for an experiment not included in the paper
include("fair-categorical-edge-clustering-optimal.jl")
function get_val(dict::Dict{Int64,Int64}, key::Int64)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end
function getthem(Data::String)
    betas=[0.1*i for i in 0:9]
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
        k=maximum(colors)
        list=zeros(Int64,n,10)
        for β in betas
            println(β)
        LPval,X,time=RegularFairEdgeCatClusGeneral(edges,colors,n,β)
        x=SimpleRound(edges,colors,X,LPval)
        x=convert(Array{Int64,1},x)
        list[:,Int(round(10*β))+1]=x
    end
    open("text/results-betatable.txt", "w") do q
        for (a,b,c,d,e,f,g,h,i,j) in zip(list[:,1],list[:,2],list[:,3],list[:,4],list[:,5],list[:,6],list[:,7],list[:,8],list[:,9],list[:,10])
            write(q, "$a $b $c $d $e $f $g $h $i $j\n")
        end
    end
end

datasets=["geometry-Posts"]
function smalldatasets(datasets::Array{String,1})
    smalltags=1.0*[18,34,36,40]
    for dataset in datasets
        data=readdlm("text/$dataset.txt",Float64)
        newdata=[Float64[]]
        M=size(data)[1]
        for i in 1:M
            if length(intersect(data[i,2],smalltags))>0
                push!(newdata,data[i,:])
            end
        end
        newdata=newdata[2:end]
        M=size(newdata)[1]
        data=zeros(Float64,M,3)
        for i in 1:M
            data[i,:]=newdata[i]
        end
        open("text/geometry-smallPosts.txt", "w") do f
            for (i, j, y) in zip(data[:,1],data[:,2],data[:,3])
                write(f, "$i $j $y\n")
            end
        end
    end
end


smalldatasets(datasets)
getthem("geometry-smallPosts")
