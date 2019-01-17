local sprites = ...

sprites.selected = 
{
  "F",
  "A"
}
  
sprites.textures = {}

sprites.empty =
[[
..
..
]]

sprites.void =
[[
wx
xw
]]
  
sprites.palette =
[[
ABC
DEF
GHI
JKL
MNO
PQR
STU
VWX
YZa
bcd
efg
hij
klm
nop
qrs
tuv
]]


function sprites:textured(name,width,height)
  local id = name .. tonumber(width) .. '-' .. tostring(height)
  if sprites.textures[id] then
    return sprites.textures[id]
  else
    return new_texture(id,name,width,height)
  end
end

function new_texture(id,name,width,height)
  local spr = sprites[name]
  local sprw = string.find(spr,'\n')-1
  local sprh = string.len(spr)/(sprw+1)
  local t = {}
  for line in string.gmatch(spr,"[a-zA-Z.]+") do
    local ratio = math.floor(width/sprw)
    local nline = line * ratio
    local modulo = width%sprw
    if modulo ~= 0 then
      for i=0,modulo do
        nline = nline .. line[i]
      end
    end
    nline = nline .. "\n"
    table.insert(t,nline)
  end
  local nt = {}
  for i = 0,height-1 do
    local rid = (i%sprh)+1
    table.insert(nt,t[rid])
  end
  sprites.textures[id] = t_to_s(nt)
  return sprites.textures[id]
end

function sprites.select_color(id,mode)
  local tk = {}
  for k,v in pairs(am.ascii_color_map) do table.insert(tk,k) end
  table.sort(tk)
  if not am.ascii_color_map[tk[id]] then return false end
  sprites.selected[mode] = tk[id]
  return am.ascii_color_map[tk[id]]
end

sprites.drawing = 
[[
..
..
]]

--function tojs()
--    local p = io.open("bucket.txt","w+")
--    local par = {}
--    for line in string.gmatch(sprites.bucket,"[a-zA-Z.]+") do
--      local row = {}
--      for c in string.gmatch(line,"[a-zA-Z.]") do
--        table.insert(row,c)
--      end
--      table.insert(par,row)
--    end
--    local form = am.to_json(par)
--    p:write(form)
--    p:close()
--end
--tojs()
