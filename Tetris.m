function [rowsel avs] = Tetris(numTests, numStages)
rowsel = zeros(1,numTests);
avs = zeros(1,numTests);
    
%% TetrisSim.m - Tetris Simulator
% J.Aho 10/16/11
% modified for Discrete Math course, Holly Borowski 10/28/13

%%
clc, close all
clearvars -except rowsel avs numTests numStages i
format compact
beep off


%% -----Students: edit this section to test your code:-----%%
NumFunc=11; % A vector of function #'s to run through
% If you are student 2, set to 2 
% Your functions should be named: tetris_policy_SN and tetris_play_SN
% where SN is your student number

%transition matrix for tetris pieces. Pij is the probability that the next
%piece will be j if the current piece is i.
P = 1/3*ones(3,3);
%P = [0 1 0; 0 0 1; 1 0 0];
%P = [0 .5 .5; .5 0 .5; .5 .5 0];

N = numStages; %total number of boards in the game (number of pieces will be N-1.)
%modify to test different game lengths with your doce

%set the start piece here. 
%startPiece = 1;
%to choose start piec randomly, uncomment below:
startPiece = randi(3);

% A few parameters you can modify if you wish.
S_Plot=0;  % Switch to Perform plotting, 1=yes
S_Sounds=0; % Switch, 1=sounds on, 0=sounds off
TimeDelay=.01; %Time delay of dropping piece (lower number=faster, only used when S_Plot=1)

%% ------------End of section for students to edit------------%

%% Initialize and Setup Game

% Total Gameboard Size  - 3 x 3 with extra rows to allow pieces to fit when
% it goes over the line
GameSize = [6,3]; 
RowCap = 3; 

% Define the game pieces
Pieces{1} = [0 1; 1 1];
Pieces{2} = [0 1 1; 1 1 0];
Pieces{3} = ones(2,1);

numRots = [3 1 1]; %number of times each piece can be rotated

% Set piece colors
 Pcolor=1:length(Pieces);

%initialize s

%% Execute Game
for NF=1:length(NumFunc);
    Fnum=NumFunc(NF); %Function Number (AKA Student Number)
    
    CurPnum = startPiece;
    
    %Generate strings for the function calls
    tetrisPolicyFcn= str2func(['tetris_policy_',num2str(Fnum)]); %student's policy function
    tetrisPlayFcn = str2func(['tetris_play_',num2str(Fnum)]);    %student's play function

    [J,mu,rows] = feval(tetrisPolicyFcn,N,P);
for tit = 1:numTests
    tit
    close all
    board=zeros(GameSize);

    if S_Plot==1
        figure
    end
    GameOver=0;
    Score=0;
    n=0;
    stoploop=0;
    for numPlays = 1:N
        n=n+1;
        if GameOver==0
            
            pr = rand;
            Probs = cumsum(P(CurPnum,:));
            for t = 1:length(Probs)
                if pr <= Probs(t)
                    break
                end
            end
            CurPnum = t;

            %% HERE IS WHERE YOU WILL CALL YOUR GAME PLAY FUNCTION

            boardLower = board(GameSize-RowCap+1:end,:); %this is the portion of the game board that is under the red line
            boardLower = boardLower>0;
            decision = feval(tetrisPlayFcn,boardLower,CurPnum,n,mu);

            cols = find(sum(decision)>0);
            rows = find(sum(decision,2)>0);
            CurPlace = cols(1);
            CurPiece = decision(rows,cols);
            cp = Pieces{CurPnum};

            %% check to see if your decision is valid
            valid = 0;
            for j = 0:numRots(CurPnum)
                testMatrix = rot90(cp,j);
                if (size(testMatrix)==size(CurPiece))
                    test = sum(sum(testMatrix~=CurPiece));
                    if ~test
                        valid = 1;
                        break;
                    end
                end
            end

            if valid==0
                error('Invalid decision!')
            end

            CurPiece = CurPiece*Pcolor(CurPnum);

            [CPr,CPc]=size(CurPiece);

            if CurPlace+CPc-1>GameSize(2)
                warning('WARNING: Your piece is off the gameboard!')
            end

            overlap=0;
            GameBoard1=board;
            count=0;
            while overlap==0
                count=count+1;

                if count+CPr-2==GameSize(1)
                    overlap=1;
                    board=GameBoard1;
                elseif max(max((board(count:count+CPr-1,CurPlace:CurPlace+CPc-1)>0)+(CurPiece>0)))>1
                    overlap=1;
                    board=GameBoard1;
                else
                    GameBoard1=board;
                    GameBoard1(count:count+CPr-1,CurPlace:CurPlace+CPc-1)=board(count:count+CPr-1,CurPlace:CurPlace+CPc-1)+CurPiece;
                    %break;
                end

                if S_Plot==1

                    [r,c] = size(GameBoard1);                           %# Get the matrix size
                    imagesc((1:c)+0.5,(1:r)+0.5,GameBoard1,[0,max(Pcolor)]);            %# Plot the image
                    axis equal                                   %# Make axes grid sizes equal
                    set(gca,'XTick',1:c+1,'YTick',1:r+1,...  %# Change some axes properties
                        'XLim',[1 c+1],'YLim',[1 r+1],...
                        'XTickLabel',0:c,'YTickLabel',0:r,...
                        'GridLineStyle','-','XGrid','on','YGrid','on');
                    hold on
                    plot([0,r],[r-RowCap+1,r-RowCap+1],'r', 'LineWidth',3)
                    title(['Score=',num2str(Score), ', N=', num2str(n-1)])
                    hold off
                    pause(TimeDelay);
                end
            end

            S=sum(board>0,2)==GameSize(2);

            board(S==1,:)=[];
            Score=Score+sum(S);
            board=[zeros(sum(S),GameSize(2));board];
            if sum(S)>0 && S_Sounds==1
                beep
            end

            if sum(sum(board(1:GameSize(1)-RowCap,:)))>0 || numPlays == N
                GameOver=1;
                if  S_Plot==1
                    title(['GAME OVER, Score=',num2str(Score) ,' , Pieces=', num2str(n-1)])
                    disp(['GAME OVER, Score=',num2str(Score) ,' , Pieces=', num2str(n-1)])
                end
                if S_Sounds==1, load gong.mat; sound(y,1*Fs);  end
            end
        end
        if GameOver==1,stoploop=1;  end
    end

    Iscore(NF)=Score; % Store the scores
    %rowsen = Score + rowsen;
    fprintf('Score = %i\n',Score)
    rowsel(tit) = Score;
    avs(tit) = sum(rowsel)/tit;   
end
end

disp('Thank you for playing!')




