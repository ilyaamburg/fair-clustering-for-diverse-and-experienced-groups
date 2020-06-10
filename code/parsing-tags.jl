dataset="Posts"
using EzXML
using Dates
a=readxml("Posts.xml")
posts=root(a)
el=elements(posts)
const answer_start = "PostTypeId=\"2\""
const auth_start = "OwnerUserId="
const date_start = "LastEditDate="
const tags_start = "Tags=\"&lt;"
id=[el[i]["Id"] for i in 1:length(el)]
id_dict=Dict(id.=>[i for i in 1:length(el)])
author_map = Dict{AbstractString, Int64}()
tags_map = Dict{AbstractString, Int64}()
function get_val(dict::Dict{AbstractString,Int64}, key::AbstractString)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end
authors=Int64[]
tags=Int64[]
times=Float64[]
for i in 1:length(el)
    elem=el[i]
    if elem["PostTypeId"]=="1"; continue; end

    #if findfirst(date_start, ln)==nothing; continue; end
        if i % 10000==0; println(i); end

    try elem["OwnerUserId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    try elem["LastEditDate"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try elem["ParentId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    author=elem["OwnerUserId"]
    #println(author)

    time=elem["LastEditDate"]
    time=datetime2unix(DateTime("$time"))
    row_id=elem["ParentId"]
    row_number=get(id_dict,row_id,0)
    #if findfirst(tags_start, ln)==nothing; continue; end
    try el[row_number]["Tags"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    author=get_val(author_map,author)
    tg=el[row_number]["Tags"]
    tg=split(tg[2:end-1],"><")
    for h in 1:length(tg)
        push!(authors,author)

        push!(times,time)
        push!(tags, get_val(tags_map,tg[h]))

    end
end
open("text/$dataset.txt", "w") do f
    for (i, j, y) in zip(authors,tags,times)
        write(f, "$i $j $y\n")
    end
end
t=Dict(v=>k for (k,v) in tags_map)
t=sort(t)
open("text/tags-math.txt", "w") do f
    for (k,v) in t
        write(f, "$k $v\n")
    end
end
## geometry
id=[el[i]["Id"] for i in 1:length(el)]
id_dict=Dict(id.=>[i for i in 1:length(el)])
author_map = Dict{AbstractString, Int64}()
tags_map = Dict{AbstractString, Int64}()
function get_val(dict::Dict{AbstractString,Int64}, key::AbstractString)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end
authors=Int64[]
tags=Int64[]
times=Float64[]
for i in 1:length(el)
    elem=el[i]
    if elem["PostTypeId"]=="1"; continue; end

    #if findfirst(date_start, ln)==nothing; continue; end
        if i % 10000==0; println(i); end

    try elem["OwnerUserId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    try elem["LastEditDate"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try elem["ParentId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    #println(author)

    time=elem["LastEditDate"]
    time=datetime2unix(DateTime("$time"))
    row_id=elem["ParentId"]
    row_number=get(id_dict,row_id,0)
    #if findfirst(tags_start, ln)==nothing; continue; end
    try el[row_number]["Tags"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    tg=el[row_number]["Tags"]
    tg=split(tg[2:end-1],"><")
    for h in 1:length(tg)
        if !occursin("-geometry",tg[h]); continue; end
        global get_val=get_val
        author=elem["OwnerUserId"]
        author=get_val(author_map,author)
        push!(authors,author)
        push!(times,time)
        push!(tags, get_val(tags_map,tg[h]))

    end
end
open("text/geometry-$dataset.txt", "w") do f
    for (i, j, y) in zip(authors,tags,times)
        write(f, "$i $j $y\n")
    end
end
t=Dict(v=>k for (k,v) in tags_map)
t=sort(t)
open("text/geometry-tags.txt", "w") do f
    for (k,v) in t
        write(f, "$k $v\n")
    end
end

## algebra
id=[el[i]["Id"] for i in 1:length(el)]
id_dict=Dict(id.=>[i for i in 1:length(el)])
author_map = Dict{AbstractString, Int64}()
tags_map = Dict{AbstractString, Int64}()
function get_val(dict::Dict{AbstractString,Int64}, key::AbstractString)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end
authors=Int64[]
tags=Int64[]
times=Float64[]
for i in 1:length(el)
    elem=el[i]
    if elem["PostTypeId"]=="1"; continue; end

    #if findfirst(date_start, ln)==nothing; continue; end
        if i % 10000==0; println(i); end

    try elem["OwnerUserId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    try elem["LastEditDate"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try elem["ParentId"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    #println(author)

    time=elem["LastEditDate"]
    time=datetime2unix(DateTime("$time"))
    row_id=elem["ParentId"]
    row_number=get(id_dict,row_id,0)
    #if findfirst(tags_start, ln)==nothing; continue; end
    try el[row_number]["Tags"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    tg=el[row_number]["Tags"]
    tg=split(tg[2:end-1],"><")
    for h in 1:length(tg)
        if !occursin("-algebra",tg[h]); continue; end
        global get_val=get_val
        author=elem["OwnerUserId"]
        author=get_val(author_map,author)
        push!(authors,author)
        push!(times,time)
        push!(tags, get_val(tags_map,tg[h]))

    end
end
open("text/algebra-$dataset.txt", "w") do f
    for (i, j, y) in zip(authors,tags,times)
        write(f, "$i $j $y\n")
    end
end
t=Dict(v=>k for (k,v) in tags_map)
t=sort(t)
open("text/algebra-tags.txt", "w") do f
    for (k,v) in t
        write(f, "$k $v\n")
    end
end
##

##

##

##

##

##

##
