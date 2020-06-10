using DelimitedFiles

using Plots
using Colors
pyplot()
ft = Plots.font("DejaVu Sans", 20)
default(titlefont=ft, guidefont=ft, tickfont=ft, legendfont=ft)
function tagsPlots(datasets::Array{String,1},mesh::Float64,iter::Int64,step::Int64)
        labels=["music","madison","vegas","algebra","geometry"]
        PyPlot.clf()
        dataset=datasets[1]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,4]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        plot([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], framestyle=:box,label=labels[1], title="", xlabel="β", ylabel="# exchanges")
        for (i, dataset) in enumerate(datasets[2:end])
                results=readdlm("text/results$dataset.txt",Float64)
                average_clusters=results[:,4]

                plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], framestyle=:box,label=labels[i+1], title="", xlabel="β", ylabel="# exchanges",legend=:topright)
        end
        savefig("plots/exchanges.pdf")
        PyPlot.clf()
        dataset=datasets[1]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,6]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        plot([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], framestyle=:box,label=labels[1], title="", xlabel="β", ylabel="|s. clust.|/|l. clust.|")
        for (i, dataset) in enumerate(datasets[2:end])
                results=readdlm("text/results$dataset.txt",Float64)
                average_clusters=results[:,6]

                plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], framestyle=:box,label=labels[i+1], title="", xlabel="β", ylabel="|s. clust.|/|l. clust.|")
        end
        plot!([0.1],[0.75],linewidth=0,label="",linecolor=:white)
        savefig("plots/ratio.pdf")
        PyPlot.clf()
        PyPlot.clf()
end

function betaPlots(datasets::Array{String,1},mesh::Float64,iter::Int64,step::Int64)
        betas=readdlm("text/results-β.txt",Float64)
        betas=betas[:,4]
        PyPlot.clf()
        #objec

        labels=["music","madison","vegas","algebra","geometry"]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        dataset=datasets[1]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,1]
        plot([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=1,markerstrokecolor=1)
        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], linecolor=1,framestyle=:box,label="", title="", xlabel="β", ylabel="(r. cost)/(unreg. opt. cost)")
        dataset=datasets[2]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,1]
        plot!([0.42],[average_clusters[22]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=2,markerstrokecolor=2)
        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[2], linecolor=2,framestyle=:box,label="", title="", xlabel="β", ylabel="(r. cost)/(unreg. opt. cost)")
        dataset=datasets[3]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,1]
        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=3,markerstrokecolor=3)
        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[3], linecolor=3,framestyle=:box,label="", title="", xlabel="β", ylabel="(r. cost)/(unreg. opt. cost)")
        dataset=datasets[4]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,1]
        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=4,markerstrokecolor=4)
        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[4], linecolor=4,framestyle=:box,label="", title="", xlabel="β", ylabel="(r. cost)/(unreg. opt. cost)")
        dataset=datasets[5]
        results=readdlm("text/results$dataset.txt",Float64)
        average_clusters=results[:,1]
        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=5,markerstrokecolor=5)
        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[5], linecolor=5,framestyle=:box,label="", title="", xlabel="β", ylabel="(r. cost)/(unreg. opt. cost)")



        savefig("plots/objec.pdf")
        PyPlot.clf()
        #costs
        dataset=datasets[1]
        results=readdlm("text/results$dataset.txt",Float64)
        labels=["music","madison","vegas","algebra","geometry"]
        average_clusters=results[:,2]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        plot([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], framestyle=:box,label=labels[1], title="", xlabel="β", ylabel="approx. ratio")
        for (i, dataset) in enumerate(datasets[2:end])
                results=readdlm("text/results$dataset.txt",Float64)
                average_clusters=results[:,2]

                plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], framestyle=:box,label=labels[i+1], title="", xlabel="β", ylabel="approx. ratio")
        end
        savefig("plots/costs.pdf")
        PyPlot.clf()
        #edgecost
        dataset=datasets[2]
        results=readdlm("text/results$dataset.txt",Float64)
        labels=["music","madison","vegas","algebra","geometry"]
        average_clusters=results[:,3]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        plot([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], linecolor=2,framestyle=:box,label="", title="", xlabel="β", ylabel="(edge LP)/(unreg. edge LP)")
        plot!([0.42],[average_clusters[22]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=2,markerstrokecolor=2)
        for (i, dataset) in enumerate([datasets[1];datasets[3:end]])
                results=readdlm("text/results$dataset.txt",Float64)
                average_clusters=results[:,3]

                if i==1
                        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=1,markerstrokecolor=1)
                        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], linecolor=1,framestyle=:box,label="", title="", xlabel="β", ylabel="(edge LP)/(unreg. edge LP)")
                elseif i==2
                        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=3,markerstrokecolor=3)
                        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], linecolor=3,framestyle=:box,label="", title="", xlabel="β", ylabel="(edge LP)/(unreg. edge LP)")
                elseif i==3
                        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=4,markerstrokecolor=4)
                        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], linecolor=4,framestyle=:box,label="", title="", xlabel="β", ylabel="(edge LP)/(unreg. edge LP)")
                else
                        plot!([0.5],[average_clusters[26]],linewidth=0,marker=:circ,label="",markersize=5,markercolor=5,markerstrokecolor=5)
                        plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], linecolor=5,framestyle=:box,label="", title="", xlabel="β", ylabel="(edge LP)/(unreg. edge LP)")

                end
        end
        savefig("plots/edgecost.pdf")
        PyPlot.clf()
        #sati
        dataset=datasets[1]
        results=readdlm("text/results$dataset.txt",Float64)
        labels=["music","madison","vegas","algebra","geometry"]
        average_clusters=results[:,4]
        linestyles=[:solid,:dash,:dot,:dashdot,:solid]
        plot([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[1], framestyle=:box,label="", title="", xlabel="β", ylabel="rel. edge satisfaction")
        for (i, dataset) in enumerate(datasets[2:end])
                results=readdlm("text/results$dataset.txt",Float64)
                average_clusters=results[:,4]

                plot!([mesh*j for j in 0:iter],average_clusters,linewidth=2,grid=false,linestyle=linestyles[i+1], framestyle=:box,label="", title="", xlabel="β", ylabel="rel. edge satisfaction")
        end
        savefig("plots/sati.pdf")
end
#datasets=["windows-constrained-0.0-algebra","windows-constrained-0.5-geometry","windows-constrained-0.5-algebra","windows-constrained-0.0-geometry"]
#datasets=["windows-constrained-0.0-yelpClevelandBarsFull","windows-constrained-0.5-yelpClevelandBarsFull"]

mesh=0.0025
iter=50;
st=20;
datasets=["post-windows-constrained-0.0-amazon_music","post-windows-constrained-0.0-yelpmadison","post-windows-constrained-0.0-yelpLas vegasBarsFull","post-windows-constrained-0.0-algebra-Posts","post-windows-constrained-0.0-geometry-Posts"]
tagsPlots(datasets,mesh,iter,st)
datasets=["-betaamazon_music","-betayelpmadison","-betayelpLas vegasBarsFull","-betaalgebra-Posts","-betageometry-Posts"]
betaPlots(datasets,0.02,40,1)
