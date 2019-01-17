function group( t, g )
    local new = {}
    local item = {}
    counter = 0
    for index, value in ipairs(t) do
        table.insert(item,value)
        if(index%g==0) then
            table.insert(new, table.shallow_copy( table.map(item,function(v) return math.round(v/255.0)end) ))
            item = {}
            counter = counter + 1
        end
    end
    return new
end

function toMap(tab)
    local chars = string.reverse('CBAFEDIHGLKJONMRQPUTSXWVaZYdcbgfejihmlkponsrqvut')
    local map = {
        w = vec4(0.4,0.4,0.4,1),
        x = vec4(0.44,0.44,0.44,1),
        y = vec4(1,1,1,0.5),
        z = vec4(0,0,0,0.5),
    }
    local c = 1

    for index, value in ipairs(tab) do
        map[chars[c]]  = vec4(unpack(value)){a=1}
        c = c+1
    end
    
    am.ascii_color_map = map
    
    return map
end

function readPalette(name)
    local buff = am.load_image(ROOT..'Palettes/'..name..'.png')
    local view = buff.buffer:view('ubyte')

    local values = {}
    for i=1,#view do
      table.insert(values,view[i])
    end

    local map = group(values, 4)
    
    return toMap(map)
end
if io.exists(ROOT..'Palettes/SNES.png') then
  readPalette('SNES')
end
