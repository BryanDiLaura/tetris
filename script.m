rowsEll = [];

for N = [5, 10, 20, 40, 80, 160, 300, 500, 700, 1000]
    [j,mu,rows] = tetris_policy_11(N,(1/3)*ones(3,3));
    rowsEll = [rowsEll rows];
end