obs           = obslua
source_timer   = ""
source_delay   = ""
total_seconds = 0
inserted_seconds = 0

cur_seconds   = 0
delay_seconds   = 0
last_text     = ""
stop_text     = ""
activated     = false

delay		= false

hotkey_id     = obs.OBS_INVALID_HOTKEY_ID

-- Function to set the time text
function set_time_text()


	if delay then
		local seconds       = math.floor(delay_seconds % 60)
		local delay_minutes = math.floor(delay_seconds / 60)
		local minutes       = math.floor(delay_minutes % 60)
		local text = string.format("%02d:%02d", minutes, seconds)
		text= text
		local source = obs.obs_get_source_by_name(source_delay)
		if source ~= nil then
			local settings = obs.obs_data_create()
			obs.obs_data_set_string(settings, "text", text)
			obs.obs_source_update(source, settings)
			obs.obs_data_release(settings)
			obs.obs_source_release(source)
		end
	else
		local seconds       = math.floor(cur_seconds % 60)
		local total_minutes = math.floor(cur_seconds / 60)
		local minutes       = math.floor(total_minutes % 60)
		local text = string.format("%02d:%02d", minutes, seconds)
		if text ~= last_text then
			local source = obs.obs_get_source_by_name(source_timer)
			if source ~= nil then
				local settings = obs.obs_data_create()
				obs.obs_data_set_string(settings, "text", text)
				obs.obs_source_update(source, settings)
				obs.obs_data_release(settings)
				obs.obs_source_release(source)
			end
		end
		last_text = text
	end

end

function timer_callback()
	if cur_seconds < 1 then
		delay = true
		local source_delay = obs.obs_get_source_by_name(source_delay)
		obs.obs_source_set_enabled(source_delay, true)
		obs.obs_source_release(source_delay)
		local source_timer = obs.obs_get_source_by_name(source_timer)
		obs.obs_source_set_enabled(source_timer, false)
		obs.obs_source_release(source_timer)
	end
	if delay then
		delay_seconds = delay_seconds + 1
	else
		cur_seconds = cur_seconds - 1
	end
	--if cur_seconds < 0 then
	--	obs.remove_current_callback()
	--	cur_seconds = 0
	--end

	set_time_text()
end

function activate(activating)
	if activated == activating then
		return
	end

	activated = activating

	if activating then
		cur_seconds = total_seconds
		set_time_text()
		obs.timer_add(timer_callback, 1000)
	else
		obs.timer_remove(timer_callback)
	end
end

-- Called when a source is activated/deactivated
function activate_signal(cd, activating)
	local source = obs.calldata_source(cd, "source_timer")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if (name == source_timer) then
			activate(activating)
		end
	end

	local source = obs.calldata_source(cd, "source_delay")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if (name == source_delay) then
			activate(activating)
		end
	end
end

function source_activated(cd)
	reset_button_clicked()
end

function source_deactivated(cd)
	activate_signal(cd, false)
end

function reset(pressed)
	if not pressed then
		return
	end

	activate(false)
	local source = obs.obs_get_source_by_name(source_timer)
	if source ~= nil then
		local active = obs.obs_source_active(source)
		obs.obs_source_release(source)
		activate(active)
	end
end

function reset_button_clicked()
	cur_seconds = 0
	delay = false
	delay_seconds = 0
	local source_delay = obs.obs_get_source_by_name(source_delay)
	obs.obs_source_set_enabled(source_delay, false)
	obs.obs_source_release(source_delay)
	
	local source_timer = obs.obs_get_source_by_name(source_timer)
	obs.obs_source_set_enabled(source_timer, true)		
	obs.obs_source_release(source_timer)
	set_time_text()
	obs.timer_remove(timer_callback)
	return false
end

function change_min(min)
	activate(false)
	delay = false
	delay_seconds = 0
	local source_delay = obs.obs_get_source_by_name(source_delay)
	obs.obs_source_set_enabled(source_delay, false)
	obs.obs_source_release(source_delay)
	local source_timer = obs.obs_get_source_by_name(source_timer)
	obs.obs_source_set_enabled(source_timer, true)
	obs.obs_source_release(source_timer)
	total_seconds = min * 60
	reset(true)
end

function min3_button_clicked(props, p)
	change_min(3)
	return false
end

function min4_button_clicked(props, p)
	change_min(4)
	return false
end

function min5_button_clicked(props, p)
	change_min(5)
	return false
end

function min10_button_clicked(props, p)
	change_min(10)
	return false
end

function min15_button_clicked(props, p)
	change_min(15)
	return false
end

function min30_button_clicked(props, p)
	change_min(30)
	return false
end

function min60_button_clicked(props, p)
	change_min(60)
	return false
end

function set_button_clicked(props, p)
	change_min(inserted_seconds)
	return false
end

function pause_button_clicked(props, p)
	if activated then
		activated = false;
		obs.timer_remove(timer_callback)
	else
		activated = true;
		obs.timer_add(timer_callback, 1000)
	end
	return false
end

----------------------------------------------------------

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	local props = obs.obs_properties_create()


	local timer = obs.obs_properties_add_list(props, "source_timer", "Timer Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local delay = obs.obs_properties_add_list(props, "source_delay", "Delay Source", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_unversioned_id(source)
			if source_id == "text_gdiplus" or source_id == "text_ft2_source" then
				local name = obs.obs_source_get_name(source)
				obs.obs_property_list_add_string(timer, name, name)
				obs.obs_property_list_add_string(delay, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	obs.obs_properties_add_button(props, "pause_button", "Play / Pause", pause_button_clicked)
	obs.obs_properties_add_button(props, "reset_button", "Stop", reset_button_clicked)
	obs.obs_properties_add_button(props, "3min_button", "3 min", min3_button_clicked)
	obs.obs_properties_add_button(props, "4min_button", "4 min", min4_button_clicked)
	obs.obs_properties_add_button(props, "5min_button", "5 min", min5_button_clicked)
	obs.obs_properties_add_button(props, "10min_button", "10 min", min10_button_clicked)
	obs.obs_properties_add_button(props, "15min_button", "15 min", min15_button_clicked)
	obs.obs_properties_add_button(props, "30min_button", "30 min", min30_button_clicked)
	obs.obs_properties_add_button(props, "60min_button", "60 min", min60_button_clicked)
	obs.obs_properties_add_int_slider(props, "duration", "Time (min)", 1, 60, 1)
	obs.obs_properties_add_button(props, "set_button", "Set", set_button_clicked)

	return props
end


-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "Timer JW Meeting"
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	--activate(false)


	inserted_seconds = obs.obs_data_get_int(settings, "duration") 
	--total_seconds = obs.obs_data_get_int(settings, "duration") * 60
	source_timer = obs.obs_data_get_string(settings, "source_timer")
	source_delay = obs.obs_data_get_string(settings, "source_delay")
	-- stop_text = obs.obs_data_get_string(settings, "stop_text")

	--reset(true)
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_int(settings, "duration", 5)
end

-- a function named script_load will be called on startup
function script_load(settings)
	-- Connect hotkey and activation/deactivation signal callbacks
	--
	-- NOTE: These particular script callbacks do not necessarily have to
	-- be disconnected, as callbacks will automatically destroy themselves
	-- if the script is unloaded.  So there's no real need to manually
	-- disconnect callbacks that are intended to last until the script is
	-- unloaded.
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
end
