module("luci.controller.sfe", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/sfe") then
		return
	end
	local page
	page = entry({"admin", "network", "sfe"}, cbi("sfe"), _("Turbo ACC Center"), 100)
	page.i18n = "sfe"
	page.dependent = true
	
	entry({"admin", "network", "sfe", "status"}, call("action_status"))
end

local function is_running()
	return luci.sys.call("lsmod | grep fast_classifier >/dev/null") == 0
end

local function is_bbr()
	return luci.sys.call("[ `cat /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null` = `uci get sfe.config.bbr 2>/dev/null` ] 2>/dev/null") == 0
end

local function is_fullcone()
	return luci.sys.call("iptables -t nat -L -n --line-numbers | grep FULLCONENAT >/dev/null") == 0
end

local function is_dns()
	return luci.sys.call("pgrep dnscache >/dev/null") == 0
end

local function is_ad()
	return luci.sys.call("pgrep AdGuardHome >/dev/null") == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		run_state = is_running(),
		down_state = is_bbr(),
		up_state = is_fullcone(),
		dns_state = is_dns(),
		ad_state = is_ad()
	})
end