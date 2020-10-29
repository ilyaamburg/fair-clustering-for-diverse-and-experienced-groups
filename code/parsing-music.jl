using JSON


catname="meta_CDs_and_Vinyl"
filename = "../text/"*catname*".json"
i=0
for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    try D["category"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    global cats=D["category"]
    println(setdiff(cats,["CDs & Vinyl"]))
    if n>200; break; end


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


for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    try D["category"]
    catch y
        if isa(y,KeyError)
            continue
        end

    end

    global cats=D["category"]
    if cats!== nothing; if length(intersect(cats,["Regional Blues","CDs & Vinyl"]))==2&&length(setdiff(cats,["CDs & Vinyl","Regional Blues","Blues"]))==1;cats_map[D["asin"]]=setdiff(cats,["CDs & Vinyl","Regional Blues","Blues"])[1]; end
    end
    if n % 10000==0; println(n); end


end
list=[["","",1]]
reviewer_map=Dict{AbstractString, Any}()
catname="CDs_and_Vinyl_5"
filename = "json/"*catname*".json"
for (n,l) in enumerate(eachline(filename))

    D = JSON.parse(l)

    reviewer= D["reviewerID"]
    asin=D["asin"]
    try cats_map[asin]
    catch y
        if isa(y,KeyError)
            continue
        end

    end
    push!(list,[reviewer,cats_map[asin],D["unixReviewTime"]])

    if n % 10000==0; println(n); end


end
list=list[2:end]
reviewers_list=[list[i][1] for i in 1:length(list)]
reviewers=sort(unique(reviewers_list))
reviewer_dict=Dict(reviewers.=>[i for i in 1:length(reviewers)])
reviewers_list=[get(reviewer_dict,reviewers_list[i],0) for i in 1:length(reviewers_list)]
for i in 1:length(reviewers_list); list[i][1]=reviewers_list[i]; end
category_list=[list[i][2] for i in 1:length(list)]
categories=sort(unique(category_list))
println(categories)
category_dict=Dict(categories.=>[i for i in 1:length(categories)])
category_list=[get(category_dict,category_list[i],0) for i in 1:length(category_list)]
for i in 1:length(category_list); list[i][2]=category_list[i]; end
# open("text/amazon_music.txt", "w") do h
#     for (a,b,c) in list
#         write(h,"$a\t $b\t $c\n")
#     end
# end
# # obtain 2010
# l=readdlm("text/amazon_music.txt",Int64)
# open("text/amazon2010_music.txt", "w") do h
#  for i in 1:size(l,1)
#      a=l[i,1]
#      b=l[i,2]
#      c=l[i,3]
#      if year(unix2datetime(l[i,3]))==2010
#          write(h,"$a\t $b\t $c\n")
#      end
#  end
end
