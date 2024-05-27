-- Define a function to extract the virtual environment name based on project criteria
local function extract_virtual_env_name(project_dir)
    -- Check if a virtual environment directory exists (e.g., .venv, venv)
    local venv_dirs = { ".venv", "venv" }
    for _, venv_dir in ipairs(venv_dirs) do
        local venv_path = project_dir .. "/" .. venv_dir
        if vim.fn.isdirectory(venv_path) == 1 then
            -- Return the full path to the virtual environment directory
            return vim.fn.resolve(venv_path)
        end
    end
    -- If no virtual environment found, return nil
    return nil
end

-- Use the extract_virtual_env_name function in your configuration
local null_ls = require("null-ls")

local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

local opts = {
    sources = {
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.mypy.with({
            extra_args = function()
                -- Detect project directory
                local project_dir = vim.fn.getcwd()  -- Get current working directory
                -- Extract virtual environment path
                local venv_path = extract_virtual_env_name(project_dir)
                if venv_path then
                    -- Construct the path to the Python executable within the virtual environment
                    local python_executable = venv_path .. "/bin/python3"
                    return { "--python-executable", python_executable, "--config-file", os.getenv("MYPY_CONFIG_FILE") }
                else
                    -- Fallback to system Python or default behavior
                    return { "--config-file", os.getenv("MYPY_CONFIG_FILE") }
                end
            end,
        }),
        null_ls.builtins.diagnostics.ruff,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr })
                end,
            })
        end
    end,
}

null_ls.setup(opts)
