# target directory for Lua/LuaRocks/...
D="$HOME/programs"


# function for logging commands (set +v is too verbose)
v() {
  echo -n -e "\033[36m" >&2
  echo -n "# $@" >&2
  echo -e "\033[0m" >&2
  "$@"
}


tgz_download() {
  (set -o pipefail; \
    curl --fail --silent --show-error --location "$1" | tar xzpf -)
}


install_lua() {
  case "`uname -s`" in
    Linux) local LUA_MAKE_TARGET=linux ;;
    Darwin) local LUA_MAKE_TARGET=macosx ;;
    FreeBSD) local LUA_MAKE_TARGET='freebsd CC=cc' ;;
    *) echo "unsupported system" >&2; return 1 ;;
  esac
  v tgz_download http://www.lua.org/ftp/lua-"$1".tar.gz && \
    (cd lua-"$1" && \
      v make $LUA_MAKE_TARGET && \
      v make install INSTALL_TOP="$D")
}


install_luajit() {
  v tgz_download https://github.com/LuaJIT/LuaJIT/archive/v"$1".tar.gz && \
    (cd LuaJIT-"$1" && \
      v make PREFIX="$D" && \
      v make install PREFIX="$D" INSTALL_INC="$D/include") && \
    v ln -sf luajit-"$1" "$D/bin/lua"
}


install_luarocks() {
  v tgz_download http://luarocks.org/releases/luarocks-"$1".tar.gz && \
    (cd luarocks-"$1" && \
      v ./configure --prefix="$D" --with-lua="$D" --force-config && \
      v make bootstrap)
}


# create base directory if it doesn't exist
[ -d "$D" ] || mkdir -p "$D"
# make sure that the LUA variable is set
[ -n "$LUA" ] || LUA=5.3.2
# download and install the requested Lua interpreter
case "$LUA" in
  [Ll]ua[Jj][Ii][Tt]-[0123456789]*.*)
    (cd "$D" && install_luajit "${LUA#???????}") ;;
  [Ll]ua-[0123456789]*.*)
    (cd "$D" && install_lua "${LUA#????}") ;;
  [0123456789]*.*)
    (cd "$D" && install_lua "$LUA") ;;
  *)
    echo "invalid Lua version: $LUA" >&2; false ;;
esac || return

# download and install LuaRocks (if requested)
if [ -n "$LUAROCKS" ]; then
  case "$LUAROCKS" in
    [Ll]ua[Rr]ocks-[0123456789]*.*)
      (cd "$D" && install_luarocks "${LUAROCKS#?????????}") ;;
    [0123456789]*.*)
      (cd "$D" && install_luarocks "$LUAROCKS") ;;
    *)
      echo "invalid LuaRocks version: $LUAROCKS" >&2; false ;;
  esac || return
fi

# setup LUA_PATH, LUA_CPATH, and PATH for Lua and LuaRocks
export PATH="$D/bin:$PATH"
[ -z "$LUAROCKS" ] || eval "`luarocks path`"
