/datum/asset/simple/scp_logos
	keep_local_name = TRUE
	assets = list()

/datum/asset/simple/scp_logos/register()
	var/list/logo_files = list(
		"scplogo.png" = "scplogo.png",
		"ethics.png" = "ethics.png",
		"o5.png" = "o5.png",
		"scp_admin.png" = "admin.png",
		"scp_eng.png" = "eng.png",
		"scp_sec.png" = "sec.png",
		"scp_med.png" = "med.png",
		"scp_sci.png" = "sci.png",
		"log.png" = "log.png",
		"isd.png" = "isd.png",
		"dea.png" = "dea.png",
		"man.png" = "man.png",
		"int.png" = "int.png",
		"mtf.png" = "mtf.png",
		"trib.png" = "trib.png",
		"ungoc.png" = "ungoc.png",
		"aiad.png" = "aiad.png",
		"amd.png" = "amd.png",
		"dcd.png" = "dcd.png",
		"fsd.png" = "fsd.png",
		"misi.png" = "misi.png",
		"pata.png" = "pata.png",
		"raisa.png" = "raisa.png",
		"uiu.png" = "uiu.png",
		"gr.png" = "gr.png",
		"mcd.png" = "mcd.png",
		"sh.png" = "sh.png",
		"ci.png" = "ci.png",
		"cotbg.png" = "cotbg.png",
		"cmax.png" = "cmax.png",
		"coc.png" = "coc.png",
		"mcf.png" = "mcf.png",
		"ar.png" = "ar.png",
		"wws.png" = "wws.png",
		"spc.png" = "spc.png",
		"talisman.png" = "talisman.png",
	)
	for(var/asset_name in logo_files)
		var/file_path = "html/images/[logo_files[asset_name]]"
		if(fexists(file_path))
			var/asset_resource = fcopy_rsc(file_path)
			if(asset_resource)
				var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, asset_resource)
				if(ACI)
					ACI.keep_local_name = keep_local_name
					assets[asset_name] = ACI
