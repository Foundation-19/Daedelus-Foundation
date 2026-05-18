/obj/item/paper/foundation/incident_report
	name = "Incident Report Form"
	desc = "A standard Foundation incident report form."

/obj/item/paper/foundation/incident_report/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - INCIDENT REPORT</h2><hr>
<b>Report ID:</b> ________<br>
<b>Date:</b> ________<br>
<b>Facility:</b> Site-53<br><hr>
<b>Reporting Personnel:</b> ________________________<br>
<b>Clearance Level:</b> 1 / 2 / 3 / 4 / 5<br>
<b>Department:</b> Security / Science / Medical / Engineering / Logistics / Other<br><hr>
<b>Incident Type:</b><br>
[ ] Containment Breach<br>
[ ] SCP Exposure / Contact<br>
[ ] Personnel Injury / Fatality<br>
[ ] Security Violation<br>
[ ] Equipment Failure<br>
[ ] Unexplained Phenomenon<br>
[ ] Other: ________________________<br><hr>
<b>SCP Designation (if applicable):</b> ________<br>
<b>Location of Incident:</b> ________________________<br>
<b>Time of Incident:</b> ________<br><hr>
<b>Description of Incident:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Personnel Involved:</b><br>
1. ________________________ (Role: ________)<br>
2. ________________________ (Role: ________)<br>
3. ________________________ (Role: ________)<br><hr>
<b>Immediate Actions Taken:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Recommendations:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Reporting Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Supervisor Review:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/obj/item/paper/foundation/testing_request
	name = "SCP Testing Request Form"
	desc = "A Foundation form for requesting supervised SCP testing."

/obj/item/paper/foundation/testing_request/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - TESTING REQUEST</h2><hr>
<b>Request ID:</b> ________<br>
<b>Date:</b> ________<br><hr>
<b>Requesting Researcher:</b> ________________________<br>
<b>Clearance Level:</b> 1 / 2 / 3 / 4 / 5<br>
<b>Department:</b> ________________________<br><hr>
<b>SCP Designation:</b> SCP-________<br>
<b>Object Class:</b> Safe / Euclid / Keter / Thaumiel / Apollyon<br>
<b>Current Containment Location:</b> ________________________<br><hr>
<b>Test Objective:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Test Procedure (detailed):</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Required Resources:</b><br>
___________________________________________________________________________<br><hr>
<b>D-Class Personnel Required:</b> ________<br>
<b>Equipment Required:</b> ________________________<br>
<b>Estimated Duration:</b> ________<br><hr>
<b>Risk Assessment:</b><br>
Low / Medium / High / Extreme<br><hr>
<b>Safety Precautions:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Researcher Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Senior Researcher Approval:</b> ________________________ <b>Date:</b> ________<br>
<b>Site Director Approval:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/obj/item/paper/foundation/amnestic_record
	name = "Amnestic Administration Record"
	desc = "A Foundation form for documenting amnestic use."

/obj/item/paper/foundation/amnestic_record/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - AMNESTIC ADMINISTRATION RECORD</h2><hr>
<b>Record ID:</b> ________<br>
<b>Date:</b> ________<br><hr>
<b>Administering Personnel:</b> ________________________<br>
<b>Clearance Level:</b> 1 / 2 / 3 / 4 / 5<br><hr>
<b>Subject Name:</b> ________________________<br>
<b>Subject Type:</b> Civilian / Foundation Personnel / D-Class / Other<br>
<b>Reason for Administration:</b><br>
[ ] Unintended SCP Exposure<br>
[ ] Security Leak<br>
[ ] Information Compromise<br>
[ ] Standard Protocol<br>
[ ] Other: ________________________<br><hr>
<b>Amnestic Class:</b> A / B / C / E<br>
<b>Dosage:</b> ________<br>
<b>Method of Administration:</b> Oral / Intravenous / Inhalation / Topical<br><hr>
<b>Memories Targeted for Removal:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Pre-Administration Assessment:</b><br>
___________________________________________________________________________<br><hr>
<b>Post-Administration Assessment:</b><br>
___________________________________________________________________________<br><hr>
<b>Complications:</b> None / Describe: ________________________<br><hr>
<b>Administering Signature:</b> ________________________ <b>Date:</b> ________<br>
<b>Supervisor Approval:</b> ________________________ <b>Date:</b> ________<br>
<br><i>CLASSIFIED - LEVEL 3 CLEARANCE REQUIRED</i><br>"}, FALSE)

/obj/item/paper/foundation/breach_report
	name = "Containment Breach Report"
	desc = "A Foundation form for documenting containment breaches."

/obj/item/paper/foundation/breach_report/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - CONTAINMENT BREACH REPORT</h2><hr>
<b>Report ID:</b> ________<br>
<b>Date of Breach:</b> ________<br>
<b>Time of Breach:</b> ________<br><hr>
<b>SCP Designation:</b> SCP-________<br>
<b>Object Class:</b> Safe / Euclid / Keter<br>
<b>Previous Containment Status:</b> Contained / Partial / Pending<br><hr>
<b>Breach Location:</b> ________________________<br>
<b>Breach Severity:</b> Minor / Moderate / Major / Catastrophic<br><hr>
<b>Sequence of Events:</b><br>
1. _________________________________________________________________________<br>
2. _________________________________________________________________________<br>
3. _________________________________________________________________________<br>
4. _________________________________________________________________________<br>
5. _________________________________________________________________________<br><hr>
<b>Personnel Casualties:</b> ________<br>
<b>D-Class Casualties:</b> ________<br>
<b>Personnel Injured:</b> ________<br><hr>
<b>Containment Failure Cause:</b><br>
[ ] Equipment Malfunction<br>
[ ] Human Error<br>
[ ] Sabotage / External Action<br>
[ ] SCP-Initiated<br>
[ ] Structural Failure<br>
[ ] Unknown<br>
[ ] Other: ________________________<br><hr>
<b>Recontainment Status:</b><br>
[ ] Recontained - Time: ________<br>
[ ] In Progress<br>
[ ] Pending MTF Deployment<br>
[ ] Not Recontained<br><hr>
<b>Preventive Measures Recommended:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Reporting Signature:</b> ________________________<br>
<b>Security Director Review:</b> ________________________<br>
<b>Site Director Review:</b> ________________________<br>
<br><i>CLASSIFIED - LEVEL 3 CLEARANCE REQUIRED</i><br>"}, FALSE)

/obj/item/paper/foundation/dclass_transfer
	name = "D-Class Transfer Form"
	desc = "A Foundation form for D-Class personnel transfers."

/obj/item/paper/foundation/dclass_transfer/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - D-CLASS TRANSFER FORM</h2><hr>
<b>Transfer ID:</b> ________<br>
<b>Date:</b> ________<br><hr>
<b>D-Class Designation:</b> D-________<br>
<b>Origin Facility:</b> ________________________<br>
<b>Destination:</b> Site-53<br><hr>
<b>Assignment:</b><br>
[ ] General Labor<br>
[ ] Medical Testing<br>
[ ] SCP Testing<br>
[ ] Maintenance<br>
[ ] Kitchen Duty<br>
[ ] Mining Operations<br><hr>
<b>Medical Clearance:</b> Cleared / Restricted - Notes: ________________________<br>
<b>Behavioral Assessment:</b> Compliant / Unstable / Hostile<br><hr>
<b>Special Notes:</b><br>
___________________________________________________________________________<br><hr>
<b>Authorizing Officer:</b> ________________________ <b>Date:</b> ________<br>"}, FALSE)

/obj/item/paper/foundation/scp_document
	name = "SCP Object Document"
	desc = "A classified SCP object documentation form."

/obj/item/paper/foundation/scp_document/Initialize(mapload)
	. = ..()
	setText({"<h2>SCP FOUNDATION - CLASSIFIED OBJECT FILE</h2><hr>
<b>Item #:</b> SCP-________<br><hr>
<b>Object Class:</b> Safe / Euclid / Keter / Thaumiel / Apollyon / Neutralized<br><hr>
<b>Special Containment Procedures:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Description:</b><br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br>
___________________________________________________________________________<br><hr>
<b>Addendum 1 - Discovery:</b><br>
___________________________________________________________________________<br><hr>
<b>Addendum 2 - Incident Log:</b><br>
___________________________________________________________________________<br><hr>
<b>Addendum 3 - Testing Log:</b><br>
___________________________________________________________________________<br><hr>
<br><i>CLASSIFIED - CLEARANCE LEVEL VARIES BY SCP DESIGNATION</i><br>"}, FALSE)
