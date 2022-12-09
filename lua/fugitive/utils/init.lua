local M = {}

M.trim = require('fugitive.utils.trim')

function M.escape(s, patterns)
    for i = 1, #patterns do
        s = s:gsub(patterns[i], '\\' .. patterns[i])
    end
    return s
end

return M
