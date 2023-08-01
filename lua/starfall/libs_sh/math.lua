
local checkluatype = SF.CheckLuaType

--- Lua math library https://wiki.garrysmod.com/page/Category:math
-- @name math
-- @class library
-- @field huge inf error-float. Represents infinity.
-- @field pi mathematical constant pi (3.1415926535898).
-- @libtbl math_library
SF.RegisterLibrary("math")

return function(instance)

local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap

local math_library = instance.Libraries.math

--- Calculates the absolute value of a number (effectively removes any negative sign).
-- @class function
-- @param number x The number to get the absolute value of
-- @return number Absolute value
math_library.abs = math.abs

--- Calculates the sign of a number
-- @class function
-- @param number x The number to get the sign of
-- @return number -1 if negative, 1 if positive, 0 if 0
function math_library.sign(x)
	return (x<0 and -1) or (x>0 and 1) or 0
end

--- Calculates an angle in radians, between 0 and pi, which has the given cos value.
-- @class function
-- @param number cos Cosine value in range of -1 to 1
-- @return number Angle in radians or nothing if the argument is out of range
math_library.acos = math.acos

--- Calculates the difference between two angles.
-- @class function
-- @param number a The first angle
-- @param number b The second angle
-- @return number The difference between the angles between -180 and 180
math_library.angleDifference = math.AngleDifference

--- Gradually approaches the target value by the specified amount.
-- @class function
-- @param number current The value we're currently at
-- @param number target The target value. This function will never overshoot this value
-- @param number change The amount that the current value is allowed to change by to approach the target (positive or negative)
-- @return number New current value, closer to the target than it was previously
math_library.approach = math.Approach

--- Increments an angle towards another by specified rate.
-- @class function
-- @param number currentAngle The current angle to increase
-- @param number targetAngle The angle to increase towards
-- @param number rate The amount to approach the target angle by
-- @return number Modified angle
math_library.approachAngle = math.ApproachAngle

--- Calculates an angle in radians, in the range -pi/2 to pi/2, which has the given sine value.
-- @class function
-- @param number sin Sine value in the range of -1 to 1
-- @return number Angle in radians or nothing if the argument is out of range
math_library.asin = math.asin

--- Calculates an angle in radians, in the range -pi/2 to pi/2, which has the given tangent.
-- @class function
-- @param number tan Tangent value
-- @return number Angle in radians
math_library.atan = math.atan

--- Functions like math.atan(y / x), except it also takes into account the quadrant of the angle and so doesn't have a limited range of output.
-- @class function
-- @param number y The Y coordinate
-- @param number x The X coordinate
-- @return number Angle of the line from (0, 0) to (x, y) in radians, in the range -pi to pi
math_library.atan2 = math.atan2

--- Converts a binary string into a number.
-- @class function
-- @param string str Binary string to convert
-- @return number Base 10 number
math_library.binToInt = math.BinToInt

--- Basic code for Bezier-Spline algorithm.
-- @class function
-- @param number i
-- @param number k
-- @param number t
-- @param number tinc
-- @return number Number value
math_library.calcBSplineN = math.calcBSplineN

--- Rounds a number up.
-- @class function
-- @param number n Number to be rounded
-- @return number Rounded number
math_library.ceil = math.ceil

--- Clamps a number between a minimum and maximum value.
-- @class function
-- @param number current Input number
-- @param number min Minimum value
-- @param number max Maximum value
-- @return number Clamped number
math_library.clamp = math.Clamp

--- Calculates cosine of the given angle.
-- @class function
-- @param number angle Angle in radians
-- @return number Cosine of the angle
math_library.cos = math.cos

--- Calculates hyperbolic cosine of the given angle.
-- @class function
-- @param number angle Angle in radians
-- @return number The hyperbolic cosine of the angle
math_library.cosh = math.cosh

--- Converts radians to degrees
-- @class function
-- @param number rad Angle in radians to be converted
-- @return number Angle in degrees
math_library.deg = math.deg

--- Calculates the difference between two points in 2D space
-- @class function
-- @param number x1 X position of first point
-- @param number y1 Y position of first point
-- @param number x2 X position of second point
-- @param number y2 Y position of second point
-- @return number Distance between the two points
math_library.distance = math.Distance

--- Calculates the progress of a value fraction, taking in to account given easing fractions.
-- @class function
-- @param number progress Fraction of the progress to ease
-- @param number easeIn Fraction of how much easing to begin with
-- @param number easeOut Fraction of how much easing to end with
-- @return number Eased value
math_library.easeInOut = math.EaseInOut

--- Returns the x power of the Euler constant.
-- @class function
-- @param number x The exponent of the function
-- @return number e to the specific power
math_library.exp = math.exp

--- Rounds a number down.
-- @class function
-- @param number n Number to be rounded
-- @return number Rounded number
math_library.floor = math.floor

--- Calculates the modulus of the specified values.
-- @class function
-- @param number base The base value
-- @param number mod The modulator
-- @return number The calculated modulus
math_library.fmod = math.fmod

--- Used to split the number value into a normalized fraction and an exponent
-- @class function
-- @param number x The value to get the normalized fraction and the exponent from
-- @return number Multiplier between 0.5 and 1
-- @return number Exponent integer
math_library.frexp = math.frexp

math_library.huge = math.huge

--- Converts an integer to a binary (base-2) string.
-- @class function
-- @param number int Number to be converted
-- @return string Binary number string. The length of this will always be a multiple of 3
math_library.intToBin = math.IntToBin

--- Takes a normalised number and returns the floating point representation.
-- @class function
-- @param number normalizedFraction The value to get the normalized fraction and the exponent from
-- @param number exponent The value to get the normalized fraction and the exponent from
-- @return number Floating point reperesentation
math_library.ldexp = math.ldexp

--- With one argument, returns the natural logarithm of x (to base e).
-- With two arguments, return the logarithm of x to the given base, calculated as log(x) / log(base).
-- @class function
-- @param number x The value to get the base from exponent from
-- @param number? base Optional logarithmic base. Default 'e'
-- @return number Logarithm of x to the given base
math_library.log = math.log

--- Returns the base-10 logarithm of x. This is usually more accurate than math.log(x, 10).
-- @class function
-- @param number x The value to get the base from exponent from
-- @return number Logarithm of x to the base 10
math_library.log10 = math.log10

--- Picks the largest value of all provided arguments.
-- @class function
-- @param ...number numbers Any amount of number values
-- @return number The largest number
math_library.max = math.max

--- Picks the smallest value of all provided arguments.
-- @class function
-- @param ...number numbers Any amount of number values
-- @return number The smallest number
math_library.min = math.Min

--- Returns the integral and fractional component of the modulo operation.
-- @class function
-- @param number base The base value
-- @return number The integral component
-- @return number The fractional component
math_library.modf = math.modf

--- Normalizes angle, so it returns value between -180 and 180.
-- @class function
-- @param number ang The angle in degrees
-- @return number The normalized angle
math_library.normalizeAngle = math.NormalizeAngle

math_library.pi = math.pi

--- Returns x raised to the power y
-- @class function
-- @param number base The Base number
-- @param number exp The Exponent
-- @return number Exponent power of base
math_library.pow = math.pow

--- Converts an angle from degrees to radians.
-- @class function
-- @param number deg Angle in degrees
-- @return number Angle in radians
math_library.rad = math.rad

--- Returns a random float between min and max.
-- @class function
-- @param number min The minimum value
-- @param number max The maximum value
-- @return number Random float between min and max
math_library.rand = math.Rand

--- When called without arguments, returns a uniform pseudo-random real number in the range 0 to 1 which includes 0 but excludes 1.
-- When called with an integer number m, returns a uniform pseudo-random integer in the range 1 to m inclusive.
-- When called with two integer numbers m and n, returns a uniform pseudo-random integer in the range m to n inclusive.
-- @class function
-- @param number? m Optional integer value. If n is not provided - upper limit; if n is provided - lower limit
-- @param number? n Optional integer value. Upper value
-- @return number Random value
math_library.random = math.random

--- Remaps the value from one range to another.
-- @class function
-- @param number value The number value
-- @param number inMin The minimum of the initial range
-- @param number inMax The maximum of the initial range
-- @param number outMin The minimum of new range
-- @param number outMax The maximum of new range
-- @return number The number in the new range
math_library.remap = math.Remap

--- Rounds the given value to the nearest whole number or to the given decimal places.
-- @class function
-- @param number value The number to be rounded
-- @param number? decimals Optional decimal places to round to. Defaults to 0
math_library.round = math.Round

--- Calculates the sine of given angle.
-- @class function
-- @param number ang Angle in radians
-- @return number Sine for given angle
math_library.sin = math.sin

--- Calculates the hyperbolic sine of the given angle.
-- @class function
-- @param number ang Angle in radians
-- @return number The hyperbolic sine of the given angle
math_library.sinh = math.sinh

--- Calculates square root of the number.
-- @class function
-- @param number value The value to get the square root of
-- @return number Square root of the provided value
math_library.sqrt = math.sqrt

--- Calculates the tangent of the given angle.
-- @class function
-- @param number ang Angle in radians
-- @return number The tangent of the given angle
math_library.tan = math.tan

--- Calculates hyperbolic tangent of the given angle.
-- @class function
-- @param number ang Angle in radians
-- @return number The hyperbolic tangent of the given angle
math_library.tanh = math.tanh

--- Calculates the fraction of where the current time is relative to the start and end times.
-- @class function
-- @param number start Start time in seconds
-- @param number end End time in seconds
-- @param number current Current time in seconds
-- @return number The time fraction
math_library.timeFraction = math.TimeFraction

--- Rounds towards zero
-- @class function
-- @param number val The number to truncate
-- @param number? digits The amount of digits to keep after the point. Default 0
-- @return number Rounded number
math_library.truncate = math.Truncate

--- Calculates B-Spline point.
-- @class function
-- @param number tDiff From 0 to tMax, where alongside the spline the point will be
-- @param number tPoints A table of Vectors. The amount cannot be less than 4
-- @param number tMax Dictates maximum value for tDiff
-- @return number Point on Bezier curve, related to tDiff
function math_library.bSplinePoint(tDiff, tPoints, tMax)
	return vwrap(math.BSplinePoint(tDiff, instance.Unsanitize(tPoints), tMax))
end

--- Performs a linear interpolation from the start number to the end number.
-- @class function
-- @param number t The fraction for finding the result. This number is clamped between 0 and 1
-- @param number from The starting number. The result will be equal to this if value t is 0
-- @param number to The ending number. The result will be equal to this if value t is 1
-- @return number The result of the linear interpolation, (1 - t) * from + t * to
function math_library.lerp(t, from, to)
	checkluatype(t, TYPE_NUMBER)
	checkluatype(from, TYPE_NUMBER)
	checkluatype(to, TYPE_NUMBER)
	return Lerp(t, from, to)
end

--- Calculates point between first and second angle using given fraction and linear interpolation.
-- @class function
-- @param number ratio Ratio of progress through values
-- @param number from Angle to begin from
-- @param number to Angle to end at
-- @return number The interpolated angle
function math_library.lerpAngle(ratio, from, to)
	checkluatype(ratio, TYPE_NUMBER)
	return awrap(LerpAngle(ratio, aunwrap(from), aunwrap(to)))
end

--- Calculates point between first and second vector using given fraction and linear interpolation.
-- @class function
-- @param number ratio Ratio of progress through values
-- @param Vector from Vector to begin from
-- @param Vector Vector to end at
-- @return Vector The interpolated vector
function math_library.lerpVector(ratio, from, to)
	checkluatype(ratio, TYPE_NUMBER)
	return vwrap(LerpVector(ratio, vunwrap(from), vunwrap(to)))
end

--- Gets the distance between a line and a point in 3d space
-- @param Vector lineStart Start of the line
-- @param Vector lineEnd End of the line
-- @param Vector pointPos Position of the point
-- @return number Distance from line
-- @return Vector Nearest point on line
-- @return number Distance along line from start
function math_library.distanceToLine(lineStart, lineEnd, pointPos)
	local nearDist, nearPoint, startDist = util.DistanceToLine(vunwrap(lineStart), vunwrap(lineEnd), vunwrap(pointPos))
	return nearDist, vwrap(nearPoint), startDist
end

--- Returns a point along a bezier curve.
-- @param number ratio Number representing how far along the curve, 0-1.
-- @param Vector start The start position of the curve.
-- @param Vector middle The middle position of the curve.
-- @param Vector end The end position of the curve.
-- @return Vector Vector representing the point along the curve.
function math_library.bezierVector(r, v1, v2, v3)
	local ri = 1-r
	local c1 = ri^2
	local c2 = 2*ri*r
	local c3 = r^2
	return setmetatable({
		c1*v1[1] + c2*v2[1] + c3*v3[1],
		c1*v1[2] + c2*v2[2] + c3*v3[2],
		c1*v1[3] + c2*v2[3] + c3*v3[3]}
	, instance.Types.Vector)
end

--- Generates a random float value that should be the same on client and server
-- @param string uniqueName The seed for the random value
-- @param number Min The minimum value of the random range
-- @param number Max The maximum value of the random range
-- @param number? additionalSeed The additional seed. Default 0
-- @return number The random float value
function math_library.sharedRandom(uniqueName, Min, Max, additionalSeed)
	checkluatype(uniqueName, TYPE_STRING)
	if additionalSeed~=nil then checkluatype(additionalSeed, TYPE_NUMBER) end
	return util.SharedRandom(uniqueName, Min, Max, additionalSeed)
end

--- Eases in by reversing the direction of the ease slightly before returning.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInBack = math.ease.InBack

--- Eases in like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInBounce = math.ease.InBounce

--- Eases in using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInCirc = math.ease.InCirc

--- Eases in by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInCubic = math.ease.InCubic

--- Eases in like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInElastic = math.ease.InElastic

--- Eases in using an exponential equation with a base of 2 and where the fraction is used in the exponent.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInExpo = math.ease.InExpo

--- Eases in and out by reversing the direction of the ease slightly before returning on both ends.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutBack = math.ease.InOutBack

--- Eases in and out like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutBounce = math.ease.InOutBounce

--- Eases in and out using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutCirc = math.ease.InOutCirc

--- Eases in and out by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutCubic = math.ease.InOutCubic

--- Eases in and out like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutElastic = math.ease.InOutElastic

--- Eases in and out using an exponential equation with a base of 2 and where the fraction is used in the exponent.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutExpo = math.ease.InOutExpo

--- Eases in and out by squaring the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutQuad = math.ease.InOutQuad

--- Eases in and out by raising the fraction to the power of 4.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutQuart = math.ease.InOutQuart
	
--- Eases in and out by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutQuint = math.ease.InOutQuint

--- Eases in and out using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInOutSine = math.ease.InOutSine

--- Eases in by squaring the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInQuad = math.ease.InQuad

--- Eases in by raising the fraction to the power of 4.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInQuart = math.ease.InQuart

--- Eases in by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInQuint = math.ease.InQuint

--- Eases in using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeInSine = math.ease.InSine

--- Eases out by reversing the direction of the ease slightly before finishing.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutBack = math.ease.OutBack

--- Eases out like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutBounce = math.ease.OutBounce

--- Eases out using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutCirc = math.ease.OutCirc

--- Eases out by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutCubic = math.ease.OutCubic

--- Eases out like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutElastic = math.ease.OutElastic

--- Eases out by raising the fraction to the power of 4.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutQuart = math.ease.OutQuart

--- Eases out by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutQuint = math.ease.OutQuint

--- Eases out using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
math_library.easeOutSine = math.ease.OutSine

end
