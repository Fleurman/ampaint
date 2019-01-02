local Parser = ...

Parser.valids = {
  window={'width','height'},
  cuts= {'Save','Save As','Export','Export As','Center view','Color picker','Swap Color','Move','Pencil','Eraser','Bucket','Toggle  viewer','Toggle tiles','Undo','Redo','Delete All'}
}
Parser.keys = {
  window={'860','620'},
  cuts={'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','ctrl','alt','shift','left','right','up','down','enter','backspace','space'}
}

local state = ''
  
function trim(s)
  s = string.gsub(s,"%s*$",'')
  return string.gsub(s,"^%s*",'')
end
function Parser:parseINI(t)
  
  if(trim(t)[1] == '#') then return end
  
  local invalid = false
  local values = {}
  
  local realm = string.match(t,'%[(.+)%]')
  if realm then
    realm = string.lower(realm)
    if not(realm == state) then 
      state = realm 
    end
  end
  
  if state == 'window' then
    local id,id2,k,v = string.find(t,'([^=]+)=(.+)')
    if id then
      k,v = trim(k),trim(v)
      if (validWindowINIkey(k)) then
        if k=='width' then
          if v and type(tonumber(v)) == 'number' then
            local w = tonumber(v)
            w = math.max(800,math.min(1920,w))
            CONFIG.window.width = w
          end
        elseif k=='height' then
          if v and type(tonumber(v)) == 'number' then
            local h = tonumber(v)
            h = math.max(560,math.min(1280,h))
            CONFIG.window.height = h
          end
--        elseif k=='fullscreen' then
--          if v then
--            if v == 'true' then
--              CONFIG.window.mode = 'fullscreen'
--            end
--          end
--        elseif k=='resizable' then
--          if v then
--            local bool = v == 'true'
--            CONFIG.window.resizable = v
--          end
        end
      end
    end
  elseif state == 'shortcuts' then
    local id,id2,k,v1,v2,v3 = string.find(t,'([^=]+)%s+=%s*(%a+)+?([^+]*)+?([^+]*)')
    if id then
    --print('shortcut:',id,id2,k,v1,v2,v3)
      if validShortcutsINIkey(k) then
        if #v1 > 0 then if validShortcutsINIvalue(v1) then table.insert(values,v1) else invalid=true end end
        if #v2 > 0 then if validShortcutsINIvalue(v2) then table.insert(values,v2) else invalid=true end end
        if #v3 > 0 then if validShortcutsINIvalue(v3) then table.insert(values,v3) else invalid=true end end
        if not invalid then
          k = string.gsub(k,'%s*','')
          k = string.lower(k)
          Cuts.data[k] = values
        end
      end
    end
  end
end

function validWindowINIkey(t) if table.search(Parser.valids.window,t) then return true else return false end end

function validShortcutsINIkey(t) if table.search(Parser.valids.cuts,t) then return true else return false end end
function validShortcutsINIvalue(t) if table.search(Parser.keys.cuts,t) then return true else return false end end

function Parser:readINI()
  local f = io.open('CONFIG.ini','r+')
  if not f then f = io.open('Config.ini','r+') end
  if not f then f = io.open('config.ini','r+') end
  if not f then f = io.open('CONFIG.txt','r+') end
  if not f then f = io.open('Config.txt','r+') end
  if not f then f = io.open('config.txt','r+') end
  if f then
    for line in f:lines() do
      if line == '' or line[1] == '[' then else
        self:parseINI(line)
      end
    end
  end
end
Parser:readINI()