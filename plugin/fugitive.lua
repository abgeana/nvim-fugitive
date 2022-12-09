local trim = require('fugitive.utils.trim')

local nvim_call = vim.api.nvim_call_function

function escape(s, patterns)
    for i = 1, #patterns do
        s = s:gsub(patterns[i], '\\' .. patterns[i])
    end
    return s
end

function _G.ArgSplit(s)
    s = trim.trim_space(s)

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
        s = trim.trim_space(s:sub(to + 1))
    end

    return args
end

function _G.OpenParse(s, wants_cmd, wants_multiple)
    local opts = {}
    local cmds = {}
    local args = _G.ArgSplit(s)

    while #args > 0 do
        if args[1]:sub(1, 2) == '++' then
            table.insert(opts, ' ' .. escape(table.remove(args, 1), {'|', '"', ' '}))
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
        pre = pre .. ' +' .. escape(table.concat(cmds, '|'), {'|', '"', ' '})
    elseif #cmds == 1 then
        pre = pre .. ' +' .. escape(cmds[1], {'|', '"', ' '})
    end

    if wants_multiple == 1 then
        return {urls, pre}
    else
        print(urls[1], pre)
        return {urls[1], pre}
    end
end
