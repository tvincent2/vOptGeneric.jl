# vOptGeneric: part of vOptSolver for non-structured problems

**vOptSolver** is a solver of multiobjective linear optimization problems (MOCO, MOIP, MOMILP, MOLP).
This repository concerns **vOptGeneric**, the part of vOptSolver devoted to **multiobjective non-structured problems** (currently available: 2IP). With vOptGeneric, the problem is expressed using JuMP algebraic language extended to multiple objectives.

We suppose you are familiar with vOptSolver; if not, read first this [presentation](https://voptsolver.github.io/vOptSolver/).


## Instructions 
For a local use, a working version of:
- Julia must be ready; instructions for the installation are available [here](https://julialang.org/downloads/)
- your favorite MILP solver must be ready (GLPK is suggested); 
  instructions for the installation are available [here](http://jump.readthedocs.io/en/latest/installation.html)
  
### Run Julia

On linux or in the cloud (juliaBox):

- open a console on your computer or in the cloud
- when the prompt is ready, type in the console `julia`

On macOS:

- locate the application `julia` and 
- click on the icon, the julia console comes to the screen

### Installation Instructions

Before your first local or distant use, 
1. run Julia and when the terminal is ready with the prompt `julia` on screen, 
2. add as follow the two mandatory packages to your Julia distribution: 

```
julia> Pkg.clone("http://github.com/vOptSolver/vOptGeneric.jl")
julia> Pkg.add("GLPK") ; Pkg.add("GLPKMathProgInterface")
```

That's all folk; at this point, vOptGeneric is properly installed.

### Usage Instructions

When vOptGeneric is properly installed,

1. run Julia and when the terminal is ready with the prompt `julia` on screen, 
2. invoke vOptGeneric and the MILP solver to activate in typing in the console:
```
julia> using vOptGeneric
julia> using GLPK ; using GLPKMathProgInterface
```
vOptGeneric is ready. See examples for further informations and have fun with the solver! 

## Examples
The folder `examples` provides (1) source code of problems ready to be solved and (2) selected datafiles into different formats.

## Limitations
No special limitation; the solving strength of vOptGeneric is currently provided by the MILP solver (GLPK, CPLEX, etc.) invoked.
