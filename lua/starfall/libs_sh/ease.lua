--- Ease library https://wiki.facepunch.com/gmod/math.ease
-- @name ease
-- @class library
-- @libtbl ease_library
SF.RegisterLibrary("ease")

return function(instance)

local ease_library = instance.Libraries.ease

--- Eases in by reversing the direction of the ease slightly before returning.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inBack = math.ease.InBack

--- Eases in like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inBounce = math.ease.InBounce

--- Eases in using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inCirc = math.ease.InCirc

--- Eases in by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inCubic = math.ease.InCubic

--- Eases in like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inElastic = math.ease.InElastic

--- Eases in using an exponential equation with a base of 2 and where the fraction is used in the exponent.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inExpo = math.ease.InExpo

--- Eases in and out by reversing the direction of the ease slightly before returning on both ends.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutBack = math.ease.InOutBack

--- Eases in and out like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutBounce = math.ease.InOutBounce

--- Eases in and out using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutCirc = math.ease.InOutCirc

--- Eases in and out by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutCubic = math.ease.InOutCubic

--- Eases in and out like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutElastic = math.ease.InOutElastic

--- Eases in and out using an exponential equation with a base of 2 and where the fraction is used in the exponent.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutExpo = math.ease.InOutExpo

--- Eases in and out by squaring the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutQuad = math.ease.InOutQuad

--- Eases in and out by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutQuint = math.ease.InOutQuint

--- Eases in and out using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inOutSine = math.ease.InOutSine

--- Eases in by squaring the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inQuad = math.ease.InQuad

--- Eases in by raising the fraction to the power of 4.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inQuart = math.ease.InQuart

--- Eases in by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inQuint = math.ease.InQuint

--- Eases in using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.inSine = math.ease.InSine

--- Eases out by reversing the direction of the ease slightly before finishing.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outBack = math.ease.OutBack

--- Eases out like a bouncy ball.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outBounce = math.ease.OutBounce

--- Eases out using a circular function.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outCirc = math.ease.OutCirc

--- Eases out by cubing the fraction.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outCubic = math.ease.OutCubic

--- Eases out like a rubber band.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outElastic = math.ease.OutElastic

--- Eases out by raising the fraction to the power of 4.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outQuart = math.ease.OutQuart

--- Eases out by raising the fraction to the power of 5.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outQuint = math.ease.OutQuint

--- Eases out using math.sin.
-- @class function
-- @param number fraction Fraction of the progress to ease, from 0 to 1
-- @return number "Eased" Value
ease_library.outSine = math.ease.OutSine

end