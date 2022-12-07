function _G.OpenParse(string, wants_cmd, wants_multiple)
    return vim.api.nvim_call_function("fugitive#OpenParse_deprecated", {string, wants_cmd, wants_multiple})
end
