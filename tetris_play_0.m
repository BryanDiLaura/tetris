function [ decision ] = tetris_play_0( board, pieceNum, iteration_num, mu )
%this is a dummy function. just places the piece as-is on the right side of
%the board.

    switch pieceNum
        case 1
            decision = [0 0 0; 0 0 1; 0 1 1];
        case 2
            decision = [0 0 0; 0 1 1; 1 1 0];
        case 3
            decision = [0 0 0; 0 0 1; 0 0 1];
    end

end