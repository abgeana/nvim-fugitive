local utils = require('fugitive.utils')

local nvim_call = vim.api.nvim_call_function

local function ArgSplit(s)
    s = utils.trim.space(s)

    args = {}
    while #s > 0 do
        -- match all "escaped" characters and non space characters
        local r = vim.regex([[^\%(\\.\|\S\)\+]])
        from, to = r:match_str(s)
        arg = s:sub(from, to)

        -- remove the backslash for the following "escaped" characters: bar |, double quotes " and space
        arg = arg:gsub([[\|]], [[|]])
        arg = arg:gsub([[\"]], [["]])
        arg = arg:gsub([[\ ]], [[ ]])

        table.insert(args, arg)
        s = utils.trim.space(s:sub(to + 1))
    end

    return args
end

local function OpenParse(s, wants_cmd, wants_multiple)
    local opts = {}
    local cmds = {}
    local args = _G.ArgSplit(s)

    while #args > 0 do
        if args[1]:sub(1, 2) == '++' then
            table.insert(opts, ' ' .. utils.escape(table.remove(args, 1), {'|', '"', ' '}))
        elseif wants_cmd == 1 and args[1] == '+' then
            table.remove(args, 1)
            table.insert(cmds, '$')
        elseif wants_cmd == 1 and string.sub(args[1], 1, 1) == '+' then
            table.insert(cmds, string.sub(table.remove(args, 1), 2))
        else
            break
        end
    end

    if wants_multiple == false and #args == 0 then
        table.insert(args, '>:')
    end

    local dir = nvim_call('fugitive#Dir', {})
    local urls = {}
    for _, arg in pairs(args) do
        local url, lnum = unpack(nvim_call('fugitive#OpenExpand', {dir, arg, wants_cmd}))
        if lnum ~= nil and lnum ~= 0 then
            table.insert(cmds, 1, lnum)
        end
        table.insert(urls, url)
        wants_cmd = 0
    end

    local pre = table.concat(opts)
    if #cmds > 1 then
        for k, v in pairs(cmds) do
            cmds[k] = 'exe \'' .. v .. '\''
        end
        pre = pre .. ' +' .. utils.escape(table.concat(cmds, '|'), {'|', '"', ' '})
    elseif #cmds == 1 then
        pre = pre .. ' +' .. utils.escape(cmds[1], {'|', '"', ' '})
    end

    if wants_multiple == 1 then
        return {urls, pre}
    else
        return {urls[1], pre}
    end
end

-- exports for vimscript, eventually to be removed once all vimscript has been ported to lua
_G.ArgSplit = ArgSplit
_G.OpenParse = OpenParse
