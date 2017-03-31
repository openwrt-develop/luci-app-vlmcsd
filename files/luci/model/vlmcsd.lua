local fs = require "nixio.fs"
local util = require "nixio.util"

local m, s, o

local running=(luci.sys.call("pidof vlmcsd > /dev/null") == 0)
if running then	
	m = Map("vlmcsd", translate("KMS Emulator"), translate("Vlmcsd is running."))
else
	m = Map("vlmcsd", translate("KMS Emulator"), translate("Vlmcsd is not running."))
end

s = m:section(TypedSection, "vlmcsd", "")
s.anonymous = true

s:tab("basic", translate("Basic Setting"))
s:taboption("basic", Flag, "enable", translate("Start"))
s:taboption("basic", Flag, "use_conf_file", translate("Using Config File")).rmempty = false
o = s:taboption("basic", Value, "port", translate("Local Port"))
o:depends("use_conf_file", "")
o.datatype = "port"
o.default = 1688
o.placeholder = 1688

local hostname = luci.model.uci.cursor():get_first("system", "system", "hostname")

autoactivate = s:taboption("basic", Flag, "autoactivate", translate("Auto activate"))
autoactivate.rmempty = false
function autoactivate.write(self, section, value)
	if value == "1" then
		luci.sys.call("sed -i '/srv-host=_vlmcs._tcp.lan/d' /etc/dnsmasq.conf")
		luci.sys.call("echo srv-host=_vlmcs._tcp.lan,".. hostname ..".lan,1688,0,100 >> /etc/dnsmasq.conf")
		luci.sys.call("/etc/init.d/dnsmasq restart")
	else
		luci.sys.call("sed -i '/srv-host=_vlmcs._tcp.lan/d' /etc/dnsmasq.conf")
		luci.sys.call("/etc/init.d/dnsmasq restart")
	end
	Flag.write(self, section, value)
end

s:tab("config", translate("Config File"))
conf = s:taboption("config", Value, "editconf", nil, translate("开头的数字符号（＃）或分号（;）的每一行被视为注释；删除（;）启用指定选项。"))
conf.template = "cbi/tvalue"
conf.rows = 20
conf.wrap = "off"
function conf.cfgvalue(self, section)
	return fs.readfile("/etc/vlmcsd.ini") or ""
end
function conf.write(self, section, value)
	if value then
		value = value:gsub("\r\n?", "\n")
		fs.writefile("/tmp/vlmcsd.ini", value)
		if (luci.sys.call("cmp -s /tmp/vlmcsd.ini /etc/vlmcsd.ini") == 1) then
			fs.writefile("/etc/vlmcsd.ini", value)
		end
		fs.remove("/tmp/vlmcsd.ini")
	end
end

return m
