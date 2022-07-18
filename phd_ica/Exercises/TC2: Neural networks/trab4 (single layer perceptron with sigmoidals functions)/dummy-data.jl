using FileIO, JLD2, Random, LinearAlgebra, Plots, LaTeXStrings
Σ=sum

## algorithm parameters and hyperparameters
Nᵣ = 20 # number of realizations
Nₑ = 100 # number of epochs
c = 3 # number of perceptrons (neurons) of the single layer
α = 0.001 # learning step
σₓ = .1 # signal standard deviation
N = 150 # number of instances
Nₐ = 2 # number of attributes
Nₜᵣₙ = 80 # % percentage of instances for the train dataset
Nₜₛₜ = 20 # % percentage of instances for the test dataset

## generate dummy data
𝐗⚫ = [σₓ*randn(50)'.+1.5; σₓ*randn(50)'.+1]
𝐗△ = [σₓ*randn(50)'.+1; σₓ*randn(50)'.+2]
𝐗⭐ = [σₓ*randn(50)'.+2; σₓ*randn(50)'.+2]

𝐗 = [fill(-1,N)'; [𝐗⚫ 𝐗△ 𝐗⭐]]
𝐃 = [repeat([1,0,0],1,50) repeat([0,1,0],1,50) repeat([0,0,1],1,50)]

## useful functions
function shuffle_dataset(𝐗, 𝐃)
    shuffle_indices = Random.shuffle(1:size(𝐗,2))
    return 𝐗[:, shuffle_indices], 𝐃[:, shuffle_indices]
end

function train(𝐗, 𝐃, 𝐖, is_training_accuracy=true)
    φ = uₙ -> uₙ>0 ? 1 : 0 # McCulloch and Pitts's activation function (step function)
    Nₑ = 0 # number of errors - misclassification
    for (𝐱ₙ, 𝐝ₙ) ∈ zip(eachcol(𝐗), eachcol(𝐃))
        𝛍ₙ = 𝐖*𝐱ₙ
        𝐲ₙ = map(φ, 𝛍ₙ) # for the training phase, you do not pass yₙ to a harder decisor (the McCulloch and Pitts's activation function) (??? TODO)
        𝐞ₙ = 𝐝ₙ - 𝐲ₙ
        𝐖 += α*𝐞ₙ*𝐱ₙ'

        # this part is optional: only if it is interested in seeing the accuracy evolution of the training dataset throughout the epochs
        i = findfirst(x->x==maximum(𝛍ₙ), 𝛍ₙ)
        Nₑ = 𝐝ₙ[i]==1 ? Nₑ : Nₑ+1
    end
    if is_training_accuracy
        accuracy = (size(𝐃,2)-Nₑ)/size(𝐃,2)
        return 𝐖, accuracy
    else
        return  𝐖
    end
end

function test(𝐗, 𝐃, 𝐖)
    φ = uₙ -> uₙ>0 ? 1 : 0 # McCulloch and Pitts's activation function (step function)
    Nₑ = 0 # number of errors - misclassification
    for (𝐱ₙ, 𝐝ₙ) ∈ zip(eachcol(𝐗), eachcol(𝐃))
        𝛍ₙ = 𝐖*𝐱ₙ
        # yₙ = map(φ, 𝛍ₙ) # theoretically, you need to pass 𝛍ₙ through the activation function, but, in order to solve ambiguous instances (see Ajalmar's handwritings), we pick the class with the highest activation function input
        i = findfirst(x->x==maximum(𝛍ₙ), 𝛍ₙ) # predicted value → choose the highest activation function input as the selected class
        Nₑ = 𝐝ₙ[i]==1 ? Nₑ : Nₑ+1
    end
    accuracy = (size(𝐃,2)-Nₑ)/size(𝐃,2)
    return accuracy
end

## init
accₜₛₜ = fill(NaN, Nᵣ) # vector of accuracies for test dataset
for nᵣ ∈ 1:Nᵣ
    # initialize!
    𝐖 = rand(c, Nₐ+1) # [𝐰₁ᵀ; 𝐰₂ᵀ; ...; 𝐰ᵀ_c]
    accₜᵣₙ = fill(NaN, Nₑ) # vector of accuracies for train dataset (to see its evolution during training phase)

    # prepare the data!
    global 𝐗, 𝐃 = shuffle_dataset(𝐗, 𝐃)
    # hould-out
    global 𝐗ₜᵣₙ = 𝐗[:,1:(N*Nₜᵣₙ)÷100]
    global 𝐃ₜᵣₙ = 𝐃[:,1:(N*Nₜᵣₙ)÷100]
    global 𝐗ₜₛₜ = 𝐗[:,size(𝐃ₜᵣₙ, 2)+1:end]
    global 𝐃ₜₛₜ = 𝐃[:,size(𝐃ₜᵣₙ, 2)+1:end]

    # train!
    for nₑ ∈ 1:Nₑ # for each epoch
        𝐖, accₜᵣₙ[nₑ] = train(𝐗ₜᵣₙ, 𝐃ₜᵣₙ, 𝐖)
        𝐗ₜᵣₙ, 𝐃ₜᵣₙ = shuffle_dataset(𝐗ₜᵣₙ, 𝐃ₜᵣₙ)
    end
    # test!
    global accₜₛₜ[nᵣ] = test(𝐗ₜₛₜ, 𝐃ₜₛₜ, 𝐖) # accuracy for this realization
    
    # make plots!
    if nᵣ==1
        # training dataset accuracy evolution by epochs for the 1th realization
        local fig = plot(accₜᵣₙ, ylims=(0,1), xlabel="Epochs", ylabel="Accuracy", linewidth=2)
        savefig(fig, "figs/trab3 (single layer perceptron)/dummy data - training dataset accuracy evolution.png")

        # plot decision surface for the 1th realization
        local x₁_range = floor(minimum(𝐗[2,:])):.1:ceil(maximum(𝐗[2,:]))
        local x₂_range = floor(minimum(𝐗[3,:])):.1:ceil(maximum(𝐗[3,:]))
        local y(x₁, x₂) = findfirst(a -> a==maximum(𝐖*[-1, x₁, x₂]), 𝐖*[-1, x₁, x₂]) # predict

        fig = contour(x₁_range, x₂_range, y, xlabel = L"x_1", ylabel = L"x_2", fill=true, levels=2)
        # train circe label
        scatter!(𝐗ₜᵣₙ[2,𝐃ₜᵣₙ[1,:].==1], 𝐗ₜᵣₙ[3,𝐃ₜᵣₙ[1,:].==1], markershape = :hexagon, markersize = 8, markeralpha = 0.6, markercolor = :white, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "circe class [train]")
            
        # test circle label
        scatter!(𝐗ₜₛₜ[2,𝐃ₜₛₜ[1,:].==1], 𝐗ₜₛₜ[3,𝐃ₜₛₜ[1,:].==1], markershape = :dtriangle, markersize = 8, markeralpha = 0.6, markercolor = :white, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "circle class [test]")

        # train triangle label
        scatter!(𝐗ₜᵣₙ[2,𝐃ₜᵣₙ[2,:].==1], 𝐗ₜᵣₙ[3,𝐃ₜᵣₙ[2,:].==1], markershape = :hexagon, markersize = 8, markeralpha = 0.6, markercolor = :cyan, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "triangle class [train]")

        # test triangle label
        scatter!(𝐗ₜₛₜ[2,𝐃ₜₛₜ[2,:].==1], 𝐗ₜₛₜ[3,𝐃ₜₛₜ[2,:].==1], markershape = :dtriangle, markersize = 8, markeralpha = 0.6, markercolor = :cyan, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "triangle class [test]")

        # train star label
        scatter!(𝐗ₜᵣₙ[2,𝐃ₜᵣₙ[3,:].==1], 𝐗ₜᵣₙ[3,𝐃ₜᵣₙ[3,:].==1], markershape = :hexagon, markersize = 8, markeralpha = 0.6, markercolor = :green, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "star class [train]")

        # test star label
        scatter!(𝐗ₜₛₜ[2,𝐃ₜₛₜ[3,:].==1], 𝐗ₜₛₜ[3,𝐃ₜₛₜ[3,:].==1], markershape = :dtriangle, markersize = 8, markeralpha = 0.6, markercolor = :green, markerstrokewidth = 3, markerstrokealpha = 0.2, markerstrokecolor = :black, label = "star class [test]")

        title!("Decision surface")
        savefig(fig, "figs/trab3 (single layer perceptron)/dummy data - decision surface.png")
    end
end

# analyze the accuracy statistics of each independent realization
āc̄c̄ = Σ(accₜₛₜ)/Nᵣ # Mean
𝔼acc² = Σ(accₜₛₜ.^2)/Nᵣ
σacc = sqrt.(𝔼acc² .- āc̄c̄.^2) # standard deviation

println("Mean: $(āc̄c̄)")
println("Standard deviation: $(σacc)")