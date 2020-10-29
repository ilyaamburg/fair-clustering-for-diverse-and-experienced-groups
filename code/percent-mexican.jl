#Code to do Mexican restaurant case study
using Dates
using DelimitedFiles
include("fair-categorical-edge-clustering-optimal.jl")
function get_val(dict::Dict{Int64,Int64}, key::Int64)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end
function getthem(Data::String,cn::Int64,betas,z)

    data=readdlm("../datasets/$Data.txt",Float64)
    authors=data[:,1]
    authors=convert(Vector{Int64},authors)
    tags=data[:,2]
    tags=convert(Vector{Int64},tags)
    global author_map = Dict{Int64, Int64}()
    global cats_map = Dict{Int64, Int64}()
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
    #return years,months
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
    #return edges
    edges=edges[2:end]
    println(length(edges))
    n=maximum([maximum(edges[i]) for i in 1:length(edges)])
    k = maximum(colors)
    M = length(edges)
    author_map = Dict{Int64, Int64}()
    global cats_map2 = Dict{Int64, Int64}()
    for i in 1:length(edges)
        for j in 1:length(edges[i])
            edges[i][j]=get_val(author_map,edges[i][j])
        end
    end
    for i in 1:length(colors); colors[i]=get_val(cats_map2,colors[i]); end
    n=maximum([maximum(edges[i]) for i in 1:length(edges)])
    k=maximum(colors)
    list=zeros(Float64,length(betas))
    for (j,β) in enumerate(betas)
        println(β)
        mv = MajorityVote(edges,colors,n,k)
        global ed,roundlp,ip,X,dmax,xx,d=RegularFairEdgeCatClusGeneralDmaxD(edges,colors,n,β)
        global x=SimpleRound(edges,colors,X,1.0)
        cluster=findall(x.==cn)
        list[j]=sum(d[cluster,cn])/sum(d[cluster,:])
    end
    open("../text/percent-mexican.txt", "w") do q
        for i in 1:length(betas)
            write(q, string(list[i])*"\n")
        end
    end
end


# datasets=["algebra-Posts","geometry-Posts","yelpLas VegasBarsFull","yelpMadison","amazon_music"]


datasets=["yelpMadison"]


betas=[0,0.01,0.02,0.03,0.04]
for dataset in datasets; getthem(dataset,1,betas,1); end
