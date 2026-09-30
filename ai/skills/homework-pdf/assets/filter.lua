local function typst_string(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
end

-- Obsidian gives widths in pixels; Typst treats 1px as 0.75pt at 96 dpi.
local function typst_length(w)
  if not w then return nil end
  local n, unit = w:match('^([%d%.]+)(%a*%%?)$')
  if not n then return nil end
  if unit == '' or unit == 'px' then return tostring(tonumber(n) * 0.75) .. 'pt' end
  return n .. unit
end

local function image_call(img)
  -- pandoc percent-encodes the src, but Typst needs the real file path.
  local src = img.src:gsub('%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
  local args = typst_string(src)
  local width = typst_length(img.attributes.width)
  if width then args = args .. ', width: ' .. width end
  return pandoc.RawBlock('typst', '#img(' .. args .. ')')
end

-- A paragraph that holds nothing but images becomes centered, size-capped images.
local function image_only(el)
  local images = {}
  for _, inline in ipairs(el.content) do
    if inline.t == 'Image' then
      table.insert(images, image_call(inline))
    elseif inline.t ~= 'Space' and inline.t ~= 'SoftBreak' and inline.t ~= 'LineBreak' then
      return nil
    end
  end
  if #images > 0 then return images end
end

function Para(el) return image_only(el) end
function Plain(el) return image_only(el) end

function Div(el)
  if el.classes:includes('transcribed') then return el.content end
  if not el.classes:includes('question') then return nil end
  local number = el.attributes.number or ''
  local blocks = { pandoc.RawBlock('typst', '#question(' .. typst_string(number) .. ')[') }
  for _, b in ipairs(el.content) do table.insert(blocks, b) end
  table.insert(blocks, pandoc.RawBlock('typst', ']'))
  return blocks
end
