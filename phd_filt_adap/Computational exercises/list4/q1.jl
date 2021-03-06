using LinearAlgebra, Plots

Ī» = 0.98
Ī“ = 100

š² = fill(NaN, 10)
šd = Ī“*I(3)
š© = zeros(3)

for n ā 3:10
    š±āāā = cos.(Ļ*(n:-1:n-2)/3)
    dāāā = cos(Ļ*(n+1)/3) # d(n) = x[n+1]

    global šd = (šd - (šd*š±āāā*š±āāā'*šd)/(Ī» + š±āāā'*šd*š±āāā))/Ī»
    global š© = Ī»*š© + dāāā'*š±āāā
    š°āāā = šd*š©
    yāāā = š°āāā ā š±āāā # y(n)
    š²[n] = yāāā
end

fig = plot([cos.(Ļ*(1:10)/3) š²], markershape=:xcross, linewidth=2, markersize=5, markerstrokewidths=4, label=["x(n)" "y(n)"], xlabel="n")

savefig(fig, "list4/figs/q1.png")