-- Add the ability to require Lua modules from the after directory
local home_dir = os.getenv("HOME")
package.path = home_dir .. "/.config/nvim/?.lua;" .. package.path

require("custom")
