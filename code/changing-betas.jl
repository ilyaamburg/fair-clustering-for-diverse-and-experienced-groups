#Code used to generate static beta plots for figure 1
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
function getthem(Data::String)
    betas=[0.02*i for i in 0:40]

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
    objec=Float64[]
    costs=Float64[]
    edgecost=Float64[]
    sati=Float64[]
    dmaxes=Int64[]
    xxoptimals=Float64[]
    ipcosts=Float64[]
    for β in betas
        println(β)
        ed,roundlp,ip,X,dmax,xx=RegularFairEdgeCatClusGeneralDmax(edges,colors,n,β)
        x=SimpleRound(edges,colors,X,1.0)
        mistakes=EdgeCatClusObj(edges,colors,x)
        xoptimal=SimpleRound(edges,colors,xx,1.0)
        mistakesoptimal=EdgeCatClusObj(edges,colors,xoptimal)
        push!(objec,roundlp)
        push!(edgecost,ed)
        push!(costs,roundlp/ip)
        push!(sati,(M-mistakes)/M)
        push!(dmaxes,dmax)
        push!(ipcosts,ip)
        push!(xxoptimals,(M-mistakesoptimal)/M)
    end
    edgecost=edgecost./edgecost[1]
    objec=objec./ipcosts[1]

    sati=sati./xxoptimals[1]
    open("text/results-beta$Data.txt", "w") do q
        for (a,b,c,d,e) in zip(objec,costs,edgecost,sati,dmaxes)
            write(q, "$a $b $c $d $e\n")
        end
    end
end


datasets=["algebra-Posts","geometry-Posts","yelpLas VegasBarsFull","yelpMadison","amazon_music"]
for dataset in datasets; getthem(dataset); end
