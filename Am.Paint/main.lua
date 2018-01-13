math.randomseed(math.random(1000))

local meta = getmetatable("")
meta.__add = function(a,b)
  return a..b
end
meta.__mul = function(a,b)
  return string.rep(a,b)
end
meta.__index = function(a,b)
  if type(b) ~= "number" then return string[b] end
  return a:sub(b,b)
end

function wrap(str, limit)
  limit = limit or 72
  local here = 2
  return str:gsub("(.)()",function(l, n) if n-here == limit then here = n return "\n"..l end end)
end

function bounds(window)local w,h = window.pixel_width,window.pixel_height return vec4(-w*0.5,-h*0.5,w*0.5,h*0.5)end
function t_to_s(t) local s = [[]] for i,v in pairs(t) do s =s .. tostring(v) end return s end
function s_to_t(s) local t = {} for w in string.gmatch(s,"[a-zA-Z.0-9]+") do table.insert(t,w) end return t end
function math.between(min,v,max) if v>min and v<max then return true else return false end end
function math.ult(m,n) return m<n end
function math.ampl(v,d) return v<0 and v-d or v+d end
function math.trint(n)local i,f=math.modf(n) return f<0.5 and math.floor(n) or math.ceil(n) end
function math.round(n, deci) deci = 10^(deci or 10) return math.floor(n*deci+.5)/deci end
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end
function math.within(rect,pos) if pos.x>rect.r and pos.x<rect.b and pos.y>rect.g and pos.y<rect.a then return true else return false end end
function printTable(t) p='' for k,v in ipairs(t) do p=''..p ..k ..": " ..v .."\n" end print(p) end

function am.square(x,y,w,h,thickness,color)
  local width = w
  local height = h
  local function points()
  return {vec2(x,y),
          vec2(x,y+height),
          vec2(x+width,y+height),
          vec2(x+width,y)}
  end
  
  local inner = am.translate(0,0)
                ^ am.group()
                  ^ {am.line(points()[1],points()[2],thickness,color),
                     am.line(points()[2],points()[3],thickness,color),
                     am.line(points()[3],points()[4],thickness,color),
                     am.line(points()[4],points()[1],thickness,color)}
  local wrapped = am.wrap(inner):tag"square"
  function wrapped:get_x()
    return x
  end
  function wrapped:set_x(v)
    inner"translate".x = v
  end
  function wrapped:get_y()
    return y
  end
  function wrapped:set_y(v)
    inner"translate".y = v
  end
  function wrapped:get_scale()
    return height
  end
  function wrapped:set_scale(v)
    height = v
    width = v
    for i,child in inner"group":child_pairs() do
      child.point1 = points()[i]
      local id = i+1
      if id == 5 then id = 4 end
      child.point2 = points()[id]
    end
  end
  function wrapped:get_thickness()
    return thickness
  end
  function wrapped:set_thickness(v)
    thickness = v
    for i,child in inner"group":child_pairs() do
      child.thickness = v
    end
  end
  function wrapped:set_color(v)
    for i,child in inner"group":child_pairs() do
      child.color = v
    end
  end
  wrapped:action(coroutine.create(function(node)
        while true do
            am.wait(am.delay(0.4))
            node.color = vec4(0.9,0.9,0.9,1)
            am.wait(am.delay(0.4))
            node.color = vec4(1,1,1,1)
        end
    end))
  return wrapped
end

win = am.window{
    title = "Am.Paint v0.06.3",
    width = 960,
    height = 700,
    --resizable = false,
    --letterbox = false
}

onGui = false
onSys = false
onAct = false

Cuts = require "Shortcuts"
Parser = require "INIParser"
Maps = require "ColorMaps"
Cursor = require "Cursor"
Sprites = require "Sprites"
Color = require "Color"
GUI = require "GUI"
Inputs = require "Inputs"
Icons = require "Icons"
Viewer = require "View"
Palette = require "Palette"
Menu = require "Menu"
Canvas = require "Canvas"

win.scene = am.group()
            ^ {
              am.rect(win.left,
                      win.top,
                      win.right,
                      win.bottom,
                      vec4(0.1,0.1,0.1,1))
              , am.text("Create a\nnew canvas",vec4(0.5,0.5,0.5,1)):tag'create'
              , am.group():tag"here"
              , Color.node
              , Palette.node()
              , Menu.node()
              , Icons.node()
              , Viewer.node()
              , am.translate(-280,150)
                ^ am.text("log",vec4(1,1,1,0)):tag"log"
            }

--view.scene = am.group()
              --^ Viewer.node()