using FileIO, Plots, LinearAlgebra, Statistics
Ξ£=sum

## Input analisys and delimiters

π±, π² = FileIO.load("TC1data.jld2", "x", "y") # π± -> Inputs; π² -> Outputs

all_K = 5:7 # range of K values
π« = rand(length(all_K)) # vector with all coefficient of determination
π = rand(length(all_K)) # vector with all Pearson correlation

for (i,K) β enumerate(all_K)
    # the kth order plynomial regressors
    π = vcat(map(xβ -> xβ.^(0:K)', π±)...) # observation matrix
    πβΊ = pinv(π) # the pseudoinverse (not the same Matlab's garbage pinv() function)
    π = πβΊ*π² # estimated coefficients
    π²Μ = π*π # regressor output
    π = π² - π²Μ # residues

    # residues statistics
    πΜ = Ξ£(π)/length(π) # must be approximetly zero
    πΌπΒ² = Ξ£(π.^2)/length(π) # second moment
    ΟΜΒ²β = πΌπΒ² - πΜ^2 # ΟΜΒ²ββπΌπΒ² (varianceβpower)

    # coefficient of determination
    π²Μ = Ξ£(π²)/length(π²)
    RΒ² = 1 - (Ξ£(π.^2)/Ξ£((π².-π²Μ).^2))
    π«[i] = RΒ²

    # Pearson correlation between π² and π²Μ
    π[i] = cor(π², π²Μ)

    # plot the results
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
    plot!(π±, π²Μ, linewidth=2, color=:red, label="$(K)th order polynomial regressor")
    savefig(p, "figs/kth-poly-reg/$(K)th-order.png")
end

println(π«)
println(π)