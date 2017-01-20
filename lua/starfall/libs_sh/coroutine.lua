--- Coroutine library

--- Coroutine library
-- @shared
local coroutine_library, _ = SF.Libraries.Register( "coroutine" )
local coroutine = coroutine

local _, thread_metamethods = SF.Typedef( "thread" )
local wrap, unwrap = SF.CreateWrapper( thread_metamethods, true, false )


SF.Libraries.AddHook("initialize",function(instance)
	instance.data.coroutines = setmetatable( {}, { __mode = "v" } )
end)

SF.Libraries.AddHook("deinitialize",function(instance)
	for thread, wrapped in pairs(instance.data.coroutines) do
		local unwrapped = unwrap( wrapped )
		unwrapped.thread = nil
		unwrapped.func = nil
		instance.data.coroutines[ thread ] = nil
	end
end)


local function createCoroutine ( func )
	-- Make sure we're not in a coroutine creation infinite loop
	local curthread = coroutine.running()
	local stacklevel
	if curthread then
		stacklevel = unwrap( SF.instance.data.coroutines[ curthread ] ).stacklevel + 1
		if stacklevel == 100 then SF.throw( "Coroutine stack overflow!", 1 ) end
	else
		stacklevel = 0
	end
	-- Can't use coroutine.create, because of a bug that prevents halting the program when it exceeds quota
	-- Hack to get the coroutine from a wrapped function. Necessary because coroutine.create is not available
	local wrappedFunc = coroutine.wrap( function() return func( coroutine.yield( coroutine.running() ) ) end ) 
	
	local thread = wrappedFunc()

	local wrappedThread = wrap( { thread = thread, func = wrappedFunc, stacklevel = stacklevel } )
	
	SF.instance.data.coroutines[ thread ] = wrappedThread
	
	return wrappedFunc, wrappedThread
end

--- Creates a new coroutine.
-- @param func Function of the coroutine
-- @return coroutine
function coroutine_library.create ( func )
	SF.CheckType( func, "function" )
	local wrappedFunc, wrappedThread = createCoroutine( func )
	return wrappedThread
end

--- Creates a new coroutine.
-- @param func Function of the coroutine
-- @return A function that, when called, resumes the created coroutine. Any parameters to that function will be passed to the coroutine.
function coroutine_library.wrap ( func )
	SF.CheckType( func, "function" )
	local wrappedFunc, wrappedThread = createCoroutine( func )
	return wrappedFunc
end

--- Resumes a suspended coroutine. Note that, in contrast to Lua's native coroutine.resume function, it will not run in protected mode and can throw an error.
-- @param thread coroutine to resume
-- @param ... optional parameters that will be passed to the coroutine
-- @return Any values the coroutine is returning to the main thread
function coroutine_library.resume ( thread, ... )
	SF.CheckType( thread, thread_metamethods )
	local func = unwrap( thread ).func
	return func( ... )
end

--- Suspends the currently running coroutine. May not be called outside a coroutine.
-- @param ... optional parameters that will be returned to the main thread
-- @return Any values passed to the coroutine
function coroutine_library.yield ( ... )
	return coroutine.yield( ... )
end

--- Returns the status of the coroutine.
-- @param thread The coroutine
-- @return Either "suspended", "running", "normal" or "dead"
function coroutine_library.status ( thread )
	SF.CheckType( thread, thread_metamethods )
	local thread = unwrap( thread ).thread
	return coroutine.status( thread )
end

--- Returns the coroutine that is currently running.
-- @return Currently running coroutine
function coroutine_library.running ()
	local thread = coroutine.running()
	return SF.instance.data.coroutines[ thread ]
end

--- Suspends the coroutine for a number of seconds. Note that the coroutine will not resume automatically, but any attempts to resume the coroutine while it is waiting will not resume the coroutine and act as if the coroutine suspended itself immediately.
-- @param time Time in seconds to suspend the coroutine
function coroutine_library.wait ( time )
	SF.CheckType( time, "number" )
	coroutine.wait( time )
end
