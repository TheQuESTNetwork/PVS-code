* People's Voice Survey derived variable creation
* Date of last update: October 2024
* N Kapoor, S Sabwa, M Yu

/*

	This file creates derived variables for analysis from the multi-country 
	dataset after append in the crPVS_append.do file.

*/

* UPDATE 4-30-2024: SS updated variable names to V2.0 variables


***************************** Deriving variables *******************************
u "$data_mc/02 recoded data/input data files/pvs_appended_v2.dta", clear

*dropping participants less than 18 years of age:
drop if q1 <18 // N=434 obs deleted from DE (122), CH (312)

*------------------------------------------------------------------------------*
***************************** Derive variable creation

* age: exact respondent age or middle of age range 
gen age = q1 
recode age (.r = 23.5) if q2 == 1
recode age (.r = 34.5) if q2 == 2
recode age (.r = 44.5) if q2 == 3
recode age (.r = 54.5) if q2 == 4
recode age (.r = 64.5) if q2 == 5
recode age (.r = 74.5) if q2 == 6
recode age (.r = 80) if q2 == 7
recode age (. = .r)
lab def ref .r "Refused"
lab val age ref

* age_cat: categorical age 
gen age_cat = q2
recode age_cat (.a = 1) if q1 >= 18 & q1 <= 29
recode age_cat (.a = 2) if q1 >= 30 & q1 <= 39
recode age_cat (.a = 3) if q1 >= 40 & q1 <= 49
recode age_cat (.a = 4) if q1 >= 50 & q1 <= 59
recode age_cat (.a = 5) if q1 >= 60 & q1 <= 69
recode age_cat (.a = 6) if q1 >= 70 & q1 <= 79
recode age_cat (.a = 7) if q1 >= 80

lab def age_cat 1 "18 to 29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70-79" 7 "80+"
lab val age_cat age_cat

* female: gender 	   
gen gender = q3
lab val gender gender

* covid_vax_v1
recode q14_v1 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax_v1)
	
recode q14_la_v1 ///
	(0 = 0 "Unvaccinated (0 doses)") (1 = 1 "Partial vaccination (1 dose)") /// 
	(2 3 4 = 2 "Fully vaccinated (2+ doses)") (.r = .r Refused) (.a = .a NA), ///
	gen(covid_vax_la)
replace covid_vax_v1 = covid_vax_la if country == 11
drop covid_vax_la
	
* covid_vax_intent_v1 
gen covid_vax_intent_v1 = q15_v1 
replace covid_vax_intent_v1 = q15_la_v1 if country == 11
lab val covid_vax_intent_v1 yes_no_doses
* Note: In Laos, q15 was only asked to those who said 0 doses 

* region
gen region = q4
lab val region q4_label2

* patient activiation
gen activation = 1 if q12_a == 3 & q12_b == 3
recode activation (. = 1) if q12_a == 3 & q12_b == .r | q12_a == .r & q12_b == 3 
recode activation (. = 0) if q12_a < 3 | q12_b < 3 
recode activation (. = .r) if q12_a == .r & q12_b == .r
recode activation (. = .r) if inlist(country, 8, 11, 23)
lab def pa 0 "Not activated" ///
			1 "Activated (Very confident on q12_a and q12_b)" ///
			.r "Refused", replace
lab val activation pa

* usual_reason 
recode q16 (2 16 = 1 "Proximity/convenience") /// 
           (1 8 = 2 "Cost/financial coverage") ///
           (4 14 = 3 "Technical quality") ///
           (5 22 = 4 "Interpersonal quality") ///
           (3 10 = 5 "Access/efficiency") ///
           (6 = 6 "Service readiness") ///
           (7 = 7 "Only facility available") ///
           (11 13 21 = 8 "Recommended by others") ///
           (15 17 23 = 9 "Chosen by family") ///
           (12 20 = 10 "Provider referral") ///
           (.r . 9 18 19 997 = .r "Other or Refused") ///
           (.a = .a "NA") , gen(usual_reason)

* visits
gen visits = q18_q19
recode visits (. = .r)

* visits_cat
gen visits_cat = 0 if q18 == 0 | q19 == 0
recode visits_cat (. = 1) if q18 >=1 & q18 <= 4 | q19 == 1
recode visits_cat (. = 2) if q18 > 4 & q18 < . | q19 == 2 | q19 == 3
* recode visits_cat (. = .r) if q18 == .r | q19 == .r
recode visits_cat (. = .r) 
lab def visits_cat 0 "Non-user (0 visits)" 1 "Occasional user (1-4 visits)" ///
			   2 "Frequent user (more than 4)" .r "Refused"
lab val visits_cat visits_cat

* visits_covid_v1
gen visits_covid_v1 = q25_b_v1
recode visits_covid_v1 (.a = 1) if q25_a_v1 == 1
recode visits_covid_v1 (.a = 0) if q25_a_v1 == 0

*fac_number
* Note: recoded 0's and 1's in q21 during cleaning 
gen fac_number = 1 if q20 == 1 
recode fac_number (. = 2) if q21 == 2 | q21 == 3
recode fac_number (. = 3) if q21 > 3 & q21 < . 
recode fac_number (. = .a) if q20 == .a & q21 == .a
recode fac_number (. = .d) if q21 == .d
recode fac_number (. = .r) if q20 == .r | q21 == .r
lab def fn 1 "1 facility (q20 is yes)" 2 "2-3 facilities (q21 is 2 or 3)" ///
		   3 "More than 3 facilities (q21 is 4 or more)" .a "NA" .r "Refused" ///
		   .d "Don't know"
lab val fac_number fn 

* visits_home
gen visits_home = q22
gen visits_tele = q23

* tele_qual
recode q25 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(tele_qual_vge) label(exc_pr_2)
	   
replace	tele_qual_vge = 0 if (q25 == 0 | q25 == 1) & country == 23
replace	tele_qual_vge = 1 if (q25 == 2 | q25 == 3 | q25 == 4) & country == 23

* visits_total
egen visits_total = rowtotal(q18_q19 q22 q23)

* value label for all numeric var
lab val visits visits_total visits_home visits_tele na_rf

* unmet_reason
* Note: "Illness not serious enough" (q30=7) is coded as .a (structural missing) 
* because if the patient did not perceive a need, the health system cannot be 
* said to have failed to meet it -- this is therefore not true unmet need.
recode q30 (1 15 19 21 = 1 "Cost/financial") ///
           (2 = 2 "Distance/convenience") ///
           (3 11 20 22 16 18 = 3 "Access/efficiency") ///
           (4 = 4 "Technical quality") ///
           (5 = 5 "Interpersonal quality") ///
           (6 24 = 6 "Service readiness") ///
           (8 9 = 7 "COVID") ///
           (12 13 14 25 27 = 8 "Fear/avoidance") ///
           (. .r 10 17 23 26 = .r "Other or Refused") ///
           (.d = .d "Don't know") ///
           (.a 7 = .a "NA") , gen(unmet_reason)
		   
recode q34 (1 = 1 "Urgent or new problem") (2 = 2 "Follow-up for chronic disease") ///
		   (3 = 3 "Preventative or health check") (4 5 6 7 8 9 10 11 12 13 = 4 "Other") (.a = .a "NA") ///
		   (.r = .r "Refused"), gen(last_reason)

recode last_reason (. = .r) if country==4

*last_wait_time
* SS: updated 4-15-25 with V2.0 var 
gen last_wait_time = 0 if q37_v1 <= 15
recode last_wait_time (. = 1) if q37_v1 >= 15 & q37_v1 < 60
recode last_wait_time (. = 2) if q37_v1 >= 60 & q37_v1 < .
recode last_wait_time (. = .a) if q37_v1 == .a
recode last_wait_time (. = .r) if q37_v1 == .r
lab def lwt 0 "Short (15 minutes)" 1 "Moderate (< 1 hour)" 2 "Long (>= 1 hour)" ///
			.r "Refused" .a "NA" .d "Don't know"
lab val last_wait_time lwt

recode last_wait_time (. = 0) if q37 == 1
recode last_wait_time (. = 1) if q37 == 2 | q37 == 3
recode last_wait_time (. = 2) if q37 == 4 | q37 == 5 | q37 == 6 | q37 == 7
recode last_wait_time (. = .a) if q37 == .a
recode last_wait_time (. = .r) if q37 == .r
recode last_wait_time (. = .d) if country==19

*last_sched_time
* SS: updated 4-15-25 with V2.0 var: same or next day, 2 days to 1 week, and greater than one week

recode q36 (1 = 0 "Short (Same or next day)") (2 = 1 "Moderate (2 days to less than 1 week)") ///
		   (3 4 5 6 7 8 = 2 "Long (1 week or greater)") (.a = .a "NA") (.r = .r "Refused") ///
		   (.d = .d "Don't know"), gen(last_sched_time)

recode last_sched_time (.a = 0) if q36_v1 <=1 
recode last_sched_time (.a = 1) if q36_v1 >1 & q36_v1 <7 
recode last_sched_time (.a = 2) if q36_v1 >=7 & q36_v1 < .
						
*last_visit_time_v1
gen last_visit_time_v1 = 0 if q47_v1 <= 15
recode last_visit_time_v1 (. = 1) if q47_v1 > 15 & q47_v1 < .
recode last_visit_time_v1 (. = .a) if q47_v1 == .a
recode last_visit_time_v1 (. = .r) if q47_v1 == .r
lab def lvt 0 "<= 15 minutes" 1 "> 15 minutes " ///
			.r "Refused" .a "NA"
lab val last_visit_time_v1 lvt


* last_promote
gen last_promote = 0 if q39 < 8
recode last_promote (. = 1) if q39 == 8 | q39 == 9 | q39 == 10
recode last_promote (. = .a) if q39 == .a
recode last_promote (. = .r) if q39 == .r
lab def lp 0 "Detractor" 1 "Promoter" .r "Refused" .a "NA"
lab val last_promote lp

* system_outlook 
gen system_outlook = q45
lab def system_outlook 0 "Getting worse" 1 "Staying the same" /// 
		2 "Getting better" .r "Refused", replace
lab val system_outlook system_outlook


* system_reform (SS: added back 10/8 for PVS dashabord)
gen system_reform = q46
lab def sr 1 "Health system needs to be rebuilt" 2 "Health system needs major changes" /// 
		3 "Health system only needs minor changes" .r "Refused", replace
lab val system_reform sr


* system_reform_minor 
recode q46 ///
	(1 2 = 0 "Major changes/Rebuilt") (3 = 1 "Minor changes") ///
	(.r = .r "Refused") , gen(system_reform_minor) label(system_reform2)

**** Yes/No Questions ****

* health_chronic, ever_covid, covid_confirmed, usual_source, inpatient
* unmet_need 
* Yes/No/Refused - Q11 Q12 Q13 q13 q26 q29 

gen health_chronic = q11
recode health_chronic (. = .r) if country ==23

gen ever_covid_v1 = q12_v1 
gen covid_confirmed_v1 = q13_v1 
gen usual_source = q13
recode usual_source (.a = 1) if (q13a_la == 1 & inlist(q14_q15a_la,1,2,3,4,6)) | q13b_la == 1
recode usual_source (.a = 0) if q13a_la == 0 | q13a_la == 1 & q13b_la == 0
recode usual_source (.a = .r) if q13b_la == .r
recode usual_source (. = .r) if country==23

gen inpatient = q26 
recode inpatient (. = .r) if inlist(country, 11, 23)
gen unmet_need = q29 
recode unmet_need (. = .r) if country==23
lab val health_chronic usual_source inpatient unmet_need yes_no	
* blood_pressure mammogram cervical_cancer eyes_exam teeth_exam blood_sugar  
* blood_chol care_mental 
* Yes/No/Don't Know/Refused - q27_a q27_b q27_c q27_d q27_e q27_f q27_g q27_h q27_a q28_b q52 

gen blood_pressure = q27_a 
gen mammogram = q27_b
gen cervical_cancer = q27_c
gen eyes_exam = q27_d
gen teeth_exam = q27_e
gen blood_sugar = q27_f 
gen blood_chol = q27_g
gen care_mental = q27_h 

recode blood_pressure (. = .r) if country==23

recode mammogram (. = .a) if inlist(country, 2, 7, 10)
recode mammogram (. = .a) if country==21&gender==0
recode mammogram (. = .r) if country==21&gender==1
recode mammogram (. = .r) if country==23&gender==1

recode cervical_cancer (. = .a) if inlist(country, 2, 7, 10)& gender==0
recode cervical_cancer (. = .r) if country==23&gender==1

recode eyes_exam (. = .r) if country==23
recode teeth_exam (. = .r) if country==23
recode blood_sugar (. = .r) if country==23
recode blood_chol (. = .r) if country==23

gen hiv_test = q27i_za
recode hiv_test (. = .a) if country !=9 | country==9&wave==2

gen care_srh = q27i_ng
recode care_srh (. = .a) if country !=20 

gen breast_exam = q27i_cn
recode breast_exam (. = .a) // here I checked that this question have skip logic, so all of the . goes to .a
lab val breast_exam q27_label

gen color_ultrasound = q27j_cn 
recode color_ultrasound (. = .a) if country !=21
lab val color_ultrasound q27_label

gen sti_test = q27i_us //wave 2 US only
recode sti_test (. = .a) if country !=12 | country==12&wave==1
lab val sti_test q27_label

gen endoscope = q27i_jp 
recode endoscope (. = .a) if country !=8

gen barium_test = q27j_jp 
recode barium_test (. = .a) if country !=8

gen fecal_blood = q27k_jp 
recode fecal_blood (. = .a) if country !=8

gen electrocardiogram = q27l_jp 
recode electrocardiogram (. = .a) if country !=8

*SS: confirm with Todd what this should be
*gen = q27i_gr_in_ro

gen mistake = q28_a
recode mistake (. = .r) if inlist(country, 8, 23)

gen discrim = q28_b
recode discrim (. = .r) if inlist(country, 8, 23)
lab val blood_pressure mammogram cervical_cancer eyes_exam teeth_exam /// 
	blood_sugar blood_chol hiv_test care_srh care_mental mistake discrim endoscope barium_test fecal_blood electrocardiogram yes_no_dk
lab val mistake discrim yes_no_na
	
**** Excellent to Poor scales *****	   
*SS: Edit for Nepal Likert scale

recode q9 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(health_vge) label(health2)
	   
replace	health_vge = 0 if q9 == 0 | q9 == 1 | q9 == 2 & country == 23
replace	health_vge = 1 if q9 == 3 | q9 == 4 & country == 23	   

recode q10 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (. = .r "Refused"), /// 
	   gen(health_mental_vge) label(health_mental2)
	   
replace	health_mental_vge = 0 if q10 == 0 | q10 == 1 | q10 == 2 & country == 23
replace	health_mental_vge = 1 if q10 == 3 | q10 == 4 & country == 23	
	   
recode q17 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (5 .a = .a "NA"), /// 
	   gen(usual_quality_vge) label(exc_pr_2)	   

replace	usual_quality_vge = 0 if q17 == 0 | q17 == 1 | q17 == 2 & country == 23
replace	usual_quality_vge = 1 if q17 == 3 | q17 == 4 & country == 23	
recode usual_quality_vge (. = .r) if inlist(country, 8, 23)
	   
recode q38_a (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(last_qual_vge) label(exc_pr_2)

replace	last_qual_vge = 0 if q38_a == 0 | q38_a == 1 | q38_a == 2 & country == 23
replace	last_qual_vge = 1 if q38_a == 3 | q38_a == 4 & country == 23		   

recode q38_b (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(last_skills_vge) label(exc_pr_2)

replace	last_skills_vge = 0 if q38_b == 0 | q38_b == 1 | q38_b == 2 & country == 23
replace	last_skills_vge = 1 if q38_b == 3 | q38_b == 4 & country == 23	   
	   
recode q38_c (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(last_supplies_vge) label(exc_pr_2)
 
replace	last_supplies_vge = 0 if q38_c == 0 | q38_c == 1 | q38_c == 2 & country == 23
replace	last_supplies_vge = 1 if q38_c == 3 | q38_c == 4 & country == 23	   
 
recode q38_d (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_respect_vge) label(exc_pr_2)

replace	last_respect_vge = 0 if q38_d == 0 | q38_d == 1 | q38_d == 2 & country == 23
replace	last_respect_vge = 1 if q38_d == 3 | q38_d == 4 & country == 23	   	   
	   
recode q38_e (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(last_know_vge) label(exc_pr_2)	   

replace	last_know_vge = 0 if q38_e == 0 | q38_e == 1 | q38_e == 2 & country == 23
replace	last_know_vge = 1 if q38_e == 3 | q38_e == 4 & country == 23	
replace	last_know_vge = .a if q38_e == 5 & country == 8	| q38_e == 5 & country == 25 | q38_e == 5 & country == 1	   	   	   
	   
recode q38_f (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_explain_vge) label(exc_pr_2)

replace	last_explain_vge = 0 if q38_f == 0 | q38_f == 1 | q38_f == 2 & country == 23
replace	last_explain_vge = 1 if q38_f == 3 | q38_f == 4 & country == 23		   
	   
recode q38_g (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_decisions_vge) label(exc_pr_2)	 

replace	last_decisions_vge = 0 if q38_g == 0 | q38_g == 1 | q38_g == 2 & country == 23
replace	last_decisions_vge = 1 if q38_g == 3 | q38_g == 4 & country == 23		   
	   
recode q38_h (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_visit_rate_vge) label(exc_pr_2)	  

replace	last_visit_rate_vge = 0 if q38_h == 0 | q38_h == 1 | q38_h == 2 & country == 23
replace	last_visit_rate_vge = 1 if q38_h == 3 | q38_h == 4 & country == 23		   
	   
recode q38_i (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_wait_rate_vge) label(exc_pr_2)	  

replace	last_wait_rate_vge = 0 if q38_i == 0 | q38_i == 1 | q38_i == 2 & country == 23
replace	last_wait_rate_vge = 1 if q38_i == 3 | q38_i == 4 & country == 23		   
	   
recode q38_j (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge"), /// 
	   gen(last_courtesy_vge) label(exc_pr_2)
	   
replace	last_courtesy_vge = 0 if q38_j == 0 | q38_j == 1 | q38_j == 2 & country == 23
replace	last_courtesy_vge = 1 if q38_j == 3 | q38_j == 4 & country == 23

replace	last_courtesy_vge = .a if q38_h == 6 & country == 23 | q38_h == 5 & country == 25 | q38_h == 6 & country == 8
	   
recode q38_k (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.r = .r "Refused"), /// 
	   gen(last_sched_rate_vge) label(exc_pr_2)	 
	   
replace	last_sched_rate_vge = 0 if q38_k == 0 | q38_k == 1 | q38_k == 2 & country == 23
replace	last_sched_rate_vge = 1 if q38_k == 3 | q38_k == 4 & country == 23		   

recode q40_a (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(phc_women_vge) label(exc_pr_judge_2)
	   
replace	phc_women_vge = 0 if q40_a == 0 | q40_a == 1 | q40_a == 2  & country == 23
replace	phc_women_vge = 1 if q40_a == 3 | q40_a == 4 & country == 23	

recode q40_b (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(phc_child_vge) label(exc_pr_judge_2)	   
	   
recode phc_child_vge (. = .a) if country ==22

replace	phc_child_vge = 0 if q40_b == 0 | q40_b == 1 | q40_b == 2 & country == 23
replace	phc_child_vge = 1 if q40_b == 3 | q40_b == 4 & country == 23		

recode q40_c (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(phc_chronic_vge) label(exc_pr_judge_2)	

replace	phc_chronic_vge = 0 if q40_c == 0 | q40_c == 1 | q40_c == 2 & country == 23
replace	phc_chronic_vge = 1 if q40_c == 3 | q40_c == 4 & country == 23		   
	   
recode q40_d (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(phc_mental_vge) label(exc_pr_judge_2)	
	   
replace	phc_mental_vge = 0 if q40_d == 0 | q40_d == 1 | q40_d == 2 & country == 23
replace	phc_mental_vge = 1 if q40_d == 3 | q40_d == 4 & country == 23		   

*Recoding "I am unable to judge = .d"
recode phc_women_vge phc_child_vge phc_chronic_vge phc_mental_vge (5 = .d) if country == 21 | country == 22 | country == 8

*"6 = "I am unable to judge" response option in Nepal-only being recoded to missing
recode phc_women_vge phc_child_vge phc_chronic_vge phc_mental_vge (6 = .d) if country ==23

recode q40_e_ng (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(qual_srh_vge) label(exc_pr_judge_2)	 
	   
recode qual_srh_vge (. = .a) if country !=20
 
recode q40b_so (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(care_infections_vge) label(exc_pr_judge_2)	
	   
recode care_infections_vge (. = .a) if country !=22
recode care_infections_vge (5 = .d) if country ==22

recode q40f_so (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA") (.d = .d "I am unable to judge") (.r = .r "Refused"), /// 
	   gen(care_nonurgent_vge) label(exc_pr_judge_2)	
	   
recode care_nonurgent_vge (. = .a) if country !=22
recode care_nonurgent_vge (5 = .a) if country ==22
	
recode q42 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(qual_public_vge) label(exc_pr_2)
	   
replace	qual_public_vge = 0 if (q42 == 0 | q42 == 1) & country == 23
replace	qual_public_vge = 1 if (q42 == 2 | q42 == 3 | q42 == 4) & country == 23		   

recode q43 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(qual_private_vge) label(exc_pr_2)

replace	qual_private_vge = 0 if (q43 == 0 | q43 == 1) & country == 23
replace	qual_private_vge = 1 if (q43 == 2 | q43 == 3 | q43 == 4) & country == 23	
recode qual_private_vge (. = .a) if country==25 //LX: later check with SS and Todd
	   
recode q47 (0 1 2 = 0 "Poor/Fair/Good") (3 4 = 1 "Very good/Excellent") (.r = .r "Refused") /// 
	   (.a = .a "NA"), /// 
	   gen(covid_manage_vge) label(exc_pr_2)

replace	covid_manage_vge = 0 if q47 == 0 | q47 == 1 | q47 == 2 & country == 23
replace	covid_manage_vge = 1 if q47 == 3 | q47 == 4 & country == 23
recode covid_manage_vge (. = .a) if country==25 //LX: later check with SS and Todd
	   
gen vignette_poor = q48
recode vignette_poor (. = .a) if country==25 //LX: later check with SS and Todd
gen vignette_good = q49	
recode vignette_good (. = .a) if country==25 //LX: later check with SS and Todd

**** All Very Confident to Not at all Confident scales ****

* conf_sick_scvc conf_afford_scvc conf_opinion (double check for Nepal)

recode q41_a q41_b ///
	   (3 2 = 1 "Somewhat confident/Very confident") ///
	   (0 1 = 0 "Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a na), /// 
	   pre(der) label(vc_nc_der)   	   

recode q41_c ///
	   (3 2 = 1 "Somewhat confident/Very confident") ///
	   (0 1 = 0 "Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a na), /// 
	   gen(conf_opinion_scvc) label(vc_nc_der)	


ren (derq41_a derq41_b) (conf_sick_scvc conf_afford_scvc)

gen conf_getafford_scvc = .
replace conf_getafford_scvc=1 if conf_sick_scvc==1 & conf_afford_scvc==1
replace conf_getafford_scvc=0 if conf_sick_scvc==0 | conf_afford_scvc==0
replace conf_getafford_scvc=.r if conf_sick_scvc==.r | conf_afford_scvc==.r
lab val conf_getafford_scvc vc_nc_der

*urban/rural
recode q5 (1001 1002 9001 9002 9003 5006 5007 7006 7007 8001 8002 2009 2010 3009 3010 10012 10013 11001 11003 ///
		   12001 12002 12003 13001 13002 13003 14001 14002 14003 15001 16001 16002 ///
           4015 4016 17001 17002 17003 18018 19021 20022 20023 21001 21002 22001 2001 2002 ///
		   7001 7002 10001 10002 23001 23002 23003 6002 24001 24002 25001 25002 = 1 "Urban") ///
          (1003 8003 8004 9004 5008 7008 2011 3011 10014 11002 12004 12005 12006 12007 13004 ///
		  14004 15002 16003 4017 17004 ///
		  18019 19020 20024 21003 21004 22002 22003 2003 7003 10003 23004 6001 24003 ///
		  24004 25003 25004 = 0 "Rural") ///
		  (.r = .r "Refused"), gen(urban)

* insurance status
* Note: All are insured in Laos, Italy, Mendoza and UK
gen insured = q6 
recode insured (.a = 1) if country == 11 | country == 14 | country == 17 | q6_za == 1 | country == 8
recode insured (.a = 0) if inlist(q7,2030,7014,13003,13014) | q6_za == 0 
recode insured (.a = 1) if inlist(q7,2015, 2016, 2017, 2018, 2028, 7010, 7011, 7012, 7013, 10019, 10020, 10021, 10022, 13001, 13002, 13004, 13005, 16001, ///
								     16002, 16003, 16004, 16005) | inlist(q6_kr, 1, 2, 3)
recode insured (.a = .r) if q7 == .r | inlist(q7,13995) | q6_kr == .r | q6_za == .r
lab val insured yes_no

	* LAC:
	recode insured (.a = 0) if (country == 2 | country == 7 | country == 10) & wave == 2 & q6_lac == 1 | q6_lac == 2
	recode insured (.a = .a) if (country == 2 | country == 7 | country == 10) & wave == 2 & q6_lac == .a
	recode insured (.a = .r) if (country == 2 | country == 7 | country == 10) & wave == 2 & q6_lac == .r
	recode insured (.a = 1) if (country == 2 | country == 7 | country == 10) & wave == 2 & q6_lac != 1 | q6_lac != 2 | q6_lac !=.a | q6_lac !=.r


* For Colombia, moved "no insurance" to "yes" in insured and "public" in "insur_type"
* insur_type 

recode q7 ///
    (2001 2003 2012 2013 2017 2018 3001 4023 4024 4025 4026 5003 7004 7010 ///
     10005 10019 12002 12003 12005 12006 16001 18029 19031 20034 20037 21001 21002 ///
     21003 21005 22002 23002 23003 23004 24001 = 0 "Public") ///
    (1004 1005 2028 2010 2011 3002 3007 4027 5004 5005 5006 6001 6003 7013 7015 9008 9009 9995 9997 ///
     10021 10016 10017 12001 12004 13005 16005 18004 18030 19032 19033 19034 20035 20036 21004 22001 ///
     22003 22004 23001 24002 24003 = 1 "Private") ///
    (1001 1002 1003 2015 2016 2006 2007 7011 7012 7008 7019 ///
     10009 10020 10022 13001 13002 13004 16002 16003 16004 = 2 "Social security/military") ///
    (1006 2995 2020 12995 12007 13995 4995 18995 19995 20995 21006 7021 10009 10020 5997 ///
     23005 6002 24005 = 3 "Other") ///
    (.r = .r "Refused") ///
    (2030 7014 13014 16007 13003 7002 10001 1000 14001 14002 24004 = .a "NA"), ///
    gen(insur_type) //SS: confirm placement of 1000

/* 03-03-2026 LW: Muted for now but kept for recored just in case
recode insur_type (.a = 0) if q6_za == 1 & !inlist(q7, 9008, 9009, 9995, 9997)
recode insur_type (0 = .a) if q6_za == 0 | q6_za == .r
recode insur_type (.r = 0) if q6_za == 1

replace insur_type = .a if country == 9
recode insur_type (.a = 1) if q6_za == 1
*/

replace insur_type = .a if inlist(country, 8, 11, 14, 15, 17, 25) //LW: here just to make sure the countries that have universal coverage systems are ".a"

recode insur_type (. = .a) if q7 == . & inlist(country, 2, 7, 10, 23) //LW: here just to make sure all "." goes to the right categories

* insur_type_universal
recode q7 (8002 11002 17002 = 0 "Public or mandatory private") ///
		  (8001 11001 17001 = 1 "Supplemental private") /// 
		  (.r = .r "Refused") (.a  = .a "NA"), gen(insur_type_universal)

recode insur_type_universal (.a = 1) if q7_kr == 1
recode insur_type_universal (.a = 0) if q7_kr == 0

recode insur_type_universal (.a = 1) if q6_it == 1
recode insur_type_universal (.a = 0) if q6_it == 0
recode insur_type_universal (.a = .r) if q6_it == .r

recode insur_type_universal (. = .a) if q7 ==. & inlist(country, 11, 25) // just to clean up the "."
recode insur_type_universal (.a = .r) if q7 == . & country == 11

*Swiss updates to insur_type_universal (SS: ask for code review, this question was a multi-checkbox field so one participant could've checked multiple answers)
recode insur_type_universal (.a = 0) if q7i_ch == 1

recode insur_type_universal (.a = 1) if q7a_ch ==1 | /// Suppl dental ins.
										 q7b_ch ==1 | /// Suppl hosp. ins.
										 q7c_ch ==1 | /// Suppl pharmacy ins.
										 q7d_ch ==1 | /// Suppl alternative med. ins.
										 q7e_ch ==1 | /// Suppl glasses ins.
										 q7f_ch ==1 | /// Suppl ins. for sport and wellness
										 q7g_ch ==1 // Suppl health ins. for travel
										 
recode insur_type_universal (.a = .r) if q7a_ch !=1 & q7b_ch !=1 & ///
										 q7c_ch !=1 & q7d_ch !=1 & q7e_ch!=1 & ///
										 q7f_ch !=1 & q7g_ch !=1 & q7h_ch !=1 & q7i_ch !=1 & ///
										 q7j_ch == 1 // confirm this, especially the addition of "other here", essentially just trying to select the people who said yes only to "don't know/prefer not to answer"

* recoding the remaining 9 NAs for CH
recode insur_type_universal (.a = .r) if q7h_ch == 1 & q7j_ch == 1

recode insur_type_universal (.a = 0) if q7a_ch !=1 & q7b_ch !=1 & ///
										q7c_ch !=1 & q7d_ch !=1 & q7e_ch!=1 & ///
										q7f_ch !=1 & q7g_ch !=1 & q7i_ch !=1 & ///
										q7j_ch != 1 & q7h_ch == 1
										 
*removing these from finalized dataset (confirm if they should be kept in)
*drop q7a_ch q7b_ch q7c_ch q7d_ch q7e_ch q7f_ch q7g_ch q7h_ch q7i_ch q7j_ch
			
replace insur_type_universal = .a if !inlist(country, 8, 11, 14, 15, 17, 25) //LW: here just to make sure the countries that don't have universal coverage systems are ".a"

* education
recode q8 (1001 1002 3001 3002 5007 9012 9013 2025 2026 7018 7019 10032 10033 11001 13001 ///
		   14001 12001 15001 16001 16002 4039 17001 18045 19052 20058 21001 21002 ///
		   22001 22002 2001 2002 7001 7002 10001 23001 23010 23011 6001 ///
		   24013 25001 = 0 "None (or no formal education)") ///
          (1003 3003 5008 8001 9014 9015 2027 7020 10034 11002 13002 14002 12002 12003 ///
		   15002 16003 4040 17002 18046 19053 20059 21003 21004 22003 22004 ///
		   2003 7003 10002 10003 23002 23003 6002 24012 25002 = 1 "Primary") ///
		   (1004 3004 5009 9016 2028 7021 8002 10035 11003 11004 14004 14005 13003 13004 12004 ///
		   15003 15004 16004 4041 14003 17003 18047 19054 19055 20060 21005 21006 ///
		   22005 2004 7004 10004 23004 23005 23009 6003 24002 24003 24004 24005 24006 24007 24008 24009 24010 24011 25003 25004 25005 25008 25009 = 2 "Secondary") ///
          (1005 1006 1007 3005 5010 5011 9017 2029 2030 2031 7022 7023 7024 8003 8004 8005 10036 10037 10038 11005 ///
		   11006 14006 14007 13005 13006 13007 12005 12006 15005 15006 15007 16005 ///
		   16006 16007 4042 4043 4044 17004 17005 18048 18049 18050 19056 19057 19058 20061 ///
		   20062 21007 21008 21009 21010 22006 2005 2006 2007 7005 7006 7007 10005 ///
		   10006 10007 23006 23007 23008 6004 24001 25006 25007 25010 25011 25012 = 3 "Post-secondary") ///
		   (24014 = 4 "Other") ///
          (.r = .r "Refused") (. = .r "Refused") (.a  = .a "NA"), gen(education)

* usual_type_own	  
recode q14_multi (1 = 0 "Public") (2 3 = 1 "Private") (4 = 2 "Other") /// 
		(.a = .a "NA") (.d = .d "Don't Know") (.r = .r "Refused"), ///
		gen(usual_type_own)

* Colombia recode
* Recode based on insurance type (but refusal for insurance defaults to q14_co_pe)
recode usual_type_own (.a = 0) if country == 2 & wave == 1 & inlist(q7,2017,2018,2030) & usual_source==1
recode usual_type_own (.a = 1) if country == 2 & wave == 1 & q7 == 2028 & usual_source==1
recode usual_type_own (.a = 2) if country == 2 & wave == 1 & inlist(q7,2015,2016) & usual_source==1
recode usual_type_own (.a = .r) if country == 2 & wave == 1 & q7==.r & usual_source==1

	* Wave 2:
	recode usual_type_own (.a = 0) if country == 2 & wave ==2 & q14_co == 1
	recode usual_type_own (.a = 1) if country == 2 & wave ==2 & q14_co == 2
	recode usual_type_own (.a = 2) if country == 2 & wave ==2 & q14_co == 3
	recode usual_type_own (.a = .r) if country == 2 & wave ==2 & q14_co == 4

*Peru recode, wave 1
replace usual_type_own = . if country == 7 & wave == 1

* For skipped type (no usual source)
replace usual_type_own = .a if country == 7 & wave == 1 & usual_source == 0

* For refused usual source
replace usual_type_own = .r if country == 7 & wave == 1 & usual_source == .r

* For usual source == yes, assign usual_type_own based on q14_co_pe_v1 and q7
replace usual_type_own = 0 if country == 7 & wave == 1 & usual_source == 1 & q14_co_pe_v1 == 1 & inlist(q7, 7010, 7014, 7013) //public
replace usual_type_own = 0 if country == 7 & wave == 1 & usual_source == 1 & q14_co_pe_v1 == 1 & q7 == .r //public //refusals in insurance
replace usual_type_own = 1 if country == 7 & wave == 1 & usual_source == 1 & q14_co_pe_v1 == 2 //private
replace usual_type_own = 2 if country == 7 & wave == 1 & usual_source == 1 & q14_co_pe_v1 == 1 & inlist(q7, 7011, 7012) //social security
replace usual_type_own = .r if country == 7 & wave == 1 & usual_source == 1 & q14_co_pe_v1 == .r //refusals in usual source type

	*Peru recode, wave 2
	recode usual_type_own (.a = 0) if country == 7 & wave ==2 & q14_pe == 1 
	recode usual_type_own (.a = 1) if country == 7 & wave ==2 & q14_pe == 3
	recode usual_type_own (.a = 2) if country == 7 & wave ==2 & q14_pe == 2 | q14_pe == 4 | q14_pe == 5 
		
*Uruguay recode 
*Updated 8-22 SS
recode usual_type_own (.a = 0) if country == 10 & wave ==1 & q14_uy == 1
recode usual_type_own (.a = 1) if country == 10 & wave ==1 & q14_uy == 2
recode usual_type_own (.a = 2) if country == 10 & wave ==1 & q14_uy == 5

	* Wave 2: 
	recode usual_type_own (.a = 0) if country == 10 & wave ==2 & q14_uy == 1
	recode usual_type_own (.a = 1) if country == 10 & wave ==2 & q14_uy == 3
	recode usual_type_own (.a = 2) if country == 10 & wave ==2 & q14_uy == 5 | q14_uy == 2


*China/Somaliland recode
recode usual_type_own (.a = 0) if q14_cn == 1 | q14_so == 1
recode usual_type_own (.a = 1) if q14_cn == 2 | q14_so == 2

*Multi-country - generally adding here:
recode usual_type_own (.a = 0) if (q14_q15a_la == 1 | q14_q15a_la == 2 |  ///
								  q14_q15b_la == 1 | q14_q15b_la == 2 | ///
								  q14_it == 1 | inlist(q14_mx,3,4) | ///
								  q14_kr == 1 | ///
								  q14_ar == 1 | q14a_gb == 1 | q14b_gb == 1 | ///
								  q14_gr == 1) | inlist(q14_np,1,6) | q14_de == 1
								  
								  							  
recode usual_type_own (.a = 1) if inlist(q14_q15a_la,3,4,6) | ///
								  inlist(q14_q15b_la,3,4,6) | ///
								  q14_it == 2 | q14_it == 3 | q14_mx == 6 | ///
								  q14_kr == 3 | q14_ar == 3 ///
								  | q14a_gb == 2 | q14b_gb == 2 | q14_gr == 2 | ///
								  inlist(q14_np,2,3,4) | inlist(q14_de,2,3)
								  
						  
recode usual_type_own (.a = 2) if q14_q15a_la == 9 | q14_q15b_la == 7 | ///
								  q14_it == 4 | inlist(q14_mx,1,2,5,7) | ///
                  q14_kr == 4 | inlist(q14_ar,2,4,6,7) ///
								  | q14a_gb == 3 | q14_gr == 3 | q14_np == 5 | inlist(q14_de,4,5)
								  
recode usual_type_own (.a = .r) if q14_q15a_la == .r | q14_q15b_la == .r | ///
								   q14_it == .r | q14_mx == .r | ///
								    q14_kr == .r | ///
								   q14_ar == .r | q14a_gb == .r | q14b_gb == .r | ///
								   q14_cn == .r

*China recode
recode usual_type_own (.a = 0) if q14_cn == 1 | q14_so == 1
recode usual_type_own (.a = 1) if q14_cn == 2 | q14_so == 2
recode usual_type_own (.a = 2) if q14_cn == 3
*recode usual_type_own (.a = .a) if q14_cn == .a
recode usual_type_own (.a = .d) if q14_cn == .d | q14_so == .d

*Ecuador recode
recode usual_type_own (.a = 0) if q14_ec == 1
recode usual_type_own (.a = 1) if q14_ec == 2 | q14_ec == 6
recode usual_type_own (.a = 2) if q14_ec == 3 | q14_ec == 4 | q14_ec == 5 | q14_ec == 7
recode usual_type_own (.a = .a) if q14_ec == .a

*United States recode
*Wave 1:
recode usual_type_own (.a = 0) if country == 12 & wave ==1 & inlist(q15,12003,12004)
recode usual_type_own (.a = 1) if country == 12 & wave ==1 & inlist(q15,12001,12002,12005,12006)
recode usual_type_own (.a = 2) if country == 12 & wave ==1 & q15 == 12995
recode usual_type_own (.a = .r) if country == 12 & wave ==1 & q15 == .r 
*Wave 2:
recode usual_type_own (.a = 0) if country == 12 & wave ==2  & insur_type ==0
recode usual_type_own (.a = 1) if country == 12 & wave ==2 & insur_type ==1
recode usual_type_own (.a = 2) if country == 12 & wave ==2 & insur_type ==3
recode usual_type_own (.a = .r) if country == 12 & wave ==2 & insur_type ==.r | insur_type ==.d

*Japan
recode usual_type_own (.a = 0) if q14_jp == 1 
recode usual_type_own (.a = 1) if q14_jp == 2 
recode usual_type_own (.a = 2) if q14_jp == 3
	
* usual type level			  
recode q15 (1001 1002 1003 1005 1007 3001 3002 3003 3006 3007 3008 /// 
			3011 5012 5014 5015 5016 5017 5018 5020 9023 9024 9025 9026 9027 9028 9031 9032 9033 9036 ///
			2080 2085 2090 7001 7002 7008 7040 7043 7045 7047 7048 8001 10092 10094 10096 10098 10100 10102 10104 ///
			14001 14002 13001 13002 13005 13008 13009 13012 13013 13015 13017 13018 12001 12002 12003 12004 ///
			15001 15002 16001 16003 16005 16006 16009 4067 4068 4069 4072 4073 4074 17001 17002 17003 17004 17005 ///
			17006 19001 19002 19005 19006 19007 19120 19122 19126 19124 19125 19129 19128 20131 20132 20135 20136 20137 20139 21004 21005 21006 21007 ///
			2101 2108 7102 7103 7105 7108 10104 10108 23006 23007 23009 23010 23011 23012 23013 23014 6004 6005 6007 6010 24001 24002 24003 24004 25001 25004 = 0 "Primary") /// 
		   (1004 1006 1008 3004 3005 3009 3021 5013 5019 5021 9029 9030 9034 9035 9037 ///
		   2081 2082 2086 2087 7041 7042 7044 7046 7049 8002 8003 8004 10093 10097 10101 10105 14003 14004 ///
		   13003 13004 13006 13007 13010 13011 13014 13016 13019 13020 12005 12006 ///
		   15003 15004 16002 16004 16007 16008 4070 4071 4075 4076 17007 17008 17009 19003 19004 19121 19127 19123 19130 ///
		   20133 20134 20138 20140 21001 21002 21003 2109 2111 2115 7106 7109 7110 7114 7115 10107 10112 10113 ///
		   10115 23001 23002 23003 23004 23005 23016 23017 6001 6002 6003 6008 24005 24006 25002 25003 = 1 "Secondary (or higher)") ///
		   (.a 18106 18107 18108 18109 18110 18111 18112 18113 18115 18116 18117 18996 25006 = .a "NA") ///
		   (3995 9995 12995 4995 14005 18995 20995 21008 .r 3997 4997 5997 9997 23015 12007 24007 19008 = .r "Refused"), gen(usual_type_lvl)

		   recode usual_type_lvl (.a = 0) if inlist(q14_q15a_la,2,4,6) | ///
								  inlist(q14_q15b_la,2,4,6)
recode usual_type_lvl (.a = 1) if q14_q15a_la == 1 | q14_q15a_la == 3 | q14_q15b_la == 1 | q14_q15b_la == 3

recode usual_type_lvl (.a . .r = 0) if (q15a_gr == 1 | q15a_gr == 2) & country == 18

recode usual_type_lvl (.a . = 1) if (q15a_gr == 3 | q15a_gr == 4 | q15a_gr == 6) & country == 18

recode usual_type_lvl (. = 0) if q15a_so == 2 | q15a_so == 3 | q15b_so == 2 | q15b_so == 3 | q15b_so == 4 | q15c_so  == 1 ///
								  | q15c_so  == 2 | q15c_so  == 3 | q15c_so  == 4 | q15c_so  == 6

recode usual_type_lvl (. = 1) if q15a_so == 1 | q15b_so == 1 | q15c_so  == 5 | q15c_so == 7
recode usual_type_lvl (. = .a) if insured == 0 & country == 22
recode usual_type_lvl (. = .a) if inlist(country, 2, 6, 7, 10, 17, 22, 23)
		   
* usual_type - ownership and level 
gen usual_type = . 
recode usual_type (. = 0) if usual_type_own == 0 & usual_type_lvl == 0
recode usual_type (. = 1) if usual_type_own == 0 & usual_type_lvl == 1
recode usual_type (. = 2) if usual_type_own == 1 & usual_type_lvl == 0
recode usual_type (. = 3) if usual_type_own == 1 & usual_type_lvl == 1
recode usual_type (. = 4) if usual_type_own == 2 & usual_type_lvl == 0
recode usual_type (. = 5) if usual_type_own == 2 & usual_type_lvl == 1
recode usual_type (. = .a) if usual_type_own == .a | usual_type_lvl == .a
recode usual_type (. = .r) if usual_type_own == .r | usual_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val usual_type fac_own_lvl


* last_type_own
recode q32_multi (1 = 0 "Public") (2 3 = 1 "Private") (4 = 2 "Other") /// 
		(.a = .a "NA") (.r = .r "Refused") (.d = .d "Don't know"), ///
		gen(last_type_own)

* Colombia recode
* Recode based on insurance type (but refusal for insurance defaults to q32_co_pe)
recode last_type_own (.a = 0) if country == 2 & inlist(q7,2017,2018,2030) 
recode last_type_own (.a = 1) if country == 2 & q7 == 2028 
recode last_type_own (.a = 2) if country == 2 & inlist(q7,2015,2016)

	* Wave 2: (shouldn't use q7 for ownership)
	recode last_type_own (.a = 0) if p32_col == 1
	recode last_type_own (.a = 1) if p32_col == 2
	recode last_type_own (.a = 2) if p32_col == 3

*Peru recode 
*Recode based on q32_co_pe, but those who say public and have SHI are recoded to other 
recode last_type_own (.a = 0) if country == 7 & q32_co_pe_v1 == 1 & inlist(q7,7010,7014)
recode last_type_own (.a = 1) if country == 7 & q32_co_pe_v1 == 2 & q7==7013 
recode last_type_own (.a = 2) if country == 7 & q32_co_pe_v1 == 1 & inlist(q7,7011,7012) 

	* Wave 2: 
	recode last_type_own (.a = 0) if p32_per == 1 
	recode last_type_own (.a = 1) if p32_per == 3
	recode last_type_own (.a = 2) if p32_per == 2 | p32_per == 4 | p32_per == 5 

*Uruguay recode 
*Updated 8-22 SS
recode last_type_own (.a = 0) if country == 10 & q32_uy == 1
recode last_type_own (.a = 1) if country == 10 & q32_uy == 2
recode last_type_own (.a = 2) if country == 10 & q32_uy == 5

	* Wave 2: 
	recode last_type_own (.a = 0) if p32_uru == 1
	recode last_type_own (.a = 1) if p32_uru == 3
	recode last_type_own (.a = 2) if p32_uru == 5

*Laos
recode last_type_own (.a = 0) if q32_la == 1 | q33 == 11002
recode last_type_own (.a = 1) if q32_la == 2 | q33 == 11003

*China
recode last_type_own (.a = 0) if q32_cn == 1 & country ==21
recode last_type_own (.a = 1) if q32_cn == 2 & country ==21

*Somaliland
recode last_type_own (.a = 0) if q32_so == 1 & country ==22
recode last_type_own (.a = 1) if q32_so == 2 & country ==22
recode last_type_own (.a = 2) if q32_so == 4 & country ==22
recode last_type_own (.a = .r) if q32_so == .r & country ==22

*Ecuador
recode last_type_own (.a = 0) if q32_ec == 1 | q32_ec == 4 | q32_ec == 5
recode last_type_own (.a = 1) if q32_ec == 2 | q32_ec == 6
recode last_type_own (.a = 2) if q32_ec == 3 | q32_ec == 7
recode last_type_own (.a = .r) if q32_ec == .r

*United States
*Wave 1:
recode last_type_own (.a = 0) if country ==12 & wave ==1 & inlist(q33,12003,12004,12005)
recode last_type_own (.a = 1) if country ==12 & wave ==1 & inlist(q33,12001,12002,12006,12007) 
recode last_type_own (.a = 2) if country ==12 & wave ==1 & q33 == 12995 
recode last_type_own (.a = .r) if country ==12 & wave ==1 & (q33 == .r & country == 12) 

*Wave 2: 
recode last_type_own (.a = 0) if country ==12 & wave ==2 & insur_type ==0
recode last_type_own (.a = 1) if country ==12 & wave ==2 & insur_type ==1
recode last_type_own (.a = 2) if country ==12 & wave ==2 & insur_type ==3
recode last_type_own (.a = .r) if country ==12 & wave ==2 & insur_type ==.r | insur_type ==.d

*Japan
recode last_type_own (.a = 0) if q32_jp == 1
recode last_type_own (.a = 1) if q32_jp == 2
recode last_type_own (.a = 2) if q32_jp == 3


* Other countries:
recode last_type_own (.a = 0) if q32_uy == 1 | q32_it == 1 | inlist(q32_mx,3,4) | ///
								 q32_kr == 1 | ///
								 q32_ar == 1 | q32a_gb == 1 | q32b_gb == 1 | q32a_gr == 1 ///
								 | inlist(q32_np,1,6) | q32_de == 1
								 
recode last_type_own (.a = 1) if q32_uy == 2 | q32_it == 2 | q32_it == 3 | q32_mx == 6 | ///
								 q32_kr == 3 | ///
								 q32_ar == 3 | q32a_gb == 2 | q32b_gb == 2 | q32a_gr == 2 | ///
								 q32a_gr == 3 | inlist(q32_np,2,3,4) | inlist(q32_de, 2, 3)
 
recode last_type_own (.a = 2) if inlist(q32_uy,5,995) | q32_it == 4 | inlist(q32_mx,1,2,5,7) | ///
                  q32_kr == 4 | inlist(q32_ar,2,4,6,7) ///
								 | q32a_gb == 3 | q32a_gr == 5 | q32_np == 5 | inlist(q32_de, 4, 5)
								 
recode last_type_own (.a = .r) if q32_uy == .r | q32_it == .r | q32_mx == .r | ///
								  q32_kr == .r | ///
								  q32_ar == .r | q32a_gb == .r | q32b_gb == .r | ///
								  q32a_gr == .r | q32_de == .r
								  
recode last_type_own (.a = .d) if q32_de == .d

* Recode last_type_own where repondents have no in-person visits
replace last_type_own = .a if q18_q19 == 0 & last_type_own != .a
								  
							  
* last type level							  
recode q33 (1001 1002 1005 1007 3001 3002 3003 3006 3007 3008 3011 5012 5014 5015 5016 5017 5018 5020 9023 ///
			9024 9025 9026 9027 9028 9031 9032 9033 9036 2080 2085 2090 7001 7002 7040 7043 7045 7047 7048 8001 10092 ///
			10094 10096 10100 10102 10104 11002 11003 14001 14002 13001 13002 13005 13008 13009 13012 13013 13015 13017 13018 ///
			12001 12002 12003 12004 12008 15001 15002 16001 16003 16004 16005 4067 4068 4069 4072 4073 4074 ///
			17001 17002 17003 17004 17005 17006 19001 19002 19005 19006 19007 19120 19122 19124 19125 19128 19129 20131 20132 20135 20136 20137 20139 ///
			21004 21005 21006 21007 22002 22003 22005 22061 22064 2101 2108 7102 7103 7105 7108 10104 10108 23006 23007 23009 23010 23011 23012 23013 ///
		   23014 6004 6005 6007 24001 24002 24003 24004 25001 25004 = 0 "Primary") /// 
		   (1004 1006 1008 3004 3005 3009 3021 5013 5019 5021 9029 9030 9034 9035 9037 2081 2082 2086 ///
		   2087 7008 7009 7041 7042 7044 7046 7049 8002 8003 8004 10093 10097 10101 10103 10105 11001 14003 14004 13003 13004 ///
		   13006 13007 13010 13014 13016 13019 13020 12005 12006 12007 15003 15004 16002 16006 16007 4070 4071 ///
		   4075 4076 17007 17008 17009 19003 19004 19121 ///
		   19127 19130 19123 20133 20134 20138 20140 21001 21002 21003 22001 22004 2109 2111 2115 7106 7109 7110 7114 ///
		   7115 10107 10112 10113 10115 23001 23002 23003 23004 23005 23016 23017 6001 6002 6003 6008 24005 24006 25002 25003 = 1 "Secondary (or higher)") ///
		   (.a 18106 18107 18108 18109 18110 18111 18112 18113 18115 18116 18117 = .a "NA") ///
		   (.r 3995 9995 11995 12995 12996 13995 4995 14005 18995 20995 21008 22006 3997 5997 9997 23015 6010 24007 25006 19008 = .r "Refused"), gen(last_type_lvl)

* Greece recode
recode last_type_lvl (.a = 0) if q33a_gr == 1 | q33a_gr == 2
recode last_type_lvl (.a = 1) if q33a_gr == 3 | q33a_gr == 4 | q33a_gr == 6		   
		   
* Somaliland recode
recode last_type_lvl (.a = 0) if q33a_gr == 1 | q33a_gr == 2
recode last_type_lvl (.a = 1) if q33a_gr == 3 | q33a_gr == 4 | q33a_gr == 6

* 03-04-2026 LX: missingness recode, already checking using q18 and q19
recode last_type_lvl (. = .r) if inlist(country,2,4,7,10)
recode last_type_lvl (. = .a) if inlist(country,8,17)
recode last_type_lvl (. = .r) if country==3&q18==2
recode last_type_lvl (. = .d) if country==3&q18==.d

		      
* last_type - ownership and level
gen last_type = . 
recode last_type (. = 0) if last_type_own == 0 & last_type_lvl == 0
recode last_type (. = 1) if last_type_own == 0 & last_type_lvl == 1
recode last_type (. = 2) if last_type_own == 1 & last_type_lvl == 0
recode last_type (. = 3) if last_type_own == 1 & last_type_lvl == 1
recode last_type (. = 4) if last_type_own == 2 & last_type_lvl == 0
recode last_type (. = 5) if last_type_own == 2 & last_type_lvl == 1
recode last_type (. = .a) if last_type_own == .a | last_type_lvl == .a
recode last_type (. = .r) if last_type_own == .r | last_type_lvl == .r
lab def fac_own_lvl 0 "Public primary" 1 "Public secondary (or higher)" 2 "Private primary" /// 
					3 "Private secondary (or higher)" 4 "Other primary" 5 "Other secondary (or higher)" ///
					.a NA .r Refused, replace
lab val last_type fac_own_lvl

* drop lac vars for usual_type_own + usual_type_lvl
*drop p14_col p14_per p14_uru p32_col p32_per p32_uru p33_col p33_per p33_uru

* minority

*Notes: No data for AR, For India: No actual data for Bodo" or "Dogri" but it is in the country-specific sheet.
recode q50 (11002 11003 11001 12001 12002 12003 = .a) // First recode all to .a for Laos since we will be using q50a_la

recode q50 (1013 1014 1017 5001 5005 5008 5009 5010 5011 5012 5013 5014 5015 3023 3024 3025 ///
		   3026 3027 3028 3029 3030 3031 3032 7044 7045 7049 8002 2081  ///
		   15002 9035 9036 9037 9038 9041 9044 2995 3995 5995 11995 3995 9995 ///
		   4055 4062 4063 4064 4066 4068 4070 4071 4072 4073 4995 11002 11003 11005 18995 19092 19093 19995 ///
		   20097 20099 20103 20104 20105 20107 20108 20109 20995 21002 2002 2003 2004 2011 2012 2014 7005 7006 ///
		   7007 7008 7009 7010 7013 3997 4058 4997 5997 9997 6002 6003 6004 6005 6006 22002 22003 24002 24003 24004 24005 ///
		   24006 24007 24008 24009 24011 14002 14003 14004 14005 14006 14007 14008 14009 14010 14011 14012 14013 ///
		   14014 14015 14016 14017 14018 14019 14020 14021 = 1 "Minority group") ///
		   (1015 5002 5003 5004 5006 5007 3021 3022 7053 8001 2087 15001 9033 ///
		   9034 9039 9040 9042 9043 4060 4056 4067 4075 4074 4059 4076 4061 4069 4065 11001 18090 19091 ///
		   20094 20095 20096 20098 20100 20101 20102 20106 21001 22001 2001 7001 6001 24001 24010 14001 = 0 "Majority group") ///
		   (.r = .r "Refused") (.a = .a "NA"), gen(minority)
		   
recode minority (8008 = .a) if q50 == 8008 & country == 8
		   
*US & MX:
recode minority (.a = 1) if q50_mx == 1		   
recode minority (.a = 1) if q50a_us == 1
recode minority (.a = 1) if inlist(q50b_us,1,2,3,4,6,995)

*US:white and non-hispanic group = majority:
recode minority (.a = 0) if (q50b_us == 5 & q50a_us == 2)
recode minority (.a = .r) if q50b_us == .r & q50a_us == .r // (two refused q50a_us but answered q50b_us)

*Mexico majority group (doesn't speak indigenous language)
recode minority (.a = 0) if q50_mx == 0
recode minority (.a = .r) if q50_mx == .r 

*UK
recode minority (.a = 1) if inlist(q50_gb,1,2,3,5)
recode minority (.a = 0) if q50_gb == 4	
recode minority (.a = .r) if q50_gb == .r   

*Laos:
recode minority (.a = 1) if inlist(q50a_la,11002,11003,11004,11005)
recode minority (.a = 0) if q50a_la == 11001

*Somaliland (no recoding?)
recode minority (. = .a) if country == 22 // LX: check with SS and Todd

*Nepal
replace minority = 1 if q50a_np ==1 | q50a_np == 3
replace minority = 0 if q50a_np ==2 | q50a_np == 4 | q50a_np == 5 | q50a_np == 6 | ///
						q50a_np == 7 | q50a_np == 8 | q50a_np == 9 | q50a_np == 10 | q50a_np == 11
						
*Switzerland: note that these vars were a part of a MC field, SS: check if people have multiple options?
replace minority = 1 if q50f_ch == 1 | q50h_ch == 1 | q50i_ch == 1 | ///
						q50j_ch == 1 | q50l_ch == 1 | q50m_ch == 1
replace minority = 0 if q50a_ch	== 1 | q50b_ch == 1	| q50c_ch == 1 | q50d_ch ==1	

	*removing the multi-checkbox vars from final MC dataset:
	drop q50a_ch q50b_ch q50c_ch q50d_ch q50f_ch q50h_ch q50i_ch q50j_ch q50k_ch q50l_ch q50m_ch q50_ch_dk

* Italy
replace minority = 0 if q50 == 14001
replace minority = 1 if inrange(q50, 14002, 14021)
recode minority (. = .a) if country ==14

drop minority_it

* income 
* Note - this is the income categories trying to reflex tertiles as close as possible based on distribution in sample 

recode q51 (1001 1002 2039 2040 2041 3009 3111 3112 4024 04025 4127 4128 4129 5001 5101 5102 6001 7031 7032 ///
		   8001 9015 9016 9017 9118 9119 9120 10049 10050 10051 11001 11002 ///
		   13001 14001 14002 15001 15002 15003 15004 16001 16002 16003 17001 ///
		   17002 18062 19068 19169 20075 20076 20077 21001 21002 22001 2001 2002 7006 10011 10012 ///
		   23001 24001 24002 24003 25001 25002 = 0 "Lowest income") /// 
		   (1003 2042 2043 2044 3010 3113 3114 4027 4130 4131 4132 5103 5104 5105 6002 7033 8002 8003 9018 9019 9121 9122 ////
		   10052 10053 10054 11003 11004 13002 14003 15005 15006 ///
		   16004 16005 17003 17004 4026 18063 18064 18065 18066 18067 18082 18083 ///
		   18084 19069 19070 19071 19072 19073 19170 20078 20079 21003 21004 22002 2003 ///
		   7007 10013 10014 23002 24004 25003 25004 = 1 "Middle income") /// 
		   (1004 1005 2045 2048 3011 3012 3013 3014 3115 3116 3117 4028 4029 4030 4133 ///
		   4134 4135 5002 5003 5004 5005 5006 5007 5106 5107 5108 5109 5110 6003 6004 6005 7034 7035 7036 ///
		   7037 7038 8004 8005 9020 9021 ///
		   9022 9023 9123 9124 9125 9126 10055 10061 11005 11006 11007 ///
		   13003 13004 13005 14004 14005 14006 14007 15007 15008 16005 16006 ///
		   16007 17005 17006 18085 19074 19171 19172 19174 20080 20081 21005 21006 ///
		   22003 22004 22005 22006 22007 2004 2005 7008 7009 7010 10015 ///
		   23003 23004 23005 23006 24005 24006 24007 24008 24009 25005 25006 25007 25008 25009 = 2 "Highest income") ///
		   (.r = .r "Refused") (.d = .d "Don't know") (.a = .a "NA"), gen(income)
	
* United States income recoding:
replace income = 0 if q51 == 12001 | 12002 & country ==12  & wave ==1
replace income = 1 if q51 == 12003 | q51 == 12004 & country ==12 & wave ==1
replace income = 2 if q51 == 12005 & country ==12 & wave ==1
replace income = 0 if q51 == 12101 | q51 == 12102 | q51 == 12103 & country == 12 & wave ==2
replace income = 1 if q51 == 12104 | q51 == 12105 & country ==12 & wave ==2
replace income = 2 if q51 == 12106 | q51 == 12107 & country ==12 & wave ==2

*Italy income recoding
replace income = 0 if income_it ==0 & country ==14 & wave ==2
replace income = 1 if income_it ==1 & country ==14 & wave ==2
replace income = 2 if income_it ==2 & country ==14 & wave ==2
drop income_it

recode income (. = .r)
	
* Colombia q23 values seem implausible
recode visits_tele (80 = .) if country == 2 
* Ethiopia: 92 visits for q28 
recode visits_home (92 = .) if country == 3 
* India 2 visits value and 3 visit_home value
replace visits = . if visits > 60 & visits < . & country == 4 
replace visits_home = . if visits_home > 60 & visits_home < . & country == 4 
*South Africa: 120 visits for q28
recode visits_home (120 = .) if country == 9 
* South Africa; 144 visits for q18
recode visits (144 = .) if country == 9 
* Uruguay: q18 values seem implausible 
recode visits (200 = .) (156 = .) if country == 10 
* US visits, 4 values recoded
replace visits = . if visits > 60 & visits < . & country == 12
recode visits_tele (60 = .) if country == 12  // 1 change  
* Italy visits, 1 value recoded 
replace visits = . if visits > 60 & visits < . & country == 14 
* Korea, 1 visit_home and 1 visit_covid value, 5 visit values
recode visits_home (68 = .) if country == 15 
*recode visits_covid (80 = .) if country == 15 
replace visits = . if visits > 60 & visits < . & country == 15 
* Argentina (Mendoza) visits, 4 value recoded, visits_tele, 1 value recoded 
replace visits = . if visits > 50 & visits < . & country == 16 
recode visits_tele (96 = .) if country == 16 
* UK 
recode visits (150 = .) if country == 17
recode visits_tele (100 = .) if country == 17
* Greece:
replace visits = . if visits > 80 & visits < . & country == 18 // 4 changes
* Romania: (none)
*Nigeria
recode visits_tele (60 = .) if country == 20  // 1 change 
*China
replace visits = . if visits > 70 & visits < . & country == 21 // 1 change 
*Ecuador: (none)
*Germany q18 visits seem implausible: 200, 355
recode visits (200 = .) (355 = .) if country == 24

* Recode extreme values to missing 

* All visit count variables and wait time variables:

* q18, q22, q23

* Mia's note: check extreme values for Nigeria needed
qui levelsof country, local(countrylev)

foreach i in `countrylev' {
	
	if !inlist(`i', 12, 13, 14, 17) {
		extremes visits_home country if country == `i', high
	}
	
	foreach var in visits visits_tele {

		
		extremes `var' country if country == `i', high
	}
}


*adding "NA" for countries' that don't have V1.0 vars
recode covid_vax_v1 ///
	   covid_vax_intent_v1 visits_covid_v1 last_visit_time_v1 ever_covid_v1 covid_confirmed_v1 ///
	   (. = .a) if country == 21 | country == 22 | country == 23 | country == 8

*Generate country dummy variables

local map 1 EC 2 CO 3 ET 4 IN 5 KE 6 MW 7 PE 9 ZA 10 UY 11 LA 12 US 13 MX ///
           14 IT 15 KR 16 AR 17 GB 18 GR 19 RO 20 NG 21 CN 22 SO 23 NP 24 DE 25 CH

forvalues i = 1/25 {
    gen cc_`i' = (country == `i')

    local iso ""
    if `i' == 1  local iso "EC"
    if `i' == 2  local iso "CO"
    if `i' == 3  local iso "ET"
    if `i' == 4  local iso "IN"
    if `i' == 5  local iso "KE"
	if `i' == 6  local iso "MW"
    if `i' == 7  local iso "PE"
	if `i' == 8  local iso "JP"
    if `i' == 9  local iso "ZA"
    if `i' == 10 local iso "UY"
    if `i' == 11 local iso "LA"
    if `i' == 12 local iso "US"
    if `i' == 13 local iso "MX"
    if `i' == 14 local iso "IT"
    if `i' == 15 local iso "KR"
    if `i' == 16 local iso "AR"
    if `i' == 17 local iso "GB"
    if `i' == 18 local iso "GR"
    if `i' == 19 local iso "RO"
    if `i' == 20 local iso "NG"
    if `i' == 21 local iso "CN"
    if `i' == 22 local iso "SO"
    if `i' == 23 local iso "NP"
	if `i' == 24 local iso "DE"
	if `i' == 25 local iso "CH" 

    capture confirm variable cc_`i'
    if "`iso'" != "" & !_rc {
        rename cc_`i' `iso'
    }
}


*Strata var for countries with cluster sampling for household interviews
decode country_reg, generate(strata)
replace strata = "Ethiopia_CATI" if country==3 & mode==1
replace strata = "Ethiopia_F2F" if country==3 & mode==2
replace strata = "Kenya_CATI" if country==5 & mode==1
replace strata = "Kenya_F2F" if country==5 & mode==2
replace strata = "Somaliland_CATI" if country==22 & mode==1
replace strata = "Somaliland_F2F" if country==22 & mode==2
replace strata = "Malawi_CATI" if country==6 & mode==1
replace strata = "Malawi_F2F" if country==6 & mode==2

*********************************9-20 SS: adding back variables for PVS dashboard:
gen health = q9 
gen health_mental = q10 
recode health_mental (. = .r) if country==23
gen last_qual = q38_a 
gen last_skills = q38_b 
gen last_supplies = q38_c 
gen last_respect = q38_d 
gen last_explain = q38_f 
gen last_decisions = q38_g
gen last_visit_rate = q38_h 
gen last_wait_rate = q38_i 
*courtesy
gen last_sched_rate = q38_k 

lab val health health_mental last_qual last_skills last_supplies last_respect /// 
last_explain last_decisions last_visit_rate last_wait_rate last_sched_rate vignette_poor /// 
vignette_good exc_poor
	   
gen usual_quality = q17
recode usual_quality (5 = .a)
recode usual_quality (. = .r) if inlist(country, 8, 23)
gen last_know = q38_e
gen last_courtesy = q38_j
lab val usual_quality exc_pr_hlthcare
lab val last_know exc_pr_visits
lab val last_courtesy exc_poor_staff

*phc women, child, chronic, mental, qual_srh, care_infection, care_nonurgent, conf_sick, conf_afford, conf_getafford,qual_public, qual_private, covid_manage
gen phc_women = q40_a
gen phc_child = q40_b
gen phc_chronic = q40_c
gen phc_mental = q40_d

*Recoding "Iam unable to judge = .d"
recode phc_women phc_child phc_chronic phc_mental (5 = .d) if country == 21 | country == 22
*"6 = "I am unable to judge" response option in Nepal-only being recoded to missing
recode phc_women phc_child phc_chronic phc_mental (6 = .d) if country ==23
gen qual_srh = q40_e_ng
recode qual_srh (. = .a) if country !=20
gen care_infections = q40b_so 
recode care_infections (. = .a) if country !=22
*replace phc_mental = q40e_so if country ==22
gen care_nonurgent = q40f_so 
recode care_nonurgent (. = .a) if country !=22
lab val phc_women phc_child phc_chronic phc_mental qual_srh care_infections ///
		care_nonurgent exc_poor_judge
		
recode phc_women phc_child (. = .a) if country ==22
recode phc_women phc_chronic phc_child phc_mental (. = .r) if country ==23
	
gen qual_public = q42
gen qual_private = q43 
gen covid_manage = q47

recode qual_private (. = .a) if country ==25
lab val qual_public qual_private covid_manage exc_poor

**** All Very Confident to Not at all Confident scales ****
* conf_sick conf_afford conf_opinion
recode q41_a q41_b ///
	   (3 2 = 1 "Somewhat confident/Very confident") ///
	   (0 1 = 0 "Not too confident/Not at all confident") /// 
	   (.r = .r Refused) (.a = .a na), /// 
	   pre(der) label(vc_nc_der)
gen conf_opinion = q41_c
lab val conf_opinion vc_nc
ren (derq41_a derq41_b) (conf_sick conf_afford)
gen conf_getafford = .
replace conf_getafford=1 if conf_sick==1 & conf_afford==1
replace conf_getafford=0 if conf_sick==0 | conf_afford==0
replace conf_getafford=.r if conf_sick==.r | conf_afford==.r
lab val conf_getafford vc_nc_der

*********************************01-12-2026 LW: adding back some derived variables after PVS dashboard:
* tele_qual
recode q25 (0 = 0 "Poor") (1 = 1 "Fair") (2 = 2 "Good") (3 = 3 "Very Good") (4 = 4 "Excellent") ///
			(.r = .r "Refused") (.a = .a "NA") , gen(tele_qual)
			
*last_sched
recode q35 (0 = 0 "No") (1 = 1 "Yes") ///
		   (.a = .a "NA") (.r = .r "Refused"), gen(last_sched)
		   
*********************************03-02-2026 LW: normalize weight for DE and CH
* recommend doing here because the reference from census dataset usually includes age under 18 
bysort country: egen mean_wgt = mean(weight)
replace weight = weight / mean_wgt if inlist(country, 25, 24)

*****************************

**** Order Variables ****

order q*, sequential	   
order respondent_serial respondent_id country country_reg wave language language_other date /// 
	  int_length mode strata weight psu_id_for_svy_cmds age age_cat gender urban region ///
	  insured insur_type insur_type_universal education health health_vge health_mental health_mental_vge health_chronic ///
	  ever_covid_v1 covid_confirmed_v1 covid_vax_v1 covid_vax_intent_v1 activation ///
	  usual_source usual_type_own usual_type_lvl usual_type ///
	  usual_reason usual_quality usual_quality_vge visits visits_cat visits_covid_v1 ///
	  fac_number visits_home visits_tele tele_qual tele_qual_vge visits_total inpatient blood_pressure mammogram ///
	  cervical_cancer eyes_exam teeth_exam blood_sugar blood_chol hiv_test care_srh care_mental /// 
	  breast_exam color_ultrasound sti_test endoscope barium_test fecal_blood electrocardiogram mistake discrim unmet_need unmet_reason last_type_own last_type_lvl ///
	  last_type last_reason last_sched last_wait_time last_visit_time_v1 last_sched_time ///
	  last_qual last_qual_vge last_skills last_skills_vge last_supplies last_supplies_vge last_respect last_respect_vge last_know last_know_vge ///
	  last_explain last_explain_vge last_decisions last_decisions_vge last_visit_rate last_visit_rate_vge last_wait_rate last_wait_rate_vge ///
	  last_courtesy last_courtesy_vge last_sched_rate last_sched_rate_vge ///
	  last_promote phc_women phc_women_vge phc_child phc_child_vge phc_chronic phc_chronic_vge phc_mental phc_mental_vge ///
	  qual_srh qual_srh_vge care_infections care_infections_vge care_nonurgent care_nonurgent_vge ///
	  conf_sick conf_sick_scvc conf_afford conf_afford_scvc conf_getafford conf_getafford_scvc conf_opinion conf_opinion_scvc qual_public qual_public_vge qual_private qual_private_vge ///
	  system_outlook system_reform system_reform_minor covid_manage covid_manage_vge vignette_poor /// 
	  vignette_good minority income   	   	  
	
***************************** Labeling variables ***************************** 

lab var wave "Survey wave"
lab var age "Exact respondent age or midpoint of age range (Q1/Q2)"
lab var age_cat "Age (categorical) (Q1/Q2)"
lab var gender "Gender (Q3)" 
lab var urban "Respondent lives in urban vs rural area (Q5)"
lab var region "Region where respondent lives (County, state, province, etc.) (Q4)"
lab var insured "Insurance status (Q6)"
lab var insur_type "Type of insurance (for those who have insurance) (Q7)" 
lab var insur_type_universal "Supplemental private insurance in universal public systems (Q7)"
lab var education "Highest level of education completed (Q8)"
lab var health "Self-rated health (Q9)"
lab var health_vge "Self-rated health (Q9)"
lab var health_mental "Self-rated mental health (Q10)"
lab var health_mental_vge "Self-rated mental health (Q10)"
lab var	health_chronic "Longstanding illness or health problem (chronic illness) (Q11)"
lab var ever_covid_v1 "Ever had COVID-19 or coronavirus (V1.0 - Q12)"
lab var	covid_confirmed_v1	"COVID-19 or coronavirus confirmed by a test (V1.0 - Q13)"
lab var	covid_vax_v1 "COVID-19 vaccination status (V1.0 - Q14)"
lab var	covid_vax_intent_v1 "Intent to receive all recommended COVID vaccine doses if available (V1.0 - Q15)"
lab var	activation "Patient activation: manage overall health and tell a provider concerns (Q12_a/Q12_b)"
lab var	usual_source "Whether respondent has a usual source of care (Q13)"
lab var	usual_type_own "Facility ownership for usual source of care (Q14)"
lab var	usual_type_lvl "Facility level for usual source of care (Q15)"
lab var	usual_type "Facility ownership and level for usual source of care (Q14/Q15)"
lab var	usual_reason "Main reason for choosing usual source of care facility (Q16)"
lab var	usual_quality "Overall quality rating of usual source of care (Q17)"
lab var	usual_quality_vge "Overall quality rating of usual source of care (Q17)"
lab var	visits "Visits (continuous) made in-person to a facility in past 12 months (Q18/Q19)"
lab var	visits_cat "Visits (categorical) made in-person to a facility in past 12 months (Q18/Q19)"
lab var	visits_covid_v1 "Number of visits made for COVID in past 12 months (Q25A/Q25B)"
lab var	fac_number "Number of facilities visited during the past 12 months (Q20/Q21)"
lab var visits_home "Number of visits made by healthcare provider at home (Q22)"
lab var visits_tele "Number of virtual or telemedicine visits (Q23)"
lab var	visits_total "Total number of healthcare contacts: facility, home, and tele (Q18/Q22/Q23)"
lab var	inpatient "Stayed overnight at a facility in past 12 months (inpatient care) (Q26)"
lab var	blood_pressure "Blood pressure checked by healthcare provider in past 12 months (Q27_a)"
lab var	mammogram "Mammogram conducted by healthcare provider in past 12 months (Q27_b)"
lab var	cervical_cancer "Cervical cancer screening done by healthcare provider in past 12 months (Q27_c)"
lab var	eyes_exam "Eyes checked by healthcare provider in past 12 months (Q27_d)"
lab var	teeth_exam "Teeth checked by healthcare provider in past 12 months (Q27_e)"
lab var	blood_sugar "Blood sugar tested by healthcare provider in past 12 months (Q27_f)"
lab var	blood_chol "Blood cholesterol tested by healthcare provider in past 12 months (Q27_g)"		
lab var care_srh "NG only: Received care for sexual and reproductive health condition (Q27i_ng)"
lab var	hiv_test "ZA only: HIV test conducted by healthcare provider in past 12 months (Q27_za)"
lab var	care_mental	"Received care for depression, anxiety, or another mental health condition (Q27_h)"
lab var breast_exam "CN only: Breast examination conducted by healtchare provider in past 12 months (Q27i_cn)"
lab var color_ultrasound "CN: Color Ultrasound Mammography conducted by healtchare provider in past 12 months (Q27j_cn)"
lab var	sti_test "US only: STI test conducted in past 12 months (Q27i_us)"
lab var	endoscope "JP only: Endoscope conducted in past 12 months (Q27i_jp)"
lab var	barium_test "JP only: Barium swallow test conducted in past 12 months (Q27j_jp)"
lab var	fecal_blood "JP only: Fecal occult blood test conducted in past 12 months (Q27k_jp)"
lab var	electrocardiogram "JP only: Electrocardiogram conducted in past 12 months (Q27l_jp)"


lab var	mistake	"A medical mistake was made in treatment or care in the past 12 months (Q28_a)"	
lab var	discrim	"You were treated unfairly or discriminated against in the past 12 months (Q28_b)"	
lab var	unmet_need "Needed medical attention but did not get healthcare (Q29)"
lab var	unmet_reason "Reason for not getting healthcare when needed medical attention (Q30)"
lab var	last_type_own "Facility ownership for last visit to a healthcare provider (Q32)"
lab var	last_type_lvl "Facility level for last visit to a healthcare provider (Q33)"
lab var last_type "Facility ownership and level for last visit to a healthcare provider (Q32/Q33)"
lab var	last_reason	"Reason for last healthcare visit (Q34)" 
lab var	last_wait_time "Length of time waited for last visit to a healthcare provider (Q37)"
lab var	last_visit_time_v1 "Length of time spent with the provider during last healthcare visit (V1.0 - Q47)"
lab var	last_qual "Last visit rating: overall quality (Q38A)"
lab var	last_qual_vge "Last visit rating: overall quality (Q38A)"
lab var	last_skills "Last visit rating: knowledge and skills of provider (Care competence) (Q38_b)"
lab var	last_skills_vge "Last visit rating: knowledge and skills of provider (Care competence) (Q38_b)"
lab var	last_supplies "Last visit rating: equipment and supplies provider had available (Q38_c)"
lab var	last_supplies_vge "Last visit rating: equipment and supplies provider had available (Q38_c)"
lab var	last_respect "Last visit rating: provider respect (Q38_d)"
lab var	last_respect_vge "Last visit rating: provider respect (Q38_d)"
lab var	last_know "Last visit rating: knowledge of prior tests and visits (Q38_e)"
lab var	last_know_vge "Last visit rating: knowledge of prior tests and visits (Q38_e)"
lab var	last_explain "Last visit rating: explained things in an understandable way (Q38_f)"
lab var	last_explain_vge "Last visit rating: explained things in an understandable way (Q38_f)"
lab var	last_decisions "Last visit rating: involved you in decisions about your care (Q38_g)"
lab var	last_decisions_vge "Last visit rating: involved you in decisions about your care (Q38_g)"
lab var	last_visit_rate "Last visit rating: amount of time provider spent with you (Q38_h)"
lab var	last_visit_rate_vge "Last visit rating: amount of time provider spent with you (Q38_h)"
lab var	last_wait_rate "Last visit rating: amount of time you waited before being seen (Q38_i)"
lab var	last_wait_rate_vge "Last visit rating: amount of time you waited before being seen (Q38_i)"
lab var	last_courtesy "Last visit rating: courtesy and helpfulness of the staff (Q38_j)"
lab var	last_courtesy_vge "Last visit rating: courtesy and helpfulness of the staff (Q38_j)"
lab var	last_promote "Net promoter score for facility visited for last visit (Q39)"
lab var	phc_women "Public primary care system rating for: pregnant women (Q40_a)"
lab var	phc_women_vge "Public primary care system rating for: pregnant women (Q40_a)"
lab var	phc_child "Public primary care system rating for: children (Q40_b)"
lab var	phc_child_vge "Public primary care system rating for: children (Q40_b)"
lab var	phc_chronic "Public primary care system rating for: chronic conditions (Q40_c)"
lab var	phc_chronic_vge "Public primary care system rating for: chronic conditions (Q40_c)"
lab var	phc_mental "Public primary care system rating for: mental health (Q40_d)"
lab var	phc_mental_vge "Public primary care system rating for: mental health (Q40_d)"
lab var qual_srh "Rating for quality of care provided for sexual or reproductive health?"
lab var qual_srh_vge "Rating for quality of care provided for sexual or reproductive health?"
lab var care_infections "Rating for care for infections such as Malaria, Tuberculosis etc?"
lab var care_infections_vge "Rating for care for infections such as Malaria, Tuberculosis etc?"
lab var care_nonurgent "Rating for the quality of care provided for other non-urgent common illnesses such as skin, ear conditions, stomach problems, urinary problems, joint paints etc."
lab var care_nonurgent_vge "Rating for the quality of care provided for other non-urgent common illnesses such as skin, ear conditions, stomach problems, urinary problems, joint paints etc."
lab var	conf_sick_scvc "Confidence in receiving good quality healthcare if became very sick (Q41_a)"
lab var conf_getafford "Confidence in Receiving and affording healthcare if became very sick (Q41a/Q41b)"
lab var	conf_afford_scvc	"Confidence in ability to afford care healthcare if became very sick (Q41_b)"
lab var	conf_opinion "Confidence that the gov considers public's opinion when making decisions (Q41_c)"
lab var	conf_opinion_scvc "Confidence that the gov considers public's opinion when making decisions (Q41_c)"
lab var	qual_public	"Overall quality rating of gov or public healthcare system in country (Q42)"
lab var	qual_public_vge	"Overall quality rating of gov or public healthcare system in country (Q42)"
lab var	qual_private "Overall quality rating of private healthcare system in country (Q43)"
lab var	qual_private_vge "Overall quality rating of private healthcare system in country (Q43)" 
lab var	system_outlook "Health system opinion: getting better, staying the same, or getting worse (Q45)"
lab var	system_reform "Health system opinion: minor, major changes, or must be completely rebuilt (Q46)" 
lab var	covid_manage "Rating of the government's management of the COVID-19 pandemic (Q47)" 
lab var	covid_manage_vge "Rating of the government's management of the COVID-19 pandemic (Q47)" 
lab var	vignette_poor "Rating of vignette in q48 (poor care)"
lab var	vignette_good "Rating of vignette in q49 (good care)"
lab var	minority "Minority group (based on native language, ethnicity or race) (Q50)"
lab var	income "Income group (Q51)"
lab var tele_qual "Overall quality of last telemedicine visit (Q25)"
lab var tele_qual_vge "Overall quality of last telemedicine visit (Q25)"
lab var last_sched_time "Length of days between scheduling visit and seeing provider (Q36)"
lab var last_sched_rate "Last visit rating: time between scheduling visit and seeing provider (Q38_k)"
lab var conf_getafford_scvc "Confidence in receiving and affording healthcare if became very sick (Q41_a/Q41_b)"
lab var strata "Strata for survey mode (household only)"
*lab var pol_align_v1 "Political alignment in respondent's region / district / state"

**************************** Save data *****************************

drop p32_col p32_per p32_uru p33_col p33_per p33_uru

/* Dropping excess variables (for series 2026)
drop q1217scale m1_a m1_b m1_2_a m1_2_b m1_2_c m1_2_d m1_2_e m1_2_f m1_2_g m2_a m2_b m2_c m2_d m2_e m2_f m2_g m2_h m2_i m2_i_other m3 m4 m5 m6_a m6_b m6_c m6_d m6_e m6_f m6_g m6_h m6_i m6_j m6_j_other m7 m8 m9 m10 m11 m12 xchannel usw_main2 usw_rural2 usw_under302 usw_mo5 visits_mental m6_total phq2 phq2_cat phq9 phq9_cat m4_vge
*/

notes drop _all
compress 
save "$data_mc/02 recoded data/pvs_all_countries_v2.dta", replace


/*
**************=Save individual datasets to recoded data folder****************

*Colombia
preserve
keep if country == 2
save "$data/Colombia/02 recoded data/pvs_colombia_recoded", replace
restore

*Ethiopia
preserve
keep if country == 3
save "$data/Ethiopia/02 recoded data/pvs_ethiopia_recoded", replace
restore

*India
preserve
keep if country == 4
save "$data/India/02 recoded data/pvs_india_recoded", replace
restore

*Kenya
preserve
keep if country == 5
save "$data/Kenya/02 recoded data/pvs_kenya_recoded", replace
restore

*Peru
preserve
keep if country == 7
save "$data/Peru/02 recoded data/pvs_peru_recoded", replace
restore

*South Africa
preserve
keep if country == 9
save "$data/South Africa/02 recoded data/pvs_za_recoded", replace
restore

*Uruguay
preserve
keep if country == 10
save "$data/Uruguay/02 recoded data/pvs_uruguay_recoded", replace
restore

*Lao PDR
preserve
keep if country == 11
save "$data/Laos/02 recoded data/pvs_laos_recoded", replace
restore

preserve
keep if country == 12 & wave ==1
save "$data/United States/02 recoded data/pvs_us_wave1_recoded", replace
restore

*wave 2 specifically 
preserve
keep if country == 12 & wave ==2
save "$data/United States wave 2/02 recoded data/pvs_us_wave2_recoded", replace
restore

*Mexico
preserve
keep if country == 13
save "$data/Mexico/02 recoded data/pvs_mx_recoded", replace
restore

*Italy
preserve
keep if country == 14
save "$data/Italy/02 recoded data/pvs_it_recoded", replace
restore

*South Korea
preserve
keep if country == 15
save "$data/South Korea/recoded data/pvs_korea_recoded", replace
restore

*Argentina
preserve
keep if country == 16
save "$data/Argentina (Mendoza)/02 recoded data/pvs_argentina_recoded", replace
restore

*United Kingdown
preserve
keep if country == 17
save "$data/United Kingdom/02 recoded data/pvs_gb_recoded", replace
restore

*Greece
preserve
keep if country == 18
save "$data/Greece/02 recoded data/pvs_gr_recoded", replace
restore

*Romania
preserve
keep if country == 19
save "$data/Romania/02 recoded data/pvs_ro_recoded", replace
restore

*Nigeria 
preserve
keep if country == 20
save "$data/Nigeria/02 recoded data/pvs_ng_recoded", replace
restore

*China 
preserve
keep if country == 21
save "$data/China/02 recoded data/pvs_cn_recoded", replace
restore

*Somaliland 
preserve
keep if country == 22
save "$data/Somaliland/02 recoded data/pvs_so_recoded", replace
restore



drop if country == 19 // remove once we are able to use Romania data

* ONLY RUN COMMAND BELOW WHEN SHARING TO PUBLIC REPOSITORIES
* save "$data/Multi-country (shared)/pvs_all_countries_3-7-24.dta", replace 


