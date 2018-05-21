return {
  cURL = {
    {
      description = "cURL: Lua binding to libcurl",
      homepage = "https://github.com/Lua-cURL",
      license = "MIT/X11",
      name = "cURL",
      require = {
        lcurl = "0.3.1-103",
        luajit = "2.0"
      },
      version = "0.3.1-103",
      version_dir = "0_3_1+103"
    }
  },
  clib_libcurl = {
    {
      description = "free and easy-to-use client-side URL transfer library",
      homepage = "http://curl.haxx.se",
      license = "MIT/X11-derived",
      name = "clib_libcurl",
      require = {
        luajit = "2.0"
      },
      version = "7.42.1-3",
      version_dir = "7_42_1+3"
    }
  },
  lcurl = {
    {
      description = "cURL: Lua binding to libcurl",
      homepage = "https://github.com/Lua-cURL",
      license = "MIT/X11",
      name = "lcurl",
      require = {
        cURL = "0.3.1-103",
        clib_libcurl = "7",
        luajit = "2.0"
      },
      version = "0.3.1-103",
      version_dir = "0_3_1+103"
    }
  },
  lfs = {
    {
      description = "luafilesystem : File System Library for the Lua Programming Language",
      homepage = "",
      license = "MIT/X11",
      name = "lfs",
      require = {
        luajit = "2.0"
      },
      version = "1.7.0-203",
      version_dir = "1_7_0+203"
    }
  },
  logging = {
    {
      description = "lualogging : A simple API to use logging features",
      homepage = "https://github.com/Neopallium/lualogging",
      license = "MIT/X11",
      require = {
        ltn12 = "2.0.2-6",
        luajit = "2.0",
        mime = "2.0.2-6",
        socket = "2.0.2-6"
      },
      version = "1.3.0-103",
      version_dir = "1_3_0+103"
    }
  },
  ltn12 = {
    {
      description = "luasocket : Network support for the Lua language",
      homepage = "http://luaforge.net/projects/luasocket/",
      license = "MIT",
      require = {
        luajit = "2.0",
        mime = "2.0.2-603",
        socket = "2.0.2-603"
      },
      version = "2.0.2-603",
      version_dir = "2_0_2+603"
    }
  },
  luadoc = {
    {
      description = "luadoc : LuaDoc is a documentation tool for Lua source code",
      homepage = "http://luadoc.luaforge.net/",
      license = "MIT/X11",
      require = {
        lfs = "1.2.1",
        logging = "1.1.3",
        luajit = "2.0"
      },
      version = "3.0.1-103",
      version_dir = "3_0_1+103"
    }
  },
  luajit = {
    {
      description = "LuaJIT: Just-In-Time Compiler (JIT) for Lua",
      homepage = "http://luajit.org/luajit.html",
      license = "MIT",
      name = "luajit",
      require = {},
      version = "2.1.head20151128",
      version_dir = "2_1_head20151128"
    }
  },
  mime = {
    {
      description = "luasocket : Network support for the Lua language",
      homepage = "http://luaforge.net/projects/luasocket/",
      license = "MIT",
      require = {
        ltn12 = "2.0.2-603",
        luajit = "2.0",
        socket = "2.0.2-603"
      },
      version = "2.0.2-603",
      version_dir = "2_0_2+603"
    }
  },
  pkg = {
    {
      description = "ULua package manager",
      homepage = "http://ulua.io/pkg.html",
      license = "MIT <http://opensource.org/licenses/MIT>",
      name = "pkg",
      require = {
        cURL = "0.3.1",
        lfs = "1.6.2",
        luajit = "2.0",
        serpent = "0.27"
      },
      version = "1.0.beta10",
      version_dir = "1_0_beta10"
    }
  },
  serpent = {
    {
      description = "serpent : Lua serializer and pretty printer",
      homepage = "https://github.com/pkulchenko/serpent",
      license = "MIT",
      name = "serpent",
      require = {
        luajit = "2.0"
      },
      version = "0.28-103",
      version_dir = "0_28+103"
    }
  },
  socket = {
    {
      description = "luasocket : Network support for the Lua language",
      homepage = "http://luaforge.net/projects/luasocket/",
      license = "MIT",
      require = {
        ltn12 = "2.0.2-603",
        luajit = "2.0",
        mime = "2.0.2-603"
      },
      version = "2.0.2-603",
      version_dir = "2_0_2+603"
    }
  }
}