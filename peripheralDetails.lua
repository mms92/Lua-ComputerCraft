local file = fs.open("peripheral_details.data", "w")
 
local function explore(t)
    local t_form = {}
    for k,v in pairs(t) do
        local valueType = type(v)
  if valueType == "table" then 
      t_form[k] = explore(v)
        elseif valueType == "function" then
            local pcallRet = {pcall(v)}
            if pcallRet[1] then
    table.remove(pcallRet, 1)
    local format_name = ("%s()"):format(k)
    print(format_name)
                t_form[format_name] = explore(pcallRet)
   else
     local i = 0
     repeat
       pcallRet = {pcall(v,i)}
       i = i + 1
     until pcallRet[1] or i > 10
     if pcallRet[1] then
         local format_name = ("%s(?: number)"):format(k)
         table.remove(pcallRet, 1)
         t_form[format_name] = explore(pcallRet)
     else
         local format_name = ("%s(?...)"):format(k)
         t_form[format_name] = "???"
     end
            end
        else
            print(k, valueType)
            t_form[k] = valueType
        end
        os.sleep(1/20);
    end
    return t_form
end
 
local data = {}
 
for i,v in ipairs( peripheral.getNames() ) do
    print(v)
    os.sleep(1/20);
    data[v] = {
        ["type"] = peripheral.getType(v),
        ["description"] = explore(peripheral.wrap(v))
    }
end
 
local text_data = textutils.serialize(data)
 
file.write(text_data)
file.close()