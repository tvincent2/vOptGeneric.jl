using vOptGeneric, CPLEX

m = parseMOP(ARGS[1], solver = CplexSolver())

solve(m, method=:epsilon)

print_X_E(m)

using PyPlot
Y_N = getY_N(m)
f1, f2 = map(x -> x[1], Y_N), map(x -> x[2], Y_N)
xlabel("z1") ; ylabel("z2")
plot(f1,f2,"bx", markersize = "6")
!isinteractive() && show()
