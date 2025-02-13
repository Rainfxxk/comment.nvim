local single_line_comment_table = {
    lua =  "-- ",
    c = "// ",
    cpp = "// ",
    v = "// ",
}

local single_line_comment_pattern_table = {
    lua =  "(%-%-[%s])",
    c = "(//[%s])",
    cpp = "(//[%s])",
    v = "(//[%s])",
}

local get_file_type = function()
    local file_path = vim.api.nvim_buf_get_name(0);
    local pattern = "%.(%w+)$"
    return string.match(file_path, pattern)
end

local if_commented = function(start_line, end_line, file_type)

    local comment_pattern = single_line_comment_pattern_table[file_type]

    for i = start_line, end_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        local comment_start, comment_end = string.find(line, comment_pattern)

        if (not comment_start) then
            return false
        end
    end

    return true
end


local add_comment = function(start_line, end_line, file_type)

    local comment = single_line_comment_table[file_type]
    local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, false)[1]
    local _, comment_start = string.find(line, "^[%s]*")

    for i = start_line + 1, end_line do
        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]

        if (string.len(line) > 0) then

            local blank_start, blank_end = string.find(line, "^[%s]*")
             
            if (blank_end < comment_start) then
                comment_start = blank_end
            end
        end

     end

     vim.print(comment_start)
 
     for i = start_line, end_line do

        local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        local new_line = string.sub(line, 1, comment_start) .. comment .. string.sub(line, comment_start + 1, -1)

        vim.api.nvim_buf_set_lines(0, i - 1, i, false, { new_line })

    end

end

local del_comment = function(start_line, end_line, file_type)

    local comment_pattern = single_line_comment_pattern_table[file_type]

      for i = start_line, end_line do
         local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
         local comment_start, comment_end = string.find(line, comment_pattern)
  
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

local auto_comment = function(args)

    local start_line = args.line1
    local end_line = args.line2
    local file_type = get_file_type()

    if (not file_type) then
        vim.print(file_path .. " no file type")
        return
    end
    
    if (if_commented(start_line, end_line, file_type)) then
        del_comment(start_line, end_line, file_type)
    else
        add_comment(start_line, end_line, file_type)
    end

end
 
vim.api.nvim_create_user_command(
    "AutoComment",
    auto_comment,
    {
        range = true,        
    }
)
