/// -- Paperwork defines. --
/// The file containing the paperwork strings.
#define PAPERWORK_FILE "paperwork.json"

/// String defines for admin fax machines.
#define SYNDICATE_FAX_MACHINE "the Syndicate"
#define CENTCOM_FAX_MACHINE "Central Command"

GLOBAL_LIST_INIT(admin_fax_destinations, list(
	SYNDICATE_FAX_MACHINE,
	CENTCOM_FAX_MACHINE,
	"Foundation Regional Command",
	"Ethics Committee Central Office",
	"Global Occult Coalition",
	"Unusual Incidents Unit",
	"Marshall, Carter and Dark",
	"Chaos Insurgency",
	"Horizon Initiative",
	"Anderson Robotics",
	"Serpent's Hand"
))

/// Text macro for replying to a message with a paper fax.
#define ADMIN_FAX_REPLY(machine) "(<a href='?_src_=holder;[HrefToken(TRUE)];FaxReply=[REF(machine)]'>FAX</a>)"
