local Parser = ...

Parser.valids = {'Save','Save As','Export','Export As','Center view','Color picker','Swap Color','Move','Pencil','Eraser','Bucket','Viewer','Undo','Redo','Delete All'}
Parser.keys = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','ctrl','alt','shift','left','right','up','down','enter','backspace','space'}

function Parser:parseINI(t)
  id,id2,k,v1,v2,v3 = string.find(t,'([^=]+)%s+=%s*(%a+)+?([^+]*)+?([^+]*)')
  local invalid = false
  local values = {}
  if validINIkey(k) then
    if #v1 > 0 then if validINIvalue(v1) then table.insert(values,v1) else invalid=true end end
    if #v2 > 0 then if validINIvalue(v2) then table.insert(values,v2) else invalid=true end end
    if #v3 > 0 then if validINIvalue(v3) then table.insert(values,v3) else invalid=true end end
    if not invalid then
      k = string.gsub(k,'%s*','')
      k = string.lower(k)
      Cuts.data[k] = values
      --printTable(values)
    end
  end
end

function validINIkey(t) if table.search(Parser.valids,t) then return true else return false end end
function validINIvalue(t) if table.search(Parser.keys,t) then return true else return false end end

function Parser:readINI()
  local f = io.open('SHORTCUTS.ini','r+')
  for line in f:lines() do
    if line == '' or line[1] == '[' then else
      self:parseINI(line)
    end
  end
end
Parser:readINI()