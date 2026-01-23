function testScrollbar()
    local lines = {}
    for i = 1, 50 do
        table.insert(lines, "Line " .. i .. ": This is a test line to demonstrate the scrollbar functionality")
    end
    return lines
end

-- More content to scroll through
local config = {
    scrollbar = {
        enabled = true,
        show_git_changes = true,
        show_cursor_position = true,
    },
    git = {
        show_added = true,
        show_modified = true,
        show_deleted = true,
    }
}

-- Test function with more lines
function generateContent()
    local content = {}
    for i = 1, 100 do
        if i % 10 == 0 then
            content[#content + 1] = "-- Section " .. (i / 10)
        end
        content[#content + 1] = "Content line " .. i .. ": Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    end
    return content
end

print("Scrollbar test file loaded successfully!")