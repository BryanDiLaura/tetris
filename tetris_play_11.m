function [decision] = tetris_play_11(board, piece, iteration_num, mu)
%


%find current node of array
currentNode = board2dec(board);

%adjust for matlab indexing from 1
currentNode = currentNode+1;

%retrieve decision from mu
decDecision = mu(currentNode, iteration_num, piece);

%output decision
decision = dec2board(decDecision);

end

%generates the decimal number for a given board
function [number] = board2dec(board)
    v = reshape(board,1,9);
    number = bin2dec(num2str(v));
end

%generates the matrix for a given decimal number
function [matrix] = dec2board(number)
    bintemp = dec2bin(number,9);
    matrix = reshape((num2str(bintemp)-'0'),3,3);
end