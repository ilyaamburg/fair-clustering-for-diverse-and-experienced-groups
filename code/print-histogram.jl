#Code for plotting results for the two case studies.
using DelimitedFiles

using Plots

using Colors

pyplot()

ft = Plots.font("DejaVu Sans", 14)
default(titlefont=ft, guidefont=ft, tickfont=ft, legendfont=ft, markeralpha=0.5, linealpha=1, linewidth=0.7,yscale=:auto,yaxis=:black)
function plothistogram()
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon]
        PyPlot.clf()
        results=readdlm("../text/results-histogram.txt",',')
        average_clusters=results[1,:]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        l=["Mexican","Chinese","Italian","Korean","French","Thai","Japanese","American","Indian"]
        plot([i for i in 1:9],average_clusters,grid=false,framestyle=:box,label=labels[1],title="",xlabel="category",ylabel="fraction",markershape=markers[1],markersize=10,xticks=(1:1:9,l),xrotation=59)
        for i in 2:5
                average_clusters=results[i,:]
                plot!([j for j in 1:9],average_clusters,grid=false,framestyle=:box,label=labels[i],title="",xlabel="category",ylabel="fraction",legend=:topright,markershape=markers[i],markersize=10)
        end
        savefig("../plots/category-distribution.pdf")
end

plothistogram()

function plothistogram()
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm("../text/results-histogram.txt",',')
        average_clusters=results[:,1]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["Mexican","Chinese","Italian","Korean","French","Thai","Japanese","American","Indian"]
        plot([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label=labels[1],title="",xlabel="β",ylabel="fraction",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04),legendfont=8)
        for i in 2:9
                average_clusters=results[:,i]
                plot!([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label=labels[i],title="",xlabel="β",ylabel="fraction",legend=:topright,markershape=markers[i],markersize=10)
        end
        savefig("../plots/2category-distribution.pdf")
        savefig("../plots/2category-distribution.png")
end


plothistogram()

function plothistogram()
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm("../text/percent-mexican.txt",',')
        average_clusters=results[:,1]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["Mexican","Chinese","Italian","Korean","French","Thai","Japanese","American","Indian"]
        plot([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label="",title="",xlabel="β",ylabel="experience homogeneity",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04))
        savefig("../plots/percent-mexican.pdf")
        savefig("../plots/percent-mexican.png")
end


plothistogram()

function plothistogram()
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm("../text/music-details.txt",',')
        average_clusters=results[:,1]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["New York blues","Chicago blues","Delta blues","St, Louis blues","Cajun & Zydeco","Memphis blues","Detroit blues"]
        plot([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label=labels[1],title="",xlabel="β",ylabel="fraction",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04),legendfont=8)
        for i in 2:7
                average_clusters=results[:,i]
                plot!([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label=labels[i],title="",xlabel="β",ylabel="fraction",legend=:topright,markershape=markers[i],markersize=10)
        end
        savefig("../plots/blues-distribution.pdf")
        savefig("../plots/blues-distribution.png")
end


plothistogram()

function plothistogram()
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm("../text/percent-first.txt",',')
        average_clusters=results[:,1]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["Mexican","Chinese","Italian","Korean","French","Thai","Japanese","American","Indian"]
        plot([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label="",title="",xlabel="β",ylabel="experience homogeneity",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04))
        # for i in 2:9
        #         average_clusters=results[:,i]
        #         plot!([0.01*j for j in 0:4],average_clusters,grid=false,framestyle=:box,label=labels[i],title="",xlabel="β",ylabel="fraction",legend=:topright,markershape=markers[i],markersize=10)
        # end
        savefig("../plots/percent-first.pdf")
        savefig("../plots/percent-first.png")
end


plothistogram()

function plothistogram()
        files=["../text/largestentropy-amazon_music-unlabeled-results.txt","../text/largestentropy-yelpMadison-unlabeled-results.txt","../text/largestentropy-yelpLas VegasBarsFull-unlabeled-results.txt","../text/largestentropy-algebra-Posts-unlabeled-results.txt","../text/largestentropy-geometry-Posts-unlabeled-results.txt"]
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm(files[1],',')
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["music","madison","vegas","algebra","geometry"]
        plot([0.01*j for j in 0:4],results,grid=false,framestyle=:box,label=labels[1],title="",xlabel="β",ylabel="normalized entropy",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04))
        for i in 2:5
                results=readdlm(files[i],',')
                plot!([0.01*j for j in 0:4],results,grid=false,framestyle=:box,label=labels[i],title="",xlabel="β",ylabel="normalized entropy",legend=:bottomright,markershape=markers[i],markersize=10)
        end
        savefig("../plots/entropy.pdf")
        savefig("../plots/entropy.png")
end


plothistogram()

function plothistogram()
        files=["../text/percent-amazon_music-unlabeled-results.txt","../text/percent-yelpMadison-unlabeled-results.txt","../text/percent-yelpLas VegasBarsFull-unlabeled-results.txt","../text/percent-algebra-Posts-unlabeled-results.txt","../text/percent-geometry-Posts-unlabeled-results.txt"]
        labels=["β=0.00","β=0.01","β=0.02","β=0.03","β=0.04"]
        markers=[:utriangle,:diamond,:pentagon,:hexagon,:heptagon,:star4,:star5,:star6,:star7]
        PyPlot.clf()
        results=readdlm(files[1],',')
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        labels=["music","madison","vegas","algebra","geometry"]
        plot([0.01*j for j in 0:4],results,grid=false,framestyle=:box,label=labels[1],title="",xlabel="β",ylabel="average fraction",markershape=markers[1],markersize=10,xticks=(0:0.01:0.04))
        for i in 2:5
                results=readdlm(files[i],',')
                plot!([0.01*j for j in 0:4],results,grid=false,framestyle=:box,label=labels[i],title="",xlabel="β",ylabel="average fraction",legend=:topright,markershape=markers[i],markersize=10)
        end
        savefig("../plots/percent.pdf")
        savefig("../plots/percent.png")
end


plothistogram()
