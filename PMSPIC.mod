set Components;

param T;
param d;
param c{Components};

param M{1..T,Components};

param c2{i in Components, s in 1..T, t in s+1..T+1}:=
c[i] + M[t-s,i];

var x{Components, 1..T, 1..T+1} binary;
var z{1..T} binary;

minimize Cost:
sum{i in Components, s in 1..T, t in s+1..T+1} c2[i,s,t]*x[i,s,t]+ sum{t in 1..T} d*z[t];

subject to MaintainInTime{i in Components, t in 2..T}:
sum{s in 1..t-1} x[i,s,t] <= z[t];

subject to EqualOccasions{i in Components, t in 2..T}:
sum{s in 1..(t-1)} x[i,s,t] = sum{r in (t+1)..(T+1)} x[i,t,r];

subject to StartAtZero{i in Components}:
sum{s in 2..T+1} x[i,1,s] = 1;

#subject to somet:
#x[1,1,51]=1;

#param cumulative_market {p in PROD, t in 1..T} >= if t = 1 then 0 else cumulative_market[p,t-1];+x[1,1,53]+x[1,1,52]+x[1,1,50]
#param demand {j in DEST, p in PROD} = share[j] * tot_dem[p] / tot_sh;
#param mininv {p in PROD, t in 0..T} =if t = 0 then inv0[p] else 0.5 * (mininv[p,t-1] + frac * market[p,t+1]);
