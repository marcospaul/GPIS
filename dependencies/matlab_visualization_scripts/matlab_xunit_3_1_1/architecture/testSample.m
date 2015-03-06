function test_suite = testSample
% Copyright 2013 The MathWorks, Inc.
initTestSuite;

function testMyCode
assertEqual(1, 1);
assertElementsAlmostEqual(1, 1.1);
assertTrue(10 == 10);
