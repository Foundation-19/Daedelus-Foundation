/datum/offsite_template
	abstract_type = /datum/offsite_template
	var/name = "Unset - contact a coder!"
	var/uses_header = TRUE
	var/uses_footer = TRUE

/datum/offsite_template/proc/generate_header(origin, custom)
	if(!uses_header)
		return ""

/datum/offsite_template/proc/generate_footer(origin, custom)
	if(!uses_footer)
		return ""

/datum/offsite_template/foundation
	name = "Foundation Command"

/datum/offsite_template/foundation/generate_header(origin, custom)
	var/header = "\[scplogo\]"
	header += "\[center\]\[b\]SCP FOUNDATION - [origin]\[/b\]\[/center\]"
	header += "\[hr\]"
	header += "\[small\]\[i\]Radio Uplink Signed Message\[br\]"
	if(custom)
		header += "[custom]\[br\]"
	header += "\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/foundation/generate_footer(origin, custom)
	return "\[hr\]\[small\]This message is the property of the SCP Foundation. Unauthorized disclosure of its contents constitutes a security violation. Report any suspected breach to your site's Internal Security Department representative.\[/small\]"

/datum/offsite_template/goc
	name = "GOC Command"

/datum/offsite_template/goc/generate_header(origin, custom)
	var/header = "\[goclogo\]"
	header += "\[center\]\[b\]GLOBAL OCCULT COALITION\[br\]Survival. Concealment. Protection. Destruction. Education.\[/b\]\[/center\]"
	header += "\[hr\]"
	header += "\[small\]\[i\]PSYCHE General Transmission\[br\]"
	if(custom)
		header += "[custom]\[br\]"
	header += "\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/goc/generate_footer(origin, custom)
	return "\[hr\]\[small\]UNDER PSYCHE DIVISION AUTHORITY - CLASSIFIED LEVEL IV - UNAUTHORIZED INTERCEPTION IS A CRIMINAL OFFENSE UNDER UNITED NATIONS SECURITY COUNCIL RESOLUTION 1924\[/small\]"

/datum/offsite_template/ethics
	name = "Ethics Committee"

/datum/offsite_template/ethics/generate_header(origin, custom)
	var/header = "\[ethicslogo\]"
	header += "\[center\]\[b\]ETHICS COMMITTEE CENTRAL OFFICE\[/b\]\[/center\]"
	header += "\[hr\]"
	if(custom)
		header += "\[small\]\[i\][custom]\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/ethics/generate_footer(origin, custom)
	return "\[hr\]\[small\]The Ethics Committee reminds all personnel that moral and ethical considerations are not optional. They are the Foundation.\[/small\]"

/datum/offsite_template/uiu
	name = "UIU Command"

/datum/offsite_template/uiu/generate_header(origin, custom)
	var/header = "\[uiulogo\]"
	header += "\[center\]\[b\]FEDERAL BUREAU OF INVESTIGATION\[br\]Unusual Incidents Unit\[/b\]\[/center\]"
	header += "\[hr\]"
	if(custom)
		header += "\[small\]\[i\][custom]\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/uiu/generate_footer(origin, custom)
	return "\[hr\]\[small\]FBI-UIU Internal Communication - Do Not Distribute\[/small\]"

/datum/offsite_template/mcd
	name = "MC&D"

/datum/offsite_template/mcd/generate_header(origin, custom)
	var/header = "\[mcdlogo\]"
	header += "\[center\]\[b\]MARSHALL, CARTER AND DARK, LTD.\[/b\]\[/center\]"
	header += "\[hr\]"
	if(custom)
		header += "\[small\]\[i\][custom]\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/mcd/generate_footer(origin, custom)
	return "\[hr\]\[small\]This correspondence is the exclusive property of Marshall, Carter and Dark, Ltd. and is intended solely for the named recipient.\[/small\]"

/datum/offsite_template/ci
	name = "Chaos Insurgency"

/datum/offsite_template/ci/generate_header(origin, custom)
	var/header = "\[cilogo\]"
	header += "\[center\]\[b\]CHAOS INSURGENCY - DELTA COMMAND\[/b\]\[/center\]"
	header += "\[hr\]"
	if(custom)
		header += "\[small\]\[i\][custom]\[/i\]\[/small\]\[hr\]"
	return header

/datum/offsite_template/ci/generate_footer(origin, custom)
	return "\[hr\]\[small\]OPERATOR INFORMATION: This transmission is classified under CI Protocol 7. Unauthorized interception will be met with extreme prejudice.\[/small\]"
