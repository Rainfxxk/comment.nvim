opt = {noremap = true, silent = true}
vim.keymap.set({'n', 'v'}, "<c-/>", ":AutoComment<cr>", opt)
vim.keymap.set({'i'}, "<c-/>", "<Esc>:AutoComment<cr>i", opt)
