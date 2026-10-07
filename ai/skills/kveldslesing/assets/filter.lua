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

-- A lead-in ending with ":" must not be stranded at the bottom of a page, apart from the code, table or list it introduces.
local introduced = { CodeBlock = true, Table = true, Figure = true, BulletList = true, OrderedList = true }

function Blocks(blocks)
  local out = pandoc.Blocks({})
  for i, b in ipairs(blocks) do
    local nxt = blocks[i + 1]
    if b.t == 'Para' and nxt and introduced[nxt.t] and pandoc.utils.stringify(b):match(':%s*$') then
      out:insert(pandoc.RawBlock('typst', '#block(sticky: true)['))
      out:insert(b)
      out:insert(pandoc.RawBlock('typst', ']'))
    else
      out:insert(b)
    end
  end
  return out
end
