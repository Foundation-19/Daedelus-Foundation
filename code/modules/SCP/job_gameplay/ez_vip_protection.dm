/datum/vip_protection_detail
	var/detail_id = ""
	var/vip_name = ""
	var/vip_job = ""
	var/assigned_guard = ""
	var/status = "active"
	var/time_created = 0
	var/checkins = 0
	var/last_checkin = 0
	var/checkin_interval = 5 MINUTES
	var/overdue = FALSE

/datum/vip_protection_detail/New(vip, guard)
	detail_id = "VIP-[world.time]-[rand(10,99)]"
	time_created = world.time
	if(istype(vip, /mob/living/carbon/human))
		var/mob/living/carbon/human/V = vip
		vip_name = V.real_name
		vip_job = V.job
	if(istype(guard, /mob/living/carbon/human))
		var/mob/living/carbon/human/G = guard
		assigned_guard = G.real_name

/datum/vip_protection_detail/proc/checkin()
	checkins++
	last_checkin = world.time
	overdue = FALSE

/datum/vip_protection_detail/proc/check_overdue()
	if(!last_checkin)
		return world.time > time_created + checkin_interval
	return world.time > last_checkin + checkin_interval

/obj/item/vip_beacon
	name = "VIP Tracking Beacon"
	desc = "A small tracking device assigned to VIP personnel for EZ security monitoring."
	icon = 'icons/obj/device.dmi'
	icon_state = "signaller"
	w_class = WEIGHT_CLASS_TINY
	var/vip_name = ""
	var/datum/vip_protection_detail/linked_detail

/obj/item/vip_beacon/attack_self(mob/user)
	if(linked_detail)
		linked_detail.checkin()
		to_chat(user, span_notice("VIP check-in logged for [vip_name]."))

SUBSYSTEM_DEF(vip_protection)
	name = "VIP Protection"
	wait = 10 SECONDS
	priority = FIRE_PRIORITY_DEFAULT
	var/list/datum/vip_protection_detail/details = list()
	var/total_details = 0
	var/overdue_alerts = 0

/datum/controller/subsystem/vip_protection/fire()
	for(var/datum/vip_protection_detail/D in details)
		if(D.status == "active" && D.check_overdue() && !D.overdue)
			D.overdue = TRUE
			overdue_alerts++
			priority_announce("VIP PROTECTION: [D.vip_name] ([D.vip_job]) has missed a check-in. EZ Security investigate immediately.", "VIP Protection", null, ANNOUNCER_ALERT)
			if(SSraisa)
				SSraisa.record_incident(D.vip_name)
			if(SSfoundation_comms)
				SSfoundation_comms.create_dispatch(null, DISPATCH_SECURITY, "VIP [D.vip_name] missed check-in. Investigate immediately.", 2)

/datum/controller/subsystem/vip_protection/proc/assign_detail(mob/vip, mob/guard)
	var/datum/vip_protection_detail/D = new(vip, guard)
	details += D
	total_details++
	to_chat(vip, span_notice("VIP protection detail assigned. Guard: [guard.real_name]. Check in regularly with your beacon."))
	to_chat(guard, span_notice("VIP protection detail assigned. Protect [vip.real_name]. Monitor their check-ins."))
	return D.detail_id

/datum/controller/subsystem/vip_protection/proc/release_detail(detail_id)
	for(var/datum/vip_protection_detail/D in details)
		if(D.detail_id == detail_id)
			D.status = "released"
			return TRUE
	return FALSE


