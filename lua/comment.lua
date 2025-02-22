local single_line_comment_table = {
    nxdc = "# ",
    lua =  "-- ",
    c = "// ",
    cpp = "// ",
    v = "// ",
}

local single_line_comment_pattern_table = {
    nxdc = "(#[%s]?)",
    lua =  "(%-%-[%s]?)",
    c = "(//[%s]?)",
    cpp = "(//[%s]?)",
    v = "(//[%s]?)",
}

local get_comment_and_pattern = function()
    local file_name = vim.api.nvim_buf_get_name(0);
    local pattern = "%.(%w+)$"
    file_name =  string.match(file_name, pattern)
    return single_line_comment_table[file_name], single_line_comment_pattern_table[file_name]
end

local if_commented = function(start_line, end_line, comment_pattern)

    if start_line == end_line then
        local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
        local comment_start, comment_end = string.find(line, comment_pattern)

        if (comment_start) then
            return true
        else
            return false
        end
    end

    for i = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if (string.len(line) > 0) then
            local comment_start, comment_end = string.find(line, comment_pattern)

            if (not comment_start) then
                return false
            end
        end
    end

    return true
end

local add_comment = function(start_line, end_line, comment)

    local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
    local _, comment_start = string.find(line, "^[%s]*")
    local comment_pos = comment_start

    for i = start_line + 1, end_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if (string.len(line) > 0) then

            local blank_start, blank_end = string.find(line, "^[%s]*")

            if (blank_end < comment_start or (comment_start == 0 and blank_end > 0)) then
                comment_start = blank_end
            end
        end

     end

     for i = start_line, end_line do

        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if (string.len(line) >= comment_start) then
            local new_line = string.sub(line, 1, comment_start) .. comment .. string.sub(line, comment_start + 1, -1)

            vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })
        end
    end

    return comment_pos
end

local del_comment = function(start_line, end_line, comment_pattern)

    local del_len = 0
    local comment_pos = 0

      for i = start_line, end_line do
         local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

         if (string.len(line) > 0) then
            local comment_start, comment_end = string.find(line, comment_pattern)
            if (del_len == 0 and comment_pos == 0) then
                del_len = comment_end - comment_start + 1
                comment_pos = comment_start
            end
  
            if (comment_start) then
                local new_line

                if (comment_start == 1) then
                    new_line = string.sub( line, comment_end + 1, -1)
                else
                    new_line = string.sub( line, 1, comment_start - 1) .. string.sub( line, comment_end + 1, -1)
                end
  
                vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line } )
            end
        end
    end

    return comment_pos, del_len

end

local auto_comment = function(args)

    local cursor_pos= vim.api.nvim_win_get_cursor(0)
    local cursor_row = cursor_pos[1]
    local cursor_col = cursor_pos[2]

    local start_line = args.line1
    local end_line = args.line2
    local comment, comment_pattern = get_comment_and_pattern()

    if (not comment or not comment_pattern) then
        vim.notify("don't support current file type")
        return
    end

    if (if_commented(start_line, end_line, comment_pattern)) then
        local comment_pos, del_len = del_comment(start_line, end_line, comment_pattern)
        if (cursor_col > comment_pos) then
            cursor_col = cursor_col - del_len
        end
    else
        local comment_pos = add_comment(start_line, end_line, comment)
        if (cursor_col > comment_pos - 1) then 
            cursor_col = cursor_col + string.len(comment)
        end
    end

    if (cursor_col < 0) then
        cursor_col = 0
    end

    cursor_pos[2] = cursor_col
    
    vim.api.nvim_win_set_cursor(0, cursor_pos)
end
 
vim.api.nvim_create_user_command(
    "AutoComment",
    auto_comment,
    {
        range = true,        
    }
)
