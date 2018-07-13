local fs = require "nixio.fs"

local m, s

if luci.sys.call("pidof vlmcsd >/dev/null") == 0 then
	status = translate("<b><font color=green>Vlmcsd is running.</font></b>")
else
	status = translate("<b><font color=red>Vlmcsd is not running.</font></b>")
end

m = Map("vlmcsd")
m.title = translate("KMS Server")
m.description = translate("A KMS Serever Emulator to active your Windows or Office")

s = m:section(TypedSection, "vlmcsd")
s.addremove = false
s.anonymous = true
s.description = translate(string.format("%s<br /><br />", status))

s:tab("basic", translate("Basic Setting"))
enable = s:taboption("basic", Flag, "enabled", translate("Enable"))
enable.rmempty = false

autoactivate = s:taboption("basic", Flag, "autoactivate", translate("Auto activate"))
autoactivate.rmempty = false

s:tab("config", translate("Config File"))
config = s:taboption("config", Value, "config", "", translate("开头的数字符号（＃）或分号（;）的每一行被视为注释；删除（;）启用指定选项。"))
config.template = "cbi/tvalue"
config.rows = 20
config.wrap = "off"
function config.cfgvalue(self, section)
	return fs.readfile("/etc/vlmcsd.ini") or ""
end
function config.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
	else
		value = ""
	end
	fs.writefile("/tmp/vlmcsd.ini", value)
	if (luci.sys.call("cmp -s /tmp/vlmcsd.ini /etc/vlmcsd.ini") == 1) then
		fs.writefile("/etc/vlmcsd.ini", value)
	end
	fs.remove("/tmp/vlmcsd.ini")
end

return m
