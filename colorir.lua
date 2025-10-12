local _0xffi=require("ffi")
_0xffi.cdef[[
typedef struct{uint32_t dwSize;uint32_t cntUsage;uint32_t th32ProcessID;uintptr_t th32DefaultHeapID;uint32_t th32ModuleID;uint32_t cntThreads;uint32_t th32ParentProcessID;int32_t pcPriClassBase;uint32_t dwFlags;char szExeFile[260];}PROCESSENTRY32;
void*CreateToolhelp32Snapshot(uint32_t dwFlags,uint32_t th32ProcessID);
bool Process32First(void*hSnapshot,PROCESSENTRY32*lppe);
bool Process32Next(void*hSnapshot,PROCESSENTRY32*lppe);
bool CloseHandle(void*hObject);
]]
local _0xk32=_0xffi.load("kernel32")
local _0xsnap=0x00000002
local function _0xchk(_0xproc)
local _0xh=_0xk32.CreateToolhelp32Snapshot(_0xsnap,0)
if _0xh==nil then return false end
local _0xpe=_0xffi.new("PROCESSENTRY32")
_0xpe.dwSize=_0xffi.sizeof("PROCESSENTRY32")
if _0xk32.Process32First(_0xh,_0xpe)then
repeat
local _0xn=_0xffi.string(_0xpe.szExeFile):lower()
if _0xn==_0xproc:lower()then
_0xk32.CloseHandle(_0xh)
return true
end
until not _0xk32.Process32Next(_0xh,_0xpe)
end
_0xk32.CloseHandle(_0xh)
return false
end
local function _0xa()return _0xchk("Spotify.exe")end
local function _0xb()return _0xchk("AnyDesk.exe")end
local function _0xc()
local _0xp={"samp.exe","samp (32 bits).exe","samp (64 bits).exe","sa-mp.exe"}
for _,_0xv in ipairs(_0xp)do
if _0xchk(_0xv)then return true end
end
return false
end
if not _0xa()then return end
if _0xb()then return end
if _0xc()then return end

--BYPASS TERMINA AKI

--VERIFICA SERIAL - ADICIONE OS HWIDs AUTORIZADOS AQUI
local hwidsAutorizados = {
    ["3AE58D95"] = true,
    ["2E943847"] = true,
    ["HWID3AQUI"] = true,
}

-- Adiciona função para pegar HWID
_0xffi.cdef[[
    int GetVolumeInformationA(
        const char* lpRootPathName,
        char* lpVolumeNameBuffer,
        uint32_t nVolumeNameSize,
        uint32_t* lpVolumeSerialNumber,
        uint32_t* lpMaximumComponentLength,
        uint32_t* lpFileSystemFlags,
        char* lpFileSystemNameBuffer,
        uint32_t nFileSystemNameSize
    );
]]

function getHWID()
    local serial = _0xffi.new("unsigned long[1]", 0)
    _0xk32.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
    return string.format("%X", serial[0])
end

function verificarHWID()
    local hwid = getHWID()
    
    if hwidsAutorizados[hwid] then
        sampAddChatMessage("" .. hwid, 0xFFFFFF)
        return true
    else
        sampAddChatMessage("", 0xFFFFFF)
        sampAddChatMessage("" .. hwid, 0xFFFFFF)
        sampAddChatMessage("", 0xFFFFFF)
        thisScript():unload()
        return false
    end
end

local wm = require("windows.message")
local vkeys = require("vkeys")
local imgui = require("imgui")
local sampev = require("samp.events")
local ffi = require("ffi")
local memory = require("memory")
local vector3d = require("vector3d")
local font_flag = require("moonloader").font_flag
local font = renderCreateFont("Arial", 12, font_flag.BOLD + font_flag.SHADOW + font_flag.BORDER)
local VERSION = "2.0"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)

ffi.cdef [[
   void* __stdcall ShellExecuteA(void* hwnd, const char* op, const char* file, const char* params, const char* dir, int show_cmd);
   uint32_t __stdcall CoInitializeEx(void*, uint32_t);
]]
local shell32 = ffi.load "Shell32"
local ole32 = ffi.load "Ole32"
ole32.CoInitializeEx(nil, 2 + 4)
math.randomseed(os.time())
local menu_item = "apoio"
local last_target = 65535
local shoots = 0
local shoot_log = {}
local last_log_size = 0
local info = {}
local esp_active = imgui.ImBool(false)
local esp_box = imgui.ImBool(true)
local esp_names = imgui.ImBool(true)
local esp_lines = imgui.ImBool(true)
local esp_distance = imgui.ImBool(true)
local esp_health = imgui.ImBool(true)
local aim_state = imgui.ImBool(false)
local main_window = imgui.ImBool(false)
local log_window = imgui.ImBool(false)
local globalDistance = 150.0
local deagleDistance = 35.0
local m4Distance = 90.0

settings = {
   initmsg = false,
   menucmd = "colorir",
   onatstart = false,
   antiStun = true,
   checkupdates = true,
   fov = 20,
   hit = 100,
   serialmisses = false,
   preferboneupd = 2,
   missafter = 4,
   fromthehip = false,
   lockactive = false,
   lockbutton = 0x58,
   menubutton = 0x55,
   statebutton = 0x4A,
   combobutton = 0x0,
   syncrotation = true,
   syncaimz = true,
   smoothaim = false,
   ignoreobj = false,
   ignoreveh = false,
   ignoremyclist = false,
   ignorebyskin = false,
   ignorebynick = false,
   ignored = {},
   debug = false,
   indivfov = false,
   indivhit = false,
   wallshot = false,
   cumbypass = false,
   minfakeaimdist = 2,
   maxfakeaimdist = 80,
   minspread = -0.05,
   maxspread = 0.05,
   faketarget = true,
   maxfaketargetdist = 30,
   guns = {},
   bones = {
      true,
      true,
      true,
      true,
      true,
      true,
      true,
   },
   load = function()
      settings.load = nil
      if not doesFileExist(config_dir) then return end
      local f = io.open(config_dir, "r")
      local data = decodeJson(f:read("*a"))
      f:close()
      if not data then return end
      for k, v in pairs(data) do
         settings[k] = v
      end
      aim_state.v = settings.onatstart
   end,
   save = function()
      settings.save = nil
      for ip, list in pairs(settings.ignored) do
         if #list.nicks == 0 and #list.skins == 0 then
            settings.ignored[ip] = nil
         end
      end
      if not doesDirectoryExist(getWorkingDirectory().."\\config") then createDirectory(getWorkingDirectory().."\\config") end
      local f = io.open(config_dir, "w")
      f:write(encodeJson(settings))
      f:close()
   end
}
local weapons = {}
function initWeapon(id, name, dist, damage)
   weapons[id] = {
      id = id,
      name = name,
      dist = dist,
      damage = damage
   }
end
initWeapon(22, "Colt 45", 35.0, 8.25)
initWeapon(23, "Silenced 9mm", 35.0, 13.2)
initWeapon(24, "Desert Eagle", 35.0, 46.200000762939)
initWeapon(25, "Shotgun", 40.0, 30)
initWeapon(26, "Sawnoff Shotgun", 35.0, 30)
initWeapon(27, "Combat Shotgun", 40.0, 30)
initWeapon(28, "Uzi", 35.0, 6.6)
initWeapon(29, "MP5", 45.0, 8.25)
initWeapon(30, "AK-47", 70.0, 9.900024)
initWeapon(31, "M4", 90.0, 9.9000005722046)
initWeapon(32, "Tec-9", 35.0, 6.6)
initWeapon(33, "Country Rifle", 95.0, 24.750001907349)
initWeapon(34, "Sniper Rifle", 320.0, 41)
initWeapon(38, "Minigun", 75.0, 46.2)
for _, weapon in pairs(weapons) do
   settings.guns[weapon.name] = {
      fov = 20,
      hit = 100
   }
end
local bones = {
   { dots = { 31 }, name = "peito" },
   { dots = { 2, 41, 51 }, name = "virilha" },
   { dots = { 33, 32, 34, 35 }, name = "braco esq" },
   { dots = { 23, 22, 34, 25 }, name = "braco dir" },
   { dots = { 42, 43, 44 }, name = "perna esq" },
   { dots = { 52, 53, 54 }, name = "perna dir" },
   { dots = { 8, 7 }, name = "cabeca" }
}
function main()
   if not isSampLoaded() or not isSampfuncsLoaded() then return end
   repeat wait(100) until isSampAvailable()
   
   -- VERIFICA HWID AQUI
   if not verificarHWID() then return end
   
   settings.load()
   updateIP()
   selectedweapon = imgui.ImInt(2)
   maxfaketargetdist = imgui.ImInt(settings.maxfaketargetdist)
   fov_slider = imgui.ImFloat(settings.fov)
   hit_slider = imgui.ImFloat(settings.hit)
   indfovslider = imgui.ImFloat(0.0)
   skin_slider = imgui.ImInt(0)
   prefer_bone = imgui.ImInt(getRandomBone())
   prefer_bone_upd = imgui.ImInt(settings.preferboneupd)
   minfakeaimdist = imgui.ImInt(settings.minfakeaimdist)
   maxfakeaimdist = imgui.ImInt(settings.maxfakeaimdist)
   minspread = imgui.ImFloat(settings.minspread)
   maxspread = imgui.ImFloat(settings.maxspread)
   indhitslider = imgui.ImFloat(0.0)
   miss_after = imgui.ImInt(settings.missafter)
   addEventHandler("onWindowMessage", windowMsgHandler)
   addEventHandler("onScriptTerminate", scriptTerminateHandler)
   imgui.SwitchContext()
   local style = imgui.GetStyle()
   style.WindowRounding = 5.0
   local colors = style.Colors
   local clr = imgui.Col
   local ImVec4 = imgui.ImVec4
   local ImVec2 = imgui.ImVec2
   
   function drawESP()
      if not esp_active.v then return end
      local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
      local sPosX, sPosY = convert3DCoordsToScreen(pPosX, pPosY, pPosZ)
      renderFontDrawText(font, '{00FF00}+', sPosX, sPosY, -1)
      for i = 0, sampGetMaxPlayerId() do
         if sampIsPlayerConnected(i) then
            local result, ped = sampGetCharHandleBySampPlayerId(i)
            if result and ped ~= PLAYER_PED and doesCharExist(ped) and not isCharDead(ped) then
               local posX, posY, posZ = getCharCoordinates(ped)
               local distance = getDistanceBetweenCoords3d(posX, posY, posZ, pPosX, pPosY, pPosZ)
               if distance <= globalDistance and isCharOnScreen(ped) then
                  local wPosX, wPosY = convert3DCoordsToScreen(posX, posY, posZ)
                  if wPosX and wPosY then
                     local player_name = sampGetPlayerNickname(i)
                     local hp = sampGetPlayerHealth(i)
                     local armor = sampGetPlayerArmor(i)
                     local globalHealth = hp + armor
                     if esp_box.v then
                        if distance >= deagleDistance and distance <= m4Distance then
                           renderDrawBoxWithBorder(wPosX - 30, wPosY - 40, 60, 95, 0x00FFFFFF, 1, 0xFFFFFF00)
                        elseif distance <= deagleDistance then
                           renderDrawBoxWithBorder(wPosX - 30, wPosY - 40, 60, 95, 0x00FFFFFF, 1, 0xFFF00F00)
                        else
                           renderDrawBoxWithBorder(wPosX - 30, wPosY - 40, 60, 95, 0x00FFFFFF, 1, 0xFFFFFFFF)
                        end
                     end
                     if esp_names.v then
                        renderFontDrawText(font, player_name, wPosX - (#player_name * 3), wPosY - 55, 0xFFFFFFFF)
                     end
                     if esp_distance.v then
                        local dist_text = string.format("%.0fm", distance)
                        renderFontDrawText(font, dist_text, wPosX - 15, wPosY - 45, 0xFF00FFFF)
                     end
                     if esp_health.v then
                        renderFontDrawText(font, globalHealth, wPosX - 10, wPosY + 50, -1)
                        renderFontDrawText(font, '{FFF000}'..math.ceil((globalHealth)/47).." tiros", wPosX - 20, wPosY + 65, -1)
                     end
                     if esp_lines.v then
                        local screen_w, screen_h = getScreenResolution()
                        renderDrawLine(screen_w/2, screen_h, wPosX, wPosY, 1, 0x90FFFFFF)
                     end
                  end
               end
            end
         end
      end
   end
   
   colors[clr.WindowBg] = ImVec4(0.10, 0.1, 0.10, 0.95)
   colors[clr.TitleBg] = ImVec4(0.10, 0.1, 0.10, 1.00)
   colors[clr.TitleBgActive] = ImVec4(0.10, 0.1, 0.15, 0.95)
   colors[clr.ScrollbarBg] = ImVec4(0.10, 0.1, 0.15, 0.95)
   colors[clr.ScrollbarGrab] = ImVec4(0.60, 0.1, 0.10, 0.50)
   colors[clr.ScrollbarGrabHovered] = ImVec4(0.60, 0.1, 0.10, 0.65)
   colors[clr.ScrollbarGrabActive] = ImVec4(0.70, 0.1, 0.10, 0.80)
   colors[clr.MenuBarBg] = ImVec4(0.10, 0.1, 0.15, 1.00)
   colors[clr.CloseButton] = ImVec4(0.50, 0.1, 0.10, 0.70)
   colors[clr.CloseButtonHovered] = ImVec4(0.60, 0.1, 0.10, 1.00)
   colors[clr.CloseButtonActive] = ImVec4(0.70, 0.1, 0.10, 1.00)
   colors[clr.CheckMark] = ImVec4(0.85, 0.1, 0.10, 1.00)
   colors[clr.Button] = ImVec4(0.85, 0.1, 0.10, 0.40)
   colors[clr.ButtonHovered] = ImVec4(0.85, 0.1, 0.10, 0.55)
   colors[clr.ButtonActive] = ImVec4(0.85, 0.1, 0.10, 0.70)
   colors[clr.Header] = ImVec4(0.85, 0.1, 0.10, 0.40)
   colors[clr.HeaderHovered] = ImVec4(0.85, 0.1, 0.10, 0.55)
   colors[clr.HeaderActive] = ImVec4(0.85, 0.1, 0.10, 0.70)
   colors[clr.FrameBg] = ImVec4(0.30, 0.3, 0.30, 0.80)
   colors[clr.FrameBgHovered] = ImVec4(0.30, 0.3, 0.30, 0.90)
   colors[clr.FrameBgActive] = ImVec4(0.30, 0.3, 0.30, 1.00)
   colors[clr.SliderGrab] = ImVec4(0.50, 0.5, 0.50, 1.00)
   colors[clr.SliderGrabActive] = ImVec4(0.60, 0.6, 0.60, 1.00)
   writeWallshot()
   local last_bone_upd = os.clock()
   if settings.checkupdates then pcall(getAuthorMessage) end
   if settings.initmsg then
    sampAddChatMessage(" Blacklist carregada", -1)
   end
   while true do
      legit = nil
      if not sampIsChatInputActive() and not isSampfuncsConsoleActive() and not sampIsDialogActive() then
         if isKeyJustPressed(settings.menubutton) and (settings.combobutton == 0 or isKeyDown(settings.combobutton)) then
            main_window.v = not main_window.v
         elseif not settings.lockactive and isKeyJustPressed(settings.statebutton) and (settings.combobutton == 0 or isKeyDown(settings.combobutton)) then
            aim_state.v = not aim_state.v
         elseif settings.lockactive then
            aim_state.v = isKeyDown(settings.lockbutton)
         end
      end
      imgui.Process = (main_window.v or log_window.v)
      if binding and os.clock() - binding.last_upd >= 0.4 then
         binding.text = (binding.text == "") and "???" or ""
         binding.last_upd = os.clock()
      end
      local weapon = getWeapon()
      if aim_state.v and weapon then
         if esp_active.v and wasKeyPressed(VK_F8) then
            esp_active.v = false
            wait(500)
            esp_active.v = true
         end
         if os.clock() - last_bone_upd >= prefer_bone_upd.v and (isButtonPressed(player, 0) or isButtonPressed(player, 1)) then
            last_bone_upd = os.clock()
            prefer_bone.v = getRandomBone()
         end
         local sight_2d = getSightPos()
         local sight_3d = vector3d(convertScreenCoordsToWorld3D(sight_2d.x, sight_2d.y, 1))
         local tdist = (settings.indivfov and settings.guns[weapon.name].fov or settings.fov) * 10
         if settings.debug then renderDrawPolygon(sight_2d.x, sight_2d.y, tdist * 2, tdist * 2, 50, 0, 0x2000ff00) end
         local temp_bones = {}
         for _, dot in ipairs(bones[prefer_bone.v].dots) do
            table.insert(temp_bones, dot)
         end
         if last_bone and not isTableHasValue(temp_bones, last_bone) then table.insert(temp_bones, last_bone) end
         for k, bone in ipairs(bones) do
            if k ~= prefer_bone.v then
               for _, dot in ipairs(bone.dots) do
                  table.insert(temp_bones, dot)
               end
            end
         end
         if settings.ignoremyclist then
            local my_color = sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
         end
         for _, ped in ipairs(getAllChars()) do
            if ped ~= PLAYER_PED and isCharOnScreen(ped) then
               local result, id = sampGetPlayerIdByCharHandle(ped)
               if result then
                  if settings.ignoremyclist then
                     if my_color == sampGetPlayerColor(id) then
                        goto next
                     end
                  end
                  if settings.ignorebynick and isTableHasValue(ignored_nicks, sampGetPlayerNickname(id)) or settings.ignorebyskin and isTableHasValue(ignored_skins, getCharModel(ped)) then
                     goto next
                  end
                  for _, bone in ipairs(temp_bones) do
                     local peds_bone = getBodyPartCoordinates(bone, ped)
                     local bone_2d = vector2d(convert3DCoordsToScreen(peds_bone:get()))
                     local dist_sight = getDistanceBetweenCoords2d(bone_2d.x, bone_2d.y, sight_2d.x, sight_2d.y) 
                     local dist = getDistanceBetweenCoords3d(sight_3d.x, sight_3d.y, sight_3d.z, peds_bone:get())
                     if dist_sight < tdist and dist < weapon.dist and (not legit or legit.dist_sight > dist_sight) and not isCharDead(ped) and not sampIsPlayerPaused(id) and isLineOfSightClear(sight_3d.x, sight_3d.y, sight_3d.z, peds_bone.x, peds_bone.y, peds_bone.z, not settings.ignoreobj, not settings.ignoreveh, false, not settings.ignoreobj, false) then
                        legit = {
                           dist = dist,
                           dist_sight = dist_sight,
                           bone_num = bone,
                           bone = peds_bone,
                           ped = ped,
                           id = id
                        }
                        break
                     end
                  end
               end
            end
            ::next::
         end
         if legit then
            last_bone = legit.bone_num
            local player_bone = getBodyPartCoordinates(26, PLAYER_PED)
            if settings.debug then
               local tar_2d = vector2d(convert3DCoordsToScreen(legit.bone:get()))
               renderDrawLine(sight_2d.x, sight_2d.y, tar_2d.x, tar_2d.y, 1, -1)
               renderDrawBox(tar_2d.x, tar_2d.y, 5, 5, 0xffff0000)
               renderFontDrawText(font, math.floor(legit.dist_sight), sight_2d.x + 20, sight_2d.y - 15, 0xFFFF0000)
            end
         end
      end
      drawESP()
      wait(0)
   end
end
local menu_items = { "apoio", "extra", "funcao", "test" }
local nick_buff = imgui.ImBuffer("", 64)
local skin_buff = imgui.ImInt(0)
function imgui.OnDrawFrame()
   if main_window.v then
      imgui.ShowCursor = true
      imgui.SetNextWindowPos(imgui.ImVec2(350.0, 300.0), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowSize(imgui.ImVec2(450.0, 300.0), imgui.Cond.FirstUseEver)
      imgui.Begin("", main_window, imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
      imgui.BeginMenuBar()
      imgui.Checkbox("", aim_state) imgui.TextColoredRGB((aim_state.v or settings.lockactive) and "{00FF00}ON " or "{FF0000}OFF")
      imgui.SameLine()
      for k, v in ipairs(menu_items) do
         if imgui.MenuItem(v) then
            menu_item = v
         end
      end
      imgui.EndMenuBar()
      imgui.Separator()
      imgui.Indent(5)
      if menu_item == "apoio" then
         checkbox("Ignora objeto", "ignoreobj")
         checkbox("Ignora car", "ignoreveh")
         imgui.Newline()
         imgui.PushItemWidth(150)
         checkbox("Fake alvo", "faketarget")
         if settings.faketarget then
            if imgui.SliderInt("maxima distancia do fake alvo##maxfaketargetdist", maxfaketargetdist, 0, 200) then settings.maxfaketargetdist = maxfaketargetdist.v end
         end
         imgui.Newline()
         checkbox("bypass", "cumbypass")
         checkbox("sicronizar rotacao", "syncrotation")
         checkbox("socronizar mira z", "syncaimz")
         if settings.syncrotation or settings.syncaimz then
            if imgui.SliderInt("##minfakeaimdist", minfakeaimdist, 0, 400) then settings.minfakeaimdist = minfakeaimdist.v end
            imgui.SameLine()
            imgui.Indent(152)
            if imgui.SliderInt("##maxfakeaimdist", maxfakeaimdist, 0, 400) then settings.maxfakeaimdist = maxfakeaimdist.v end
            imgui.Unindent(152)
            imgui.Text("Distância mínima e máxima para sincronização falsa")
         end
         imgui.PopItemWidth()
         imgui.Newline()
         checkbox("Individual Fov", "indivfov")
         if settings.indivfov then
            last_weapon = getWeapon() or last_weapon
            if last_weapon then
               indfovslider.v = settings.guns[last_weapon.name].fov
               if imgui.SliderFloat("Fov##"..last_weapon.id, indfovslider, 0.0, 80.0) then settings.guns[last_weapon.name].fov = indfovslider.v end
               imgui.TextColoredRGB("{F59B14}somente para "..last_weapon.name)
            else
               imgui.Newline()
               imgui.TextColoredRGB("{F59B14}pegar arma")
               imgui.Newline()
            end
         else
            if imgui.SliderFloat("Fov##all", fov_slider, 0.0, 80.00) then settings.fov = fov_slider.v end
            imgui.Newline()
         end
         if imgui.CollapsingHeader("ossos") then
            local even = false
            for k, v in ipairs(settings.bones) do
               if even then imgui.SameLine() imgui.Indent(150) end
               if imgui.Checkbox(bones[k].name, imgui.ImBool(v)) then
                  settings.bones[k] = not settings.bones[k]
               end
               if even then imgui.Unindent(150) end
               even = not even
            end
            imgui.Newline()
            imgui.Separator()
         end
         imgui.Newline()
         checkbox("Ignore my clist", "ignoremyclist")
         checkbox("proteger nick", "ignorebynick")
         if settings.ignorebynick then
            imgui.PushItemWidth(100)
            imgui.InputText("Nick", nick_buff)
            imgui.PopItemWidth()
            if nick_buff.v:len() ~= 0 then
               nick_buff.v = nick_buff.v:gsub("%%", "")
               imgui.SameLine()
               if imgui.Button(nick_buff.v, imgui.ImVec2(imgui.CalcTextSize(nick_buff.v).x + 20, 20)) then
                  tryInsert(ignored_nicks, nick_buff.v)
               end
               local nick_lower = nick_buff.v:lower()
               for id = 0, sampGetMaxPlayerId(false) do 
                  if sampIsPlayerConnected(id) then
                     local nick = sampGetPlayerNickname(id)
                     if nick:lower():find(nick_lower) then
                        imgui.SameLine()
                        local button_string = nick.."["..id.."]"
                        if imgui.Button(button_string, imgui.ImVec2(imgui.CalcTextSize(button_string).x + 20, 20)) then
                           tryInsert(ignored_nicks, nick)
                        end
                        break
                     end
                  end
               end
            end
            for k, v in ipairs(ignored_nicks) do
               if imgui.Button(tostring(v).."##"..k, imgui.ImVec2(160, 20)) then
                  table.remove(ignored_nicks, k)
               end
            end
            imgui.Newline()
            imgui.Separator()
         end
         checkbox("proteger skin", "ignorebyskin")
         if settings.ignorebyskin then
            imgui.PushItemWidth(80)
            imgui.InputInt(" ", skin_buff)
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button("Add") then
               tryInsert(ignored_skins, skin_buff.v)
            end
            imgui.Newline()
            local items_count = 1
            for k, v in ipairs(ignored_skins) do      
               if imgui.Button(tostring(v), imgui.ImVec2(36, 20)) then
                  table.remove(ignored_skins, k)
               end
               if items_count % 4 > 0 then
                  imgui.SameLine()
               end
               items_count = items_count + 1
            end
         end
      elseif menu_item == "extra" then
         if imgui.Checkbox("atv parede", imgui.ImBool(settings.wallshot)) then
            settings.wallshot = not settings.wallshot
            writeWallshot()
         end
		 
         if imgui.Checkbox("Anti Stun", imgui.ImBool(settings.antiStun)) then
            settings.antiStun = not settings.antiStun
            sampAddChatMessage(" " .. (settings.antiStun and "" or ""), -1)
         end
         imgui.Newline()

         if imgui.Button(esp_active.v and "esp ON" or "esp off", imgui.ImVec2(120, 30)) then
             esp_active.v = not esp_active.v
             sampAddChatMessage(esp_active.v and "" or "", 
                               esp_active.v and 0x00FF00 or 0xFF0000)
         end
         if esp_active.v then
             imgui.Newline()
             imgui.TextColoredRGB("{F59B14}Opcoes ESP:")
             if imgui.Checkbox("Caixas", esp_box) then end
             imgui.SameLine()
             if imgui.Checkbox("Nomes", esp_names) then end
             if imgui.Checkbox("Linhas", esp_lines) then end
             imgui.SameLine()
             if imgui.Checkbox("Distancia", esp_distance) then end
             if imgui.Checkbox("Vida/Colete", esp_health) then end
         end
         imgui.PushItemWidth(150)
         if imgui.SliderFloat("##minspread", minspread, -0.15, 0) then settings.minspread = minspread.v end
         imgui.SameLine()
         imgui.Indent(152)
         if imgui.SliderFloat("##maxspread", maxspread, 0, 0.15) then settings.maxspread = maxspread.v end
         imgui.Unindent(152)
         imgui.PopItemWidth()
         imgui.Text("Min. & Max. spread in bone")
         imgui.Newline()
         checkbox("Individual Hit", "indivhit")
         if settings.indivhit then
            last_weapon = getWeapon() or last_weapon
            if last_weapon then
               indhitslider.v = settings.guns[last_weapon.name].hit
               if imgui.SliderFloat("Hit##"..last_weapon.id, indhitslider, 0.0, 100.0) then settings.guns[last_weapon.name].hit = indhitslider.v end
               imgui.TextColoredRGB("{F59B14}Only for "..last_weapon.name)
            else
               imgui.Newline()
               imgui.TextColoredRGB("{F59B14}Get any weapon")
            end
         else
            if imgui.SliderFloat("Hit##all", hit_slider, 0.0, 100.00) then settings.hit = hit_slider.v end
            imgui.Newline()
         end
         imgui.Newline()
         checkbox("Serial misses", "serialmisses")
         if settings.serialmisses then
            if imgui.SliderInt("Miss after", miss_after, 0, 100) then settings.missafter = miss_after.v end
         end
         imgui.Newline()
         checkbox("Shoot from the hip", "fromthehip")
      elseif menu_item == "funcao" then
         if imgui.Checkbox("ativa ao iniciar", imgui.ImBool(settings.onatstart)) then
            settings.onatstart = not settings.onatstart
         end
         checkbox("trava ativacao", "lockactive")
         imgui.Newline()

         for k, v in pairs({ lockbutton = "trava", menubutton = "Menu", statebutton = "State", combobutton = "Combo" }) do
            imgui.Text(v)
            imgui.SameLine()
            imgui.Indent(50)
            if binding and binding.key == k then
               imgui.Button(binding.text, imgui.ImVec2(100, 20))
            else
               local key = vkeys.id_to_name(settings[k]) or ""
               if imgui.Button(key.."##"..k, imgui.ImVec2(100, 20)) then
                  binding = { key = k, last_upd = os.clock(), text = "???" }
               end
            end
            imgui.Unindent(50)
         end
         if binding then
            imgui.Text("ESC - Cancel\nBACKSPACE - Clear")
         else
            imgui.TextDisabled("ESC - Cancel\nBACKSPACE - Clear")
         end
      elseif menu_item == "test" then
         imgui.BeginChild("Misc1", imgui.ImVec2(140, 220), false)
         checkbox("mostra fov", "debug")
         if imgui.Button("mostra dano", imgui.ImVec2(120, 20)) then
            log_window.v = not log_window.v
         end
         if imgui.Button("Clear log", imgui.ImVec2(120, 20)) then
            shoot_log = {}
         end
         imgui.EndChild()
         imgui.SameLine()
         imgui.BeginChild("Misc2", imgui.ImVec2(275, 220), false)
         if info.text then
            imgui.TextColoredRGB(info.text)
         end
         if info.links then
            imgui.Text("\nLinks:")
            for _, link in ipairs(info.links) do
               imgui.Link(link.url, link.caption)
            end
         end
         imgui.EndChild()
         imgui.Separator()
         local update_check_result
         if info.version then
            if VERSION == info.version then
               update_check_result = "{00CC00}Script atualizado"
            else
               update_check_result = "{F59B14}Versao "..info.version.." disponivel"
            end
         else
            update_check_result = "{#FFFF00} TIGRIN DU BYPASS "
         end
         imgui.TextColoredRGB("v. "..VERSION.." | "..update_check_result)
      end
      imgui.End()
   end
   if log_window.v then
      if not main_window.v then
         imgui.SetMouseCursor(-1) imgui.ShowCursor = false else imgui.ShowCursor = true
      end
      local x,y = getCursorPos()
      imgui.SetNextWindowPos(imgui.ImVec2(x - 150, y - 10), imgui.Cond.FirstUseEver)
      imgui.SetNextWindowSize(imgui.ImVec2(550, 400), imgui.Cond.FirstUseEver)
      imgui.Begin(os.date("%d %B %Y", os.time()), log_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
      for k, v in ipairs(shoot_log) do
         imgui.TextColoredRGB(v)
      end
      if #shoot_log > last_log_size then imgui.SetScrollHere() end
      last_log_size = #shoot_log
      imgui.End()
   end
end
function getCamMode()
   local aimptr = allocateMemory(31)
   local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
   sampStorePlayerAimData(pid, aimptr)
   local cam_mode = memory.getuint8(aimptr, 0)
   freeMemory(aimptr)
   return cam_mode
end

-- FUNÇÃO MESCLADA COM O ANTI-STUN
function sampev.onSendPlayerSync(data)
   -- LÓGICA DO ANTI-STUN
   if settings.antiStun then
      if data.animationId == 1084 then
         data.animationFlags = 32772
         data.animationId = 1189
      end
   end

   -- LÓGICA ORIGINAL DO AIMBOT
   if not aim_state.v then return end
   local cam_mode = getCamMode()
   if legit and (cam_mode == 53 or cam_mode == 7 or cam_mode == 55) then
      sendWeaponSync(legit.id)
   else
      sendWeaponSync(65535)
   end
   if not legit then return end
   local weapon = getWeapon()
   if not weapon then return end
   if weapon.id == 24 or weapon.id == 26 or weapon.id == 28 or weapon.id == 32 then return end
   if not isButtonPressed(player, 6) then cam_mode = 4 end
   if not settings.syncrotation or (cam_mode ~= 53 and cam_mode ~= 7) or legit.dist < minfakeaimdist.v or legit.dist > maxfakeaimdist.v then return end
   local my_bone = getBodyPartCoordinates(23, PLAYER_PED)
   local b = 0 * math.pi / 360.0
   local h = 0 * math.pi / 360.0 
   local a = getHeadingFromVector2d(legit.bone.x - my_bone.x, legit.bone.y - my_bone.y) * math.pi / 360.0
   local c1, c2, c3 = math.cos(h), math.cos(a), math.cos(b)
   local s1, s2, s3 = math.sin(h), math.sin(a), math.sin(b)
   data.quaternion[0] = c1 * c2 * c3 - s1 * s2 * s3
   data.quaternion[3] = -( c1 * s2 * c3 - s1 * c2 * s3 )
end

function sendWeaponSync(id)
   if last_target == id then return end
   local weapon = getWeapon()
   if not weapon then return end
   local bs = raknetNewBitStream()
   raknetBitStreamWriteInt8(bs, 204)
   raknetBitStreamWriteInt16(bs, id)
   raknetBitStreamWriteInt16(bs, 65535)
   raknetBitStreamWriteInt8(bs, getWeapontypeSlot(weapon.id))
   raknetBitStreamWriteInt8(bs, weapon.id)
   raknetBitStreamWriteInt16(bs, getAmmoInCharWeapon(PLAYER_PED, weapon.id))
   raknetSendBitStream(bs)
   raknetDeleteBitStream(bs)
   last_target = id
end
function sampev.onSendAimSync(data)
   if not aim_state.v or not legit or legit.dist < minfakeaimdist.v or legit.dist > maxfakeaimdist.v then
      return true
   end
   local my_bone = getBodyPartCoordinates(23, PLAYER_PED)
   if settings.syncaimz then
      local d = vector2d(getDistanceBetweenCoords3d(legit.bone.x, legit.bone.y, my_bone.z, my_bone:get()), getDistanceBetweenCoords3d(my_bone.x, my_bone.y, legit.bone.z, my_bone:get()))
      local aimZ = math.atan(math.abs(d.y/d.x))
      data.aimZ = legit.bone.z > my_bone.z and -aimZ or aimZ
   end
   if settings.cumbypass then
      data.camFront = vector3d(0.0, 0.0, -0.1)
      data.camPos = legit.bone
   end
end
function sampev.onSendWeaponsUpdate(player_target, actor_target, weapons)
   if settings.faketarget and legit and settings.maxfaketargetdist > legit.dist then
      last_target = legit.id
      return { legit.id, 65535, weapons }
   end
   if player_target == 65535 then last_target = 65535 end
end
function sampev.onSendCameraTargetUpdate(object_id, vehicle_id, player_id, actor_id)
   if settings.faketarget and legit then
      return { 65535, 65535, legit.id, 65535 }
   end
end
function sampev.onSendCommand(cmd)
   if cmd == "/"..settings.menucmd then
      main_window.v = not main_window.v
      return false
   end
end
function sampev.onSendBulletSync(data)
   if not aim_state.v or not legit or data.targetType == 1 or not doesCharExist(legit.ped) then return true end
   local weapon = getWeapon()
   if not weapon then return true end
   local player_state = isCharOnFoot(PLAYER_PED) and "Onfoot" or "Incar"
   if not settings.fromthehip and not isCharInAnyCar(PLAYER_PED) and getCamMode() == 4 then
      if settings.debug then log("Skipped shot from the hip with "..weapon.name.." - "..player_state, false) end
      return true
   end
   shoots = shoots + 1
   local missrate = settings.indivhit and settings.guns[weapon.name].hit or hit_slider.v
   if missrate < 100 then
      local rand = math.random(1, 100)
      if rand >= missrate then
         if settings.debug then log("Skipped shot by random ( "..rand.." >= "..math.floor(missrate).." ) - "..player_state, false) end
         return true
      end
   end
   if settings.serialmisses then
      if shoots % (miss_after.v + 1) == 0 then
         if settings.debug then log("Serial miss ( "..shoots.." % "..tostring(miss_after.v+1).." == 0 ) - "..player_state, false) end
         return true
      end
   end
   local ped_coords = vector3d(getCharCoordinates(legit.ped))
   local my_coords = vector3d(getCharCoordinates(PLAYER_PED))
   local dist = getDistanceBetweenCoords3d(my_coords.x, my_coords.y, my_coords.z, ped_coords:get())
   if legit.dist > weapon.dist or isCharDead(legit.ped) or sampIsPlayerPaused(legit.id) then
      if settings.debug then
         log(dist.." < 0 or "..dist.." > "..weapon.dist.." or target is dead/paused - "..player_state, false)
      end
      return true
   end
   local rand = vector3d(randomFloat(minspread.v, maxspread.v), randomFloat(minspread.v, maxspread.v), randomFloat(minspread.v, maxspread.v))
   data.targetType = 1
   data.targetId = legit.id
   data.target = ped_coords + rand
   data.center = legit.bone - ped_coords + rand
   if settings.debug then
      lua_thread.create(function()
         local my_bone = getBodyPartCoordinates(26, PLAYER_PED)
         local target = vector3d(data.target.x + data.center.x, data.target.y + data.center.y, data.target.z + data.center.z)
         local time = os.clock()
         while settings.debug and os.clock() - time < 10.0 do
            if isPointOnScreen(my_bone.x, my_bone.y, my_bone.z, 0) and isPointOnScreen(target.x, target.y, target.z, 0) then
               local my_bone_2d = vector2d(convert3DCoordsToScreen(my_bone:get()))
               local target_2d = vector2d(convert3DCoordsToScreen(target:get()))
               renderDrawLine(my_bone_2d.x, my_bone_2d.y, target_2d.x, target_2d.y, 2, bit.bor(0xFF0000, bit.lshift(255 - (os.clock() - time) * 25.5, 24)))
               renderDrawPolygon(target_2d.x - 5, target_2d.y - 5, 10, 10, 20, 0, bit.bor(0x00FF00, bit.lshift(255 - (os.clock() - time) * 25.5, 24)))
            end
            wait(0)
         end
      end)
   end
   for bodypart, bone in ipairs(bones) do
      for _, dot in ipairs(bone.dots) do
         if dot == legit.bone_num then
            lua_thread.create(function()
               local id = legit.id
               wait(1)
               sampSendGiveDamage(id, weapon.damage, weapon.id, bodypart + 2)
               if settings.debug then log("Sent "..math.floor(weapon.damage).." damage to "..id.." id ( "..bone.name.." ) with "..weapon.name.." - "..player_state, true) end
            end)
            return
         end
      end
   end
end
function getBodyPartCoordinates(id, handle)
   local pedptr = getCharPointer(handle)
   local vec = ffi.new("float[3]")
   getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
   return vector3d(vec[0], vec[1], vec[2])
end
function randomFloat(low, great)
   return low + math.random() * (great - low)
end
function imgui.Newline()
   imgui.Text("\n")
end
function imgui.TextColoredRGB(text)
   local style = imgui.GetStyle()
   local colors = style.Colors
   local explode_argb = function(argb)
      local a = bit.band(bit.rshift(argb, 24), 0xFF)
      local r = bit.band(bit.rshift(argb, 16), 0xFF)
      local g = bit.band(bit.rshift(argb, 8), 0xFF)
      local b = bit.band(argb, 0xFF)
      return a, r, g, b
   end
   local getcolor = function(color)
      if color:sub(1, 6):upper() == "SSSSSS" then
         local r, g, b = colors[1].x, colors[1].y, colors[1].z
         local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
         return imgui.ImVec4(r, g, b, a / 255)
      end
      local color = type(color) == "string" and tonumber(color, 16) or color
      if type(color) ~= "number" then return end
      local r, g, b, a = explode_argb(color)
      return imgui.ImColor(r, g, b, a):GetVec4()
   end
   local render_text = function(text_)
      for w in text_:gmatch("[^\r\n]+") do
         local text, colors_, m = {}, {}, 1
         w = w:gsub("{(......)}", "{%1FF}")
         while w:find("{........}") do
            local n, k = w:find("{........}")
            local color = getcolor(w:sub(n + 1, k - 1))
            if color then
               text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
               colors_[#colors_ + 1] = color
               m = n
            end
            w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
         end
         if text[0] then
            for i = 0, #text do
               imgui.TextColored(colors_[i] or colors[1], text[i])
               imgui.SameLine(nil, 0)
            end
            imgui.NewLine()
         else imgui.Text(w) end
      end
   end
   render_text(text)
end
function imgui.Link(link, text)
   text = text or link
   local tSize = imgui.CalcTextSize(text)
   local p = imgui.GetCursorScreenPos()
   local DL = imgui.GetWindowDrawList()
   local col = { 0xFFFF7700, 0xFFFF9900 }
   if imgui.InvisibleButton("##" .. link, tSize) then shell32.ShellExecuteA(nil, "open", link, nil, nil, 1) end
   local color = imgui.IsItemHovered() and col[1] or col[2]
   DL:AddText(p, color, text)
   DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end
function writeWallshot()
   for _, address in ipairs({ 0x00740701, 0x00740703, 0x00740709, 0x00740B49, 0x00740B4B, 0x00740B51, 0x0073620D, 0x0073620F, 0x00736215 }) do
      memory.write(address, settings.wallshot and 0 or 1, 1, true)
   end
end
function getSightPos()
   if getCurrentCharWeapon(PLAYER_PED) == 34 then
      local x, y = getScreenResolution()
      return vector2d(x/2, y/2)
   else
      return vector2d(convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1))
   end
end
function log(text, result)
   table.insert(shoot_log, (result and "{64FF64}" or "{FF6464}").."["..os.date("%H:%M:%S", os.time()).."] ["..(result and "DONE" or "SKIP").."] > "..text)
end
function tryInsert(table, value)
   if not isTableHasValue(table, value) then
      table[#table + 1] = value
   end
end
function isTableHasValue(table, value)
   for k, v in ipairs(table) do
      if v == value then
         return true
      end
   end
   return false
end
function checkbox(text, bool)
   if imgui.Checkbox(text, imgui.ImBool(settings[bool])) then settings[bool] = not settings[bool] end
end
function getRandomBone()
   local temp_bones = {}
   for key, bone in ipairs(settings.bones) do
      if bone then
         table.insert(temp_bones, key)
      end
   end
   return (#temp_bones > 0 and temp_bones[math.random(1, #temp_bones)] or bones[math.random(1, #bones)])
end
function getWeapon(weapon)
   return weapons[getCurrentCharWeapon(PLAYER_PED)]
end
function vector2d(x, y)
   return { x = x, y = y }
end
function updateIP()
   local ip = sampGetCurrentServerAddress()
   if not settings.ignored[ip] then
      settings.ignored[ip] = {
         nicks = {},
         skins = {}
      }
   end
   ignored_nicks = settings.ignored[ip].nicks
   ignored_skins = settings.ignored[ip].skins
end
function getAuthorMessage()
   local response = require("requests").get({url = "file:///C:/Users/ttrlk/Documents/data.json", timeout = 2})
   if response.status_code == 200 then
      info = decodeJson(response.text)
      if not info then info = {} end
   end
end
function onReceivePacket(id, bs)
   if id == 34 then
      updateIP()
   end
end
function windowMsgHandler(msg, wparam, lparam)
   if msg == wm.WM_KEYDOWN then
      if main_window.v then
         if binding then
            if wparam ~= vkeys.VK_ESCAPE then
               settings[binding.key] = wparam == vkeys.VK_BACK and 0 or wparam
            end
            binding = nil
            consumeWindowMessage()
         elseif wparam == vkeys.VK_ESCAPE then
            main_window.v = false
            consumeWindowMessage()
         end
      end
   end
end
function scriptTerminateHandler(scr)
   aim_state.v = false
   if scr == script.this then
      settings.save()
   end
end