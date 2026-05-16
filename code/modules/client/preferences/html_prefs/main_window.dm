/datum/preferences/proc/html_topic(href, list/href_list)
	if(href_list["change_slot"])
		change_character(usr)
		return TRUE

	if(href_list["select_preview"])
		var/new_preview = href_list["select_preview"]
		if(!(new_preview in list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR)))
			return TRUE

		preview_pref = new_preview
		character_preview_view.update_body()
		update_html()
		return TRUE

	if(href_list["select_category"])
		var/datum/preference_group/category/C = locate(href_list["select_category"]) in GLOB.all_pref_groups
		if(!C)
			return TRUE
		selected_category = C
		update_html()
		return TRUE

	if(href_list["pref_act"])
		var/datum/preference/P = GLOB.preference_entries[text2path(href_list["pref_act"])]
		if(!P)
			return TRUE
		if(P.button_act(usr, src, href_list))
			save_character()
			update_html()
		return TRUE

	if(href_list["close"])
		save_character()
		save_preferences()
		QDEL_NULL(character_preview_view)

	if(href_list["randomize_pref"])
		var/datum/preference/P = GLOB.preference_entries[text2path(href_list["randomize_pref"])]
		if(!P || !P.is_randomizable())
			return

		if(write_preference(P, P.create_random_value(src)))
			character_preview_view?.update_body()
			update_html()
		return TRUE

/datum/preferences/proc/html_show(mob/user)
	if(!user || !user.client)
		return

	if (isnull(character_preview_view))
		character_preview_view = create_character_preview_view(user)
	else if (character_preview_view.client != parent)
		// The client re-logged, and doing this when they log back in doesn't seem to properly
		// carry emissives.
		character_preview_view.register_to_client(parent)

	var/content = {"
	<script type='text/javascript'>
		function update_content(data){
			document.getElementById('content').innerHTML = data;
		}
	</script>
	<div id='content'>[html_create_window(user)]</div>
	"}

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_window", "<div align='center'>Personnel_File.exe</div>", 1200, 800)
	popup.set_content(content)
	popup.open(FALSE)
	onclose(user, "preferences_window", src)

/datum/preferences/proc/html_create_window()
	. = list()
	// Top computer banner
	. += {"
	<div style='background:#101820;border:2px solid #2f4f4f;margin-bottom:6px'>
		<div style='display:flex;justify-content:space-between;align-items:center;padding:6px 10px'>
			<div><span class='computerText'>ENHANCED PERSONNEL FILE SYSTEM v2.1</span></div>
			<div><span class='computerText'>User: [isnull(parent) ? "guest" : parent.ckey]</span></div>
		</div>
		<div style='padding:4px 10px;border-top:1px solid #2f4f4f'>
			<span class='computerSubText'>Path: C:/FOUNDATION/HR/Personnel_File.exe</span>
		</div>
	</div>
	"}
	. += "<fieldset class='computerPane' style='min-height:900px'>"
	. += "<legend class='computerLegend' style='margin: 0 auto'>[button_element(src, read_preference(/datum/preference/name/real_name), "change_slot=1")]</legend>"
	. += html_create_subheader()
	. += html_create_categories()
	var/header = selected_category.get_header(src)
	if(header)
		. += header
	. += "<div style='display:flex;flex-wrap:wrap'>"
	. += selected_category.get_content(src)
	. += "</div>"
	. += "</fieldset>"
	return jointext(., "")

/datum/preferences/proc/change_character()
	var/list/characters = create_character_profiles()
	for(var/i in 1 to length(characters))
		var/character = characters[i]
		if(isnull(character))
			characters[i] = "New Character"

	var/chosen_slot = input(usr, "Change Character",, characters[default_slot]) as null|anything in characters
	if(!chosen_slot)
		return

	if(!characters.Find(chosen_slot))
		return

	default_slot = characters.Find(chosen_slot)

	save_character()

	// SAFETY: `load_character` performs sanitization the slot number
	if (!load_character(default_slot))
		CRASH("Failed to load character for slot [default_slot]!")

	character_preview_view.update_body()
	update_html()

/datum/preferences/proc/html_create_categories()
	. = list()
	. += {"
	<div style='display:flex;justify-content:center;gap:8px;padding:6px 0;border-bottom:1px solid #202020;background:#0e1420'>
	"}
	for(var/datum/preference_group/category/P in GLOB.all_pref_groups)
		if(selected_category == P)
			. += "<span class='linkOn' style='padding:4px 8px;border:1px solid #3a3a3a;background:#122438'>[P.name]</span>"
		else
			. += button_element(src, P.name, "select_category=\ref[P]", style = "padding:4px 8px;border:1px solid #3a3a3a")
	. += "</div>"

	return jointext(., "")

/datum/preferences/proc/html_create_subheader()
	. = list()
	. += "<div style='text-align: center'><b><span class='computerText'>Character Preview</span></b><br>"
	for(var/option in list(PREVIEW_PREF_JOB, PREVIEW_PREF_LOADOUT, PREVIEW_PREF_UNDERWEAR))
		if(preview_pref == option)
			. += "<span class='linkOn'>[option]</span>"
		else
			. += button_element(src, option, "select_preview=[option]")
	. += "</div><HR style='background-color: #202020'>"
	return jointext(., "")
