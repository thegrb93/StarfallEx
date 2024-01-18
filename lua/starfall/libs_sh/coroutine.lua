-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local coroutine = coroutine

--- Coroutine library
-- @name coroutine
-- @class library
-- @libtbl coroutine_library
SF.RegisterLibrary("coroutine")

SF.RegisterType("thread", true, false)


return function(instance)


local coroutine_library = instance.Libraries.coroutine
local thread_meta, wrap, unwrap = instance.Types.thread, instance.Types.thread.Wrap, instance.Types.thread.Unwrap


local coroutines = {}
local coroutineStackLevels = {}

local function cleanupThread(thread)
	local unwrapped = unwrap(coroutines[thread])
	coroutineStackLevels[unwrapped.thread] = nil
	coroutineStackLevels[unwrapped.func] = nil
	unwrapped.thread = nil
	unwrapped.func = nil
	coroutines[thread] = nil
end

instance:AddHook("deinitialize", function()
	for thread in pairs(coroutines) do
		cleanupThread(thread)
	end
end)
instance.canyield = true


local function createCoroutine(func)
	-- Make sure we're not in a coroutine creation infinite loop
	local curthread = coroutine.running()
	local stacklevel = math.max(
		curthread and coroutineStackLevels[curthread] and coroutineStackLevels[curthread]+1 or 0,
		coroutineStackLevels[func] and coroutineStackLevels[func]+1 or 0
	)
	if stacklevel == 128 then SF.Throw("Coroutine stack overflow!", 3) end

	-- Can't use coroutine.create, because of a bug that prevents halting the program when it exceeds quota
	-- Hack to get the coroutine from a wrapped function. Necessary because coroutine.create is not available
	local wrappedFunc = coroutine.wrap(function()
		local thread = coroutine.running()
		local function cleanup(...) cleanupThread(thread) return ... end
		return cleanup(func(coroutine.yield(thread)))
	end)

	local thread = wrappedFunc()

	local wrappedThread = wrap({ thread = thread, func = wrappedFunc })

	coroutines[thread] = wrappedThread
	coroutineStackLevels[thread] = stacklevel
	coroutineStackLevels[wrappedFunc] = stacklevel

	return wrappedFunc, wrappedThread
end

--- Creates a new coroutine.
-- @param function func Function of the coroutine
-- @return thread Created coroutine
function coroutine_library.create(func)
	checkluatype (func, TYPE_FUNCTION)
	local wrappedFunc, wrappedThread = createCoroutine(func)
	return wrappedThread
end

--- Creates a new coroutine.
-- @param function func Function of the coroutine
-- @return function A function that, when called, resumes the created coroutine. Any parameters to that function will be passed to the coroutine.
function coroutine_library.wrap(func)
	checkluatype (func, TYPE_FUNCTION)
	local wrappedFunc, wrappedThread = createCoroutine(func)
	return wrappedFunc
end

--- Resumes a suspended coroutine. Note that, in contrast to Lua's native coroutine.resume function, it will not run in protected mode and can throw an error.
-- @param thread coroutine to resume
-- @param ... args Optional parameters that will be passed to the coroutine
-- @return ... Any values the coroutine is returning to the main thread
function coroutine_library.resume(thread, ...)
	local func = unwrap(thread).func
	if func == nil then SF.Throw("cannot resume dead coroutine", 2) end
	return func(...)
end

--- Suspends the currently running coroutine. May not be called outside a coroutine.
-- @param ... Optional parameters that will be returned to the main thread
-- @return ... Any values passed to the coroutine
function coroutine_library.yield(...)
	local thread = coroutine.running()
	if thread and coroutines[thread] and instance.canyield then
		return coroutine.yield(...)
	else
		SF.Throw("attempt to yield across C-call boundary", 2)
	end
end

--- Returns the status of the coroutine.
-- @param thread coroutine The coroutine
-- @return string Either "suspended", "running", "normal" or "dead"
function coroutine_library.status(thread)
	local thread = unwrap(thread).thread
	if thread == nil then return "dead" end
	return coroutine.status(thread)
end

--- Returns the coroutine that is currently running.
-- @return thread Currently running coroutine
function coroutine_library.running()
	local thread = coroutine.running()
	return coroutines[thread]
end

--- Suspends the coroutine for a number of seconds. Note that the coroutine will not resume automatically, but any attempts to resume the coroutine while it is waiting will not resume the coroutine and act as if the coroutine suspended itself immediately.
-- @param number time Time in seconds to suspend the coroutine
function coroutine_library.wait(time)
	local thread = coroutine.running()
	if thread and coroutines[thread] then
		checkluatype (time, TYPE_NUMBER)
		coroutine.wait(time)
	else
		SF.Throw("attempt to yield across C-call boundary", 2)
	end
end

end
