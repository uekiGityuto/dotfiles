-- 作成日（btime）
Status:children_add(function(self)
    local h = self._current.hovered
    if not h then return "" end
    local btime = tostring(h.cha.btime):sub(1, 10)
    return ui.Line {
        ui.Span(" Created: " .. os.date("%Y-%m-%d %H:%M", btime)):fg("#87afff"),
    }
end, 3200, Status.LEFT)

-- 更新日（mtime）
Status:children_add(function(self)
    local h = self._current.hovered
    if not h then return "" end
    local mtime = tostring(h.cha.mtime):sub(1, 10)
    return ui.Line {
        ui.Span(" Modified: " .. os.date("%Y-%m-%d %H:%M", mtime)):fg("#af87ff"),
    }
end, 3300, Status.LEFT)
