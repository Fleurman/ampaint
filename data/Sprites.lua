local sprites = ...

--am.ascii_color_map = {

--  A = vec4(0.55,0.55,0.55,1),
--  B = vec4(0.0,0.0,0.0,1),
--  C = vec4(0.0,0.43,0.93,1),
--  D = vec4(0.0,0.31,0.93,1),
--  E = vec4(0.37,0.23,0.95,1),
--  F = vec4(0.81,0.0,0.76,1),
--  G = vec4(0.89,0.0,0.16,1),
--  H = vec4(0.93,0.18,0.0,1),
--  I = vec4(0.85,0.32,0.02,1),
--  J = vec4(0.64,0.45,0.0,1),
--  K = vec4(0.67,0.67,0.0,1),
--  L = vec4(0.0,0.68,0.0,1),
--  M = vec4(0.0,0.62,0.0,1),
--  N = vec4(0.0,0.62,0.23,1),
--  O = vec4(0.0,0.49,0.49,1),
--  P = vec4(0.0,0.0,0.39,1),
--  Q = vec4(0.86,0.86,0.86,1),
--  R = vec4(0.16,0.16,0.16,1),
--  S = vec4(0.24,0.74,0.99,1),
--  T = vec4(0.41,0.53,0.99,1),
--  U = vec4(0.6,0.47,0.97,1),
--  V = vec4(0.97,0.47,0.97,1),
--  W = vec4(0.96,0.08,0.12,1),
--  X = vec4(0.97,0.47,0.35,1),
--  Y = vec4(0.99,0.63,0.27,1),
--  Z = vec4(0.97,0.72,0.0,1),
--  a = vec4(1.0,1.0,0.0,1),
--  b = vec4(0.72,0.97,0.09,1),
--  c = vec4(0.35,0.85,0.33,1),
--  d = vec4(0.35,0.97,0.6,1),
--  e = vec4(0.0,0.91,0.85,1),
--  f = vec4(0.31,0.0,0.31,1),
--  g = vec4(1.0,1.0,1.0,1),
--  h = vec4(0.35,0.35,0.35,1),
--  i = vec4(0.64,0.89,0.99,1),
--  j = vec4(0.72,0.72,0.97,1),
--  k = vec4(0.85,0.72,0.97,1),
--  l = vec4(0.97,0.72,0.97,1),
--  m = vec4(1.0,0.59,0.63,1),
--  n = vec4(0.94,0.82,0.69,1),
--  o = vec4(0.99,0.88,0.66,1),
--  p = vec4(0.97,0.85,0.47,1),
--  q = vec4(1.0,1.0,0.59,1),
--  r = vec4(0.78,1.0,0.47,1),
--  s = vec4(0.53,1.0,0.76,1),
--  t = vec4(0.68,1.0,1.0,1),
--  u = vec4(0.0,0.99,0.99,1),
--  v = vec4(0.1,0.2,0.0,1),

--  w = vec4(0.4,0.4,0.4,1),
--  x = vec4(0.44,0.44,0.44,1),

--  y = vec4(1,1,1,0.5),
--  z = vec4(0,0,0,0.5),
  
--}

--am.ascii_color_map = Maps.nes

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

sprites.menu_button2 =
[[
......QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ......
...gggggggggggggggQgQgQQgQQQgQQQQgQQQQQQQQQQQQQQQQQQQQQQA...
..gggQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQA..
.ggQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQA.
.gQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAA.
.gQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQA.
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAh
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAh
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAh
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAh
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAh
QgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAh
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAh
QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAhh
.QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAh.
.QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAh.
.QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAAhh.
..QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAQQQAQAQAQAAAAhh..
...QQQQQQQQQQQAQQQQAQQQAQQAQQAQAQAQAQAQAQAQAQAAAAAAAAAhhh...
......AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAhhhhhhhh......
]]

sprites.menu_button =
[[
BBggggggggggggggggggggggggggggggggggggggggggggggggggggggggBB
BgQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQB
gQQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQQQA
gQQA....................................................AQQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQA......................................................gQA
gQQA....................................................gQQA
gQQQggggggggggggggggggggggggggggggggggggggggggggggggggggQQQA
BAQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQAB
BBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABB
]]

sprites.pencil =
[[
........................
.................ggggQA.
...............ggqqqABB.
..............gmqqoonBg.
.............gmmqoonZng.
............gmmmoonZnZg.
...........gmmmmXnZnZJg.
..........gmmmXmXWnZJg..
.........gmmmXmXWGWHfg..
........gmmmXmXWGWGfg...
.......gmmmXmXWGWGfg....
......gmmmXmXWGWGfg.....
.....gmmmXmXWGWGfg......
....gmmmXmXWGWGfg.......
...gmmmXmXWGWGfg........
..gmXmXmXWGWGfg.........
.gmXmXmXWGWGfg..........
.gXmXmXWGWGfg...........
.gmXmXWGWGfg............
.gXmXWGWGfg.............
..gXGGWGfg..............
...gGGffg...............
....gggg................
........................
]]
sprites.norm =
[[
................
................
................
................
................
................
......gggg......
......gRRg......
......gRRg......
......gggg......
................
................
................
................
................
................
]]
sprites.size2 =
[[
................
................
................
................
......gggg......
......gRRg......
....gggRRggg....
....gRRRRRRg....
....gRRRRRRg....
....gggRRggg....
......gRRg......
......gggg......
................
................
................
................
]]
sprites.size3 =
[[
................
................
..gggggggggggg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gRRRRRRRRRRg..
..gggggggggggg..
................
................
]]

sprites.eraser =
[[
........................
..............gggg......
.............gQQQQg.....
............gQggggQg....
...........gQggggggQg...
..........gCCCQgggggQg..
.........gCSSSSQgggQgAg.
........gSSiiiSCQgggQAg.
.......gSiiiiiiSCQgQgAg.
......gSiiiiiiiiSCQgQAg.
.....gSiiiiiiiiiiSCQAg..
....gSiiiiiiiiiiSCEAg...
...gSSiiiiiiiiiSCSEg....
..gTSiiiiiiiSiSCSEg.....
.gTATiiiiiiSiSCSEg......
.gAgATiiSiSiSCSEg.......
.gQggATSiSiSCSEg........
..gQggATSiSCSEg.........
...gQggATSCSEg..........
....gQggQCSEg...........
.....gQgQQEg............
......gQQCg.............
.......ggg..............
........................
]]

sprites.bucket =
[[
........................
...........gggggggg.....
..........gAQAQQQAWg....
.........gAggggggWGWg...
.........gAQQQQgggWGWg..
.........gQAhhAQQggJGJg.
........gQghBBBhAQggJAg.
.......gQgQgBPBPhAQggAg.
......gQgQggAhPBPhAggQg.
.....gQgQggggAhPOPhQgQg.
....gQgQgggQQgAhPDPOgQg.
...gQQQgQgQQQQQAhPDCOQg.
..gQQQgQgQQQQQQAhhPDDg..
.gAQQgQQQQQQQQAAAhPDDOg.
.gAQgQQQQQQQQAAAhhDCCOg.
.gAQQQQQQQAQAQAhRgCiCOg.
.gAQQQQQQAQAQAARggCiCOg.
..gAQQQQAQAAAhRggCiCCOg.
..gAQQQAQAAAhRg.gCiCDOg.
...ghQhQAAhhRg..gCCCDOg.
....gRhhhhhRg...gDCDOg..
.....ggRRRRg.....gDOg...
.......gggg.......gg....
........................
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


sprites.bycolor = 
[[
................
................
..ggggg..ggggg..
..gDDDg..gHHHg..
..gDDDg..gHHHg..
..gDDDg..gHHHg..
..ggggg..ggggg..
................
................
..ggg....ggggg..
..gRRgg..gaaag..
..gRRRRg.gaaag..
..gRRgg..gaaag..
..ggg....ggggg..
................
................
]]

sprites.fillerase =
[[
................
................
.......gg.......
......gQAg......
.....gQQAAg.....
.....gAAQQg.....
....gAAAQQQg....
....gAAAQQQg....
...gAQQQAAAQg...
...gAQQQAAAQg...
...gAQQQAAAQg...
...gQAAAQQQAg...
...gQAAAQQQAg...
....gAAAQQQg....
.....gggggg.....
................
]]