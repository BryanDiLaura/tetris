function [matrix] = dec2board(number)
    bintemp = dec2bin(number,9);
    matrix = reshape((num2str(bintemp)-'0'),3,3);
end