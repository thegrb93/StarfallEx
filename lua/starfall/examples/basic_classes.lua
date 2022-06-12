--@name Basic Classes Example
--@author Vurv
--@shared

-- This is more of a generic example for middleclass / classes in StarfallEx
-- If you want to see classes in action, see other examples like the fireplace and tcpclient examples

local Student = class("Student")

-- This is the function that will be called on Class:new(...)
-- Aka the 'constructor'
function Student:initialize(name, school)
    self.name = name
    self.school = school
end

function Student:work()
    print(self.name .. " is doing some work")
end

-- Make a class that derives from Student
local CollegeStudent = class("CollegeStudent", Student)

-- This overrides Student's initialize so that won't be called alongside this.
function CollegeStudent:initialize(name, school, procrastinating)
    self.name = name
    self.school = school
    self.procrastinating = false
end

-- Add a function specifically to the CollegeStudent subclass
function CollegeStudent:procrastinate()
    print(self.name .. " is procrastinating")
    self.procrastinating = true
end

--- Now to use these classes we just made

local Jim = Student:new("Jim", "Cool School")

local Bob = CollegeStudent:new("Bob", "Cooler School")

Jim:work()
Bob:work() -- CollegeStudent is a subclass so it inherits all of the methods of Student

Bob:procrastinate()

print(Jim.procrastinating) -- 'Student' class does not have a procrastinating field, so this will be nil
print(Bob.procrastinating)