using JSON
using Dates

filename = "yelp/business.json"
i=0
for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    try D["categories"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    global cats=D["categories"]
    println(setdiff(cats,["CDs_and_Vinyl"]))
    if n>20; break; end


end


cats_map=Dict{AbstractString, Any}()
function get_val(dict::Dict{AbstractString,Int64}, key::AbstractString)
    if !haskey(dict, key)
        n = length(dict) + 1
        dict[key] = n
        return n
    end
    return dict[key]
end

city="Madison"
state="WI"
city="Cleveland"
state="OH"
cuisines=["Chinese" ,"Korean" ,"Thai" ,"Indian" ,"Mexican" ,"Japanese" ,"Italian" ,"American (Traditional)" ,"French" ,"Mongolian"]
for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    try D["categories"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try D["business_id"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try D["city"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    try D["state"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    if length(intersect(D["categories"],["Restaurants"]))==1&&length(D["categories"])==2&&D["city"]==city&&length(intersect(D["categories"],cuisines))>0&&D["state"]==state;cats_map[D["business_id"]]=setdiff(D["categories"],["Restaurants"])[1]; end
    if n % 10000==0; println(n); end


end
list=[["","",1]]
reviewer_map=Dict{AbstractString, Any}()
filename = "yelp/review.json"
for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    reviewer= D["user_id"]
    asin=D["business_id"]
    try cats_map[asin]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    push!(list,[reviewer,cats_map[asin],D["date"]])

    if n % 10000==0; println(n); end


end
list=list[2:end]
dates=[list[i][3]*"T00:00:00" for i in 1:length(list)]
dates=[datetime2unix(DateTime(dates[i])) for i in 1:length(list)]
reviewers_list=[list[i][1] for i in 1:length(list)]
reviewers=sort(unique(reviewers_list))
reviewer_dict=Dict(reviewers.=>[i for i in 1:length(reviewers)])
reviewers_list=[get(reviewer_dict,reviewers_list[i],0) for i in 1:length(reviewers_list)]
for i in 1:length(reviewers_list); list[i][1]=reviewers_list[i]; end
category_list=[list[i][2] for i in 1:length(list)]
categories=sort(unique(category_list))
category_dict=Dict(categories.=>[i for i in 1:length(categories)])
category_list=[get(category_dict,category_list[i],0) for i in 1:length(category_list)]
for i in 1:length(category_list); list[i][2]=category_list[i]; end
for i in 1:length(category_list); list[i][3]=dates[i]; end
open("text/yelp"*city*".txt", "w") do h
    for (a,b,c) in list
        write(h,"$a\t $b\t $c\n")
    end
end
