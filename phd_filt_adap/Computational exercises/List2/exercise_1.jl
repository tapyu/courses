using Plots, LinearAlgebra, LaTeXStrings

# input values
ÏÂ² = 24.4 # variance of d(n)
ð© = [2 4.5] # cross-correlation between ð±(n) and d(n)
ð°â = [2 4.5] # Wiener solution
râ0, râ1 = 1, 0
ðâ = [râ0 râ1;
      râ1 râ0]

# wâ = range(start=0, stop=10, length=100)
# wâ = range(start=0, stop=10, length=100)
# ð° = [wâ, wâ] # coefficient vector

J(wâ, wâ) = ÏÂ² - 2ð©â[wâ; wâ] + [wâ; wâ]' * ðâ * [wâ; wâ]

surface(-15:0.1:15, -10:0.1:20, J, camera=(60,40,0), zlabel=L"J(\mathbf{w})")
scatter!([ð°â[1]], [ð°â[2]], [J(ð°â[1], ð°â[2])], markershape= :circle, color= :red, markersize = 6, label = "Wiener solution") # ! make plots the scatter on the same axis

savefig("cost_function.png")