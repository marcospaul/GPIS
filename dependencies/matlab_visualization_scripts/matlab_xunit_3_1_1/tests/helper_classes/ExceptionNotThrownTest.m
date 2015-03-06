classdef ExceptionNotThrownTest < TestCase
% Copyright 2013 The MathWorks, Inc.
   methods
      function self = ExceptionNotThrownTest(methodName)
         self = self@TestCase(methodName);
      end
      
      function testThrowsException(self)
         f = @() [];
         assertExceptionThrown(f, 'a:b:c');
      end
   end
end
