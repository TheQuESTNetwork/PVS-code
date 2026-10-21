* People's Voice Survey data cleaning for Somaliland
* Date of last update: September 11,2024
* Last updated by: S Sabwa

/*

This file cleans Ipsos data for Somaliland. 

Cleaning includes:
	- Recoding outliers to missing 
	- Recoding skip patterns, refused, and don't know 
	- Creating new variables (e.g., time variables), renaming variables, labeling variables 
	- Correcting any values and value labels and their direction 
	
Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing 

*/

clear all
set more off 

*********************** SOMALILAND ***********************

* Import data 

import spss "$data/Somaliland/01 raw data/IpsosKY_Somaliland_PVS_F2F_CATI_Fulldata_V5.sav" // used spss data because time vars were off in .dta file
rename *, lower
 
notes drop _all

* Note: .a means NA, .r means refused, .d is don't know, . is missing 
*------------------------------------------------------------------------------*
* Rename some variables, and some recoding if variable will be dropped 
drop qq2

gen psu_id = ""
replace psu_id = "SO" + string(q4) if mode == 2

gen wave = 1

gen reccountry = 22
lab def country 22 "Somaliland"
lab values reccountry country

ren instanceid respondent_serial 
ren q12a q12_a
ren q12b q12_b
ren q14 q14_so
ren q15a q15a_so
ren q15b q15b_so
ren q15c q15c_so
ren q27a q27_a
ren q27b q27_b
ren q27c q27_c
ren q27d q27_d
ren q27e q27_e
ren q27f q27_f
ren q27g q27_g
ren q27h q27_h
ren q28a q28_a
ren q28b q28_b
ren q31a q31a
ren q31b q31b
ren q32 q32_so
ren q33a q33a_so 
ren q33b q33b_so
ren q33c q33c_so
ren q38a q38_a
ren q38b q38_b
ren q38c q38_c
ren q38d q38_d
ren q38e q38_e
ren q38f q38_f
ren q38g q38_g
ren q38h q38_h
ren q38i q38_i
ren q38j q38_j
ren q38k q38_k

ren q40a q40a_so
ren q40b q40b_so
ren q40c q40_c
ren q40e q40_d
ren q40d q40e_so 
ren q40f q40f_so

ren q41a q41_a
ren q41b q41_b
ren q41c q41_c

* gen rec variable for variables that have overlap values to be country code * 1000 + variable 
* replace the value to .r if the original one is 999

* Combine q33a, b, and c with q33 variable
replace q33 = q33a_so if missing(q33) & !missing(q33a_so)
replace q33 = q33b_so if missing(q33) & !missing(q33b_so)
replace q33 = q33c_so if missing(q33) & !missing(q33c_so)
drop q33a_so q33b_so q33c_so

* Recode extra categories in q33

replace q33 = 3 if q33 == 61          	// Clinic → PHU
replace q33 = 2 if inlist(q33, 64, 65) 	// Community health centre & Gov MCH → Health Center
replace q33 = 8 if q33 == .           	// . → refused 

*gen reclanguage = reccountry*1000 + language  // SS: missing from dataset
*gen recinterviewer_id = reccountry*1000 + interviewer_id // SS: missing from dataset

gen language = .a
label define Language .a "NA", replace
label values language Language

gen recq4 = reccountry*1000 + q4
*replace recq4 = .r if q4 == 998 // not needed in SO

gen recq5 = reccountry*1000 + q5  
*replace recq5 = .r if q5 == 999 // not needed in SO

gen recq7 = reccountry*1000 + q7
replace recq7 = .r if q7== .

gen recq8 = reccountry*1000 + q8
replace recq8 = .r if q8== 999

gen recq33 = reccountry*1000 + q33
replace recq33 = .r if q33== 8		

gen recq50 = reccountry*1000 + q50
*replace recq50 = .r if q50== 999 // not needed in SO

gen recq51 = reccountry*1000 + q51
replace recq51 = .r if q51== 999

* Relabel some variables now so we can use the orignal label values

*lab def lang 22001 "SO: Somali" 22002 "SO: Arabic" 22003 "SO: English" 20004 "SO: Others (specify)" 
*lab values reclanguage lang

local q4l labels3
local q5l labels4
local q7l labels6
local q8l labels7
local q33l labels32
local q50l labels46
local q51l labels47

foreach q in q4 q5 q7 q8 q33 q50 q51 {
	qui elabel list ``q'l'
	local `q'n = r(k)
	local `q'val = r(values)
	local `q'lab = r(labels)
	local g 0
	foreach i in ``q'lab'{
		local ++g
		local gr`g' `i'
	}

	qui levelsof rec`q', local(`q'level)

	forvalues i = 1/``q'n' {
		local recvalue`q' = 22000+`: word `i' of ``q'val''
		foreach lev in ``q'level'{
			if strmatch("`lev'", "`recvalue`q''") == 1{
				elabel define `q'_label (= 22000+`: word `i' of ``q'val'') ///
									    (`"SO: `gr`i''"'), modify			
			}	
		}                 
	}

	
	label val rec`q' `q'_label
}

drop q4 q5 q7 q8 q33 q50 q51 
ren rec* *

*------------------------------------------------------------------------------*
* Fix interview length variable and other time variables 

*generate recdate = dofc(date)
*format recdate %td // SS: date is missing from dataset

*------------------------------------------------------------------------------*
* Generate variables 
gen respondent_id = "SO" + string(respondent_serial) 

gen q52 = .a

* q18/q19 mid-point var 
gen q18_q19 = q18 
recode q18_q19 (999 = 0) (998 = 0) if q19 == 1
recode q18_q19 (999 = 2.5) (998 = 2.5) if q19 == 2
recode q18_q19 (999 = 7) (998 = 7) if q19 == 3
recode q18_q19 (999 = 10) (998 = 10) if q19 == 4
recode q18_q19 (998 = .r) if q19 == 999
recode q18_q19 (999 = .r) if q19 == 999

format duration %tcHH:MM:SS
gen int_length = (hh(duration)*60 + mm(duration) + ss(duration)/60)
drop duration

recode q45 (1 = 2 "Getting better") (2 = 1 "Staying the same") (3 = 0 "Getting worse") ///
		   (.a = .a "NA") (.d = .d "Don't Know") (.r = .r "Refused"), pre(rec) label(q45_label)

drop q45
ren rec* *		  

*------------------------------------------------------------------------------*
* Recode refused and don't know values 
recode q14_so q18 q21 q22 q23 q27_a q27_b q27_c q27_d q27_f q27_g q27_h cell1 (998 = .d)
	
recode q1 q8 q10 q12_a q12_b q13 q18 q19 q20 q22 q23 q24 q25 q27_a q27_b q27_c q28_a ///
	   q28_b q30 q31b q32_so q34 q35 q37 q38_a q38_b q38_c q38_d q38_e q38_g q38_i ///
	   q38_j q39 q40a_so q40b_so q40_c q40_d q40e_so q40f_so q41_a q41_b q41_c q42 q43 q45 ///
	   q46 q47 q48 q49 q51 cell2 (999 = .r)

recode q33 (22995 = .a)
recode q33 (22008 = .r)

*------------------------------------------------------------------------------*
* Check for implausible values - review

* Q20, Q21
list q18_q19 q21 if q21 > q18_q19 & q21 < . 
*N=9 people, ask Todd to confirm how I cleaned this:
replace q21 = q18_q19 if q21 > q18_q19 & q21 < . 

list q20 q21 if q21 == 0 | q21 == 1
*SS: N=6 people with q21 == 0
recode q21 (0 = .a)   

* List if yes to q20: "all visits in the same facility" but q21: "how many different healthcare facilities did you go to" is more than 0
list q20 q21 if q20 == 2 & q21 > 0 & q21 < . // Note: Yes needs to be recoded in q20 to 1
* None

* Q28a, Q28b 
* list if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months - Note: q28_a and q28_b in this dataset does not have this option
egen visits_total = rowtotal(q18_q19 q22 q23) 
list visits_total q17 if q17 == 5 & visits_total > 0 & visits_total < . | q17 == 5 & visits_total > 0 & visits_total < .
*SS: N=4 with issues, this is how we've fixed it in the past
recode q17 (5 = .r) if visits_total > 0 & visits_total < .

drop visits_total

*------------------------------------------------------------------------------*
 * Recode missing values to NA for intentionally skipped questions 
* do some of these have to be the rec version?

*q1/q2 
recode q2 (. = .a) if q1 > 0 & q1 < . //change q2 missing to .a if q1 has an actual value, keep q2 be . if q1 == .
recode q1 (. = .r) if inrange(q2,2,8) | q2 == .r 
* Note: Some missing values in q1 that should be refused 

* q7 
recode q7 (. = .a) if q6 == 2 | q6 == .r | q6 == .
recode q7 (nonmissing = .a) if q6 == 2

*q14_so-17
recode q14_so q15a_so q15b_so q15c_so q16 q17 (. = .a) if q13 == 0 | q13 == .r 
recode q15a_so (. = .a) if q14_so !=1
recode q15b_so (. = .a) if q14_so !=2
recode q15c_so (. = .a) if q14_so !=3

* NA's for q19-21 
recode q19 (. = .a) if q18 != .d & q18 != .r 
recode q20 (. = .a) if q18 == 0 | q18 == 1 | q19 == 1 | q19 == .r 
recode q21 (. = .a) if q20 == 2 | q20 == .a | q20 == .r

*q24 
recode q24 (. = .a) if q23 == 0 | q23 == .d | q23 == .r

*q25
recode q25 (. = .a) if q23 == 0 | q23 == .d | q23 == .r

* q27_b q27_c
recode q27_b q27_c (. = .a) if q3 !=1

*q28
recode q28_a q28_b (. = .a) if q18 == 0 | q19 == 1 | q19 == .r

* q30
recode q30 (. = .a) if q29 == 0 | q29 == .r

* q32_so- na's
recode q32_so q33 q34 q35 q36 q37 q38_a q38_b q38_c q38_d q38_e q38_f /// 
	   q38_g q38_h q38_i q38_j q38_k q39 (. = .a) if q18 == 0 | q19 == 1 | q19 == .r
	  	   	   
recode q32_so q33 q34 q35 q36 q37 q38_a q38_b q38_c q38_d q38_e q38_f /// 
	   q38_g q38_h q38_i q38_j q38_k q39 (nonmissing = .a) if q18 == 0 | q19 == 1

recode q36 (. = .a) if q35!=1 

recode q38_k (. = .a) if q35 !=1

*CELL2
recode cell2 (. = .a) if cell1 != 1

*------------------------------------------------------------------------------*
* Recode values and value labels:
* Recode values and value labels so that their values and direction make sense:

recode q2 (2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 5) (7 = 6) (8 = 7)
lab def q2_label 0 "under 18" 1 "18-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" ///
				6 "70-79" 7 "80 +" .r "Refused" .a "NA" .d "Don't Know" .r "Refused"
lab val q2 q2_label

* add a new label for q15b_so to avoid conflicts
label define q15b_so_lbl ///
    1 "Private hospital" ///
    2 "Private Clinic" ///
    3 "Pharmacy" ///
    4 "Traditional practitioner/ Religious healer" ///
    .a "NA" ///
    .r "Refused", replace

label values q15b_so q15b_so_lbl

*add new option for q16 
recode q16 (10 = 15)
lab def q16_label 1 "Low cost" 2 "Short distance" 3 "Short waiting time" ///
				  4 "Good healthcare provider skills" ///
				  5 "Staff shows respect" 6 "Medicines and equipment are available" ///
				  7 "Only facility available" ///
				  8 "Covered by insurance" 9 "Other, specify" ///
				  15 "SO: Determined by the family in the cities " .a "NA" ///
				 .d "Don't Know" .r "Refused"
lab val q16 q16_label

recode q19 (1 = 0) (2 = 1) (3 = 2) (4 = 3)
lab def labels21 0 "0" 1 "1-4" 2 "5-9" 3 "10 or more" .a "NA" .d "Don't know" .r "Refused",replace
lab val q19 labels21

*fix order of q20/q21
*q21 has two different versions of "2"?
recode q20 (2 = 1 "Yes") (1 = 0 "No") (.r = .r "Refused") (.a = .a "NA"), ///
	   pre(rec) label(yes_no)
	   
recode q30 (9 = 16) (10 = 17) (11 = 18) (8 = 10)
lab def q30_label 1 "High cost (e.g., high out of pocket payment, not covered by insurance)"  ///
				 2 "Far distance (e.g., too far to walk or drive, transport not readily available)" ///
				 3 "Long wait time (e.g., long line to access facility, long wait for the provider)" ///
				 4 "Poor healthcare provider skills (e.g., spent too little time with patient, did not conduct a thorough exam)" ///
				 5 "Staff don't show respect (e.g., staff is rude, impolite, dismissive)" ///
				 6 "Medicines and equipment are not available (e.g., medicines regularly out of stock, equipment like X-ray machines broken or unavailable)" ///
				 7 "Illness not serious enough" 10 "Other (specify)" 16 "SO: They are closed" ///
				 17 "SO: Was affected by conflicts" 18 "SO: Doctor was not available" .a "NA" ///
				 .d "Don't Know" .r "Refused"
lab val q30 q30_label				 

recode q32_so (4 = 1) (7 = 4)
lab def q32_so_label 1 "Public" 2 "Private (including pharmacies and traditional practitioners)" ///
	    3 "Community health centre" 4 "Other" .a "NA" .d "Don't Know" .r "Refused"
lab val q32_so q32_so_label		

recode q34 (7 = 6) (8 = 7) (9 = 8) (11 = 9) (12 = 10) (13 = 11)
lab def q34_label 1 "Care for an urgent or new health problem such as an accident or injury or a new symptom like fever, pain, diarrhea, or depression." 2 "Follow-up care for a longstanding illness or chronic disease such as hypertension or diabetes. This may include mental health conditions." 3 "Preventive care or a visit to check on your health, such as an annual check-up, antenatal care, or vaccination." 4 "Other (specify)" 5 "SO: Allergies" 6 "SO: Blood transfusion" 7 "SO: Dental issue" 8 "SO: Eye problem" 9 "SO: Gastric/stomach ache" 10 "SO: Nerve pain" 11 "SO: Visited a hospitalised member of the family" .a "NA" .d "Don't Know" .r "Refused"
lab val q34 q34_label

recode q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k (5=4) (4=3) (3=2) (2=1) (1=0) (6=.a) (7=.a)
lab def q38_label 0 "Poor" 1 "Fair" 2 "Good" 3 "Very good" 4 "Excellent" .a "NA" .d "Don't Know" .r "Refused"
lab val q38_a q38_b q38_c q38_d q38_e q38_f q38_g q38_h q38_i q38_j q38_k q38_label 

* Add value labels 
label define labels24 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels25 .a "NA" .d "Don't know" .r "Refused",add	 
label define q8_label .a "NA" .d "Don't know" .r "Refused",add	 
label define labels9 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels11 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels12 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels13 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels14 .a "NA" .d "Don't know" .r "Refused",add	 
label define labels15 .a "NA" .d "Don't know" .r "Refused",add
label define labels16 .a "NA" .d "Don't know" .r "Refused",add	
label define labels17 .a "NA" .d "Don't know" .r "Refused",add
label define labels18 .a "NA" .d "Don't know" .r "Refused",add	
label define labels19 .a "NA" .d "Don't know" .r "Refused",add
label define labels22 .a "NA" .d "Don't know" .r "Refused",add
label define labels23 .a "NA" .d "Don't know" .r "Refused",add
label define labels27 .a "NA" .d "Don't know" .r "Refused",add
label define labels28 .a "NA" .d "Don't know" .r "Refused",add
label define q33_label .a "NA" .d "Don't know" .r "Refused",add
label define labels33 .a "NA" .d "Don't know" .r "Refused",add
label define labels34 .a "NA" .d "Don't know" .r "Refused",add
label define labels36 .a "NA" .d "Don't know" .r "Refused",add
label define labels37 .a "NA" .d "Don't know" .r "Refused",add
label define labels38 .a "NA" .d "Don't know" .r "Refused",add
label define labels39 .a "NA" .d "Don't know" .r "Refused",add
label define labels40 .a "NA" .d "Don't know" .r "Refused",add
label define labels41 .a "NA" .d "Don't know" .r "Refused",add
label define labels42 .a "NA" .d "Don't know" .r "Refused",add
label define labels43 .a "NA" .d "Don't know" .r "Refused",add
label define labels44 .a "NA" .d "Don't know" .r "Refused",add
label define labels45 .a "NA" .d "Don't know" .r "Refused",add
label define labels48 .a "NA" .d "Don't know" .r "Refused",add

*for appending process:
label copy q4_label q4_label2
label copy q5_label q5_label2
label copy q33_label q33_label2
label copy q50_label q50_label2
label copy q51_label q51_label2

label val q4 q4_label2
label val q5 q5_label2
lab val q33 q33_label2
lab val q50 q50_label2
lab val q51 q51_label2


label drop q4_label q5_label q33_label q50_label q51_label

*------------------------------------------------------------------------------*

* Renaming variables 
* Rename variables to match question numbers in current survey

drop q20 gps_longitude gps_latitude start_time end_time q37_other
ren rec* *

*Reorder variables
order cell1 cell2
order q*, sequential
order respondent_id weight respondent_serial mode country // 


*------------------------------------------------------------------------------*
* Label variables					
lab var country "Country"
*lab var int_length "Interview length (minutes)" 
*lab var date "Date of the interview"
lab var respondent_id "Respondent ID"
*lab var language "Language"
lab var mode "mode"
lab var q1 "Q1. Respondent's еxact age"
lab var q2 "Q2. Respondent's age group"
lab var q3 "Q3. Respondent's gender"
lab var q4 "Q4. What region do you live in?"
lab var q5 "Q5. Which of these options best describes the place where you live?"
lab var q6 "Q6. Do you have health insurance?"
lab var q7 "Q7. What type of health insurance do you have?"
lab var q8 "Q8. What is the highest level of education that you have completed?"
lab var q9 "Q9. In general, would you say your health is:"
lab var q10 "Q10. In general, would you say your mental health, including your mood and your ability to think clearly, is:"
lab var q11 "Q11. By longstanding, I mean illness, health problem, or mental health problem which has lasted or is expected to last for six months or more."
lab var q12_a "Q12a. How confident are you that you are responsible for managing your health?"
lab var q12_b "Q12b. Can tell a healthcare provider your concerns even when not asked?"
lab var q13 "Q13. Is there one healthcare facility or provider's group you usually go to?" 
lab var q14_so "Q14. SO only: Is this a public, private or another type of facility?"
lab var q15a_so "Q15a. SO only: What type of healthcare facility is this? Government facilities"
lab var q15b_so "Q15b. SO only: What type of healthcare facility is this? Private Sector"
lab var q15c_so "Q15c. SO only: What type of healthcare facility is this? Other"
label variable q16 "Q16. Why did you choose this healthcare facility? Please tell us the main reason."
label variable q17 "Q17. Overall, how would you rate the quality of healthcare you received in the past 12 months from this healthcare facility?"
label variable q18 "Q18. How many healthcare visits in total have you made in the past 12 months?"
label variable q19 "Q19. Total number of healthcare visits in the past 12 months choice(range)"
lab var q18_q19 "Q18/Q19. Total mumber of visits made in past 12 months (q18, q19 mid-point)"
label variable q20 "Q20. You said you made * visits. Were they all to the same facility?"
label variable q21 "Q21. How many different healthcare facilities did you go to in total?"
label variable q22 "Q22. How many visits did you have with a healthcare provider at your home?"
label variable q23 "Q23. How many virtual or telemedicine visits did you have in the past 12 months?"
label variable q24 "Q24. What was the main reason for the virtual or telemedicine visit?"
label variable q25 "Q25. How would you rate the overall quality of your last telemedicine visit?"
label variable q26 "Q26. Stayed overnight at a facility in past 12 months (inpatient care)"
label variable q27_a "Q27a. Blood pressure tested in the past 12 months"
label variable q27_b "Q27b. Breast examination"
label variable q27_c "Q27c. Received cervical cancer screening, like a pap test or visual inspection"
label variable q27_d "Q27d. Had your eyes or vision checked in the past 12 months"
label variable q27_e "Q27e. Had your teeth checked in the past 12 months"
label variable q27_f "Q27f. Had a blood sugar test in the past 12 months"
label variable q27_g "Q27g. Had a blood cholesterol test in the past 12 months"
label variable q27_h "Q27h. Received care for depression, anxiety, or another mental health condition"
label variable q28_a "Q28a. A medical mistake was made in your treatment or care in the past 12 months"
label variable q28_b "Q28b. been treated unfairly or discriminated against by a doctor, nurse, or..."
label variable q29 "Q29. Have you needed medical attention but you did not get it in past 12 months?"
label variable q30 "Q30. The last time this happened, what was the main reason?"
label variable q31a "Q31a. Have you ever needed to borrow money to pay for healthcare"
label variable q31b "q31b. Sell items to pay for healthcare"
label variable q32_so "Q32. SO only: Was this a public, private or another type of facility?"
label variable q33 "Q33. What type of healthcare facility is this?"
label variable q34 "Q34. What was the main reason you went?"
label variable q35 "Q35. Was this a scheduled visit or did you go to the facility without an appt?"
label variable q36 "Q36. How long did you wait in days, weeks, or months between scheduling the appointment and seeing the health care provider?"
label variable q37 "Q37. At this most recent visit, once you arrived at the facility, approximately how long did you wait before seeing the provider?"
label variable q38_a "Q38a. How would you rate the overall quality of care you received?"
label variable q38_b "Q38b. How would you rate the knowledge and skills of your provider?"
label variable q38_c "Q38c. How would you rate the equipment and supplies that the provider had?"
label variable q38_d "Q38d. How would you rate the level of respect your provider showed you?"
label variable q38_e "Q38e. How would you rate your provider knowledge about your prior visits and test results?"
label variable q38_f "Q38f. How would you rate whether your provider explained things clearly?"
label variable q38_g "Q38g. How would you rate whether you were involved in your care decisions?"
label variable q38_h "Q38h. How would you rate the amount of time your provider spent with you?"
label variable q38_i "Q38i. How would you rate the amount of time you waited before being seen?"
label variable q38_j "Q38j. How would you rate the courtesy and helpfulness at the facility?"
label variable q38_k "Q38k. How would you rate how long it took for you to get this appointment?"
label variable q39 "Q39. How likely would recommend this facility to a friend or family member?"
label variable q40a_so "Q40a. How would you rate the quality of care provided for care for pregnancy and children?"
label variable q40b_so "Q40b. Care for infections such as Malaria, Tuberculosis etc?"
label variable q40_c "Q40c. How would you rate the quality of care provided for chronic conditions?"
label variable q40_d "Q40d. How would you rate the quality of care provided for the mental health?"
label variable q40e_so "Q40e. SO only: How would you rate the quality of care provided for the mental health?"
label variable q40f_so "Q40f. SO only: How would you rate the quality of care provided for other non-urgent common illnesses such as skin, ear conditions, stomach problems, urinary problems, joint paints etc."
label variable q41_a "Q41a. How confident are you that you'd get good healthcare if you were very sick?"
label variable q41_b "Q41b. How confident are you that you'd be able to afford the care you required?"
label variable q41_c "Q41c. How confident are you that the government considers the public's opinion?"
label variable q42 "Q42. How would you rate the quality of government or public healthcare system in your country?"
label variable q43 "Q43. How would you rate the quality of the private for-profit healthcare system in your country?"
label variable q45 "Q45. Is your country's health system is getting better, staying the same or getting worse?"
label variable q46 "Q46. Which of these statements do you agree with the most?"
label variable q47 "Q47. How would you rate the government's management of the COVID-19 pandemic overall?"
label variable q48 "Q48. How would you rate the quality of care provided? (Vignette, option 1)"
label variable q49 "Q49. How would you rate the quality of care provided? (Vignette, option 2)"
label variable q50 "Q50. What is your native language or mother tongue?"
label variable q51 "Q51. Total monthly household income"
label variable cell1 "CELL1. Do you have another mobile phone number besides the one I am calling you on?"
label variable cell2 "CELL2. How many other mobile phone numbers do you have?"
label variable int_length "Interview length"


*------------------------------------------------------------------------------*
* WEIGHT CONSTRUCTION
* Date: March 2026
*
* Two sets of weights produced:
*   1. weight_ipsos: Original Ipsos weights (raked on Region × Gender only),
*      rescaled to sum to sample size
*   2. weight: New KGHP weights (raked on Age × Region × Edu×Gender)
*
* Methodology follows Malawi (crPVS_cln_MW.do):
*   Step 1: F2F design weights (correct regional non-proportionality)
*   Step 2: Mode blending weights (CATI=phone owners, F2F=non-phone)
*   Step 3: Combine into base weight
*   Step 4: Normalise (mean = 1)
*   Step 5: IPF raking to population benchmarks
*   Step 6: Diagnostics and comparison with Ipsos weights
*
* Population benchmark sources:
*   Region: Somaliland MoH/Ministry of Economic Planning 2024 projections
*           (via Ipsos technical report, Table 1)
*   Age:    UN World Population Prospects (Somalia, adults 18+)
*   Gender: SLHDS 2020 (49% male, 51% female)
*   Education: SLHDS 2020 (collapsed to 3 levels)
*   Phone ownership: SLHDS 2020 (~75% household mobile ownership)
*------------------------------------------------------------------------------*

* Rescale original Ipsos weight so it sums to sample size (per Todd's email 11/26/2024)
egen total_weight = total(weight)
gen rescaled_weight = (weight / total_weight) * _N
drop weight total_weight
rename rescaled_weight weight

tab country // confirm sample size (expect N=2,500)

*---------- Create demographic variables for weighting ----------*

** Gender: q3: 0=Male, 1=Female
gen gender = 0 if q3==0
replace gender = 1 if q3==1
label define gender 0 "Male" 1 "Female"
label values gender gender
tab gender, m

** Age (5 groups): derived from q2
* q2: 1=18-29, 2=30-39, 3=40-49, 4=50-59, 5=60-69, 6=70-79, 7=80+
gen age_5g = 0 if q2==1
replace age_5g = 1 if q2==2
replace age_5g = 2 if q2==3
replace age_5g = 3 if q2==4
replace age_5g = 4 if q2==5 | q2==6 | q2==7
label define age_5g 0 "18-29" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60+"
label values age_5g age_5g
tab age_5g, m

** Region: derived from q4
* q4 values confirmed from tab q4 output:
*   22001 → Marodijeeh: 1,456,218  (29.99%)
*   22002 → Togdheer:     860,061  (17.71%)
*   22003 → Awdal:        931,953  (19.19%)
*   22004 → Sanaag:       753,193  (15.51%)
*   22005 → Sahil:        305,916  ( 6.30%)
*   22006 → Sool:         548,799  (11.30%)
* Population estimates from Ipsos/MoH 2024 (total = 4,856,142)
tab q4

gen Region = .
replace Region = 0 if q4==22001  // Marodijeeh
replace Region = 1 if q4==22002  // Togdheer
replace Region = 2 if q4==22003  // Awdal
replace Region = 3 if q4==22004  // Sanaag
replace Region = 4 if q4==22005  // Sahil
replace Region = 5 if q4==22006  // Sool
label define Region 0 "Marodijeeh" 1 "Togdheer" 2 "Awdal" 3 "Sanaag" 4 "Sahil" 5 "Sool"
label values Region Region
tab Region, m
tab Region mode, m  // verify F2F regional distribution

** Education (3 groups): derived from q8
* q8 values confirmed from crPVS_der.do:
*   22001, 22002 → None (no formal education)
*   22003, 22004 → Primary
*   22005 → Secondary
*   22006 → Post-secondary/Tertiary
* SLHDS 2020: No ed=78.4%, Primary=9.4%, Secondary=6.4%, Tertiary=5.8%
* Collapsed: None/Primary=87.8%, Secondary=6.4%, Tertiary+=5.8%
tab q8

gen education_3g = .
replace education_3g = 0 if inlist(q8, 22001, 22002, 22003, 22004)  // None or Primary
replace education_3g = 1 if q8==22005                                // Secondary
replace education_3g = 2 if q8==22006                                // Tertiary+
* Impute refused/missing q8 to modal category (None/Primary = 87.8% of pop)
* so ipfweight does not drop these observations (N=2 in current data)
replace education_3g = 0 if missing(education_3g)
label define education_3g 0 "None or primary" 1 "Secondary" 2 "Tertiary+"
label values education_3g education_3g
tab education_3g, m

** Joint distribution: education × gender (for raking)
gen edu_gender = 0 if education_3g==0 & gender==1
replace edu_gender = 1 if education_3g==1 & gender==1
replace edu_gender = 2 if education_3g==2 & gender==1
replace edu_gender = 3 if education_3g==0 & gender==0
replace edu_gender = 4 if education_3g==1 & gender==0
replace edu_gender = 5 if education_3g==2 & gender==0
label define edu_gender 0 "None/Primary, Female" 1 "Secondary, Female" ///
	2 "Tertiary+, Female" 3 "None/Primary, Male" 4 "Secondary, Male" ///
	5 "Tertiary+, Male"
label values edu_gender edu_gender
tab edu_gender, m

** Cross-tabs to inspect sample discrepancies
tab gender Region, cell
tab age_5g Region, cell
tab education_3g gender, cell


*********************************************************
* STEP 1: Design weights for F2F (CAPI)
* F2F targeted villages with zero/poor network coverage
* NOT proportional to population — must correct
* Note: No F2F interviews were conducted in Sool (Region==5)
* Population shares rescaled to 5 F2F regions (excl. Sool):
*   Marodijeeh: 29.99/88.70 = 33.81%
*   Togdheer:   17.71/88.70 = 19.97%
*   Awdal:      19.19/88.70 = 21.63%
*   Sanaag:     15.51/88.70 = 17.49%
*   Sahil:       6.30/88.70 =  7.10%
*********************************************************
count if mode==2
local n_f2f = r(N)

count if mode==2 & Region==0
local n_marodijeeh = r(N)
count if mode==2 & Region==1
local n_togdheer = r(N)
count if mode==2 & Region==2
local n_awdal = r(N)
count if mode==2 & Region==3
local n_sanaag = r(N)
count if mode==2 & Region==4
local n_sahil = r(N)

di "F2F counts — Marodijeeh: `n_marodijeeh'  Togdheer: `n_togdheer'  Awdal: `n_awdal'  Sanaag: `n_sanaag'  Sahil: `n_sahil'  Total: `n_f2f'"

gen dw_f2f = .
replace dw_f2f = 0.3381 / (`n_marodijeeh' / `n_f2f') if mode==2 & Region==0
replace dw_f2f = 0.1997 / (`n_togdheer'   / `n_f2f') if mode==2 & Region==1
replace dw_f2f = 0.2163 / (`n_awdal'      / `n_f2f') if mode==2 & Region==2
replace dw_f2f = 0.1749 / (`n_sanaag'     / `n_f2f') if mode==2 & Region==3
replace dw_f2f = 0.0710 / (`n_sahil'      / `n_f2f') if mode==2 & Region==4

* Sool (Region==5): CATI only, no F2F interviews conducted
* CATI: population-proportionate sampling → design weight = 1
replace dw_f2f = 1 if mode==1

assert !missing(dw_f2f)

*********************************************************
* STEP 2: Blending weights by mode
* Phone ownership: ~75% (SLHDS 2020)
* CATI frame  = phone owners (75% of adult population)
* F2F frame   = non-phone owners (25% of adult population)
*********************************************************
local phone_own     = 0.75
local non_phone_own = 0.25

count if mode==1
local n_cati = r(N)
count if mode==2
local n_f2f = r(N)
count
local n_total = r(N)

scalar cati_share = `n_cati'  / `n_total'
scalar f2f_share  = `n_f2f'   / `n_total'

gen blend_wgt = .
replace blend_wgt = `phone_own'     / cati_share if mode==1
replace blend_wgt = `non_phone_own' / f2f_share  if mode==2

assert !missing(blend_wgt)

*********************************************************
* STEP 3: Combine for base weight
*********************************************************
gen base_wgt = dw_f2f * blend_wgt

*********************************************************
* STEP 4: Normalise base weight
* Rescale so mean = 1 (weights sum to total sample size)
*********************************************************
sum base_wgt
gen base_wgt_norm = base_wgt / r(mean)

*********************************************************
* STEP 5: IPF raking to population benchmarks
* Dimensions: age_5g (5), Region (6), edu_gender (6)
*
* Benchmarks (percentages):
*   age_5g:  18-29=43, 30-39=24, 40-49=15, 50-59=10, 60+=8
*            Source: UN World Population Prospects (Somalia, adults 18+)
*
*   Region (in order 0-5):
*     0=Marodijeeh=29.99, 1=Togdheer=17.71, 2=Awdal=19.19,
*     3=Sanaag=15.51, 4=Sahil=6.30, 5=Sool=11.30
*            Source: Somaliland MoH/Min. of Econ. Planning 2024
*
*   edu_gender (education × gender, assuming independence):
*     Education (SLHDS 2020, 3g): None/Primary=87.8%, Secondary=6.4%, Tertiary+=5.8%
*     Gender (SLHDS 2020): Female=51%, Male=49%
*     Cells: None/Primary×Female=44.78, Secondary×Female=3.26, Tertiary+×Female=2.96,
*            None/Primary×Male=43.02,   Secondary×Male=3.14,   Tertiary+×Male=2.84
*     Note: Assumes independence between education and gender.
*           Males likely have somewhat higher education in Somaliland —
*           refine if better gender-specific education data available.
*********************************************************
ipfweight age_5g Region edu_gender, gen(weight_mod) startwgt(base_wgt_norm) ///
	val(43 24 15 10 8 ///
		29.99 17.71 19.19 15.51 6.30 11.30 ///
		44.78 3.26 2.96 43.02 3.14 2.84) ///
	maxit(50) tolerance(0.005) upthreshold(5)

*********************************************************
* STEP 6: DIAGNOSTICS
*********************************************************
* Modified weight distribution
di _n "=== MODIFIED WEIGHT (weight_mod) DISTRIBUTION ==="
sum weight_mod, detail

* Ipsos weight distribution
di _n "=== IPSOS WEIGHT (weight) DISTRIBUTION ==="
sum weight, detail

* Check by mode — F2F should have higher avg weight given smaller sample
di _n "=== WEIGHTS BY MODE ==="
di "Modified weight by mode:"
tab mode, sum(weight_mod)
di "Ipsos weight by mode:"
tab mode, sum(weight)

* Flag extreme weights (> 5x mean is a common threshold)
sum weight_mod
gen extreme_wgt = (weight_mod > 5 * r(mean))
tab extreme_wgt mode
drop extreme_wgt

* Verify weighted marginals match population targets
di _n "=== VERIFY MODIFIED WEIGHT MARGINALS ==="
foreach var of varlist age_5g Region edu_gender {
	di _n "--- `var' (weight_mod) ---"
	tab `var' [iweight=weight_mod]
}

*********************************************************
* STEP 7: COMPARE MODIFIED vs IPSOS WEIGHTS
*********************************************************
di _n "=== COMPARISON: weight_mod vs weight (Ipsos) ==="
corr weight_mod weight

* Compare weighted distributions on key dimensions
foreach var of varlist age_5g Region edu_gender gender {
	di _n "--- `var' ---"
	di "Unweighted:"
	tab `var'
	di "Ipsos weight:"
	tab `var' [iweight=weight]
	di "Modified weight:"
	tab `var' [iweight=weight_mod]
}

* Compare weighted means of key outcome variables
* Uncomment and adjust variable names as needed:
/*
foreach var of varlist q9 q42 q43 q45 {
	di _n "--- `var' ---"
	mean `var'
	mean `var' [pweight=weight]
	mean `var' [pweight=weight_mod]
}
*/

*********************************************************
* STEP 8: REPLACE THE ORIGIANL ONE "WEIGHT" USE WEIGHT_MOD 
*********************************************************
replace weight = weight_mod


* Drop intermediate weighting variables
drop dw_f2f blend_wgt base_wgt base_wgt_norm 
drop gender age_5g Region education_3g edu_gender
drop weight_mod

* Reorder variables
order q*, sequential
order respondent_id weight respondent_serial mode country

*------------------------------------------------------------------------------*

* Save data
save "$data_mc/02 recoded data/input data files/pvs_so.dta", replace
