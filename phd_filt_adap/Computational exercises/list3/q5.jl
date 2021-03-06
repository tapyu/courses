using LinearAlgebra, Plots, LaTeXStrings, DSP

Nβ = 1000 # number of samples
N = 13 # 13 tapped delay plus the bias
π± = 2β(3)rand(Nβ).-β(3) # ~ U(-β(3), β(3)) -> ΟβΒ² = 1
ΞΌβββ = 1/N
π = I(N) # correlation matrix of x(n) -> is I since it is a white process
ΟβΒ² = 1e-3 # measurement variance
πΌeΒ²βα΅’β = ΟβΒ² # minimum MSE (only achievable by the steepest descent method, using the deterministic gradient)

# system output
πΚΌ = [0; rand(Nβ-1)] # initial stage
for n β N:Nβ
    πΚΌ[n] = πΚΌ[n-1] + π±[n] - π±[n-12]
end

# reference signal (system output + noise)
π§ = β(ΟβΒ²)randn(Nβ) # ~ N(0, ΟβΒ²)
π = πΚΌ + π§

plots_lms = Array{Plots.Plot{Plots.GRBackend}, 1}(undef,4) # or Vector{Plots.GRBackend}(undef,4)
plots_mse = Array{Plots.Plot{Plots.GRBackend}, 1}(undef,4) # or Vector{Plots.GRBackend}(undef,4)
for (j, i) β enumerate((1, 2, 10, 50))
    ΞΌ = ΞΌβββ/i # step learning
    # the LMS algorithm
    global π°βββ = rand(N) # initial coefficient vector
    πΌeΒ² = zeros(Nβ) # MSE (mean-squared error) signal
    π² = [fill(NaN, N); rand(Nβ-N)] # adaptive filter output
    for n β N:Nβ
        π±βββ = π±[n:-1:n-12] # input signal
        π²[n] = π±βββ β π°βββ # adaptive filter output
        eβββ = π[n] - π²[n] # signal error
        πΌeΒ²[n] = ((n-N)*πΌeΒ²[n-1] + eβββ^2)/(n-N+1) # estimate the the MSE recursively
        π°βββ += 2ΞΌ*eβββ*π±βββ
    end
    plots_lms[j] = plot([π π²], label=[L"d(n)" L"y(n)"*" for "*L"\mu=\mu_{max}"*(i!=1 ? "/$(i)" : "")], xlabel="n", legend=:topleft)
    plots_mse[j] = plot(πΌeΒ², label=L"e^2(n)"*" for "*L"\mu=\mu_{max}"*(i!=1 ? "/$(i)" : ""), xlabel="n", legend=:bottomright)

    πΌeΒ²ββc = πΌeΒ²[end] - πΌeΒ²βα΅’β

    # println("Excess MSE = $(πΌeΒ²ββc) for ΞΌ = ΞΌβββ/$(i) (practical result)")
    # println("Excess MSE = $(ΞΌ*ΟβΒ²*tr(π)/(1 - ΞΌ*tr(π))) for ΞΌ = ΞΌβββ/$(i) (theoretical result)")

    println("Misadjustment M = $(πΌeΒ²ββc/πΌeΒ²βα΅’β) for ΞΌ = ΞΌβββ/$(i) (practical result)")
    println("Misadjustment M = $(ΞΌ*tr(π)/(1 - ΞΌ*tr(π))) for ΞΌ = ΞΌβββ/$(i) (theoretical result)")
end

# save LMS fig convergence
fig = plot(plots_lms..., layout=(4,1), size=(1200,800), title=["System identification output for differents learning steps" "" "" ""]) # plots_lms... -> dereferencing
savefig(fig, "list3/figs/q5_lms_algorithm.png")

# save MSE
fig = plot(plots_mse..., layout=(4,1), size=(1200,800)) # plots_ems... -> dereferencing
savefig(fig, "list3/figs/q5_mse_algorithm.png")

H = DSP.PolynomialRatio([1; fill(0,11); -1], [1, -1]) # transfer function of H(β―^(jΟ)) vs. HΜ(β―^(jΟ))
Hβwβ, w = DSP.freqresp(H)
fig = plot(w, abs.(Hβwβ), label=L"\mid H(e^{jw})\mid", linewidth=2)
HΜ = DSP.PolynomialRatio(π°βββ, [1])
HΜβwβ, w = DSP.freqresp(HΜ)
plot!(w, abs.(HΜβwβ), xlabel="Digital frequency "*L"w"*" (radians/sample)", label=L"\mid\hat{H}(e^{jw})\mid", xticks = ([0, Ο/2, Ο], ["0", "Ο/2", "Ο"]), linewidth=2)
savefig(fig, "list3/figs/transfer_function.png")