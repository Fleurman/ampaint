win = am.window{
    title = "Am.Paint v0.06.4",
    width = 1080,
    height = 700,
    resizable = false
    --letterbox = false
}

local scale = vec2(win.width/300,win.height/300)

win.scene = am.group()
            ^ {
               am.viewport(win.right,-win.bottom,300,300) ^am.scale(scale) 
               ^ am.translate(-150,-150) ^ am.rect(0,0,150,150,vec4(1,0.6,0.5,1)),
               am.rect(10,10,140,140,vec4(1))}