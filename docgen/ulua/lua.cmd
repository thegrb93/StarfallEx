@echo off
SETLOCAL
if defined BIT (
  if "%BIT%"=="32" (
    SET LJ_ARCH=x86
  ) else (
    if "%BIT%"=="64" (
      SET LJ_ARCH=x64
    ) else (
      echo ERROR: BIT=%BIT% is not a valid setting, use 32 or 64 1>&2 && exit /b 1
    )
  )
) else (
  SET LJ_ARCH=x86
)
SET LJ_VER_EXT=luajit/2_1_head20151128
SET LUA_ROOT=%~dp0
SET LUA_ROOT=%LUA_ROOT:~0,-1%
SET LUA_ROOT=%LUA_ROOT:\=/%
SET LJ_SYS=Windows
SET LJ_CORE=%LUA_ROOT%/%LJ_VER_EXT%/%LJ_SYS%/%LJ_ARCH%
SET LUA_PATH=%LUA_ROOT%/?/init.lua;%LUA_ROOT%/?.lua;%LJ_CORE%/?/init.lua;%LJ_CORE%/?.lua;
SET LUA_CPATH=%LUA_ROOT%/?.dll;%LUA_ROOT%/loadall.dll;
"%LJ_CORE%/luajit" -l__init %*
