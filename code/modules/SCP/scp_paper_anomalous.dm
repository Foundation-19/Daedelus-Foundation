/obj/item/paper/self_writing
	color = "#b0c4de"
	var/cooldown = 0

/obj/item/paper/self_writing/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return
	if(cooldown > world.time)
		to_chat(user, span_warning("[src] is seemingly in a resting phase for now..."))
		return
	if(ishuman(A))
		cooldown = world.time + 40 SECONDS
		var/mob/living/carbon/human/H = A
		H.visible_message(span_danger("[src] shakes as words begin to form on it!"), span_userdanger("[src] is surfing through your mind, pulling the ideas and words from it!"))
		info = null
		for(var/i in 1 to 3)
			if(!do_after(user, 5 SECONDS, H))
				to_chat(user, span_warning("[src] stops absorbing words[i <= 1 ? " before it can do anything." : ", but it seems like it wasn't done yet..."]"))
				return
			playsound(src, 'sound/items/handling/paper_pickup.ogg', 25, TRUE)
			cooldown += 5 SECONDS
			switch(i)
				if(1)
					var/job_title = "Unknown"
					if(H.mind?.assigned_role)
						if(istext(H.mind.assigned_role))
							job_title = H.mind.assigned_role
						else
							var/datum/job/J = H.mind.assigned_role
							job_title = J.title
					info = "<center><b><font size=\"4\">[H.real_name], [job_title]</font></b><br><i><font size = \"1\">Interviewed by [user.real_name]</font></i></center><HR><BR>"
					info += "Name: [H.real_name]<BR>"
					info += "Job: [job_title]<BR>"
					info += "Species: [H.dna?.species?.name || "Unknown"]<BR>"
					info += "Age: [H.age]<BR>"
					info += "Blood type: [H.dna?.blood_type?.name || "Unknown"]<HR><BR>"
				if(2)
					info += "Health status: [round(H.health / H.maxHealth * 100)]%<BR>"
				if(3)
					info += "<b>Document complete.</b><BR>"
			to_chat(user, span_notice("[src] is done writing down the information!"))
		return
	if(isliving(A))
		cooldown = world.time + 20 SECONDS
		var/mob/living/L = A
		L.visible_message(span_danger("[src] shakes as words rapidly form on it!"))
		info = "<center><b><font size=\"4\">[L.name]</font></b></center><BR><i>[L.desc]</i><HR><BR>"
		info += "Health status: [round(L.health / L.maxHealth * 100)]%<BR>"
		playsound(src, 'sound/items/handling/paper_pickup.ogg', 25, TRUE)
		return
	if(isitem(A))
		cooldown = world.time + 10 SECONDS
		var/obj/item/I = A
		I.visible_message(span_danger("[src] shakes as words rapidly form on it!"))
		info = "<center><b><font size=\"4\">[I.name]</font></b></center><BR>"
		info += "Object identified.<BR>"
		playsound(src, 'sound/items/handling/paper_pickup.ogg', 25, TRUE)
		return
	cooldown = world.time + 5 SECONDS
	return ..()
