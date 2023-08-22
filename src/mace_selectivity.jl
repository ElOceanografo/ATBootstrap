
#=
Questions for Kresimir:
    - Which functions to apply in EBS?
        - 
    - Which column in SKSD are these calculating?
        - sample_correction_scalar (reciprocal of p)
    - What are confidence intervals for parameters of each?
    - Citation for these?
        - 201906 report?
        - 202107 report...(not out yet)?
    - How is age calculated?
    - How is weight calculated?
    - How to re-run analysis for nearest-haul myself?
        -
=#

# (Intercept)      Length 
#  -4.0207641   0.3533825 

# 2 x 2 Matrix of class "dpoMatrix"
#             (Intercept)       Length
# (Intercept)  1.04110776 -0.085418314
# Length      -0.08541831  0.007097557


# > L50_95_range
#     2.5%    97.5% 
# 10.35141 11.98987 
# > SR_95_range
#      2.5%     97.5% 
#  4.207268 11.592823 

# glmm_fit_sel=exp(betas[1]+length_bins*betas[2])/(1+exp(betas[1]+length_bins*betas[2]))


function make_selectivity_function(stochastic=true)
    μ = [-4.0207641, 0.3533825]
    Σ = [1.04110776 -0.0854183;
         -0.0854183  0.007097557]
    D = MvNormal(μ, Σ)
    β = stochastic ? rand(D) : μ
    selectivity(L) = exp(β[1]+L*β[2])/(1+exp(β[1]+L*β[2]))
    return selectivity
end

function apply_selectivity!(scaling, selectivity_function)
    for i in 1:nrow(scaling)
        species_code = scaling[i, :species_code]
        L = scaling[i, :primary_length]
        if species_code == 21740
            scaling[i, :sample_correction_scalar] = 1 / selectivity_function(L)
            scaling[i, :w] = scaling[i, :catch_sampling_expansion] .*
                scaling[i, :user_defined_expansion] .*
                scaling[i, :sample_correction_scalar] .* scaling[i, :haul_weight]
        end
    end
end



