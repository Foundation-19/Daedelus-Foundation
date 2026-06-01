// SCP Document Reader — TGUI Interface
// Replaces the old HTML-based document reader with a proper SCP-terminal TGUI

/obj/item/scp_document_reader/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SCPDocumentReader", "SCP FOUNDATION — DOCUMENT TERMINAL")
		ui.open()

/obj/item/scp_document_reader/ui_data(mob/user)
	var/list/data = list()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/card/id/id_card = H.get_idcard(TRUE)
		reader_clearance = 1
		if(id_card)
			if(ACCESS_ADMIN in id_card.access)
				reader_clearance = 5
			else if(ACCESS_SCIENCE in id_card.access)
				reader_clearance = 3
			else if(ACCESS_SECURITY in id_card.access)
				reader_clearance = 2

	sync_unlocked_documents(user)

	data["clearance"] = reader_clearance
	data["currentTime"] = time2text(world.time, "hh:mm:ss")

	var/list/docs = list()
	for(var/scp_id in unlocked_documents)
		var/list/doc_data = unlocked_documents[scp_id]
		docs += list(list(
			"id" = scp_id,
			"objectClass" = doc_data["object_class"],
			"status" = doc_data["containment_status"],
		))
	data["documents"] = docs

	return data

/obj/item/scp_document_reader/ui_static_data(mob/user)
	var/list/data = list()
	data["allDocuments"] = list()
	for(var/scp_id in unlocked_documents)
		var/list/doc_data = unlocked_documents[scp_id]
		data["allDocuments"][scp_id] = list(
			"id" = doc_data["id"],
			"objectClass" = doc_data["object_class"],
			"containmentStatus" = doc_data["containment_status"],
			"procedures" = doc_data["special_containment_procedures"],
			"description" = doc_data["description"],
			"addenda" = doc_data["addenda"],
		)
	return data

/obj/item/scp_document_reader/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("sync")
			last_sync_time = 0
			sync_unlocked_documents(ui.user)
			. = TRUE
