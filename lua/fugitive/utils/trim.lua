local M = {}

function M.space(s)
    if type(s) ~= 'string' then
        error(format('invalid argument #1 (string expected, got %s)', type(s)), 2)
    elseif s == '' then
        return ''
    end

    -- remove leading whitespaces
    local _, pos = string.find(s, '^%s+')
    if pos then s = string.sub(s, pos + 1) end

    -- remove trailing whitespaces
    pos = string.find(s, '%s+$')
    if pos then return string.sub(s, 1, pos - 1) end

    return s
end

local function prefix(s, prefix)
    if type(s) ~= 'string' then
        error(format('invalid argument #1 (string expected, got %s)', type(s)), 2)
    elseif type(prefix) ~= 'string' then
        error(format('invalid argument #2 (string expected, got %s)', type(prefix)), 2)
    end

    if #s == 0 or #prefix == 0 or #s < #prefix then
        return s
    elseif s == prefix then
        return ''
    elseif string.sub(s, 1, #prefix) == prefix then
        -- remove prefix
        return string.sub(s, #prefix + 1)
    end

    return s
end

function M.suffix(s, suffix)
    if type(s) ~= 'string' then
        error(format('invalid argument #1 (string expected, got %s)', type(s)), 2)
    elseif type(suffix) ~= 'string' then
        error(format('invalid argument #2 (string expected, got %s)', type(suffix)), 2)
    end

    if #s == 0 or #suffix == 0 or #s < #suffix then
        return s
    elseif s == suffix then
        return ''
    elseif string.sub(s, -#suffix) == suffix then
        -- remove suffix
        return string.sub(s, 1, #s - #suffix)
    end

    return s
end

return M
