function [ J, mu, rows ] = tetris_policy_11( N, P)
%Bryan DiLaura
%
%Project 2 (tetris) - ECEN 2703
%
%[ J, mu, rows ] = TETRIS_POLICY_101099728( N, P )
%
%This function is the workhorse of a tetris solver. It takes in N (the
%number of pieces that are going to be used) and a P matrix (a 3x3 matrix
%giving the probability of each piece happening (column) when you currently
%have a specific piece (row). For example:
%
%              [1/2 1/2  0 ]
%        P =   [1/3 1/3 1/3]
%              [ 1   0   0 ]
%
%If piece 1 is the current piece, there is a 1/2 chance piece 1 or 2 will
%be the next piece. If piece 2, then 1 2 or 3 comes up with equal
%probability. If piece 3, piece 1 always comes next. 
%
%
%This is a simplified version of tetris that will be played on a
%3x3 board. The possible pieces are as follows:
%
% Piece 1:           Piece 2:             Piece 3:
%   __                  __ __                __
%  |__|__            __|__|__|              |__|
%  |__|__|          |__|__|                 |__|
%
%
%This function will return: 
%- 3D 'J' matrix - (all possible board possibilites 
%  by number of stages) which denotes the number of rows that can be
%  elliminated at that specific board, given that piece for that stage. The
%  layer of the matrix is associated with the piece.
%- 3D 'mu' matrix - (same dimentions as J, but 3 layers). The first layer
%  is all of the possible boards by the number of stages, with the entry
%  being the placement of the piece that is the optimal play, for piece 1.
%  The second and third layer, are the same, using piece 2 and 3,
%  respectively.
%
%


%% DEFINE POSSIBLE PIECE ORIENTATIONS & POSITIONS
%data is referenced using piece{n}
%piece1 cell array
piece1 = cell(1,8);
piece1{1} = [0 0 0; 1 0 0; 1 1 0];
piece1{2} = [0 0 0; 0 1 0; 1 1 0];
piece1{3} = [0 0 0; 1 1 0; 0 1 0];
piece1{4} = [0 0 0; 1 1 0; 1 0 0];
piece1{5} = [0 0 0; 0 1 0; 0 1 1];
piece1{6} = [0 0 0; 0 0 1; 0 1 1];
piece1{7} = [0 0 0; 0 1 1; 0 0 1];
piece1{8} = [0 0 0; 0 1 1; 0 1 0];

%piece2 cell array
piece2 = cell(1,3);
piece2{1} = [0 0 0; 0 1 1; 1 1 0];
piece2{2} = [1 0 0; 1 1 0; 0 1 0];
piece2{3} = [0 1 0; 0 1 1; 0 0 1];

%piece3 cell array
piece3 = cell(1,5);
piece3{1} = [0 0 0; 1 0 0; 1 0 0];
piece3{2} = [0 0 0; 0 1 0; 0 1 0];
piece3{3} = [0 0 0; 0 0 1; 0 0 1];
piece3{4} = [0 0 0; 0 0 0; 1 1 0];
piece3{5} = [0 0 0; 0 0 0; 0 1 1];

%piecesize cell array
piecesize = cell(1,3);
piecesize{1} = 8;
piecesize{2} = 3;
piecesize{3} = 5;


%% BUILD CELL ARRAY WITH ALL POSSIBLE BOARDS
posBoards = cell(1,513);
for i = 0:511
    binarytemp = dec2bin(i,9);
    posBoards{i+1} = reshape((num2str(binarytemp)-'0'),3,3);
end
posBoards{513} = -1;


%% init J and mu
%J(a,b) = rows that will be elliminated given that board, and that stage
J = zeros(513,N,3);
%mu(a,b,c) = the piece that will be placed, given a (the current board
%orientation, b (the stage curretly at), and depending on what peice is
%given. Layer 1 corresponds to piece 1, layer 2 to peice 2, and layer 3 to
%piece 3. 
mu = zeros(513,N,3);



waitBar = waitbar(0,'starting...');
percentage = 1/N;
completed = 0;


%% PRIMARY LOOP TO BUILD J AND MU
for stage = N-1:-1:1
    for node = 0:511
        for pieceIter = 1:3

            %find the number of diferent orientations need to check
            index = piecesize{pieceIter};

            %init temp vectors to hold orientation results
            boards = zeros(index,1);
            elliminations = zeros(index,1);
            terminal = zeros(index,1);

            %go through the possible orientations
            for orientation = 1:index
                %if piece =1
                if (pieceIter == 1)
                    %evaluate each possible orientation
                    [a,b,c] = evalBoard(dec2board(node),piece1{orientation});
                    %if terminal case
                    if (a == 100)
                        if (b == 0)
                            %put in terminal node for board
                            boards(orientation) = 512;
                        end
                    else
                        if (a==0)
                            a = [0 0 0; 0 0 0; 0 0 0];
                        end

                        %if not, put in the correct board
                        boards(orientation) = board2dec(a);
                    end
                    %count elliminations and terminal
                    elliminations(orientation) = b;
                    terminal(orientation) = c;
                end

                %if piece 2
                if (pieceIter == 2)
                    %evaluate each possible orientation
                    [a,b,c] = evalBoard(dec2board(node),piece2{orientation});
                    %if terminal case
                    if (a == 100)
                        if (b == 0)
                            %put in terminal node for board
                            boards(orientation) = 512;
                        end
                    else
                        if (a==0)
                            a = [0 0 0; 0 0 0; 0 0 0];
                        end
                        %if not, put in the correct board
                        boards(orientation) = board2dec(a);
                    end
                    %count elliminations and terminal
                    elliminations(orientation) = b;
                    terminal(orientation) = c;
                end

                %if piece 3
                if (pieceIter == 3)
                    %evaluate each possible orientation
                    [a,b,c] = evalBoard(dec2board(node),piece3{orientation});
                    %if terminal case
                    if (a == 100)
                        if (b == 0)
                            %put in terminal node for board
                            boards(orientation) = 512;
                        end
                    else
                        if (a==0)
                            a = [0 0 0; 0 0 0; 0 0 0];
                        end
                        %if not, put in the correct board
                        boards(orientation) = board2dec(a);
                    end
                    %count elliminations and terminal
                    elliminations(orientation) = b;
                    terminal(orientation) = c;
                end
            end


            %find all future row eliminations for each move
            Jtemp = zeros(index,1);
            for j = 1:index
               Jtemp(j) = P(pieceIter,1)*J(boards(j)+1,stage+1,1) + P(pieceIter,1)*J(boards(j)+1,stage+1,2) + P(pieceIter,1)*J(boards(j)+1,stage+1,3) + elliminations(j);
            end


            %find best orientation for the given piece and board
            [mostRows, bestOrientation] = max(Jtemp);


            %put in J
            J(node+1,stage,pieceIter) = mostRows;


            %put in mu choice at stage
            if (pieceIter == 1)
               mu(node+1,stage,1) = board2dec(piece1{bestOrientation}); 
            end
            if (pieceIter == 2)
               mu(node+1,stage,2) = board2dec(piece2{bestOrientation}); 
            end
            if (pieceIter == 3)
               mu(node+1,stage,3) = board2dec(piece3{bestOrientation}); 
            end
        end
    end
    
    completed = completed + percentage;
    waitbar(completed,waitBar,'calculating...');
    
end

waitbar(1,waitBar,'done');
close(waitBar);


%% SET ROWS
rows = (1/3)*J(1,1,1) + (1/3)*J(1,1,2) + (1/3)*J(1,1,3);
%rows = [J(1,1,1); J(1,1,2); J(1,1,3)];
    
%% COMMENTS/TODO

%% ALL BELOW IS DONE (JUST KEEPING FOR DOCUMENTATION)
%TODO:
%- figure out possible board states perhpas in some sort of lookup
%  table?
%       *use dec2bin for 1 to 512 possible stages, and manually do 513
%       *create vector from bin number by doing: 
%           *v = num2str(bin#)-'0'
%       *this can then be turned into a matrix by using reshape(v,3,3)
%       *CAN DO OPPOSITE DIRECTION TO FIND CURRENT STAGE!
%           *reshape -> num2str() -> bin2dec()
%- figure out how to think about J and mu matricies
%- calculating for each piece, and each rotation?
%       *for rotating pieces, use transpose and (:,end:-1:1)!
%
%% INCREASED SPEED FROM 2 SEC PER PIECE TO 1 SEC TO PIECE
%NEW TODO:
%- optimizing for speed
%       *preallocating matricies rather than concatenating <--- start here!
%       *attempt to restructure for less for loops
%

end



%% HELPER FUNCTIONS

%generates the matrix for a given decimal number
function [matrix] = dec2board(number)
    bintemp = dec2bin(number,9);
    matrix = reshape((num2str(bintemp)-'0'),3,3);
end


%generates the decimal number for a given board
function [number] = board2dec(board)
    v = reshape(board,1,9);
    number = bin2dec(num2str(v));
end


%evaluate the board for a given piece. return if it gets to the
%terminal or not, the new board for that decision, and the reward
function [newBoard, reward, terminal] = evalBoard(current, piece)

%put on 2 zero rows on top of option
a = zeros(5,3);
a(3:5,:) = piece;

%put 2 rows of zeros on current board
b = zeros(5,3);
b(3:5,:) = current;

%move piece up as high as possible
while (sum(a(1,:)) == 0)
    a = circshift(a,-1);
end

%add them together
temp = a + b;

%while there is no overlap
while ((ismember(2,temp) == 0))
    %check elimination
    %[newBoard, reward] = rowElim(temp);
    %shift piece down 1
    a = circshift(a,1);
    %if reached bottom, break
    if (sum(a(1,:)) ~= 0)
        break
    end
    %add piece and board
    temp = a + b;
end

%if there is residual overlap from above, move up 1
if (ismember(2,temp) == 1)
    a = circshift(a,-1);
    temp = a + b;
end

%elliminate rows
[newBoard, reward] = rowElim(temp);

%check if terminal
if((sum(newBoard(1,:)) ~= 0) || (sum(newBoard(2,:)) ~= 0) || ismember(2,temp) == 1)
    newBoard = 100;
    reward = 0;
    terminal = 1;
    return
end

%return stuff
newBoard = newBoard(3:5,:);
terminal = 0;

end



%this function checks if rows need to be eliminated
%and performs the ellimination if needed
function [ newB, ellim ] = rowElim(board)
%set new board
newB = board;

%elimination counter
ellim = 0;

%split into rows
row1 = board(1,:);
row2 = board(2,:);
row3 = board(3,:);
row4 = board(4,:);
row5 = board(5,:);

%if top row is elliminated
if (sum(row3) >= 3)
    %set top row to 0's
    newB(3,:) = row2;
    newB(2,:) = row1;
    newB(1,:) = 0;
    row3 = row2;
    row2 = row1;
    row1 = 0;
    %increment counter
    ellim = ellim +1;
end

%if middle row is elliminated
if (sum(row4) >= 3)
    %move down top row, and set top to 0's
    newB(4,:) = row3;
    newB(3,:) = row2;
    newB(2,:) = row1;
    newB(1,:) = 0;
    row4 = row3;
    row3 = row2;
    row2 = row1;
    row1 = 0;
    %increment counter
    ellim = ellim +1;
end

%if bottom row is elliminated
if (sum(row5) >= 3)
    %move down middle and top rows, set top to 0's
    newB(5,:) = row4;
    newB(4,:) = row3;
    newB(3,:) = row2;
    newB(2,:) = row1;
    newB(1,:) = 0;
    row5 = row4;
    row4 = row3;
    row3 = row2;
    row2 = row1;
    row1 = 0;
    %increment counter
    ellim = ellim +1;
end

end


