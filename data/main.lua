math.randomseed(os.time())

EXPORT = not io.open('am.paint.exe')
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
Cuts = require "./data/Shortcuts"
Parser = require "./data/Parser"

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

require "./data/metamethods"
require "./data/Misc"
Src = require "./data/Ressources"
Maps = require "./data/ColorMaps"

require "./data/PaletteReader"

Cursor = require "./data/Cursor"
Sprites = require "./data/Sprites"
Color = require "./data/Color"
GUI = require "./data/GUI"
Inputs = require "./data/Inputs"
Icons = require "./data/Icons"
Viewer = require "./data/View"
Layers = require "./data/Layers"
Palette = require "./data/Palette"
Menu = require "./data/Menu"
OLayer = require "./data/OLayer"
Canvas = require "./data/Canvas"


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