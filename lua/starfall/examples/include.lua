--@name Include
--@author INP
--@include included.txt

local value = require("included.txt") -- Note the include above
printHelloWorld() -- Call global function from included file
print(value) -- Print returned value
