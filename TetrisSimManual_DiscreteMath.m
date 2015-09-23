%% TetrisSim.m - Tetris Simulator plus Manual Mode
% J.Aho 9/23/11
% Pushpak Jha 9/27/11

% This tetris simulator generates a sequence for the pieces, generates the
% pieces, and will place and rotate the pieces according to either a
% prescribed sequence of actions (Like from HW2) or from placement commands
% from a function call that is done iteratively for each piece.

% The game is cusomizable.  The following may be sepecified by the user:
% -Size of the game board
% -Row at which a game over condition occurs
% -Pieces (shape and size)

% The piece commands are as follows:

% C_Rot=# of clockwise Rotations to apply to piece
% C_Place= Index of leftmost column that piece occupies (after rotating)
% C_Shft=Shift vector:
%           Row1=# of spaces to shift (negative is left, pos is right)
%           Row2=Line number to shift at (See demo for example)
% NOTE: Pieces are trimmed so any row/column of zeros is removed

%For manual mode, set S_RunMode = 2;
%Left/Right arrows keys move blocks, up arrow key rotates, hit down arrow key
%after you're sure of your placement/rotation, and it will move the piece
%down, eliminate rows and then spawn another piece.
%NOTE: If you move a piece all the way to the right, then try to rotate it,
%if that rotation causes the piece to have more columns (a greater "width")
%the program will error saying you're off the game board. So do rotations
%when the piece spawns and is on the left, then move it to the correct
%place.

function TetrisSimManual_DiscreteMath %Need to be a function so arrow keys can be used.

%%
clear all
close all
clc
format compact
beep on

%% Initialize and Setup Game

S_Plot=1;  % Switch to Perform plotting, 1=yes
S_Shift=0; % Switch to Allow Shifting,   1=yes
S_Sounds=1; % Switch, 1=sounds on, 0=sounds off

S_RunMode=2;  % Sets mode of operation
% 0=open loop (prescribed), 1=closed loop (function call for actions)
%2 = manual mode, play with arrow keys


% Total Gameboard Size (should leave enough room above RowCap for pieces to
GameSize=[6,3];% appear (Set to [6,3] for HW 2 Problem)
RowCap=3; % The Game over line (use 3 for HW 2)

Pij = [1/3 1/3 1/3; 1/3 1/3 1/3; 1/3 1/3 1/3]; %Probability matrix Pij
%Pij = [0 1 0; 0 0 1; 1 0 0]; %Deterministic case

%% Make Pieces (NOTE: 'Pieces' is a cell array)
Psize=[3,3];
Ptemp=zeros(Psize);

Piece{1}=Ptemp;  % Piece 1 from HW 2
Piece{1}(2,1)=1;
Piece{1}(1,2)=1;
Piece{1}(2,2)=1;

Piece{2}=Ptemp; % Piece 2 from HW 2
Piece{2}(2,1:2)=[1,1];
Piece{2}(1,2:3)=[1,1];

Piece{3}=Ptemp; % Piece 3 from HW 2
Piece{3}(1:2,2)=[1;1];

% Piece{4}=Ptemp; % Example test piece (single block)
% Piece{4}(1,1)=1;

% Altermatively you may load pieces from a saved .mat file

PieceOrder = [];

%% Set piece color and trim.
Pcolor=1:length(Piece);
for n=1:length(Piece)
    Piece{n}=Piece{n}*Pcolor(n);
end

Piece_u=Piece; %This saves an untrimmed version of the pieces

for n=1:length(Piece) % Trim pieces (inefficient, but it works)
    dc=0;
    r_del=[];
    for r=1:Psize(1)
        if sum(Piece{n}(r,:))==0
            dc=dc+1;
            r_del(dc)=r;
        end
    end
    dc=0;
    c_del=[];
    for c=1:Psize(2)
        if sum(Piece{n}(:,c))==0
            dc=dc+1;
            c_del(dc)=c;
        end
    end
    Piece{n}(r_del,:)=[];
    Piece{n}(:,c_del)=[];
end

%% Specify Open Loop Actions

if S_RunMode==0
    
    fprintf('Open loop mode!\n');
    % Here is some prescribed actions for an example
    % Note, this is certainly not optimized
    PieceOrder = [2,1,3,1,2,2,2,2,2,1,3,2,3,2,1,3,2,2,1,2,1,3];
    C_Place    = [1,4,3,4,2,1,3,1,3,4,3,1,5,4,3,1,1,3,1,2,4,1];
    C_Rot      = [0,0,2,0,0,1,0,3,0,0,1,1,0,1,3,0,0,0,2,0,3,0];
    C_Shft(1,:)= [0,-1,2,0,1,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    C_Shft(2,:)= [0,1,4,0,2,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    
    % % Example of loading data in from a .mat file (produced by solver)
    % load('TetInput3.mat')
    % PieceOrder=TPath(:,1); ...etc
    
end

%% Execute Game

GameBoard=zeros(GameSize);

if S_Plot==1
    figure('KeyPressFcn',@keyPress)   
end
GameOver=0;
Score=0;
DATA=[];
n=0;
stoploop=0;
while stoploop==0
    n=n+1;
    if GameOver==0
        
        % EXAMPLE FUNCTION CALL
        % [C_Place,C_Rot,C_Shft]=Tet_DP(Piece,GameSize, RowCap, PieceOrder)
        
        if S_RunMode==0
            CurPnum=PieceOrder(n);
            CurPlace=C_Place(n);
            CurRot=C_Rot(n);
            CurShift=C_Shft(:,n);
        elseif S_RunMode==1
            %% CLOSED LOOP ACTIONS
            %% HERE IS WHERE YOU WILL CALL YOUR FUNCTION 
            %Here is just dummy variables for running
            CurPnum=ceil(length(Piece)*rand);
            CurPlace=1;
            CurRot=1;
            CurShift=[0,0];
            fprintf('Closed loop mode!\n');
            
            %Put function call here
            %[CurRot,CurPlace,CurShft,DATA]=TetPlaceFcn(CurPnum, Piece, GameBoard, GameSize, RowCap, n, DATA)
            % NOTE: DATA is any matrix, cell array or structure of data
            % that you want to keep about past values
            
            PieceOrder(n)=CurPnum;
            PieceOrder(n+1)=0;
        end
        
        %%Manual Mode%%
        if S_RunMode == 2
            placePiece = 0; %Controls moving on through the loop, stays 0 till user hits down arrow
            CurPnum=1; %Starting piece number
            CurPlace=1;
            CurRot=0;
            CurShift=[0,0];
            if length(PieceOrder) > 1 %After first piece, spawn new pieces accoring to Pij matrix
                randNum = rand;
                if randNum < Pij(PieceOrder(n-1),1)
                    CurPnum = 1;
                elseif randNum > Pij(PieceOrder(n-1),1) && randNum < (Pij(PieceOrder(n-1),1)+Pij(PieceOrder(n-1),2))
                    CurPnum = 2;
                elseif randNum > (Pij(PieceOrder(n-1),1)+Pij(PieceOrder(n-1),2))
                    CurPnum = 3;
                end
            end
                
            PieceOrder(n)=CurPnum; %Variables that need to be defined
            PieceOrder(n+1)=0;
            count = 1;

                
            while placePiece == 0
                            CurPiece=Piece{CurPnum}; %Load Current Piece
            CurPiece=rot90(CurPiece,CurRot);% Rotate Current Piece
            [CPr,CPc]=size(CurPiece);
            
           if S_Shift==1&& abs(CurShift(1))>0 && GameSize(1)-count+CPr-2+1==CurShift(2)
                    %S_Shift is always off
                
            elseif count+CPr-2==GameSize(1)
                overlap=1;
                GameBoard=GameBoard1;
            elseif max(max((GameBoard(count:count+CPr-1,CurPlace:CurPlace+CPc-1)>0)+(CurPiece>0)))>1
                overlap=1;
                GameBoard=GameBoard1;
            else
                GameBoard1=GameBoard;
                GameBoard1(count:count+CPr-1,CurPlace:CurPlace+CPc-1)=GameBoard(count:count+CPr-1,CurPlace:CurPlace+CPc-1)+CurPiece;
           end
            
                [r,c] = size(GameBoard1);                           %# Get the matrix size
                imagesc((1:c)+0.5,(1:r)+0.5,GameBoard1,[0,max(Pcolor)]);            %# Plot the image
                %colormap(gray);                              %# Use a gray colormap
                axis equal                                   %# Make axes grid sizes equal
                set(gca,'XTick',1:c+1,'YTick',1:r+1,...  %# Change some axes properties
                    'XLim',[1 c+1],'YLim',[1 r+1],...
                    'XTickLabel',0:c,'YTickLabel',0:r,...
                    'GridLineStyle','-','XGrid','on','YGrid','on');
                hold on
                plot([0,r],[r-RowCap+1,r-RowCap+1],'r', 'LineWidth',3)
                title(['Score=',num2str(Score), ', N=', num2str(n-1)])
                hold off
                pause(.1)
            end
                

        end %End of manual mode loop
        %%
        %%Moving pieces down/eliminating rows
    

        
        
        %C_Shft(2,:)=C_Shft(2,:)-1; % I messed up the indexes, this way you can prescribe index starting at 1 rather than 0, as used below
        
        CurPiece=Piece{CurPnum}; %Load Current Piece
        CurPiece=rot90(CurPiece,CurRot);% Rotate Current Piece
        [CPr,CPc]=size(CurPiece);
        
        
        if CurPlace+CPc-1>GameSize(2)
            warning('WARNING: Your piece is off the gameboard!')
        end
        
        if S_Shift==1&&(CurPlace+CPc-1+CurShift(1)>GameSize(2)||CurPlace+CurShift(1)<0)
            warning('WARNING: Your piece will be shifted off the gameboard!')
        end
        
        overlap=0;
        GameBoard1=GameBoard;
        count=0;
        while overlap==0
            count=count+1;
            
            if S_Shift==1&& abs(CurShift(1))>0 && GameSize(1)-count+CPr-2+1==CurShift(2)
                count=count-1; %Stop dropping
                sgn=sign(CurShift(1));
                for s=1:abs(CurShift(1));
                    C_P=CurPlace+sgn;
                    if C_P+CPc-1>GameSize(2)||C_P<1
                        warning('WARNING: Your piece cannot be shifted as far as specified. Out of bounds occurred.')
                    elseif max(max((GameBoard(count:count+CPr-1,C_P:C_P+CPc-1)>0)+(CurPiece>0)))>1
                        warning('WARNING: Your piece cannot be shifted as far as specified. Overlap occurred.')
                    else
                        CurPlace=C_P;
                        GameBoard1=GameBoard;
                       % GameBoard1(end-count-CPr+2:end-count+1,CurPlace:CurPlace+CPc-1)=GameBoard(end-count-CPr+2:end-count+1,CurPlace:CurPlace+CPc-1)+CurPiece;
                        GameBoard1(count:count+CPr-1,CurPlace:CurPlace+CPc-1)=GameBoard(count:count+CPr-1,CurPlace:CurPlace+CPc-1)+CurPiece;

                    end
                end
                CurShift(1)=0;
                
            elseif count+CPr-2==GameSize(1)
                overlap=1;
                GameBoard=GameBoard1;
            elseif max(max((GameBoard(count:count+CPr-1,CurPlace:CurPlace+CPc-1)>0)+(CurPiece>0)))>1
                overlap=1;
                GameBoard=GameBoard1;
            else
                GameBoard1=GameBoard;
                GameBoard1(count:count+CPr-1,CurPlace:CurPlace+CPc-1)=GameBoard(count:count+CPr-1,CurPlace:CurPlace+CPc-1)+CurPiece;
            end
            
            
            
            if S_Plot==1
                
                if S_RunMode==0, subplot(2,2,[1,3]), end
                
                [r,c] = size(GameBoard1);                           %# Get the matrix size
                imagesc((1:c)+0.5,(1:r)+0.5,GameBoard1,[0,max(Pcolor)]);            %# Plot the image
                %colormap(gray);                              %# Use a gray colormap
                axis equal                                   %# Make axes grid sizes equal
                set(gca,'XTick',1:c+1,'YTick',1:r+1,...  %# Change some axes properties
                    'XLim',[1 c+1],'YLim',[1 r+1],...
                    'XTickLabel',0:c,'YTickLabel',0:r,...
                    'GridLineStyle','-','XGrid','on','YGrid','on');
                hold on
                plot([0,r],[r-RowCap+1,r-RowCap+1],'r', 'LineWidth',3)
                title(['Score=',num2str(Score), ', N=', num2str(n-1)])
                hold off
                
                if S_RunMode==0
                    subplot(2,2,2)
                    
                    if n<length(PieceOrder)
                        mat=Piece_u{PieceOrder(n+1)};
                    else
                        mat=Ptemp;
                    end
                    
                    [r,c] = size(mat);
                    imagesc((1:c)+0.5,(1:r)+0.5,mat,[0,max(Pcolor)]);            %# Plot the image
                    %colormap(gray);                              %# Use a gray colormap
                    axis equal                                   %# Make axes grid sizes equal
                    set(gca,'XTick',1:c+1,'YTick',1:r+1,...  %# Change some axes properties
                        'XLim',[1 c+1],'YLim',[1 r+1],...
                        'XTickLabel',0:c,'YTickLabel',0:r,...
                        'GridLineStyle','-','XGrid','on','YGrid','on');
                    title('Next Piece')
                    subplot(2,2,4)
                    if n<length(PieceOrder)
                        pie([n,length(PieceOrder)-n])
                    else
                        pie(n)
                    end
                    title('Progress Through Queue')
                end
                pause(.1);
            end
        end
        
        S=sum(GameBoard>0,2)==GameSize(2);
        
        GameBoard(S==1,:)=[];
        Score=Score+sum(S);
        GameBoard=[zeros(sum(S),GameSize(2));GameBoard];
        if sum(S)>0 && S_Sounds==1
            beep
        end
        
        if sum(sum(GameBoard(1:GameSize(1)-RowCap,:)))>0
            GameOver=1;
            if S_RunMode==0, subplot(3,2,[1,3,5]), end
            title(['GAME OVER, Score=',num2str(Score) ,' , Pieces=', num2str(n-1)])
            disp(['GAME OVER, Score=',num2str(Score) ,' , Pieces=', num2str(n-1)])
            if S_Sounds==1, gongStruct = load('gong.mat'); sound(gongStruct.y, 1*gongStruct.Fs);  end
        end
    end
    if n== length(PieceOrder) || GameOver==1
        stoploop=1;
    end
end


if GameOver==0&& S_RunMode==0
    disp('Congrats!  You crushed this game and placed all the pieces in the queue!')
    disp(['Score=',num2str(Score) ,' , Pieces=', num2str(n-1)])
    
    subplot(2,2,[1,3])
    
    [r,c] = size(GameBoard);                           %# Get the matrix size
    imagesc((1:c)+0.5,(1:r)+0.5,GameBoard,[0,max(Pcolor)]);            %# Plot the image
    
    %colormap(gray);                              % Can use a different colormap
    axis equal                                   %# Make axes grid sizes equal
    set(gca,'XTick',1:c+1,'YTick',1:r+1,...  %# Change some axes properties
        'XLim',[1 c+1],'YLim',[1 r+1],...
        'XTickLabel',0:c,'YTickLabel',0:r,...
        'GridLineStyle','-','XGrid','on','YGrid','on')
    hold on
    plot([0,r],[RowCap+1,RowCap+1],'r', 'LineWidth',3)
    title(['Score=',num2str(Score), ', N=', num2str(n-1)])
    hold off
    
    
    if S_Sounds==1, load handel.mat;  sound(y, Fs); end
    
end
disp('Thank you for playing!')

%%
%Controls the key pressing functions

        %These have to be defined outside of any loops, and within an
        %overall function.
        function keyPress(src,event)
                cur_ch = sprintf('%c',event.Key);
                switch cur_ch
                case 'leftarrow'
                    if S_RunMode==2
                  CurPlace=CurPlace-1;
                  if CurPlace == 0 %Corrects if piece is moved too far left
                      CurPlace = 1;
                  end
                    end
                case 'rightarrow'
                    if S_RunMode==2
                   CurPlace=CurPlace+1;
                   [tr,tc] = size(CurPiece);
                   [gr,gc] = size(GameBoard);
                   if CurPlace > (gc-tc+1) %Corrects if piece is moved too far right
                       CurPlace = (gc-tc+1);
                   end
                    end
                case 'uparrow'
                    if S_RunMode==2
                   CurRot = CurRot+1;
                    end
                case 'downarrow'
                    placePiece = 1;
                end 
       
        end
        

end %End of overall tetris simulator function
