/mob/verb/verify_storytelling_system()
	set name = "Verify Storytelling System"
	set category = "Debug"
	set desc = "Run verification test for the Storytelling system"

	if(!check_rights(R_DEBUG))
		to_chat(src, "<span class='warning'>You don't have permission to run verification tests.</span>")
		return

	to_chat(src, "<span class='notice'>=== Storytelling System Verification ===</span>")

	if(!SSstorytelling)
		to_chat(src, "<span class='warning'>FAIL: SSstorytelling subsystem not found.</span>")
		return

	if(!SSstorytelling.manager)
		to_chat(src, "<span class='warning'>FAIL: Storytelling manager not found.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Storytelling System operational.</span>")

	var/datum/story_arc/test_arc = SSstorytelling.manager.create_arc(STORY_ARC_BREACH, "SCP-Test")
	if(!test_arc)
		to_chat(src, "<span class='warning'>FAIL: Arc creation failed.</span>")
		return

	to_chat(src, "<span class='notice'>PASS: Arc creation working. Created: [test_arc.arc_title]</span>")

	SSstorytelling.manager.log_timeline(TIMELINE_EVENT_BREACH, "Test timeline event", src.ckey)
	if(length(SSstorytelling.manager.timeline) == 0)
		to_chat(src, "<span class='warning'>FAIL: Timeline logging failed.</span>")
		SSstorytelling.manager.active_arcs -= test_arc.arc_id
		return

	to_chat(src, "<span class='notice'>PASS: Timeline logging working.</span>")

	var/datum/storytelling_ui/test_ui = new /datum/storytelling_ui(src)
	if(!test_ui)
		to_chat(src, "<span class='warning'>FAIL: TGUI interface creation failed.</span>")
		SSstorytelling.manager.active_arcs -= test_arc.arc_id
		return

	to_chat(src, "<span class='notice'>PASS: TGUI interface working.</span>")

	to_chat(src, "<span class='notice'>=== System Status ===</span>")
	to_chat(src, "<span class='notice'>Active Arcs: [length(SSstorytelling.manager.active_arcs)]</span>")
	to_chat(src, "<span class='notice'>Completed Arcs: [length(SSstorytelling.manager.completed_arcs)]</span>")
	to_chat(src, "<span class='notice'>Timeline Entries: [length(SSstorytelling.manager.timeline)]</span>")
	to_chat(src, "<span class='notice'>Journal Entries: [length(SSstorytelling.manager.journal_entries)]</span>")

	SSstorytelling.manager.active_arcs -= test_arc.arc_id

	to_chat(src, "<span class='notice'>=== VERIFICATION COMPLETE ===</span>")
