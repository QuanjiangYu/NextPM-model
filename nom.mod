set Components;         	# the set of components

param T;			# the number of time steps in the model
param D{1..T,Components};
param cc{1..T,Components};
param dt{1..T};		# costs of a maintenance occasion at time steps

var x{Components,1..T}, binary;
var z{1..T}, binary;

minimize Cost: sum{i in Components, t in 1..T}
    cc[t,i]*x[i,t] + sum{t in 1..T} dt[t]*z[t]*0.5; 
 
   
	subject to ReplaceOnce {i in Components}:
   sum{t in 1..T} x[i,t] = 1; 
   
 #  subject to OM:
 #x[1,507] =1; 
   
   
#   subject to ReplaceOnlyBenefit {i in Components, t in 1..T-1}:
 #  D[t,i]* x[i,t] >=0; 
   
# replace parts only at maintenence occasions
subject to ReplaceOnlyAtMaintenance {i in Components, t in 1..T}:
    x[i,t] <= z[t]; 


