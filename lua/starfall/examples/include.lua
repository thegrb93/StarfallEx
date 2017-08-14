--@name Include
--@author INP
--@include examples/processor/lib/included.txt

local value = require("examples/processor/lib/included.txt") -- Note the include above
printHelloWorld() -- Call global function from included file
print(value) -- Print returned value
