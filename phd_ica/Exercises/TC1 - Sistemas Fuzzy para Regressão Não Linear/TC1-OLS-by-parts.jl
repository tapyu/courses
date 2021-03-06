using FileIO, Plots
Ξ£=sum

## Input analisys and delimiters

π±, π² = FileIO.load("TC1data.jld2", "x", "y") # π± -> Inputs; π² -> Outputs

all_delimiters = Dict(3=>[1, 68, 110, 180, 250], 4=>[1, 68, 110, 145, 180, 250], 5=>[1, 68, 110, 130, 145, 180, 250])

## SISO (single input, single output) Ordinary Least-Squares (OLS)
function siso_ols_algorithm(π±,π²)
    # π²Μ = aΜπ±+bΜ
    xΜ, yΜ = Ξ£(π±)/length(π±), Ξ£(π²)/length(π²)
    πΌπ±π², πΌπ±Β² = Ξ£(π±.*π²)/length(π±), Ξ£(π±.^2)/length(π±)
    ΟΜβy = πΌπ±π² - xΜ*yΜ
    ΟΒ²β = πΌπ±Β² - xΜ^2
    aΜ = ΟΜβy/ΟΒ²β
    bΜ = yΜ - aΜ*xΜ
    return aΜ, bΜ
end

## begin LS by parts
π = Matrix{Float64}(undef, 0,maximum(keys(all_delimiters))+1+2) # variable that gather all values the coefficient of determination for each part (plus their statistics)
for (I, delimiters) β all_delimiters
    π« = rand(I+1) # vector of the coefficient of determination (RΒ²) for each part
    p = scatter(π±, π²,
        markershape = :hexagon,
        markersize = 4,
        markeralpha = 0.6,
        markercolor = :green,
        markerstrokewidth = 3,
        markerstrokealpha = 0.2,
        markerstrokecolor = :black,
        xlabel = "Inputs",
        ylabel = "Outputs",
        label = "Data")
        plot!(delimiters[2:end-1], linewidth = 2, seriestype = :vline, label = "Delimiters", color= :blue)
        savefig(p, "figs/scatterplot_with_delimiter_$(I)I.png")

    for i β 2:length(delimiters)
        π±α΅’, π²α΅’ = π±[delimiters[i-1]:delimiters[i]], π²[delimiters[i-1]:delimiters[i]]

        aΜ, bΜ = siso_ols_algorithm(π±α΅’, π²α΅’) # get the coefficients
        π²Μα΅’ = aΜ*π±α΅’ .+ bΜ
        πα΅’ = π²α΅’ - π²Μα΅’ # residues

        # coefficient of determination
        π²Μα΅’ = Ξ£(π²α΅’)/length(π²α΅’)
        RΒ² = 1 - (Ξ£(πα΅’.^2)/Ξ£((π²α΅’.-π²Μα΅’).^2))
        π«[i-1] = RΒ²
        if i==length(delimiters)
            π«Μ = Ξ£(π«)/length(π«) # mean
            πΌπ«Β² = Ξ£(π«.^2)/length(π«) # second moment
            ΟΒ²α΅£ = πΌπ«Β² - π«Μ^2 # variance
            global π = [π; [π«' zeros(1, maximum(keys(all_delimiters))+1-length(π«)) π«Μ ΟΒ²α΅£]]
        end

        # residues statistics
        πΜα΅’ = Ξ£(πα΅’)/length(πα΅’) # must be approximetly zero
        πΌπΒ² = Ξ£(πα΅’.^2)/length(πα΅’) # second moment
        ΟΜΒ²β = πΌπΒ² - πΜα΅’^2 # ΟΜΒ²ββπΌπΒ² (varianceβpower)

        # plot of the curve of the linear regressors
        if i == length(delimiters)
            plot!(p, [delimiters[i-1], delimiters[i]], [aΜ*delimiters[i-1]+bΜ, aΜ*delimiters[i] + bΜ], label="Linear Curves", color=:red, linewidth = 3)
            savefig(p, "figs/OLS_by_$(I+1)parts.png")
        else
            plot!(p, [delimiters[i-1], delimiters[i]], [aΜ*delimiters[i-1]+bΜ, aΜ*delimiters[i] + bΜ], label="", color=:red, linewidth = 3)
        end

        # histogram of the residues along with the Gaussian distribution
        πα΅’ = πα΅’/βΟΜΒ²β # normalized residues
        h = histogram(πα΅’, label="Distribution of the residues", normalize= :pdf, bins=range(-3, stop = 3, length = 8))
        x = range(-3,3,length=50)
        gaussian = exp.(-(x.^2)./(2*1))./β(2*Ο*1) # Gaussian Probability Density Function (PDF)
        plot!(h, x, gaussian, label="~N(0, 1)", linewidth=2)
        savefig(h, "figs/residues_PDF_I$(I)i$(i-1).png")
    end
end

FileIO.save("R2_LS_by_parts.jld2", "R", π)