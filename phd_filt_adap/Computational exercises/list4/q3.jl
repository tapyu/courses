using LinearAlgebra, DSP, Plots, LaTeXStrings
ÎĢ = sum

N = 200 # number of samples
ð = randn(N) # a(n) ~ N(0, 1)
ÏÂē = 1 # variance of a
ð = ð # d(n) = a(n)
ðĄ = [1, 1.6] # channel filter coefficients
Îŧ = 0.99
Îī = 5
ðē = fill(NaN, 10)
ðd = Îī*I(2)

ð = [3.56 1.6
1.6 3.56]
ðĐâd = [1.6, 0]
ð°â = inv(ð)*ðĐâd # Wiener solution
J(wâ, wâ) = ÏÂē - 2ðĐâdâ[wâ; wâ] + [wâ; wâ]' * ð * [wâ; wâ] # cost-function

# channel output
ðą = rand(N)
for n â 2:N
    ðâââ = [ð[n], ð[n-1]] # input vector at the instant n
    ðą[n] = ðĄ â ðâââ # x(n)
end

# RLS
ð°âââ = zeros(2) # initial guess of the coefficient vector
ðĐ = zeros(2)
ð = rand(2, N) # save the coefficient vector evolution
ð[:,1] = ð°âââ # save initial position
ðē = rand(N) # output signal
ðžeÂē = zeros(N) # error signal
for n â 2:N
    ðąâââ = [ðą[n], ðą[n-1]] # input vector at the instant n
    global ðd = (ðd - (ðd*ðąâââ*ðąâââ'*ðd)/(Îŧ + ðąâââ'*ðd*ðąâââ))/Îŧ
    global ðĐ = Îŧ*ðĐ + ð[n]'*ðąâââ
    global ð°âââ = ðd*ðĐ
    global ð[:,n] = ð°âââ
    global ðžeÂē[n] = ((n-2)*ðžeÂē[n-1] + (ð[n] - ðē[n])^2)/(n-1)
    ðē[n] = ð°âââ â ðąâââ # y(n)
end
p4 = plot([ðē ð], title="RLS algorithm ", label=[L"y(n)" L"d(n)"], legend=:bottomleft)
savefig(p4, "list4/figs/q2_rls_algorithm_output.png")

fig = contour(-.5:.05:1.5, -1.5:.05:1.5, J) # add the cost function contour to the last plot
scatter!([ð°â[1]], [ð°â[2]], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution", title="RLS algorithm coefficients over the contours") # ! make plots the scatter on the same axis
plot!(ð[1,:], ð[2,:], xlabel=L"w_1", ylabel=L"w_2", label="", markershape=:xcross, color=:blue)
savefig(fig, "list4/figs/q2_contour.png")

e4 = plot(ðžeÂē, title="MSE of the RLS algorithm", label=L"\mathbb{E}[e^2(n)]")
savefig(e4, "list4/figs/q2_rls_algorithm_error.png")