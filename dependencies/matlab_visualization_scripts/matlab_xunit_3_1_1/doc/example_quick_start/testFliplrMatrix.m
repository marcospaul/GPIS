function testFliplrMatrix
%testFliplrMatrix Unit test for fliplr with matrix input
%
% Copyright 2013 The MathWorks, Inc.

in = magic(3);
assertEqual(fliplr(in), in(:, [3 2 1]));
