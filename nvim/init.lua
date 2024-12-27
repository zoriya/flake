-- rtp & loader settings are set by nix

-- only use lz.n as a "require" sorter
vim.g.lz_n = {
	load = function() end,
}

require("./settings")
require("lz.n").load("plugins")
