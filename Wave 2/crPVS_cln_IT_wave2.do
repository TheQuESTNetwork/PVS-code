* People's Voice Survey data cleaning for Italy - Wave 2
* Date of last update: January 2026
* Last updated by: S Islam

/*

This file cleans Ipsos data for Italy. 

Cleaning includes:
	- Recoding outliers to missing 
	- Recoding skip patterns, refused, and don't know 
	- Creating new variables (e.g., time variables), renaming variables, labeling variables 
	- Correcting any values and value labels and their direction 
	
Missingness codes: .a = NA (skipped), .r = refused, .d = don't know, . = true missing 

*/

clear all
set more off 

*********************** ITALY (WAVE 2) ***********************

* Import raw data 
use "$data/Italy wave2/01 raw data/PVS_ita_w2_clean.dta"

*Label as wave 2 data:
gen wave = 2

*Dropping following vars:
drop country_reg q4_municipality q4_zipcode q27i_ita q27j_ita q27_h_access q27_h_facility q27_h_facility_other ///
p_r_eta_6 a_istat_reg zona_5istat zona_5istatlaurea group_code genere_a sesso n_children age_child* ///
vacc_imp vacc_safe vacc_eff priv_exp invite vacc_frag vacc_comp vacc_opt tech_use tech_impr tech_syst ///
reg_acc reg_qual inc_help inc_phys inc_scre inc_vacc inc_diet inc_smok inc_no emp_sector emp_sector_other ///
emp_role emp_role_other area zipcode municipality province id_raw laurea age age_cat gender region urban ///
insured education health health_mental health_chronic activation usual_source usual_type_own usual_type_lvl ///
usual_type usual_reason usual_quality visits visits_cat last_type_own last_type_lvl last_type last_reason ///
last_sched last_sched_time last_qual last_skills last_supplies last_respect last_know last_explain last_decisions ///
last_visit_rate last_wait_rate last_courtesy last_sched_rate last_promote phc_women phc_child phc_chronic phc_mental ///
conf_sick conf_afford conf_getafford conf_opinion qual_public qual_private system_outlook system_reform covid_manage ///
vignette_good vignette_poor

*------------------------------------------------------------------------------*
* Rename some variables, and some recoding if variable will be dropped 

gen respondent_serial = _n
gen respondent_id = "IT" + string(respondent_serial, "%09.0f")

* Match region var with Wave 1
replace q4 = 14022 if q4 == 14021 & q4_province == 7
replace q4 = 14021 if q4 == 14017 & q4_province == 21
replace q4 = 14017 if q4 == 14017 & q4_province == 22
recode q4 (. = .a)

lab copy region_lbl q4_label
lab define q4_label 14017 "IT: Provincia Autonoma Trento" 14021 "IT: Provincia Autonoma Bolzano/Bozen" 14022 "IT: Valle d'Aosta" .a "NA", modify
lab val q4 q4_label

* Match q52 with Wave 1
recode q52 ///
    (14001 = 14001 "IT: Fratelli d'Italia") ///
    (14003 = 14002 "IT: Forza Italia") ///
    (14002 = 14003 "IT: Lega per Salvini Premier") ///
    (14008 = 14004 "IT: Azione / Italia Viva") ///
    (14004 = 14005 "IT: Partito democratico") ///
    (14006 = 14006 "IT: Movimento cinque stelle") ///
    (14005 = 14007 "IT: Alleanza Verdi-Sinistra") ///
    (14007 = 14008 "IT: Stati Uniti d'Europa") ///
    (14009 = 14009 "IT: Pace Terra Dignità") ///
    (14010 = 14010 "IT: Libertà di Cateno De Luca") ///
    (14011 = 14011 "IT: Another party") ///
    (14012 = 14012 "IT: I did not vote") ///
    (14013 = 14013 "IT: I voted a blank ballot") ///
	(. = .r "Refused") ///
    , gen(recq52)

lab copy recq52 q66_label
lab values recq52 q66_label
lab drop recq52

drop q4_province q52
rename recq52 q52

recode q8 ///
    (14001 = 14001 "IT: Mai frequentato la scuola o solo Nido e Scuola dell infanzia") ///
    (14002 = 14002 "IT: Scuola primaria") ///
    (14003 = 14003 "IT: Scuola secondaria di primo grado") ///
    (14004 = 14005 "IT: Liceo, Istituto tecnico o Istituto professionale") ///
    (14005 = 14006 "IT: Università Laurea triennale(compreso alta formazione artistica)") ///
    (14006 = 14007 "IT: Università Laurea Magistrale o ciclo unico") ///
    (14007 = 14008 "IT: Dottorato") ///
	(. = .r "Refused") ///
    , gen(recq8)
	
lab copy recq8 q8_label
lab values recq8 q8_label
lab drop recq8

drop q8
rename recq8 q8                                    

**recoding derived variables
recode minority (1 = 0) (2 = 1), gen(minority_it)
lab def minority 0 "Minority group" 1 "Majority group"
lab val minority minority 
drop minority

replace income = .r if q51 == .r
label define incomlbl .r "Refused", add
label values income incomlbl

rename income income_it

*------------------------------------------------------------------------------*
* Generate vairables
* Fix interview length variable and other time variables 

recode q18 (-1 = 0) if q19 == 0

* q18/q19 mid-point var 
gen q18_q19 = q18 

recode q18_q19 (998 = 0) if q19 == 0
recode q18_q19 (998 = 1) if q19 == 1
recode q18_q19 (998 = 2.5) if q19 == 2
recode q18_q19 (998 = 7) if q19 == 3
recode q18_q19 (998 = 10) if q19 == 4

format date %td_D_M_CY

*------------------------------------------------------------------------------*
* Recode all Refused and Don't know responses

* Already recoded in dataset

*------------------------------------------------------------------------------*
* Check for implausible values 

* Q17. Overall respondent's rating of the quality received in this facility
* Q18/Q19. Total number of visits made in past 12 months (q23, q24 mid-point)
* Q20. Were all of the visits you made to the same healthcare facility? 
* Q21. How many different healthcare facilities did you go to? 
* Q22. How many visits did you have with a healthcare provider at your home?
* Q23. How many virtual or telemedicine visits did you have?

* Q20, Q21
list q18_q19 q21 if q21 > q18_q19 & q21 < .
* None 

list q20 q21 if q21 == 0 | q21 == 1
*SI: N=169 people with q21 == 1 but "no" to q20
recode q21 (1 = 0) if q20 == 0

* List if yes to q20: "all visits in the same facility" but q21: "how many different healthcare facilities did you go to" is more than 0
list q20 q21 if q20 ==1 & q21 > 0 & q21 < . 
* None

* Q28a, Q28b 
* list if they say "I did not get healthcare in past 12 months" but they have visit values in past 12 months - Note: q28_a and q28_b in this dataset does not have this option
egen visits_total = rowtotal(q18_q19 q22 q23) 
list visits_total q17 if q17 == 5 & visits_total > 0 & visits_total < . | q17 == 5 & visits_total > 0 & visits_total < .
* None

drop visits_total

*------------------------------------------------------------------------------*
* Recode missing values to NA for intentionally skipped questions (q14, q32 missing in this dataset)

*q14-17
recode q14_it q15 q16 q17 (. = .a) if q13 !=1
recode q17 (.r = .a)

* NA's for q20-21 
recode q20 (. = .a) if q18 <1 | q18 == .d | q18 == .r | q19 != 2 | q19 != 3 | q19 != 4

recode q21 (. = .a) if q20 !=0 

*q24-q25 
recode q24 q25 (. = .a) if q23 == 0  | q23 == .d | q23 == .r

* q27_b q27_c
recode q27_b q27_c (. = .a) if q3 !=1 

*q28
recode q28_a q28_b (. = .a) if q18 == 0 | q18 == .d | q18 == .r | q19 == 1 | q19 == .d | ///
							   q19 == .r | q22 == 0 | q22 == .d | q22 == .r | ///
							   q23 == 0 | q23 == .d | q23 == .r

* q30
recode q30 (. = .a) if q29 !=1

* q32-38
recode q32_it q33 q34 q35 q36 q38_a q38_b q38_c q38_d q38_e q38_f /// 
	   q38_g q38_h q38_i q38_j q38_k q39 (. = .a) if q18 == 0 | q18 == .d | q18 == .r | ///
													 q19 == 1 | q19 == .d | q19 == .r												 

recode q36 q38_k (. = .a) if q35 !=1
				
*------------------------------------------------------------------------------*
* Recode values and value labels:
* Recode values and value labels so that their values and direction make sense:

recode q4 (. = .r)
label define q4_label .r "Refused", modify

recode q30 (997 = 8)

label define insurlbl 0 "No, do not have private insurance", modify
label define q17lbl .a "NA or I did not receive healthcare from this provider in the past 12 months", modify
label define q24lbl 1 "Care for an urgent or new health problem such as an accident or injury or a new symptom like fever, pain, diarrhea, or depression." ///
					2 "Follow-up care for a longstanding illness or chronic disease such as hypertension or diabetes. This may include mental health conditions." ///
					3 "Preventive care or a visit to check on your health, such as an annual check-up, antenatal care, or vaccination." ///
					4 "Other (specify)" ///
					5 "Prescription filling/reviewing results" ///
					6 "Routine follow-up care",modify

label define q24lbl ///
            1 "Care for an urgent or new health problem such as an accident or injury or a new symptom like fever, pain, diarrhea, or depression." ///
            2 "Follow-up care for a longstanding illness or chronic disease such as hypertension or diabetes. This may include mental health conditions." ///
            3 "Preventive care or a visit to check on your health, such as an annual check-up, antenatal care, or vaccination." ///
            4 "Other (specify)" ///
			.a "NA", modify
lab values q24 q24lbl
*------------------------------------------------------------------------------*
* Fix labels

* all vars missing labels from values:
label define q14lbl .a "NA", add		
label define q15lbl .a "NA", add	
label define q16lbl .a "NA", add	
label define yesno .a "NA", add
label define q30lbl .a "NA", add
label define pubpriv .a "NA", add
label define q33lbl .a "NA", add
label define q34lbl .a "NA", add
label define q35lbl .a "NA", add
label define rating04_q38j .a "NA or the clinic had no other staff", modify


*for appending process:

label copy ital Language
label copy mod mode
label copy age_groups q2_label
label copy sexlbl gender2
label copy q4_label q4_label2
label copy arealbl q5_label2
label copy insurlbl yes_no_ins
label copy q15lbl q15_label2
label copy q33lbl q33_label2
label copy q50lbl q50_label2
label copy inclbl q51_label2

label val language Language
label val mode mode
label val q2 q2_label
label val q3 gender2
label val q4 q4_label2
label val q5 q5_label2
label val q6_it yes_no_ins
label val q15 q15_label2
label val q33 q33_label2
label val q50 q50_label2
label val q51 q51_label2

label drop ital italbl mod q4_label q15lbl q33lbl q50lbl inclbl

lab def country 14 "Italy"
lab values country country

*------------------------------------------------------------------------------*

* Other specify recode 
* This command recodes all "other specify" variables as listed in /specifyrecode_inputs spreadsheet
* This command requires an input file that lists all the variables to be recoded and their new values
* The command in data quality checks below extracts other, specify values 

foreach i in 14 {

ipacheckspecifyrecode using "$in_out/Input/specifyrecode_inputs/specifyrecode_inputs_`i'.xlsm",	///
	sheet(other_specify_recode)							///	
	id(respondent_id)	
 
}	


*------------------------------------------------------------------------------*/
*dropping derived vars that weren't actually categorized/ or that we can just use the derived variable code (no new code)
* drop urban insured education usual_type_own usual_type_lvl last_type_own last_type_lvl age qual_private qual_public age_cat gender region health health_mental health_chronic activation usual_source usual_type usual_reason usual_quality visits visits_cat last_type last_reason last_sched last_sched_time last_qual last_skills last_supplies last_respect last_know last_explain last_decisions last_visit_rate last_wait_rate last_courtesy last_sched_rate last_promote phc_women phc_child phc_chronic phc_mental conf_sick conf_afford conf_getafford conf_opinion system_outlook system_reform covid_manage vignette_poor vignette_good

* Reorder variables
	order q*, sequential
	order respondent_id respondent_serial wave country language date mode weight

*------------------------------------------------------------------------------*

* Save data
save "$data_mc/02 recoded data/input data files/pvs_it_wave2.dta", replace

*------------------------------------------------------------------------------*
