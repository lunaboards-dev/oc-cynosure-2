--[[
    Screen object for OpenComputers
    Copyright (C) 2021 Ocawesome101

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

k.log(k.L_INFO, "platform/oc/screen")

do
  k.log(k.L_INFO, "[screen] getting device info")
  k.screen = {}

  local dinfo = {}
  local gpus, screens = {}, {}
  function k.screen.refresh()
    dinfo = computer.getDeviceInfo()
  end

  function k.screen.next()
    local gpu, screen
    for addr in component.list("gpu") do
      if not gpus[addr] then
        gpu = addr
      end
    end


  end
end
