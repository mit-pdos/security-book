-- Draft TODO notes in the PDF build.
--
-- Pandoc's LaTeX writer drops span classes, so `[...]{.todo}` would otherwise
-- reach the PDF as undistinguished body text. Wrap it in \todobox (defined in
-- macros/macros-pdf-extra.tex) so it reads as an annotation.
--
-- Quarto's own conditional-content filter has already run by this point, so a
-- non-draft build has no .todo spans left for this to match.

if not FORMAT:match('latex') then
  return {}
end

local function has_todo_class(el)
  for _, class in ipairs(el.classes) do
    if class == 'todo' then return true end
  end
  return false
end

return {
  Span = function(el)
    if not has_todo_class(el) then return nil end
    local out = pandoc.List({ pandoc.RawInline('latex', '\\todobox{') })
    out:extend(el.content)
    out:insert(pandoc.RawInline('latex', '}'))
    return out
  end,
}
