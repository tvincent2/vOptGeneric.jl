__precompile__()
module vOptGeneric
using Combinatorics

importall JuMP
import MathProgBase

export vModel,
    getvOptData,
    solve,
    writeMOP,
    parseMOP,
    print_X_E,
    getvalue,
    getY_N,
    @addobjective,
    @variable,
    @constraint

include("MOP.jl")
include("algorithms.jl")

type vOptData
    objs::Array{QuadExpr}               #Objectives
	objSenses::Array{Symbol}            #Objective Senses
    Y_N::Vector{Vector{Float64}}        #Objective values for each point
    X_E::Vector{Vector{Float64}}        #Variable values for each point
end

function getvOptData(m::Model)
    !haskey(m.ext, :vOpt) && error("This model wasn't created with vOptGeneric")
    return m.ext[:vOpt]::vOptData
end

function vModel(;solver=JuMP.UnsetSolver())
    m = Model(solver=solver)
    m.solvehook = solvehook
    m.ext[:vOpt] = vOptData(Vector{QuadExpr}(), #objs
                              Vector{Symbol}(), #objSenses
                              Vector{Vector{Float64}}(), #Y_N
                              Vector{Vector{Float64}}()) #X_E
    return m
end

function solvehook(m::Model; suppress_warnings=false, method=nothing, step = 0.5)::Symbol
    if method == :epsilon
        return solve_eps(m, step)
    elseif method == :dicho || method == :dichotomy
        return solve_dicho(m)
    elseif method == :Chalmet || method == :chalmet
        return solve_Chalmet(m, step)
    elseif method == :lex || method == :lexico
        return solve_lexico(m)
    else
        warn("use solve(m, method = :(epsilon | dichotomy | chalmet | lexico) )")
        return :Unsolved
    end

end

macro addobjective(m, args...)
    if length(args) != 2
        error("in @addobjective: needs three arguments: model, 
                objective sense (Max or Min) and linear expression.")
    end
    m = esc(m)
    sense = args[1]
    if sense == :Min || sense == :Max
        sense = Expr(:quote,sense)
    end
    expr = esc(args[2])
    return quote
        f = @expression($m, $expr)
        !isa(f, JuMP.GenericAffExpr) && error("in @addobjective : vOptGeneric only supports linear objectives")
        vd = $m.ext[:vOpt]
        push!(vd.objSenses, $(esc(sense)))
        push!(vd.objs, QuadExpr(f))
    end
end

# Returns coefficients for the affine part of an objective
function prepAffObjective(m, objaff::JuMP.GenericQuadExpr)
    # Check that no coefficients are NaN/Inf
    JuMP.assert_isfinite(objaff)
    if !JuMP.verify_ownership(m, objaff.aff.vars)
        error("Variable not owned by model present in objective")
    end
    f = zeros(m.numCols)
    @inbounds for ind in 1:length(objaff.aff.vars)
        f[objaff.aff.vars[ind].col] += objaff.aff.coeffs[ind]
    end
    return f
end

function print_X_E(m::Model)
    vd = getvOptData(m)
    for i = 1:length(vd.Y_N)
        print(vd.Y_N[i]," : ")
        for j = 1:m.numCols
            if vd.X_E[i][j] != 0
                if m.colCat[j] == :Int || m.colCat[j] == :Bin
                    print(getname(m,j),"=",round(Int,vd.X_E[i][j])," ")
                else
                    print(getname(m,j),"=",vd.X_E[i][j]," ")
                end
            end
        end 
        println()
   end
end

function getvalue(v::Variable, i::Int)
    vd = getvOptData(v.m)
    return vd.X_E[i][v.col]
end

function getvalue(arr::Array{Variable}, i::Int)

    ret = similar(arr,Float64)
    isempty(ret) && return ret

    for I in eachindex(arr)
        v = arr[I]
        value = getvalue(v, i)
        ret[I] = value
    end

    return ret
end

getvalue(x::JuMP.JuMPContainer, i::Int) = JuMP._map(v -> getvalue(v, i), x)

function getY_N(m::Model)
    return getvOptData(m).Y_N
end


end#module