using LinearAlgebra, DSP, Plots, LaTeXStrings
ÎĢ = sum

N = 200 # number of samples
ð = randn(N) # a(n) ~ N(0, 1)
ÏÂē = 1 # variance of a
ð = ð # d(n) = a(n)
ðĄ = [1, 1.6] # channel filter coefficients
Îž = .1 # step learning

ð = [3.56 1.6
1.6 3.56]
ðĐ = [1.6, 0]
ð°â = inv(ð)*ðĐ # Wiener solution
J(wâ, wâ) = ÏÂē - 2ðĐâ[wâ; wâ] + [wâ; wâ]' * ð * [wâ; wâ] # cost-function

# channel output
ðą = rand(N)
for n â 2:N
    ðâââ = [ð[n], ð[n-1]] # input vector at the instant n
    ðą[n] = ðĄ â ðâââ # x(n)
end

# steepest descent
ð°âââ = zeros(2) # initial guess of the coefficient vector
ð = rand(2, N) # save the coefficient vector evolution
ð[:,1] = ð°âââ # save initial position
ðē = rand(N) # output signal
ðžeÂē = zeros(N) # error signal
for n â 2:N
    ðąâââ = [ðą[n], ðą[n-1]] # input vector at the instant n
    ðē[n] = ð°âââ â ðąâââ # y(n)
    ð âââ = -2ðĐ + 2ð*ð°âââ # deterministic gradient
    global ð°âââ -= Îž*ð âââ
    global ð[:,n] = ð°âââ
    global ðžeÂē[n] = ((n-2)*ðžeÂē[n-1] + (ð[n] - ðē[n])^2)/(n-1)
end
p1 = plot([ðē ð], title="Steepest descent "*L"(\mathbf{w}(n) = \mathbf{w}(n) - \mu \mathbf{g}(n))", label=[L"y(n)" L"d(n)"], legend=:bottomleft)
e1 = plot(ðžeÂē, title="MSE of the Steepest descent", label=L"\mathbb{E}[e^2(n)]")
fig = contour(-.5:.05:1.5, -1.5:.05:1.5, J) # add the cost function contour to the last plot
scatter!([ð°â[1]], [ð°â[2]], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution", title="Steepest descent coefficients over the contours") # ! make plots the scatter on the same axis
plot!(ð[1,:], ð[2,:], xlabel=L"w_1", ylabel=L"w_2", label="", markershape=:xcross, color=:blue)
savefig(fig, "list3/figs/q4c_steepest_descent.png")

# Newton's algorithm
ð°âââ = zeros(2) # initial guess of the coefficient vector
ð = rand(2, N) # save the coefficient vector evolution
ð[:,1] = ð°âââ # save initial position
ðē = rand(N) # output signal
ðžeÂē = zeros(N) # error signal
ð = 2ð # the Hessian
for n â 2:N
    ðąâââ = [ðą[n], ðą[n-1]] # input vector at the instant n
    ðē[n] = ð°âââ â ðąâââ # y(n)
    ð âââ = -2ðĐ + 2ð*ð°âââ # deterministic gradient
    Îð°âââââ = -inv(ð)*ð âââ
    global ð°âââ += Îð°âââââ
    global ð[:,n] = ð°âââ
    global ðžeÂē[n] = ((n-2)*ðžeÂē[n-1] + (ð[n] - ðē[n])^2)/(n-1)
end
p2 = plot([ðē ð], title="Newton's algorithm "*L"(\mathbf{w}(n) = \mathbf{w}(n) - \mu \mathbf{H}^{-1}\mathbf{g}(n))" , label=[L"y(n)" L"d(n)"], legend=:bottomleft)
e2 = plot(ðžeÂē, title="MSE of the Newton's algorithm", label=L"\mathbb{E}[e^2(n)]")
fig = contour(-.5:.05:1.5, -1.5:.05:1.5, J) # add the cost function contour to the last plot
scatter!([ð°â[1]], [ð°â[2]], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution", title="Newton's algorithm coefficients over the contours") # ! make plots the scatter on the same axis
plot!(ð[1,:], ð[2,:], xlabel=L"w_1", ylabel=L"w_2", label="", markershape=:xcross, color=:blue)
savefig(fig, "list3/figs/q4c_newton_algorithm.png")

# Least-Mean Squares (LMS) algorithm
Îž = .015 # step learning
global ð°âââ = zeros(2) # initial guess of the coefficient vector
ð = rand(2, N) # save the coefficient vector evolution
ð[:,1] = ð°âââ # save initial position
ðē = rand(N) # output signal
ðžeÂē = zeros(N) # error signal
for n â 2:N
    ðąâââ = [ðą[n], ðą[n-1]] # input vector at the instant n
    ðē[n] = ð°âââ â ðąâââ # y(n)
    eâââ = ð[n] - ðē[n]
    ð Ėâââ = -2eâââ*ðąâââ # stochastic gradient
    global ð°âââ -= Îž*ð Ėâââ
    global ð[:,n] = ð°âââ
    global ðžeÂē[n] = ((n-2)*ðžeÂē[n-1] + eâââ^2)/(n-1)
end
p3 = plot([ðē ð], title="LMS algorithm "*L"(\mathbf{w}(n) = \mathbf{w}(n) + 2\mu e(n)\mathbf{x}(n))", label=[L"y(n)" L"d(n)"], legend=:bottomleft)
e3 = plot(ðžeÂē, title="MSE of the LMS algorithm", label=L"\mathbb{E}[e^2(n)]")
fig = contour(-.5:.05:1, -1.5:.05:1, J) # add the cost function contour to the last plot
scatter!([ð°â[1]], [ð°â[2]], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution", title="LMS algorithm coefficients over the contours") # ! make plots the scatter on the same axis
plot!(ð[1,:], ð[2,:], xlabel=L"w_1", ylabel=L"w_2", label="", markershape=:xcross, color=:blue)
savefig(fig, "list3/figs/q4c_lms_algorithm.png")

# normalized LMS algorithm
Îž = .5 # step learning
ð°âââ = zeros(2) # initial guess of the coefficient vector
ð = rand(2, N) # save the coefficient vector evolution
ð[:,1] = ð°âââ # save initial position
Îģ = 20 # Normalized LMS hyperparameter
ðē = rand(N) # output signal
ðžeÂē = zeros(N) # error signal
for n â 2:N
    ðąâââ = [ðą[n], ðą[n-1]] # input vector at the instant n
    ðē[n] = ð°âââ â ðąâââ # y(n)
    eâââ = ð[n] - ðē[n]
    ð Ėâââ = -2eâââ*ðąâââ # stochastic gradient
    global ð°âââ -= Îž*ð Ėâââ/(ðąââââðąâââ + Îģ)
    global ð[:,n] = ð°âââ
    global ðžeÂē[n] = ((n-2)*ðžeÂē[n-1] + eâââ^2)/(n-1)
end
p4 = plot([ðē ð], title="Normalized LMS algorithm "*L"\left(\mathbf{w}(n) = \mathbf{w}(n) + \frac{2\mu e(n)\mathbf{x}(n)}{\mathbf{x}^\mathrm{T}(n)\mathbf{x}(n) + \gamma}\right)", label=[L"y(n)" L"d(n)"], legend=:bottomleft)
e4 = plot(ðžeÂē, title="MSE of the normalized LMS algorithm", label=L"\mathbb{E}[e^2(n)]")
fig = contour(-.5:.05:1.5, -1.5:.05:1.5, J) # add the cost function contour to the last plot
scatter!([ð°â[1]], [ð°â[2]], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution", title="Normalized LMS algorithm coefficients over the contours") # ! make plots the scatter on the same axis
plot!(ð[1,:], ð[2,:], xlabel=L"w_1", ylabel=L"w_2", label="", markershape=:xcross, color=:blue)
savefig(fig, "list3/figs/q4c_normalized_lms_algorithm.png")

# final plots
fig = plot(p1, p2, p3, p4, layout=(4,1), size=(1200,800))
savefig(fig, "list3/figs/q4_all_filter_output.png")

fig = plot(e1, e2, e3, e4, layout=(4,1), size=(1200,800))
savefig(fig, "list3/figs/q4-error-evolution.png")