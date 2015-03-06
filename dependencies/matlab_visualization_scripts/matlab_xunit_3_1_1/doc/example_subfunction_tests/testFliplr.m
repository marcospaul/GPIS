function test_suite = testFliplr
% Copyright 2013 The MathWorks, Inc.

initTestSuite;

function testFliplrMatrix
in = magic(3);
assertEqual(fliplr(in), in(:, [3 2 1]));

function testFliplrVector
assertEqual(fliplr([1 4 10]), [10 4 1]);

