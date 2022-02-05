--[[
    URL infrastructure
    Copyright (C) 2022 Ocawesome101

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
  ]]--

printk(k.L_INFO, "urls/main")

do
  k.schemes = {}

  --- Registers a scheme
  ---@param name string
  ---@param provider table
  function k.register_scheme(name, provider)
    checkArg(1, name, "string")
    checkArg(2, provider, "table")
    if k.schemes[name] then
      panic("attempted to double-register scheme " .. name)
    end
    k.schemes[name] = provider
    return true
  end

  --- Takes a URL and returns its provider plus its resource
  ---@param url string
  function k.lookup_url(url)
    local scheme, resource = url:match("(.*):/?/?(.*)")
    if not scheme then
      scheme, resource = "file", resource
    end
    if not k.schemes[scheme] then
      return nil, k.errno.EUNATCH
    end
    return k.schemes[scheme], resource
  end

  -- URL calls
  local function call(url, method, ...)
    local provider, resource = k.lookup_url(url)
    if not provider then
      return nil, resource
    end
    if not provider[method] then
      return nil, k.errno.EOPNOTSUPP
    end
    return provider, provider[method](resource, ...)
  end

  local function verify_fd(fd)
    checkArg(1, fd, "table")
    if not (fd.fd and fd.node and fd.refs) then
      error("bad argument #1 (file descriptor expected)", 2)
    end
    return true
  end

  local function fd_call(func, ...)
    if not func then
      return nil, k.errno.EOPPNOTSUPP
    end
    return func(...)
  end
  
  function k.open(url, mode)
    checkArg(1, url, "string")
    checkArg(2, mode, "number")
    local result = table.pack(call(url, "open", mode))
    if not result[1] then
      return nil, result[2]
    end
    if not result[2] then
      return nil, result[3]
    end
    return {fd = result[2], node = result[1], refs = 1}
  end

  function k.read(fd, format)
    verify_fd(fd)
    checkArg(2, format, "string", "number")
    return fd.node.read(fd.fd, format)
  end

  function k.write(fd, ...)
    verify_fd(fd)
    return fd_call(fd.node.write, fd.fd, ...)
  end

  function k.seek(fd, whence, offset)
    verify_fd(fd)
    return fd_call(fd.node.seek, fd.fd, whence, offset)
  end
  
  function k.flush(fd)
    verify_fd(fd)
    return fd_call(fd.flush)
  end

  function k.close(fd)
    verify_fd(fd)
    return fd_call(fd.close)
  end
end

--#include "src/urls/scheme_tty.lua"
--@[{bconf.SCHEME_MISC == 'y' and '#include "src/urls/scheme_misc.lua"' or ''}]
--@[{bconf.SCHEME_EXEC == 'y' and '#include "src/urls/scheme_exec.lua"' or ''}]
--@[{bconf.SCHEME_HTTP == 'y' and '#include "src/urls/scheme_http.lua"' or ''}]
--@[{bconf.SCHEME_TCP == 'y' and '#include "src/urls/scheme_tcp.lua"' or ''}]
--@[{bconf.SCHEME_COMPONENT == 'y' and '#include "src/urls/scheme_component.lua"' or ''}]
