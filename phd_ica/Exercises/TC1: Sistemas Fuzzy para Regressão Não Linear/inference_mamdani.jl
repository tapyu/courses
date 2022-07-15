function inference(μx_A, all_μy_B, I, 𝐲_range)
    if I == 3
        # 1th rule
        # IF xₙ IS MEDIUM
        # THEN yₙ IS HIGH
        μx_A₂ = μx_A[2] # the input fuzzy set MEDIUM
        all_μy_B₃ = all_μy_B[:,3] # the output fuzzy set HIGH
        μAtoB⁽¹⁾ = map(min, fill(μx_A₂, length(all_μy_B₃)), all_μy_B₃) # Modus Ponens 
        
        # 2th rule
        # IF xₙ IS LOW
        # THEN yₙ IS MEDIUM
        μx_A₁ = μx_A[1] # the input fuzzy set LOW
        all_μy_B₂ = all_μy_B[:,2] # the output fuzzy set MEDIUM
        μAtoB⁽²⁾ = map(min, fill(μx_A₁, length(all_μy_B₂)), all_μy_B₂) # Modus Ponens

        # 3th rule
        # IF xₙ IS HIGH
        # THEN yₙ IS LOW
        μx_A₃ = μx_A[3] # the input fuzzy set LOW
        all_μy_B₁ = all_μy_B[:,1] # the output fuzzy set MEDIUM
        μAtoB⁽³⁾ = map(min, fill(μx_A₃, length(all_μy_B₁)), all_μy_B₁) # Modus Ponens

        # resulting output fuzzy set (aggregation)
        μAtoB = map(max, μAtoB⁽¹⁾, μAtoB⁽²⁾, μAtoB⁽³⁾)

        # centroid mass (defuzzification)
        ŷₙ = sum(μAtoB.*𝐲_range)./sum(μAtoB)
    end

    return ŷₙ
end