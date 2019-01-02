table.map = function( tab, fn )
    for i,v in ipairs(tab) do
        tab[i] = fn(v)
    end
    return tab
end

function group( t, g )
    local new = {}
    local item = {}
    counter = 0
    for index, value in ipairs(t) do
        table.insert(item,value)
        if(index%g==0) then
            table.insert(new, table.shallow_copy( table.map(item,function(v) return v/255.0 end) ))
            item = {}
            counter = counter + 1
        end
    end
    return new
end

function toMap(tab,name)
    local chars = string.reverse('CBAFEDIHGLKJONMRQPUTSXWVaZYdcbgfejihmlkponsrqvut')
    local map = {
        w = vec4(0.4,0.4,0.4,1),
        x = vec4(0.44,0.44,0.44,1),
        y = vec4(1,1,1,0.5),
        z = vec4(0,0,0,0.5),
    }
    local c = 1

    for index, value in ipairs(tab) do
        map[chars[c]]  = vec4(unpack(value))
        c = c+1
    end
    
    am.ascii_color_map = map
    
    --print(table.tostring(map))
    
    return map
end

function readPalette(name)
    local buff = am.load_image(ROOT..'Palettes/'..name..'.png')
    if not buff then
      
    else
      local view = buff.buffer:view('ubyte')

      local values = {}
      for i=1,#view do
          table.insert(values,view[i])
      end

      local map = group(values, 4)
      
      return toMap(map)
    end
end

readPalette('SNES')