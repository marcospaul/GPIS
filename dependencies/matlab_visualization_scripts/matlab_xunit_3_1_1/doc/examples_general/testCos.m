function test_suite = testCos
% Copyright 2013 The MathWorks, Inc.

initTestSuite;

function testTooManyInputs
assertExceptionThrown(@() cos(1, 2), 'MATLAB:maxrhs');
