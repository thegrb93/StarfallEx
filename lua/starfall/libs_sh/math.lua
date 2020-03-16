
local checkluatype = SF.CheckLuaType

--- Lua math library https://wiki.garrysmod.com/page/Category:math
-- @name math
-- @class library
-- @libtbl math_library
SF.RegisterLibrary("math")

return function(instance)

local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap

local math_library = instance.Libraries.math

--- Calculates the absolute value of a number (effectively removes any negative sign).
-- @class function
-- @param x The number to get the absolute value of
-- @return Absolute value
math_library.abs = math.abs

--- Calculates an angle in radians, between 0 and pi, which has the given cos value.
-- @class function
-- @param cos Cosine value in range of -1 to 1
-- @return Angle in radians or nothing if the argument is out of range
math_library.acos = math.acos

--- Calculates the difference between two angles.
-- @class function
-- @param a The first angle
-- @param b The second angle
-- @return The difference between the angles between -180 and 180
math_library.angleDifference = math.AngleDifference

--- Gradually approaches the target value by the specified amount.
-- @class function
-- @param current The value we're currently at
-- @param target The target value. This function will never overshoot this value
-- @param change The amount that the current value is allowed to change by to approach the target (positive or negative)
-- @return New current value, closer to the target than it was previously
math_library.approach = math.Approach

--- Increments an angle towards another by specified rate.
-- @class function
-- @param currentAngle The current angle to increase
-- @param targetAngle The angle to increase towards
-- @param rate The amount to approach the target angle by
-- @return Modified angle
math_library.approachAngle = math.ApproachAngle

--- Calculates an angle in radians, in the range -pi/2 to pi/2, which has the given sine value.
-- @class function
-- @param sin Sine value in the range of -1 to 1
-- @return Angle in radians or nothing if the argument is out of range
math_library.asin = math.asin

--- Calculates an angle in radians, in the range -pi/2 to pi/2, which has the given tangent.
-- @class function
-- @param tan Tangent value
-- @return Angle in radians
math_library.atan = math.atan

--- Functions like math.atan(y / x), except it also takes into account the quadrant of the angle and so doesn't have a limited range of output.
-- @class function
-- @param y The Y coordinate
-- @param x The X coordinate
-- @return Angle of the line from (0, 0) to (x, y) in radians, in the range -pi to pi
math_library.atan2 = math.atan2

--- Converts a binary string into a number.
-- @class function
-- @param sting Binary string to convert
-- @return Base 10 number
math_library.binToInt = math.BinToInt

--- Basic code for Bezier-Spline algorithm.
-- @class function
-- @param i Number
-- @param k Number
-- @param t Number
-- @param tinc Number
-- @return Number value
math_library.calcBSplineN = math.calcBSplineN

--- Rounds a number up.
-- @class function
-- @param n Number to be rounded
-- @return Rounded number
math_library.ceil = math.ceil

--- Clamps a number between a minimum and maximum value.
-- @class function
-- @param current Input number
-- @param min Minimum value
-- @param max Maximum value
-- @return Clamped number
math_library.clamp = math.Clamp

--- Calculates cosine of the given angle.
-- @class function
-- @param angle Angle in radians
-- @return Cosine of the angle
math_library.cos = math.cos

--- Calculates hyperbolic cosine of the given angle.
-- @class function
-- @param angle Angle in radians
-- @return The hyperbolic cosine of the angle
math_library.cosh = math.cosh

--- Converts radians to degrees
-- @class function
-- @param rad Angle in radians to be converted
-- @return Angle in degrees
math_library.deg = math.deg

--- Calculates the difference between two points in 2D space (DEPRECATED! You should use math.distance instead)
-- @class function
-- @param x1 X position of first point
-- @param y1 Y position of first point
-- @param x2 X position of second point
-- @param y2 Y position of second point
-- @return Distance between the two points
math_library.dist = math.Dist

--- Calculates the difference between two points in 2D space
-- @class function
-- @param x1 X position of first point
-- @param y1 Y position of first point
-- @param x2 X position of second point
-- @param y2 Y position of second point
-- @return Distance between the two points
math_library.distance = math.Distance

--- Calculates the progress of a value fraction, taking in to account given easing fractions.
-- @class function
-- @param progress Fraction of the progress to ease
-- @param easeIn Fraction of how much easing to begin with
-- @param easeOut Fraction of how much easing to end with
-- @return Eased value
math_library.easeInOut = math.EaseInOut

--- Returns the x power of the Euler constant.
-- @class function
-- @param x The exponent of the function
-- @return e to the specific power
math_library.exp = math.exp

--- Rounds a number down.
-- @class function
-- @param n Number to be rounded
-- @return Rounded number
math_library.floor = math.floor

--- Calculates the modulus of the specified values.
-- @class function
-- @param base The base value
-- @param mod The modulator
-- @return The calculated modulus
math_library.fmod = math.fmod

--- Used to split the number value into a normalized fraction and an exponent
-- @class function
-- @param x The value to get the normalized fraction and the exponent from
-- @return Multiplier between 0.5 and 1
-- @return Exponent integer
math_library.frexp = math.frexp

--- Variable containing the largest possible number (any numerical comparison every number will be less than this).
math_library.huge = math.huge

--- Converts an integer to a binary (base-2) string.
-- @class function
-- @param int Number to be converted
-- @return Binary number string. The length of this will always be a multiple of 3
math_library.intToBin = math.IntToBin

--- Takes a normalised number and returns the floating point representation.
-- @class function
-- @param normalizedFraction The value to get the normalized fraction and the exponent from
-- @param exponent The value to get the normalized fraction and the exponent from
-- @return Floating point reperesentation
math_library.ldexp = math.ldexp

--- With one argument, returns the natural logarithm of x (to base e).
-- With two arguments, return the logarithm of x to the given base, calculated as log(x) / log(base).
-- @class function
-- @param x The value to get the base from exponent from
-- @param base Optional logarithmic base
-- @return Logarithm of x to the given base
math_library.log = math.log

--- Returns the base-10 logarithm of x. This is usually more accurate than math.log(x, 10).
-- @class function
-- @param x The value to get the base from exponent from
-- @return Logarithm of x to the base 10
math_library.log10 = math.log10

--- Picks the largest value of all provided arguments.
-- @class function
-- @param ... Any amount of number values
-- @return The largest number
math_library.max = math.max

--- Picks the smallest value of all provided arguments.
-- @class function
-- @param ... Any amount of number values
-- @return The smallest number
math_library.min = math.Min

--- Returns the modulus of the specified values. (DEPRECATED! You should use the % operator instead)
-- @class function
-- @param base The base value
-- @param mod The modulator
-- @return The calculated modulus
math_library.mod = math.mod

--- Returns the integral and fractional component of the modulo operation.
-- @class function
-- @param base The base value
-- @return The integral component
-- @return The fractional component
math_library.modf = math.modf

--- Normalizes angle, so it returns value between -180 and 180.
-- @class function
-- @param ang The angle in degrees
-- @return The normalized angle
math_library.normalizeAngle = math.NormalizeAngle

--- Variable containing mathematical constant pi (3.1415926535898).
math_library.pi = math.pi

---Returns x raised to the power y
-- @class function
-- @param base The Base number
-- @param exp The Exponent
-- @return Exponent power of base
math_library.pow = math.pow

--- Converts an angle from degrees to radians.
-- @class function
-- @param deg Angle in degrees
-- @return Angle in radians
math_library.rad = math.rad

--- Returns a random float between min and max.
-- @class function
-- @param min The minimum value
-- @param max The maximum value
-- @return Random float between min and max
math_library.rand = math.Rand

--- When called without arguments, returns a uniform pseudo-random real number in the range 0 to 1 which includes 0 but excludes 1.
-- When called with an integer number m, returns a uniform pseudo-random integer in the range 1 to m inclusive.
-- When called with two integer numbers m and n, returns a uniform pseudo-random integer in the range m to n inclusive.
-- @class function
-- @param m Optional integer value. If n is not provided - upper limit; if n is provided - lower limit
-- @param n Optional integer value. Upper value
-- @return Random value
math_library.random = math.random

--- Remaps the value from one range to another.
-- @class function
-- @param value The number value
-- @param inMin The minimum of the initial range
-- @param inMax The maximum of the initial range
-- @param outMin The minimum of new range
-- @param outMax The maximum of new range
-- @return The number in the new range
math_library.remap = math.Remap

--- Rounds the given value to the nearest whole number or to the given decimal places.
-- @class function
-- @param value The number to be rounded
-- @param decimals Optional decimal places to round to. Defaults to 0
math_library.round = math.Round

--- Calculates the sine of given angle.
-- @class function
-- @param ang Angle in radians
-- @return Sine for given angle
math_library.sin = math.sin

--- Calculates the hyperbolic sine of the given angle.
-- @class function
-- @param ang Angle in radians
-- @return The hyperbolic sine of the given angle
math_library.sinh = math.sinh

--- Calculates square root of the number.
-- @class function
-- @param value The value to get the square root of
-- @return Square root of the provided value
math_library.sqrt = math.sqrt

--- Calculates the tangent of the given angle.
-- @class function
-- @param ang Angle in radians
-- @return The tangent of the given angle
math_library.tan = math.tan

--- Calculates hyperbolic tangent of the given angle.
-- @class function
-- @param ang Angle in radians
-- @return The hyperbolic tangent of the given angle
math_library.tanh = math.tanh

--- Calculates the fraction of where the current time is relative to the start and end times.
-- @class function
-- @param start Start time in seconds
-- @param end End time in seconds
-- @param current Current time in seconds
-- @return The time fraction
math_library.timeFraction = math.TimeFraction

--- Rounds towards zero
-- @class function
-- @param val The number to truncate
-- @param digits The amount of digits to keep after the point
-- @return Rounded number
math_library.truncate = math.Truncate

--- Calculates B-Spline point.
-- @class function
-- @param tDiff From 0 to tMax, where alongside the spline the point will be
-- @param tPoints A table of Vectors. The amount cannot be less than 4
-- @param tMax Dictates maximum value for tDiff
-- @return Point on Bezier curve, related to tDiff
function math_library.bSplinePoint(tDiff, tPoints, tMax)
	return vwrap(math.BSplinePoint(tDiff, instance.Unsanitize(tPoints), tMax))
end

--- Performs a linear interpolation from the start number to the end number.
-- @class function
-- @param t The fraction for finding the result. This number is clamped between 0 and 1
-- @param from The starting number. The result will be equal to this if value t is 0
-- @param to The ending number. The result will be equal to this if value t is 1
-- @return The result of the linear interpolation, (1 - t) * from + t * to
function math_library.lerp(t, from, to)
	checkluatype(t, TYPE_NUMBER)
	checkluatype(from, TYPE_NUMBER)
	checkluatype(to, TYPE_NUMBER)
	return Lerp(t, from, to)
end

--- Calculates point between first and second angle using given fraction and linear interpolation.
-- @class function
-- @param ratio Ratio of progress through values
-- @param from Angle to begin from
-- @param to Angle to end at
-- @return The interpolated angle
function math_library.lerpAngle(ratio, from, to)
	checkluatype(ratio, TYPE_NUMBER)
	return awrap(LerpAngle(ratio, aunwrap(from), aunwrap(to)))
end

--- Calculates point between first and second vector using given fraction and linear interpolation.
-- @class function
-- @param ratio Ratio of progress through values
-- @param from Vector to begin from
-- @param to Vector to end at
-- @return The interpolated vector
function math_library.lerpVector(ratio, from, to)
	checkluatype(ratio, TYPE_NUMBER)
	return vwrap(LerpVector(ratio, vunwrap(from), vunwrap(to)))
end

end
