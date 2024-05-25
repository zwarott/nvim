local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {"<cmd> DapToggleBreakpoint <CR>"}
  }
}

M.dap_python = {
  plugin = true,
  n = {
    ["<leader>dpr"] = {
      function()
        require('dap-python').test_method()
      end
    }
  }
}

-- Remap ESC in Terminal Insert mode to switch to Normal mode
vim.api.nvim_exec([[
  tnoremap <Esc> <C-\><C-n>  
]], false)


-- Set line numbering with relativenumber
vim.opt.number = true
vim.opt.relativenumber = true

return M
