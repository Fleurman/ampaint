math.randomseed(os.time())

--[[
  
  v0.09
  
  USE AM.GLOB for FileSystem Operations
    [ ] List Saves
    [ ] List Palettes
    
    ( ) renaming ?  os.rename(old,new)
    ( ) deleting ?  os.remove(file/dir)

]]

EXPORT = io.open('./../am.paint.exe') == nil
ROOT = ''
if EXPORT then ROOT = './../' end

VERSION = '0.08.5'
CONFIG = {
  window={
    width=1080,
    height=680,
    mode='windowed',
    resizable=false
  }
}

Cuts = require "Shortcuts"
Parser = require "Parser"

--[[------------------------------------------------------------------------------
                              **WINDOW CREATION**
----------------------------------------------------------------------------------]]
win = am.window{
    title = "Am.Paint v0.08.5",
    width = CONFIG.window.width,
    height = CONFIG.window.height,
    mode = CONFIG.window.mode,
    resizable = CONFIG.window.resizable,
    --borderless=true,
    --letterbox = false
}
--[[------------------------------------------------------------------------------
                              **GLOBAL VARIABLES**
----------------------------------------------------------------------------------]]
onGui = false
onSys = false
onAct = false
onAlt = false

require "metamethods"
require "Misc"
Src = require "Ressources"
Maps = require "ColorMaps"

require "PaletteReader"

Cursor = require "Cursor"
Sprites = require "Sprites"
Color = require "Color"
GUI = require "GUI"
Inputs = require "Inputs"
Icons = require "Icons"
Viewer = require "View"
Layers = require "Layers"
Palette = require "Palette"
Menu = require "Menu"
OLayer = require "OLayer"
Canvas = require "Canvas"


--[[------------------------------------------------------------------------------
                                  **WINDOW SCENE**
----------------------------------------------------------------------------------]]
win.scene = am.group()
            ^ {
              am.rect(win.left,
                      win.top,
                      win.right,
                      win.bottom,
                      vec4(0.1,0.1,0.1,1))
              , am.text('Create a\nnew canvas',vec4(0.5,0.5,0.5,1)):tag'create'
              , am.group():tag'tiled'
              , am.group():tag'here'
              , Color.node
              , Palette.node()
              , Menu.node()
              , Icons.node()
              , Viewer.node()
              , Layers.node()
              , am.translate(-280,150)
                ^ am.text("log",vec4(1,1,1,0)):tag"log"
            }



--win.scene'log'.color = Color.white

-- win.scene:append(GUI.list())

-- win.scene:append(GUI.vslider(50,0,20,200,Color.over,'down'))
-- win.scene:append(GUI.vslider(-50,0,20,200,Color.over,'up'))

-- win.scene:append(am.translate(0,0)^am.rect(0,0,64,80,vec4(0,1,0,1)))
-- win.scene:append(am.translate(0,0)^GUI.frame(0,-80,64,80))

-- 'Exports/windowframe.png'

-- win.scene:append(GUI.frame(0,0,200,300))


--logwin = am.window{
--    title = "Log",
--    width = 600,
--    height = 240,
--    resizable = true,
--    letterbox = false
--}
--logwin.scene = am.group() ^ am.text("log",vec4(1,1,1,0)):tag"log"
