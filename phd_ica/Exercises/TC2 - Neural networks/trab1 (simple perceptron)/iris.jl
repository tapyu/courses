using FileIO, JLD2, Random, LinearAlgebra, Plots, LaTeXStrings
Ī£=sum

## load the data
š, labels = FileIO.load("Datasets/Iris [uci]/iris.jld2", "š", "š") # š ā” [attributes X instances]
# PS choose only one!!!
# uncomment ā if you want to train for all attributes
š = [fill(-1, size(š,2))'; š] # add the -1 input (bias)
# uncomment ā if you want to train for petal length and width (to plot the decision surface)
# š = [fill(-1, size(š,2))'; š[3:4,:]] # add the -1 input (bias)

## useful functions
function shuffle_dataset(š, š)
    shuffle_indices = Random.shuffle(1:size(š,2))
    return š[:, shuffle_indices], š[shuffle_indices]
end

function train(š, š, š°, is_training_accuracy=true)
    Ļ = uāāā -> uāāā>0 ? 1 : 0 # McCulloch and Pitts's activation function (step function)
    Nā = 0 # number of errors - misclassification
    for (š±āāā, dāāā) ā zip(eachcol(š), š)
        Ī¼āāā = dot(š±āāā,š°) # inner product
        yāāā = Ļ(Ī¼āāā) # for the training phase, you do not pass yāāā to a harder decisor (the McCulloch and Pitts's activation function) since you are in intended to classify yāāā. Rather, you are interested in updating š° (??? TODO)
        eāāā = dāāā - yāāā
        š° += Ī±*eāāā*š±āāā

        # this part is optional: only if it is interested in seeing the accuracy evolution of the training dataset throughout the epochs
        Nā = eāāā==0 ? Nā : Nā+1
    end
    if is_training_accuracy
        accuracy = (length(š)-Nā)/length(š) # accuracy for this epoch
        return š°, accuracy
    else
        return š°
    end
end

function test(š, š, š°, is_confusion_matrix=false)
    Ļ = uāāā -> uāāā>0 ? 1 : 0 # McCulloch and Pitts's activation function (step function)
    š² = rand(length(š)) # vector of predictions for confusion matrix
    Nā = 0
    for (n, (š±āāā, dāāā)) ā enumerate(zip(eachcol(š), š))
        Ī¼āāā = š±āāāāš° # inner product
        yāāā = Ļ(Ī¼āāā) # for the simple Perceptron, yāāā ā {0,1}. Therefore, it is not necessary to pass yāāā to a harder decisor since Ļ(ā) already does this job
        š²[n] = yāāā

        Nā = yāāā==dāāā ? Nā : Nā+1
    end
    if !is_confusion_matrix
        accuracy = (length(š)-Nā)/length(š)
        return accuracy # return the accuracy for this realization
    else
        return Int.(š²) # return the errors over the instances to plot the confusion matrix
    end
end

## algorithm parameters hyperparameters
Nįµ£ = 20 # number of realizations
Nā = size(š, 1) # =5 (including bias) number of Attributes, that is, input vector size at each intance. They mean: sepal length, sepal width, petal length, petal width
N = size(š, 2) # =150 number of instances(samples)
Nāįµ£ā = 80 # % percentage of instances for the train dataset
Nāāā = 20 # % percentage of instances for the test dataset
Nā = 100 # number of epochs
Ī± = 0.01 # learning step

## init
all_aĢcĢcĢ, all_Ļacc, all_š°āāā = rand(3), rand(3), rand(Nā,3)
for (i, desired_label) ā enumerate(("setosa", "virginica", "versicolor"))
    local š = labels.==desired_label # dāāā ā {0,1}
    local accāāā = fill(NaN, Nįµ£) # vector of accuracies for test dataset (to compute the final statistics)
    for nįµ£ ā 1:Nįµ£ # for each realization
        # initializing!
        accāįµ£ā = fill(NaN, Nā) # vector of accuracies for train dataset (to see its evolution during training phase)
        global š° = ones(Nā) # initialize a new McCulloch-Pitts neuron (a new set of parameters)
        global š # ?

        # prepare the data!
        š, š = shuffle_dataset(š, š)
        # hould-out
        global šāįµ£ā = š[:,1:(N*Nāįµ£ā)Ć·100]
        global šāįµ£ā = š[1:(N*Nāįµ£ā)Ć·100]
        global šāāā = š[:,length(šāįµ£ā)+1:end]
        global šāāā = š[length(šāįµ£ā)+1:end]

        # train!
        for nā ā 1:Nā # for each epoch
            š°, accāįµ£ā[nā] = train(šāįµ£ā, šāįµ£ā, š°)
            šāįµ£ā, šāįµ£ā = shuffle_dataset(šāįµ£ā, šāįµ£ā)
        end
        # test!
        accāāā[nįµ£] = test(šāāā, šāāā, š°)
        
        # make plots!
        if nįµ£ == 1
            all_š°āāā[:,i] = š° # save the optimum value reached during the 1th realization for setosa, versicolor, and virginica
            # if all attributes was taken into account, compute the accuracyxepochs for all classes
            if length(š°) != 3
                local p = plot(accāįµ£ā, label="", xlabel=L"Epochs", ylabel="Accuracy", linewidth=2, title="Training accuracy for $(desired_label) class by epochs")
                display(p)
                savefig(p, "trab1 (simple perceptron)/figs/accuracy-by-epochs-for-$(desired_label).png")
                # for the setosa class, compute the confusion matrix
                if desired_label == "setosa"
                    š = zeros(2,2) # confusion matrix
                    š²āāā = test(šāāā, šāāā, š°, true)
                    for n ā 1:length(š²āāā)
                        # predicted x true label
                        š[š²āāā[n]+1, šāāā[n]+1] += 1
                    end
                    h = heatmap(š, xlabel="Predicted labels", ylabel="True labels", xticks=(1:2, ("setosa", "not setosa")), yticks=(1:2, ("setosa", "not setosa")), title="Confusion matrix for the setosa class")
                    savefig(h, "trab1 (simple perceptron)/figs/setosa-confusion-matrix.png")
                    display(h) # TODO: put the number onto each confusion square
                end
            end
            # decision surface
            if length(š°) == 3 # plot the surface only if the learning procedure was taken with only two attributes, the petal length and petal width (equals to 3 because the bias)
                Ļ = uāāā -> uāāāā„0 ? 1 : 0 # activation function of the simple Perceptron
                xā_range = floor(minimum(š[2,:])):.1:ceil(maximum(š[2,:]))
                xā_range = floor(minimum(š[3,:])):.1:ceil(maximum(š[3,:]))
                y(xā, xā) = Ļ(dot([-1, xā, xā], š°))
                p = surface(xā_range, xā_range, y, camera=(60,40,0), xlabel = "petal length", ylabel = "petal width", zlabel="decision surface")

                # scatter plot for the petal length and petal length width for the setosa class
                # train and desired label 
                scatter!(šāįµ£ā[2,šāįµ£ā.==1], šāįµ£ā[3,šāįµ£ā.==1], ones(length(filter(x->x==1, šāįµ£ā))),
                        markershape = :hexagon,
                        markersize = 4,
                        markeralpha = 0.6,
                        markercolor = :green,
                        markerstrokewidth = 3,
                        markerstrokealpha = 0.2,
                        markerstrokecolor = :black,
                        xlabel = "petal\nlength",
                        ylabel = "petal width",
                        camera = (60,40,0),
                        label = "$(desired_label) train set")
                
                # test and desired label 
                scatter!(šāāā[2,šāāā.==1], šāāā[3,šāāā.==1], ones(length(filter(x->x==1, šāāā))),
                        markershape = :cross,
                        markersize = 4,
                        markeralpha = 0.6,
                        markercolor = :green,
                        markerstrokewidth = 3,
                        markerstrokealpha = 0.2,
                        markerstrokecolor = :black,
                        xlabel = "petal\nlength",
                        ylabel = "petal width",
                        camera = (60,40,0),
                        label = "$(desired_label) test set")

                # train and not desired label 
                scatter!(šāįµ£ā[2,šāįµ£ā.==0], šāįµ£ā[3,šāįµ£ā.==0], zeros(length(filter(x->x==0, šāįµ£ā))),
                        markershape = :hexagon,
                        markersize = 4,
                        markeralpha = 0.6,
                        markercolor = :red,
                        markerstrokewidth = 3,
                        markerstrokealpha = 0.2,
                        markerstrokecolor = :black,
                        xlabel = "petal\nlength",
                        ylabel = "petal width",
                        camera = (60,40,0),
                        label = "not $(desired_label) train set")

                # test and not desired label 
                scatter!(šāāā[2,šāāā.==0], šāāā[3,šāāā.==0], zeros(length(filter(x->x==0, šāāā))),
                        markershape = :cross,
                        markersize = 4,
                        markeralpha = 0.6,
                        markercolor = :red,
                        markerstrokewidth = 3,
                        markerstrokealpha = 0.2,
                        markerstrokecolor = :black,
                        xlabel = "petal\nlength",
                        ylabel = "petal width",
                        camera = (60,40,0),
                        label = "not $(desired_label) test set")
                
                title!("Decision surface for the class $(desired_label)")
                display(p)
                savefig(p,"trab1 (simple perceptron)/figs/decision-surface-for-$(desired_label).png")
            end
        end
    end
    # analyze the accuracy statistics of each independent realization
    local aĢcĢcĢ = Ī£(accāāā)/Nįµ£ # Mean
    local š¼accĀ² = Ī£(accāāā.^2)/Nįµ£
    local Ļacc = sqrt.(š¼accĀ² .- aĢcĢcĢ.^2) # standard deviation
    
    # save the performance
    all_aĢcĢcĢ[i] = aĢcĢcĢ
    all_Ļacc[i] = Ļacc
    println("Mean accuracy for $(desired_label): $(aĢcĢcĢ)")
    println("Standard deviation for $(desired_label): $(Ļacc)")
end