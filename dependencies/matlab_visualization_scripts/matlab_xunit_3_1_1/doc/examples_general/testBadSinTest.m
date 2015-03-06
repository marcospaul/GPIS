function test_suite = testBadSinTest
% Copyright 2013 The MathWorks, Inc.

initTestSuite;

function testSinPi
% Example of a failing test case.  The test writer should have used
% assertAlmostEqual here.
assertEqual(sin(pi), 0);
