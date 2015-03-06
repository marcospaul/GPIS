function test_suite = testWithSetupError
% Copyright 2013 The MathWorks, Inc.
%
%Example of a test with an error.  The setup function calls cos with
%too many input arguments.

initTestSuite;

function testData = setup
testData = cos(1, 2);

function testMyFeature(testData)
assertEqual(1, 1);

function teardown(testData)
