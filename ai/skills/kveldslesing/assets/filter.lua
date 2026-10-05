local function typst_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- A paragraph holding only an image becomes a size-capped #img, with the alt text as caption.
local function image_only(el)
  if #el.content ~= 1 or el.content[1].t ~= 'Image' then return nil end
  local img = el.content[1]
  -- pandoc percent-encodes the src, but Typst needs the real file path.
  local src = img.src:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
  local args = typst_string(src)
  local caption = pandoc.utils.stringify(img.caption)
  if caption ~= '' then args = args .. ', caption: ' .. typst_string(caption) end
  return pandoc.RawBlock('typst', '#img(' .. args .. ')')
end

function Para(el) return image_only(el) end
function Plain(el) return image_only(el) end
