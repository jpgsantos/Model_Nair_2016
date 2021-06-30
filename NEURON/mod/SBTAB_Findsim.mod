TITLE SBTAB_Findsim
COMMENT
	automatically generated from an SBtab file
	date: Tue Feb  9 15:23:52 2021
ENDCOMMENT
NEURON {
	SUFFIX SBTAB_Findsim : OR perhaps POINT_PROCESS ?
	RANGE pERK1_2_ratio1 : output
	RANGE MAPK_out : output
	RANGE MAPK_p_out : output
	RANGE MAPK_p_p_out : output
	RANGE MAPK_p_p_cplx_out : output
	RANGE MAPK_p_p_feedback_cplx_out : output
	RANGE pERK1_2_ratio2 : output
	RANGE PKC_active, PKC_active1, APC, Inositol, PC, PIP2, EGF, Ca : assigned
	RANGE PKC_Ca : compound
	RANGE PKC_DAG_AA_p : compound
	RANGE PKC_Ca_AA_p : compound
	RANGE PKC_Ca_memb_p : compound
	RANGE PKC_DAG_memb_p : compound
	RANGE PKC_basal_p : compound
	RANGE PKC_AA_p : compound
	RANGE PKC_Ca_DAG : compound
	RANGE PKC_DAG : compound
	RANGE PKC_DAG_AA : compound
	RANGE PKC_cytosolic : compound
	RANGE PLA2_cytosolic : compound
	RANGE PLA2_Ca_p : compound
	RANGE PIP2_PLA2_p : compound
	RANGE PIP2_Ca_PLA2_p : compound
	RANGE DAG_Ca_PLA2_p : compound
	RANGE PLA2_p_Ca : compound
	RANGE PLA2_p : compound
	RANGE Arachidonic_Acid : compound
	RANGE PLC : compound
	RANGE PLC_Ca : compound
	RANGE PLC_Ca_Gq : compound
	RANGE PLC_Gq : compound
	RANGE DAG : compound
	RANGE IP3 : compound
	RANGE MAPK_p_p : compound
	RANGE craf_1 : compound
	RANGE craf_1_p : compound
	RANGE MAPKK : compound
	RANGE MAPK : compound
	RANGE craf_1_p_p : compound
	RANGE MAPK_p : compound
	RANGE MAPKK_p_p : compound
	RANGE MAPKK_p : compound
	RANGE Raf_p_GTP_Ras : compound
	RANGE craf_1_p_ser259 : compound
	RANGE inact_GEF : compound
	RANGE GEF_p : compound
	RANGE GTP_Ras : compound
	RANGE GDP_Ras : compound
	RANGE GAP_p : compound
	RANGE GAP : compound
	RANGE inact_GEF_p : compound
	RANGE CaM_GEF : compound
	RANGE EGFR : compound
	RANGE L_EGFR : compound
	RANGE Internal_L_EGFR : compound
	RANGE SHC_p_Sos_Grb2 : compound
	RANGE SHC : compound
	RANGE SHC_p : compound
	RANGE Sos_p_Grb2 : compound
	RANGE Grb2 : compound
	RANGE Sos_Grb2 : compound
	RANGE Sos_p : compound
	RANGE Sos : compound
	RANGE SHC_p_Grb2_clx : compound
	RANGE PLC_g : compound
	RANGE PLC_g_p : compound
	RANGE Ca_PLC_g : compound
	RANGE Ca_PLC_g_p : compound
	RANGE PLCg_basal : compound
	RANGE MKP_1 : compound
	RANGE PPhosphatase2A : compound
	RANGE PKC_act_raf_cplx : compound
	RANGE PKC_inact_GAP_cplx : compound
	RANGE PKC_act_GEF_cplx : compound
	RANGE kenz_cplx : compound
	RANGE kenz_cplx_1 : compound
	RANGE kenz_cplx_2 : compound
	RANGE kenz_cplx_3 : compound
	RANGE kenz_cplx_4 : compound
	RANGE PLC_Ca_cplx : compound
	RANGE PLCb_Ca_Gq_cplx : compound
	RANGE MAPK_p_p_cplx : compound
	RANGE MAPK_p_p_feedback_cplx : compound
	RANGE phosph_Sos_cplx : compound
	RANGE MAPKKtyr_cplx : compound
	RANGE MAPKKthr_cplx : compound
	RANGE Raf_p_GTP_Ras_1_cplx : compound
	RANGE Raf_p_GTP_Ras_2_cplx : compound
	RANGE basal_GEF_activity_cplx : compound
	RANGE GEF_p_act_Ras_cplx : compound
	RANGE GAP_inact_Ras_cplx : compound
	RANGE CaM_GEF_act_Ras_cplx : compound
	RANGE Ca_PLC_g_phospho_cplx : compound
	RANGE SHC_phospho_cplx : compound
	RANGE Sos_Ras_GEF_cplx : compound
	RANGE PLC_g_phospho_cplx : compound
	RANGE MKP1_tyr_deph_cplx : compound
	RANGE MKP1_thr_deph_cplx : compound
	RANGE craf_dephospho_cplx : compound
	RANGE MAPKK_dephospho_cplx : compound
	RANGE MAPKK_dephospho_ser_cplx : compound
	RANGE craf_p_p_dephospho_cplx : compound
	RANGE deph_raf_ser259_cplx : compound
: USEION ca READ cai VALENCE 2 : sth. like this may be needed for ions you have in your model
}
CONSTANT {
}
PARAMETER {
	kf_R1 = 599.929 (liter/millimole-second): a kinetic parameter
	kr_R1 = 0.5 (/second): a kinetic parameter
	kf_R2 = 7.99982 (liter/millimole-second): a kinetic parameter
	kr_R2 = 8.63475 (/second): a kinetic parameter
	kf_R3 = 1.27049 (/second): a kinetic parameter
	kr_R3 = 3.5026 (/second): a kinetic parameter
	kf_R4 = 1 (/second): a kinetic parameter
	kr_R4 = 0.1 (/second): a kinetic parameter
	kf_R5 = 1.20001 (liter/millimole-second): a kinetic parameter
	kr_R5 = 0.1 (/second): a kinetic parameter
	kf_R6 = 2 (/second): a kinetic parameter
	kr_R6 = 0.2 (/second): a kinetic parameter
	kf_R7 = 1 (/second): a kinetic parameter
	kr_R7 = 50.0035 (/second): a kinetic parameter
	kf_R8 = 0.12 (liter/millimole-second): a kinetic parameter
	kr_R8 = 0.1 (/second): a kinetic parameter
	kf_R9 = 0.599998 (liter/millimole-second): a kinetic parameter
	kr_R9 = 0.1 (/second): a kinetic parameter
	kf_R10 = 18.0011 (liter/millimole-second): a kinetic parameter
	kr_R10 = 2 (/second): a kinetic parameter
	kf_R11 = 1000 (liter/millimole-second): a kinetic parameter
	kr_R11 = 0.1 (/second): a kinetic parameter
	kf_R12 = 2.99999 (liter/millimole-second): a kinetic parameter
	kr_R12 = 4 (/second): a kinetic parameter
	kf_R13 = 0.4 (/second): a kinetic parameter
	kf_R14 = 5999.29 (liter/millimole-second): a kinetic parameter
	kr_R14 = 0.1 (/second): a kinetic parameter
	kf_R15 = 0.17 (/second): a kinetic parameter
	kf_R16 = 2999.85 (liter/millimole-second): a kinetic parameter
	kr_R16 = 1 (/second): a kinetic parameter
	kf_R17 = 2.5 (/second): a kinetic parameter
	kf_R18 = 0.15 (/second): a kinetic parameter
	kf_R19 = 29998.5 (liter/millimole-second): a kinetic parameter
	kr_R19 = 1 (/second): a kinetic parameter
	kf_R20 = 10000 (liter/millimole-second): a kinetic parameter
	kr_R20 = 0.5 (/second): a kinetic parameter
	kf_R21 = 1 (/second): a kinetic parameter
	kf_R22 = 0.0001 (/second): a kinetic parameter
	kf_R23 = 0.1 (/second): a kinetic parameter
	kf_R24 = 1 (/second): a kinetic parameter
	kf_R25 = 4199.52 (liter/millimole-second): a kinetic parameter
	kr_R25 = 0.25 (/second): a kinetic parameter
	kf_R26 = 0.00199986 (/second): a kinetic parameter
	kr_R26 = 0.000329989 (/second): a kinetic parameter
	kf_R27 = 0.2 (/second): a kinetic parameter
	kf_R28 = 500.035 (liter/millimole-second): a kinetic parameter
	kr_R28 = 0.1 (/second): a kinetic parameter
	kf_R29 = 24.9977 (liter/millimole-second): a kinetic parameter
	kr_R29 = 0.0167996 (/second): a kinetic parameter
	kf_R30 = 0.001 (/second): a kinetic parameter
	kf_R31 = 24.9977 (liter/millimole-second): a kinetic parameter
	kr_R31 = 0.0167996 (/second): a kinetic parameter
	kf_R32 = 1000 (liter/millimole-second): a kinetic parameter
	kr_R32 = 1 (/second): a kinetic parameter
	kf_R33 = 180011 (liter/millimole-second): a kinetic parameter
	kr_R33 = 10 (/second): a kinetic parameter
	kf_R34 = 12000.5 (liter/millimole-second): a kinetic parameter
	kr_R34 = 10 (/second): a kinetic parameter
	kf_R35 = 0.0500035 (/second): a kinetic parameter
	kf_R36 = 0.0700003 (/second): a kinetic parameter
	kf_R37 = 949.73 (liter/millimole-second): a kinetic parameter
	kr_R37 = 15.9993 (/second): a kinetic parameter
	kf_R38 = 4 (/second): a kinetic parameter
	kf_R39 = 5657.18 (liter/millimole-second): a kinetic parameter
	kr_R39 = 15.9993 (/second): a kinetic parameter
	kf_R40 = 4 (/second): a kinetic parameter
	kf_R41 = 5657.18 (liter/millimole-second): a kinetic parameter
	kr_R41 = 15.9993 (/second): a kinetic parameter
	kf_R42 = 4 (/second): a kinetic parameter
	kf_R43 = 1272.62 (liter/millimole-second): a kinetic parameter
	kr_R43 = 21.6023 (/second): a kinetic parameter
	kf_R44 = 5.39995 (/second): a kinetic parameter
	kf_R45 = 2601.96 (liter/millimole-second): a kinetic parameter
	kr_R45 = 44.157 (/second): a kinetic parameter
	kf_R46 = 11.0408 (/second): a kinetic parameter
	kf_R47 = 8483.99 (liter/millimole-second): a kinetic parameter
	kr_R47 = 144.012 (/second): a kinetic parameter
	kf_R48 = 35.9998 (/second): a kinetic parameter
	kf_R49 = 14141.6 (liter/millimole-second): a kinetic parameter
	kr_R49 = 239.994 (/second): a kinetic parameter
	kf_R50 = 60.0067 (/second): a kinetic parameter
	kf_R51 = 28281.3 (liter/millimole-second): a kinetic parameter
	kr_R51 = 479.954 (/second): a kinetic parameter
	kf_R52 = 120.005 (/second): a kinetic parameter
	kf_R53 = 2375.75 (liter/millimole-second): a kinetic parameter
	kr_R53 = 40.0037 (/second): a kinetic parameter
	kf_R54 = 10 (/second): a kinetic parameter
	kf_R55 = 45248.1 (liter/millimole-second): a kinetic parameter
	kr_R55 = 191.999 (/second): a kinetic parameter
	kf_R56 = 47.9954 (/second): a kinetic parameter
	kf_R57 = 3677.05 (liter/millimole-second): a kinetic parameter
	kr_R57 = 80.0018 (/second): a kinetic parameter
	kf_R58 = 19.9986 (/second): a kinetic parameter
	kf_R59 = 1838.23 (liter/millimole-second): a kinetic parameter
	kr_R59 = 40.0037 (/second): a kinetic parameter
	kf_R60 = 10 (/second): a kinetic parameter
	kf_R61 = 18382.3 (liter/millimole-second): a kinetic parameter
	kr_R61 = 40.0037 (/second): a kinetic parameter
	kf_R62 = 10 (/second): a kinetic parameter
	kf_R63 = 15272.1 (liter/millimole-second): a kinetic parameter
	kr_R63 = 0.599998 (/second): a kinetic parameter
	kf_R64 = 0.15 (/second): a kinetic parameter
	kf_R65 = 15272.1 (liter/millimole-second): a kinetic parameter
	kr_R65 = 0.599998 (/second): a kinetic parameter
	kf_R66 = 0.15 (/second): a kinetic parameter
	kf_R67 = 8887.92 (liter/millimole-second): a kinetic parameter
	kr_R67 = 1.2 (/second): a kinetic parameter
	kf_R68 = 0.299999 (/second): a kinetic parameter
	kf_R69 = 8887.92 (liter/millimole-second): a kinetic parameter
	kr_R69 = 1.2 (/second): a kinetic parameter
	kf_R70 = 0.299999 (/second): a kinetic parameter
	kf_R71 = 9.47196 (liter/millimole-second): a kinetic parameter
	kr_R71 = 0.0800018 (/second): a kinetic parameter
	kf_R72 = 0.0199986 (/second): a kinetic parameter
	kf_R73 = 186.681 (liter/millimole-second): a kinetic parameter
	kr_R73 = 0.0800018 (/second): a kinetic parameter
	kf_R74 = 0.0199986 (/second): a kinetic parameter
	kf_R75 = 46655.2 (liter/millimole-second): a kinetic parameter
	kr_R75 = 40.0037 (/second): a kinetic parameter
	kf_R76 = 10 (/second): a kinetic parameter
	kf_R77 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R77 = 0.8 (/second): a kinetic parameter
	kf_R78 = 0.2 (/second): a kinetic parameter
	kf_R79 = 2828.13 (liter/millimole-second): a kinetic parameter
	kr_R79 = 0.8 (/second): a kinetic parameter
	kf_R80 = 0.2 (/second): a kinetic parameter
	kf_R81 = 1131.36 (liter/millimole-second): a kinetic parameter
	kr_R81 = 0.8 (/second): a kinetic parameter
	kf_R82 = 0.2 (/second): a kinetic parameter
	kf_R83 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R83 = 0.8 (/second): a kinetic parameter
	kf_R84 = 0.2 (/second): a kinetic parameter
	kf_R85 = 0.0972299 (/second): a kinetic parameter
	kr_R85 = 13.9991 (millimole/liter): a kinetic parameter
	kf_R86 = 0.0197925 (/second): a kinetic parameter
	kr_R86 = 57.0033 (millimole/liter): a kinetic parameter
	kf_R87 = 7972.6 (liter/millimole-second): a kinetic parameter
	kr_R87 = 2 (/second): a kinetic parameter
	kf_R88 = 0.5 (/second): a kinetic parameter
	kf_R89 = 2714.56 (liter/millimole-second): a kinetic parameter
	kr_R89 = 15.9993 (/second): a kinetic parameter
	kf_R90 = 4 (/second): a kinetic parameter
	kf_R91 = 2714.56 (liter/millimole-second): a kinetic parameter
	kr_R91 = 15.9993 (/second): a kinetic parameter
	kf_R92 = 4 (/second): a kinetic parameter
	kf_R93 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R93 = 24.9977 (/second): a kinetic parameter
	kf_R94 = 5.99998 (/second): a kinetic parameter
	kf_R95 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R95 = 24.9977 (/second): a kinetic parameter
	kf_R96 = 5.99998 (/second): a kinetic parameter
	kf_R97 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R97 = 24.9977 (/second): a kinetic parameter
	kf_R98 = 5.99998 (/second): a kinetic parameter
	kf_R99 = 1866.81 (liter/millimole-second): a kinetic parameter
	kr_R99 = 24.9977 (/second): a kinetic parameter
	kf_R100 = 5.99998 (/second): a kinetic parameter
	kf_R101 = 1806.34 (liter/millimole-second): a kinetic parameter
	kr_R101 = 23.9994 (/second): a kinetic parameter
	kf_R102 = 5.99998 (/second): a kinetic parameter
	PPhosphatase2A_ConservedConst = 0.00026001 : the total amount of a conserved sub-set of states
	MKP_1_ConservedConst = 2e-05 : the total amount of a conserved sub-set of states
	PLCg_basal_ConservedConst = 7.0002e-07 : the total amount of a conserved sub-set of states
	PLC_g_ConservedConst = 0.00082001 : the total amount of a conserved sub-set of states
	Grb2_ConservedConst = 0.0009 : the total amount of a conserved sub-set of states
	SHC_ConservedConst = 0.00040001 : the total amount of a conserved sub-set of states
	Sos_ConservedConst = 0.0001 : the total amount of a conserved sub-set of states
	EGFR_ConservedConst = 0.00016666 : the total amount of a conserved sub-set of states
	CaM_GEF_ConservedConst = 0 : the total amount of a conserved sub-set of states
	GAP_ConservedConst = 2e-05 : the total amount of a conserved sub-set of states
	inact_GEF_ConservedConst = 0.0001 : the total amount of a conserved sub-set of states
	GDP_Ras_ConservedConst = 0.0005 : the total amount of a conserved sub-set of states
	MAPKK_ConservedConst = 0.00018001 : the total amount of a conserved sub-set of states
	craf_1_ConservedConst = -0.0003 : the total amount of a conserved sub-set of states
	MAPK_ConservedConst = 0.00036 : the total amount of a conserved sub-set of states
	PLC_Ca_Gq_ConservedConst = 0 : the total amount of a conserved sub-set of states
	PLC_ConservedConst = 0.0008 : the total amount of a conserved sub-set of states
	PIP2_Ca_PLA2_p_ConservedConst = 0 : the total amount of a conserved sub-set of states
	PIP2_PLA2_p_ConservedConst = 0 : the total amount of a conserved sub-set of states
	PLA2_cytosolic_ConservedConst = 0.0004 : the total amount of a conserved sub-set of states
	PKC_cytosolic_ConservedConst = 0.00102 : the total amount of a conserved sub-set of states
}
ASSIGNED {
	time (millisecond) : alias for t
	PKC_active : a pre-defined algebraic expression
	PKC_active1 : a pre-defined algebraic expression
	APC : a pre-defined algebraic expression
	Inositol : a pre-defined algebraic expression
	PC : a pre-defined algebraic expression
	PIP2 : a pre-defined algebraic expression
	EGF : a pre-defined algebraic expression
	Ca : a pre-defined algebraic expression
	ReactionFlux0 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux1 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux2 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux3 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux4 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux5 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux6 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux7 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux8 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux9 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux10 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux11 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux12 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux13 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux14 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux15 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux16 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux17 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux18 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux19 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux20 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux21 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux22 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux23 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux24 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux25 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux26 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux27 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux28 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux29 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux30 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux31 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux32 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux33 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux34 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux35 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux36 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux37 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux38 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux39 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux40 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux41 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux42 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux43 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux44 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux45 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux46 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux47 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux48 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux49 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux50 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux51 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux52 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux53 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux54 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux55 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux56 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux57 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux58 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux59 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux60 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux61 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux62 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux63 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux64 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux65 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux66 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux67 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux68 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux69 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux70 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux71 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux72 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux73 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux74 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux75 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux76 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux77 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux78 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux79 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux80 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux81 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux82 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux83 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux84 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux85 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux86 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux87 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux88 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux89 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux90 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux91 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux92 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux93 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux94 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux95 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux96 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux97 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux98 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux99 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux100 : a flux, for use in DERIVATIVE mechanism
	ReactionFlux101 : a flux, for use in DERIVATIVE mechanism
	PPhosphatase2A : computed from conservation law
	MKP_1 : computed from conservation law
	PLCg_basal : computed from conservation law
	PLC_g : computed from conservation law
	Grb2 : computed from conservation law
	SHC : computed from conservation law
	Sos : computed from conservation law
	EGFR : computed from conservation law
	CaM_GEF : computed from conservation law
	GAP : computed from conservation law
	inact_GEF : computed from conservation law
	GDP_Ras : computed from conservation law
	MAPKK : computed from conservation law
	craf_1 : computed from conservation law
	MAPK : computed from conservation law
	PLC_Ca_Gq : computed from conservation law
	PLC : computed from conservation law
	PIP2_Ca_PLA2_p : computed from conservation law
	PIP2_PLA2_p : computed from conservation law
	PLA2_cytosolic : computed from conservation law
	PKC_cytosolic : computed from conservation law
	pERK1_2_ratio1 : an observable
	MAPK_out : an observable
	MAPK_p_out : an observable
	MAPK_p_p_out : an observable
	MAPK_p_p_cplx_out : an observable
	MAPK_p_p_feedback_cplx_out : an observable
	pERK1_2_ratio2 : an observable
}
PROCEDURE assign_calculated_values() {
	time = t : an alias for the time variable, if needed.
	PPhosphatase2A = PPhosphatase2A_ConservedConst - (craf_dephospho_cplx+MAPKK_dephospho_cplx+MAPKK_dephospho_ser_cplx+craf_p_p_dephospho_cplx+deph_raf_ser259_cplx) : conservation law
	MKP_1 = MKP_1_ConservedConst - (MKP1_tyr_deph_cplx+MKP1_thr_deph_cplx) : conservation law
	PLCg_basal = PLCg_basal_ConservedConst - (PLC_g_phospho_cplx) : conservation law
	PLC_g = PLC_g_ConservedConst - (PLC_g_p+Ca_PLC_g+Ca_PLC_g_p+Ca_PLC_g_phospho_cplx+PLC_g_phospho_cplx) : conservation law
	Grb2 = Grb2_ConservedConst - (SHC_p_Grb2_clx-Sos_p-Sos-phosph_Sos_cplx) : conservation law
	SHC = SHC_ConservedConst - (SHC_p+SHC_p_Grb2_clx+SHC_phospho_cplx-Sos_p_Grb2-Sos_Grb2-Sos_p-Sos-phosph_Sos_cplx) : conservation law
	Sos = Sos_ConservedConst - (SHC_p_Sos_Grb2+Sos_p_Grb2+Sos_Grb2+Sos_p+phosph_Sos_cplx+Sos_Ras_GEF_cplx) : conservation law
	EGFR = EGFR_ConservedConst - (L_EGFR+Internal_L_EGFR+Ca_PLC_g_phospho_cplx+SHC_phospho_cplx) : conservation law
	CaM_GEF = CaM_GEF_ConservedConst - (CaM_GEF_act_Ras_cplx) : conservation law
	GAP = GAP_ConservedConst - (GAP_p+PKC_inact_GAP_cplx+GAP_inact_Ras_cplx) : conservation law
	inact_GEF = inact_GEF_ConservedConst - (GEF_p+inact_GEF_p+PKC_act_GEF_cplx+basal_GEF_activity_cplx+GEF_p_act_Ras_cplx) : conservation law
	GDP_Ras = GDP_Ras_ConservedConst - (Raf_p_GTP_Ras+GTP_Ras+Raf_p_GTP_Ras_1_cplx+Raf_p_GTP_Ras_2_cplx+basal_GEF_activity_cplx+GEF_p_act_Ras_cplx+GAP_inact_Ras_cplx+CaM_GEF_act_Ras_cplx+Sos_Ras_GEF_cplx) : conservation law
	MAPKK = MAPKK_ConservedConst - (MAPKK_p_p+MAPKK_p+MAPKKtyr_cplx+MAPKKthr_cplx+Raf_p_GTP_Ras_1_cplx+Raf_p_GTP_Ras_2_cplx+MAPKK_dephospho_cplx+MAPKK_dephospho_ser_cplx) : conservation law
	craf_1 = craf_1_ConservedConst - (craf_1_p+craf_1_p_p+craf_1_p_ser259+PKC_act_raf_cplx+MAPK_p_p_feedback_cplx+craf_dephospho_cplx+craf_p_p_dephospho_cplx+deph_raf_ser259_cplx-GTP_Ras-GDP_Ras-basal_GEF_activity_cplx-GEF_p_act_Ras_cplx-GAP_inact_Ras_cplx-CaM_GEF_act_Ras_cplx-Sos_Ras_GEF_cplx) : conservation law
	MAPK = MAPK_ConservedConst - (MAPK_p_p+MAPK_p+MAPK_p_p_cplx+MAPK_p_p_feedback_cplx+phosph_Sos_cplx+MAPKKtyr_cplx+MAPKKthr_cplx+MKP1_tyr_deph_cplx+MKP1_thr_deph_cplx) : conservation law
	PLC_Ca_Gq = PLC_Ca_Gq_ConservedConst - (PLC_Gq+PLCb_Ca_Gq_cplx) : conservation law
	PLC = PLC_ConservedConst - (PLC_Ca+PLC_Ca_cplx) : conservation law
	PIP2_Ca_PLA2_p = PIP2_Ca_PLA2_p_ConservedConst - (kenz_cplx_2) : conservation law
	PIP2_PLA2_p = PIP2_PLA2_p_ConservedConst - (kenz_cplx_1) : conservation law
	PLA2_cytosolic = PLA2_cytosolic_ConservedConst - (PLA2_Ca_p+DAG_Ca_PLA2_p+PLA2_p_Ca+PLA2_p+kenz_cplx+kenz_cplx_3+kenz_cplx_4+MAPK_p_p_cplx) : conservation law
	PKC_cytosolic = PKC_cytosolic_ConservedConst - (PKC_Ca+PKC_DAG_AA_p+PKC_Ca_AA_p+PKC_Ca_memb_p+PKC_DAG_memb_p+PKC_basal_p+PKC_AA_p+PKC_Ca_DAG+PKC_DAG+PKC_DAG_AA) : conservation law
	PKC_active = PKC_DAG_AA_p+PKC_Ca_memb_p+PKC_Ca_AA_p+PKC_DAG_memb_p+PKC_basal_p+PKC_AA_p : assignment for expression Ex0
	PKC_active1 = 0 : assignment for expression S11
	APC = 0.030001 : assignment for expression S17
	Inositol = 0 : assignment for expression S22
	PC = 0 : assignment for expression S26
	PIP2 = 0.007 : assignment for expression S29
	EGF = 0 : assignment for expression S51
	Ca = 8e-05 : assignment for expression S69
	ReactionFlux0 = kf_R1 * Ca * PKC_cytosolic-kr_R1 * PKC_Ca : flux expression R0
	ReactionFlux1 = kf_R2 * DAG * PKC_Ca-kr_R2 * PKC_Ca_DAG : flux expression R1
	ReactionFlux2 = kf_R3 * PKC_Ca-kr_R3 * PKC_Ca_memb_p : flux expression R2
	ReactionFlux3 = kf_R4 * PKC_Ca_DAG-kr_R4 * PKC_DAG_memb_p : flux expression R3
	ReactionFlux4 = kf_R5 * Arachidonic_Acid * PKC_Ca-kr_R5 * PKC_Ca_AA_p : flux expression R4
	ReactionFlux5 = kf_R6 * PKC_DAG_AA-kr_R6 * PKC_DAG_AA_p : flux expression R5
	ReactionFlux6 = kf_R7 * PKC_cytosolic-kr_R7 * PKC_basal_p : flux expression R6
	ReactionFlux7 = kf_R8 * PKC_cytosolic * Arachidonic_Acid-kr_R8 * PKC_AA_p : flux expression R7
	ReactionFlux8 = kf_R9 * PKC_cytosolic * DAG-kr_R9 * PKC_DAG : flux expression R8
	ReactionFlux9 = kf_R10 * Arachidonic_Acid * PKC_DAG-kr_R10 * PKC_DAG_AA : flux expression R9
	ReactionFlux10 = kf_R11 * Ca * PLA2_cytosolic-kr_R11 * PLA2_Ca_p : flux expression R10
	ReactionFlux11 = kf_R12 * PLA2_Ca_p * DAG-kr_R12 * DAG_Ca_PLA2_p : flux expression R11
	ReactionFlux12 = kf_R13 * Arachidonic_Acid : flux expression R12
	ReactionFlux13 = kf_R14 * Ca * PLA2_p-kr_R14 * PLA2_p_Ca : flux expression R13
	ReactionFlux14 = kf_R15 * PLA2_p : flux expression R14
	ReactionFlux15 = kf_R16 * PLC * Ca-kr_R16 * PLC_Ca : flux expression R15
	ReactionFlux16 = kf_R17 * IP3 : flux expression R16
	ReactionFlux17 = kf_R18 * DAG : flux expression R17
	ReactionFlux18 = kf_R19 * PLC_Gq * Ca-kr_R19 * PLC_Ca_Gq : flux expression R18
	ReactionFlux19 = kf_R20 * GTP_Ras * craf_1_p-kr_R20 * Raf_p_GTP_Ras : flux expression R19
	ReactionFlux20 = kf_R21 * GEF_p : flux expression R20
	ReactionFlux21 = kf_R22 * GTP_Ras : flux expression R21
	ReactionFlux22 = kf_R23 * GAP_p : flux expression R22
	ReactionFlux23 = kf_R24 * inact_GEF_p : flux expression R23
	ReactionFlux24 = kf_R25 * EGFR * EGF-kr_R25 * L_EGFR : flux expression R24
	ReactionFlux25 = kf_R26 * L_EGFR-kr_R26 * Internal_L_EGFR : flux expression R25
	ReactionFlux26 = kf_R27 * SHC_p : flux expression R26
	ReactionFlux27 = kf_R28 * Sos_Grb2 * SHC_p-kr_R28 * SHC_p_Sos_Grb2 : flux expression R27
	ReactionFlux28 = kf_R29 * Grb2 * Sos_p-kr_R29 * Sos_p_Grb2 : flux expression R28
	ReactionFlux29 = kf_R30 * Sos_p : flux expression R29
	ReactionFlux30 = kf_R31 * Grb2 * Sos-kr_R31 * Sos_Grb2 : flux expression R30
	ReactionFlux31 = kf_R32 * Grb2 * SHC_p-kr_R32 * SHC_p_Grb2_clx : flux expression R31
	ReactionFlux32 = kf_R33 * Ca * PLC_g-kr_R33 * Ca_PLC_g : flux expression R32
	ReactionFlux33 = kf_R34 * Ca * PLC_g_p-kr_R34 * Ca_PLC_g_p : flux expression R33
	ReactionFlux34 = kf_R35 * Ca_PLC_g_p : flux expression R34
	ReactionFlux35 = kf_R36 * PLC_g_p : flux expression R35
	ReactionFlux36 = kf_R37 * craf_1 * PKC_active-kr_R37 * PKC_act_raf_cplx : flux expression R36
	ReactionFlux37 = kf_R38 * PKC_act_raf_cplx : flux expression R37
	ReactionFlux38 = kf_R39 * GAP * PKC_active-kr_R39 * PKC_inact_GAP_cplx : flux expression R38
	ReactionFlux39 = kf_R40 * PKC_inact_GAP_cplx : flux expression R39
	ReactionFlux40 = kf_R41 * inact_GEF * PKC_active-kr_R41 * PKC_act_GEF_cplx : flux expression R40
	ReactionFlux41 = kf_R42 * PKC_act_GEF_cplx : flux expression R41
	ReactionFlux42 = kf_R43 * PLA2_Ca_p * APC-kr_R43 * kenz_cplx : flux expression R42
	ReactionFlux43 = kf_R44 * kenz_cplx : flux expression R43
	ReactionFlux44 = kf_R45 * APC * PIP2_PLA2_p-kr_R45 * kenz_cplx_1 : flux expression R44
	ReactionFlux45 = kf_R46 * kenz_cplx_1 : flux expression R45
	ReactionFlux46 = kf_R47 * APC * PIP2_Ca_PLA2_p-kr_R47 * kenz_cplx_2 : flux expression R46
	ReactionFlux47 = kf_R48 * kenz_cplx_2 : flux expression R47
	ReactionFlux48 = kf_R49 * APC * DAG_Ca_PLA2_p-kr_R49 * kenz_cplx_3 : flux expression R48
	ReactionFlux49 = kf_R50 * kenz_cplx_3 : flux expression R49
	ReactionFlux50 = kf_R51 * APC * PLA2_p_Ca-kr_R51 * kenz_cplx_4 : flux expression R50
	ReactionFlux51 = kf_R52 * kenz_cplx_4 : flux expression R51
	ReactionFlux52 = kf_R53 * PIP2 * PLC_Ca-kr_R53 * PLC_Ca_cplx : flux expression R52
	ReactionFlux53 = kf_R54 * PLC_Ca_cplx : flux expression R53
	ReactionFlux54 = kf_R55 * PIP2 * PLC_Ca_Gq-kr_R55 * PLCb_Ca_Gq_cplx : flux expression R54
	ReactionFlux55 = kf_R56 * PLCb_Ca_Gq_cplx : flux expression R55
	ReactionFlux56 = kf_R57 * MAPK_p_p * PLA2_cytosolic-kr_R57 * MAPK_p_p_cplx : flux expression R56
	ReactionFlux57 = kf_R58 * MAPK_p_p_cplx : flux expression R57
	ReactionFlux58 = kf_R59 * MAPK_p_p * craf_1_p-kr_R59 * MAPK_p_p_feedback_cplx : flux expression R58
	ReactionFlux59 = kf_R60 * MAPK_p_p_feedback_cplx : flux expression R59
	ReactionFlux60 = kf_R61 * MAPK_p_p * Sos-kr_R61 * phosph_Sos_cplx : flux expression R60
	ReactionFlux61 = kf_R62 * phosph_Sos_cplx : flux expression R61
	ReactionFlux62 = kf_R63 * MAPKK_p_p * MAPK-kr_R63 * MAPKKtyr_cplx : flux expression R62
	ReactionFlux63 = kf_R64 * MAPKKtyr_cplx : flux expression R63
	ReactionFlux64 = kf_R65 * MAPKK_p_p * MAPK_p-kr_R65 * MAPKKthr_cplx : flux expression R64
	ReactionFlux65 = kf_R66 * MAPKKthr_cplx : flux expression R65
	ReactionFlux66 = kf_R67 * MAPKK * Raf_p_GTP_Ras-kr_R67 * Raf_p_GTP_Ras_1_cplx : flux expression R66
	ReactionFlux67 = kf_R68 * Raf_p_GTP_Ras_1_cplx : flux expression R67
	ReactionFlux68 = kf_R69 * MAPKK_p * Raf_p_GTP_Ras-kr_R69 * Raf_p_GTP_Ras_2_cplx : flux expression R68
	ReactionFlux69 = kf_R70 * Raf_p_GTP_Ras_2_cplx : flux expression R69
	ReactionFlux70 = kf_R71 * inact_GEF * GDP_Ras-kr_R71 * basal_GEF_activity_cplx : flux expression R70
	ReactionFlux71 = kf_R72 * basal_GEF_activity_cplx : flux expression R71
	ReactionFlux72 = kf_R73 * GEF_p * GDP_Ras-kr_R73 * GEF_p_act_Ras_cplx : flux expression R72
	ReactionFlux73 = kf_R74 * GEF_p_act_Ras_cplx : flux expression R73
	ReactionFlux74 = kf_R75 * GAP * GTP_Ras-kr_R75 * GAP_inact_Ras_cplx : flux expression R74
	ReactionFlux75 = kf_R76 * GAP_inact_Ras_cplx : flux expression R75
	ReactionFlux76 = kf_R77 * GDP_Ras * CaM_GEF-kr_R77 * CaM_GEF_act_Ras_cplx : flux expression R76
	ReactionFlux77 = kf_R78 * CaM_GEF_act_Ras_cplx : flux expression R77
	ReactionFlux78 = kf_R79 * L_EGFR * Ca_PLC_g-kr_R79 * Ca_PLC_g_phospho_cplx : flux expression R78
	ReactionFlux79 = kf_R80 * Ca_PLC_g_phospho_cplx : flux expression R79
	ReactionFlux80 = kf_R81 * L_EGFR * SHC-kr_R81 * SHC_phospho_cplx : flux expression R80
	ReactionFlux81 = kf_R82 * SHC_phospho_cplx : flux expression R81
	ReactionFlux82 = kf_R83 * SHC_p_Sos_Grb2 * GDP_Ras-kr_R83 * Sos_Ras_GEF_cplx : flux expression R82
	ReactionFlux83 = kf_R84 * Sos_Ras_GEF_cplx : flux expression R83
	ReactionFlux84 = (kf_R85*PIP2*Ca_PLC_g/(kr_R85+PIP2)) : flux expression R84
	ReactionFlux85 = (kf_R86*PIP2*Ca_PLC_g_p/(kr_R86+PIP2)) : flux expression R85
	ReactionFlux86 = kf_R87 * PLCg_basal * PLC_g-kr_R87 * PLC_g_phospho_cplx : flux expression R86
	ReactionFlux87 = kf_R88 * PLC_g_phospho_cplx : flux expression R87
	ReactionFlux88 = kf_R89 * MKP_1 * MAPK_p-kr_R89 * MKP1_tyr_deph_cplx : flux expression R88
	ReactionFlux89 = kf_R90 * MKP1_tyr_deph_cplx : flux expression R89
	ReactionFlux90 = kf_R91 * MAPK_p_p * MKP_1-kr_R91 * MKP1_thr_deph_cplx : flux expression R90
	ReactionFlux91 = kf_R92 * MKP1_thr_deph_cplx : flux expression R91
	ReactionFlux92 = kf_R93 * craf_1_p * PPhosphatase2A-kr_R93 * craf_dephospho_cplx : flux expression R92
	ReactionFlux93 = kf_R94 * craf_dephospho_cplx : flux expression R93
	ReactionFlux94 = kf_R95 * MAPKK_p_p * PPhosphatase2A-kr_R95 * MAPKK_dephospho_cplx : flux expression R94
	ReactionFlux95 = kf_R96 * MAPKK_dephospho_cplx : flux expression R95
	ReactionFlux96 = kf_R97 * MAPKK_p * PPhosphatase2A-kr_R97 * MAPKK_dephospho_ser_cplx : flux expression R96
	ReactionFlux97 = kf_R98 * MAPKK_dephospho_ser_cplx : flux expression R97
	ReactionFlux98 = kf_R99 * craf_1_p_p * PPhosphatase2A-kr_R99 * craf_p_p_dephospho_cplx : flux expression R98
	ReactionFlux99 = kf_R100 * craf_p_p_dephospho_cplx : flux expression R99
	ReactionFlux100 = kf_R101 * craf_1_p_ser259 * PPhosphatase2A-kr_R101 * deph_raf_ser259_cplx : flux expression R100
	ReactionFlux101 = kf_R102 * deph_raf_ser259_cplx : flux expression R101
}
STATE {
	PKC_Ca (millimole/litre) : a state variable
	PKC_DAG_AA_p (millimole/litre) : a state variable
	PKC_Ca_AA_p (millimole/litre) : a state variable
	PKC_Ca_memb_p (millimole/litre) : a state variable
	PKC_DAG_memb_p (millimole/litre) : a state variable
	PKC_basal_p (millimole/litre) : a state variable
	PKC_AA_p (millimole/litre) : a state variable
	PKC_Ca_DAG (millimole/litre) : a state variable
	PKC_DAG (millimole/litre) : a state variable
	PKC_DAG_AA (millimole/litre) : a state variable
	: PKC_cytosolic is calculated via Conservation Law
	: PLA2_cytosolic is calculated via Conservation Law
	PLA2_Ca_p (millimole/litre) : a state variable
	: PIP2_PLA2_p is calculated via Conservation Law
	: PIP2_Ca_PLA2_p is calculated via Conservation Law
	DAG_Ca_PLA2_p (millimole/litre) : a state variable
	PLA2_p_Ca (millimole/litre) : a state variable
	PLA2_p (millimole/litre) : a state variable
	Arachidonic_Acid (millimole/litre) : a state variable
	: PLC is calculated via Conservation Law
	PLC_Ca (millimole/litre) : a state variable
	: PLC_Ca_Gq is calculated via Conservation Law
	PLC_Gq (millimole/litre) : a state variable
	DAG (millimole/litre) : a state variable
	IP3 (millimole/litre) : a state variable
	MAPK_p_p (millimole/litre) : a state variable
	: craf_1 is calculated via Conservation Law
	craf_1_p (millimole/litre) : a state variable
	: MAPKK is calculated via Conservation Law
	: MAPK is calculated via Conservation Law
	craf_1_p_p (millimole/litre) : a state variable
	MAPK_p (millimole/litre) : a state variable
	MAPKK_p_p (millimole/litre) : a state variable
	MAPKK_p (millimole/litre) : a state variable
	Raf_p_GTP_Ras (millimole/litre) : a state variable
	craf_1_p_ser259 (millimole/litre) : a state variable
	: inact_GEF is calculated via Conservation Law
	GEF_p (millimole/litre) : a state variable
	GTP_Ras (millimole/litre) : a state variable
	: GDP_Ras is calculated via Conservation Law
	GAP_p (millimole/litre) : a state variable
	: GAP is calculated via Conservation Law
	inact_GEF_p (millimole/litre) : a state variable
	: CaM_GEF is calculated via Conservation Law
	: EGFR is calculated via Conservation Law
	L_EGFR (millimole/litre) : a state variable
	Internal_L_EGFR (millimole/litre) : a state variable
	SHC_p_Sos_Grb2 (millimole/litre) : a state variable
	: SHC is calculated via Conservation Law
	SHC_p (millimole/litre) : a state variable
	Sos_p_Grb2 (millimole/litre) : a state variable
	: Grb2 is calculated via Conservation Law
	Sos_Grb2 (millimole/litre) : a state variable
	Sos_p (millimole/litre) : a state variable
	: Sos is calculated via Conservation Law
	SHC_p_Grb2_clx (millimole/litre) : a state variable
	: PLC_g is calculated via Conservation Law
	PLC_g_p (millimole/litre) : a state variable
	Ca_PLC_g (millimole/litre) : a state variable
	Ca_PLC_g_p (millimole/litre) : a state variable
	: PLCg_basal is calculated via Conservation Law
	: MKP_1 is calculated via Conservation Law
	: PPhosphatase2A is calculated via Conservation Law
	PKC_act_raf_cplx (millimole/litre) : a state variable
	PKC_inact_GAP_cplx (millimole/litre) : a state variable
	PKC_act_GEF_cplx (millimole/litre) : a state variable
	kenz_cplx (millimole/litre) : a state variable
	kenz_cplx_1 (millimole/litre) : a state variable
	kenz_cplx_2 (millimole/litre) : a state variable
	kenz_cplx_3 (millimole/litre) : a state variable
	kenz_cplx_4 (millimole/litre) : a state variable
	PLC_Ca_cplx (millimole/litre) : a state variable
	PLCb_Ca_Gq_cplx (millimole/litre) : a state variable
	MAPK_p_p_cplx (millimole/litre) : a state variable
	MAPK_p_p_feedback_cplx (millimole/litre) : a state variable
	phosph_Sos_cplx (millimole/litre) : a state variable
	MAPKKtyr_cplx (millimole/litre) : a state variable
	MAPKKthr_cplx (millimole/litre) : a state variable
	Raf_p_GTP_Ras_1_cplx (millimole/litre) : a state variable
	Raf_p_GTP_Ras_2_cplx (millimole/litre) : a state variable
	basal_GEF_activity_cplx (millimole/litre) : a state variable
	GEF_p_act_Ras_cplx (millimole/litre) : a state variable
	GAP_inact_Ras_cplx (millimole/litre) : a state variable
	CaM_GEF_act_Ras_cplx (millimole/litre) : a state variable
	Ca_PLC_g_phospho_cplx (millimole/litre) : a state variable
	SHC_phospho_cplx (millimole/litre) : a state variable
	Sos_Ras_GEF_cplx (millimole/litre) : a state variable
	PLC_g_phospho_cplx (millimole/litre) : a state variable
	MKP1_tyr_deph_cplx (millimole/litre) : a state variable
	MKP1_thr_deph_cplx (millimole/litre) : a state variable
	craf_dephospho_cplx (millimole/litre) : a state variable
	MAPKK_dephospho_cplx (millimole/litre) : a state variable
	MAPKK_dephospho_ser_cplx (millimole/litre) : a state variable
	craf_p_p_dephospho_cplx (millimole/litre) : a state variable
	deph_raf_ser259_cplx (millimole/litre) : a state variable
}
INITIAL {
	 PKC_Ca = 0 : initial condition
	 PKC_DAG_AA_p = 0 : initial condition
	 PKC_Ca_AA_p = 0 : initial condition
	 PKC_Ca_memb_p = 0 : initial condition
	 PKC_DAG_memb_p = 0 : initial condition
	 PKC_basal_p = 2e-05 : initial condition
	 PKC_AA_p = 0 : initial condition
	 PKC_Ca_DAG = 0 : initial condition
	 PKC_DAG = 0 : initial condition
	 PKC_DAG_AA = 0 : initial condition
	: PKC_cytosolic cannot have initial values as it is determined by conservation law
	: PLA2_cytosolic cannot have initial values as it is determined by conservation law
	 PLA2_Ca_p = 0 : initial condition
	: PIP2_PLA2_p cannot have initial values as it is determined by conservation law
	: PIP2_Ca_PLA2_p cannot have initial values as it is determined by conservation law
	 DAG_Ca_PLA2_p = 0 : initial condition
	 PLA2_p_Ca = 0 : initial condition
	 PLA2_p = 0 : initial condition
	 Arachidonic_Acid = 0 : initial condition
	: PLC cannot have initial values as it is determined by conservation law
	 PLC_Ca = 0 : initial condition
	: PLC_Ca_Gq cannot have initial values as it is determined by conservation law
	 PLC_Gq = 0 : initial condition
	 DAG = 0 : initial condition
	 IP3 = 0.00073 : initial condition
	 MAPK_p_p = 0 : initial condition
	: craf_1 cannot have initial values as it is determined by conservation law
	 craf_1_p = 0 : initial condition
	: MAPKK cannot have initial values as it is determined by conservation law
	: MAPK cannot have initial values as it is determined by conservation law
	 craf_1_p_p = 0 : initial condition
	 MAPK_p = 0 : initial condition
	 MAPKK_p_p = 0 : initial condition
	 MAPKK_p = 0 : initial condition
	 Raf_p_GTP_Ras = 0 : initial condition
	 craf_1_p_ser259 = 0 : initial condition
	: inact_GEF cannot have initial values as it is determined by conservation law
	 GEF_p = 0 : initial condition
	 GTP_Ras = 0 : initial condition
	: GDP_Ras cannot have initial values as it is determined by conservation law
	 GAP_p = 0 : initial condition
	: GAP cannot have initial values as it is determined by conservation law
	 inact_GEF_p = 0 : initial condition
	: CaM_GEF cannot have initial values as it is determined by conservation law
	: EGFR cannot have initial values as it is determined by conservation law
	 L_EGFR = 0 : initial condition
	 Internal_L_EGFR = 0 : initial condition
	 SHC_p_Sos_Grb2 = 0 : initial condition
	: SHC cannot have initial values as it is determined by conservation law
	 SHC_p = 0 : initial condition
	 Sos_p_Grb2 = 0 : initial condition
	: Grb2 cannot have initial values as it is determined by conservation law
	 Sos_Grb2 = 0 : initial condition
	 Sos_p = 0 : initial condition
	: Sos cannot have initial values as it is determined by conservation law
	 SHC_p_Grb2_clx = 0 : initial condition
	: PLC_g cannot have initial values as it is determined by conservation law
	 PLC_g_p = 0 : initial condition
	 Ca_PLC_g = 0 : initial condition
	 Ca_PLC_g_p = 0 : initial condition
	: PLCg_basal cannot have initial values as it is determined by conservation law
	: MKP_1 cannot have initial values as it is determined by conservation law
	: PPhosphatase2A cannot have initial values as it is determined by conservation law
	 PKC_act_raf_cplx = 0 : initial condition
	 PKC_inact_GAP_cplx = 0 : initial condition
	 PKC_act_GEF_cplx = 0 : initial condition
	 kenz_cplx = 0 : initial condition
	 kenz_cplx_1 = 0 : initial condition
	 kenz_cplx_2 = 0 : initial condition
	 kenz_cplx_3 = 0 : initial condition
	 kenz_cplx_4 = 0 : initial condition
	 PLC_Ca_cplx = 0 : initial condition
	 PLCb_Ca_Gq_cplx = 0 : initial condition
	 MAPK_p_p_cplx = 0 : initial condition
	 MAPK_p_p_feedback_cplx = 0 : initial condition
	 phosph_Sos_cplx = 0 : initial condition
	 MAPKKtyr_cplx = 0 : initial condition
	 MAPKKthr_cplx = 0 : initial condition
	 Raf_p_GTP_Ras_1_cplx = 0 : initial condition
	 Raf_p_GTP_Ras_2_cplx = 0 : initial condition
	 basal_GEF_activity_cplx = 0 : initial condition
	 GEF_p_act_Ras_cplx = 0 : initial condition
	 GAP_inact_Ras_cplx = 0 : initial condition
	 CaM_GEF_act_Ras_cplx = 0 : initial condition
	 Ca_PLC_g_phospho_cplx = 0 : initial condition
	 SHC_phospho_cplx = 0 : initial condition
	 Sos_Ras_GEF_cplx = 0 : initial condition
	 PLC_g_phospho_cplx = 0 : initial condition
	 MKP1_tyr_deph_cplx = 0 : initial condition
	 MKP1_thr_deph_cplx = 0 : initial condition
	 craf_dephospho_cplx = 0 : initial condition
	 MAPKK_dephospho_cplx = 0 : initial condition
	 MAPKK_dephospho_ser_cplx = 0 : initial condition
	 craf_p_p_dephospho_cplx = 0 : initial condition
	 deph_raf_ser259_cplx = 0 : initial condition
}
BREAKPOINT {
	SOLVE ode METHOD cnexp
	assign_calculated_values() : procedure
}
DERIVATIVE ode {
	PKC_Ca' = ReactionFlux0-ReactionFlux1-ReactionFlux2-ReactionFlux4 : affects compound with ID S0
	PKC_DAG_AA_p' = ReactionFlux5 : affects compound with ID S1
	PKC_Ca_AA_p' = ReactionFlux4 : affects compound with ID S2
	PKC_Ca_memb_p' = ReactionFlux2 : affects compound with ID S3
	PKC_DAG_memb_p' = ReactionFlux3 : affects compound with ID S4
	PKC_basal_p' = ReactionFlux6 : affects compound with ID S5
	PKC_AA_p' = ReactionFlux7 : affects compound with ID S6
	PKC_Ca_DAG' = ReactionFlux1-ReactionFlux3 : affects compound with ID S7
	PKC_DAG' = ReactionFlux8-ReactionFlux9 : affects compound with ID S8
	PKC_DAG_AA' = -ReactionFlux5+ReactionFlux9 : affects compound with ID S9
	: Compound PKC_cytosolic with ID S10 and initial condition 0.001 had derivative -ReactionFlux0-ReactionFlux6-ReactionFlux7-ReactionFlux8, but is calculated by conservation law.
	: Compound PLA2_cytosolic with ID S12 and initial condition 0.0004 had derivative -ReactionFlux10+ReactionFlux14-ReactionFlux56, but is calculated by conservation law.
	PLA2_Ca_p' = ReactionFlux10-ReactionFlux11-ReactionFlux42+ReactionFlux43 : affects compound with ID S13
	: Compound PIP2_PLA2_p with ID S14 and initial condition 0 had derivative -ReactionFlux44+ReactionFlux45, but is calculated by conservation law.
	: Compound PIP2_Ca_PLA2_p with ID S15 and initial condition 0 had derivative -ReactionFlux46+ReactionFlux47, but is calculated by conservation law.
	DAG_Ca_PLA2_p' = ReactionFlux11-ReactionFlux48+ReactionFlux49 : affects compound with ID S16
	PLA2_p_Ca' = ReactionFlux13-ReactionFlux50+ReactionFlux51 : affects compound with ID S18
	PLA2_p' = -ReactionFlux13-ReactionFlux14+ReactionFlux57 : affects compound with ID S19
	Arachidonic_Acid' = -ReactionFlux4-ReactionFlux7-ReactionFlux9-ReactionFlux12+ReactionFlux43+ReactionFlux45+ReactionFlux47+ReactionFlux49+ReactionFlux51 : affects compound with ID S20
	: Compound PLC with ID S21 and initial condition 0.0008 had derivative -ReactionFlux15, but is calculated by conservation law.
	PLC_Ca' = ReactionFlux15-ReactionFlux52+ReactionFlux53 : affects compound with ID S23
	: Compound PLC_Ca_Gq with ID S24 and initial condition 0 had derivative +ReactionFlux18-ReactionFlux54+ReactionFlux55, but is calculated by conservation law.
	PLC_Gq' = -ReactionFlux18 : affects compound with ID S25
	DAG' = -ReactionFlux1-ReactionFlux8-ReactionFlux11-ReactionFlux17+ReactionFlux53+ReactionFlux55+ReactionFlux84+ReactionFlux85 : affects compound with ID S27
	IP3' = -ReactionFlux16+ReactionFlux53+ReactionFlux55+ReactionFlux84+ReactionFlux85 : affects compound with ID S28
	MAPK_p_p' = -ReactionFlux56+ReactionFlux57-ReactionFlux58+ReactionFlux59-ReactionFlux60+ReactionFlux61+ReactionFlux65-ReactionFlux90 : affects compound with ID S30
	: Compound craf_1 with ID S31 and initial condition 0.0002 had derivative -ReactionFlux36+ReactionFlux93+ReactionFlux101, but is calculated by conservation law.
	craf_1_p' = -ReactionFlux19+ReactionFlux37-ReactionFlux58-ReactionFlux92+ReactionFlux99 : affects compound with ID S32
	: Compound MAPKK with ID S33 and initial condition 0.00018001 had derivative -ReactionFlux66+ReactionFlux97, but is calculated by conservation law.
	: Compound MAPK with ID S34 and initial condition 0.00036 had derivative -ReactionFlux62+ReactionFlux89, but is calculated by conservation law.
	craf_1_p_p' = ReactionFlux59-ReactionFlux98 : affects compound with ID S35
	MAPK_p' = ReactionFlux63-ReactionFlux64-ReactionFlux88+ReactionFlux91 : affects compound with ID S36
	MAPKK_p_p' = -ReactionFlux62+ReactionFlux63-ReactionFlux64+ReactionFlux65+ReactionFlux69-ReactionFlux94 : affects compound with ID S37
	MAPKK_p' = ReactionFlux67-ReactionFlux68+ReactionFlux95-ReactionFlux96 : affects compound with ID S38
	Raf_p_GTP_Ras' = ReactionFlux19-ReactionFlux66+ReactionFlux67-ReactionFlux68+ReactionFlux69 : affects compound with ID S39
	craf_1_p_ser259' = -ReactionFlux100 : affects compound with ID S40
	: Compound inact_GEF with ID S41 and initial condition 0.0001 had derivative +ReactionFlux20+ReactionFlux23-ReactionFlux40-ReactionFlux70+ReactionFlux71, but is calculated by conservation law.
	GEF_p' = -ReactionFlux20+ReactionFlux41-ReactionFlux72+ReactionFlux73 : affects compound with ID S42
	GTP_Ras' = -ReactionFlux19-ReactionFlux21+ReactionFlux71+ReactionFlux73-ReactionFlux74+ReactionFlux77+ReactionFlux83 : affects compound with ID S43
	: Compound GDP_Ras with ID S44 and initial condition 0.0005 had derivative +ReactionFlux21-ReactionFlux70-ReactionFlux72+ReactionFlux75-ReactionFlux76-ReactionFlux82, but is calculated by conservation law.
	GAP_p' = -ReactionFlux22+ReactionFlux39 : affects compound with ID S45
	: Compound GAP with ID S46 and initial condition 2e-05 had derivative +ReactionFlux22-ReactionFlux38-ReactionFlux74+ReactionFlux75, but is calculated by conservation law.
	inact_GEF_p' = -ReactionFlux23 : affects compound with ID S47
	: Compound CaM_GEF with ID S48 and initial condition 0 had derivative -ReactionFlux76+ReactionFlux77, but is calculated by conservation law.
	: Compound EGFR with ID S49 and initial condition 0.00016666 had derivative -ReactionFlux24, but is calculated by conservation law.
	L_EGFR' = ReactionFlux24-ReactionFlux25-ReactionFlux78+ReactionFlux79-ReactionFlux80+ReactionFlux81 : affects compound with ID S50
	Internal_L_EGFR' = ReactionFlux25 : affects compound with ID S52
	SHC_p_Sos_Grb2' = ReactionFlux27-ReactionFlux82+ReactionFlux83 : affects compound with ID S53
	: Compound SHC with ID S54 and initial condition 0.00050001 had derivative +ReactionFlux26-ReactionFlux80, but is calculated by conservation law.
	SHC_p' = -ReactionFlux26-ReactionFlux27-ReactionFlux31+ReactionFlux81 : affects compound with ID S55
	Sos_p_Grb2' = ReactionFlux28 : affects compound with ID S56
	: Compound Grb2 with ID S57 and initial condition 0.001 had derivative -ReactionFlux28-ReactionFlux30-ReactionFlux31, but is calculated by conservation law.
	Sos_Grb2' = -ReactionFlux27+ReactionFlux30 : affects compound with ID S58
	Sos_p' = -ReactionFlux28-ReactionFlux29+ReactionFlux61 : affects compound with ID S59
	: Compound Sos with ID S60 and initial condition 0.0001 had derivative +ReactionFlux29-ReactionFlux30-ReactionFlux60, but is calculated by conservation law.
	SHC_p_Grb2_clx' = ReactionFlux31 : affects compound with ID S61
	: Compound PLC_g with ID S62 and initial condition 0.00082001 had derivative -ReactionFlux32+ReactionFlux35-ReactionFlux86, but is calculated by conservation law.
	PLC_g_p' = -ReactionFlux33-ReactionFlux35+ReactionFlux87 : affects compound with ID S63
	Ca_PLC_g' = ReactionFlux32+ReactionFlux34-ReactionFlux78+ReactionFlux84-ReactionFlux84 : affects compound with ID S64
	Ca_PLC_g_p' = ReactionFlux33-ReactionFlux34+ReactionFlux79+ReactionFlux85-ReactionFlux85 : affects compound with ID S65
	: Compound PLCg_basal with ID S66 and initial condition 7.0002e-07 had derivative -ReactionFlux86+ReactionFlux87, but is calculated by conservation law.
	: Compound MKP_1 with ID S67 and initial condition 2e-05 had derivative -ReactionFlux88+ReactionFlux89-ReactionFlux90+ReactionFlux91, but is calculated by conservation law.
	: Compound PPhosphatase2A with ID S68 and initial condition 0.00026001 had derivative -ReactionFlux92+ReactionFlux93-ReactionFlux94+ReactionFlux95-ReactionFlux96+ReactionFlux97-ReactionFlux98+ReactionFlux99-ReactionFlux100+ReactionFlux101, but is calculated by conservation law.
	PKC_act_raf_cplx' = ReactionFlux36-ReactionFlux37 : affects compound with ID S70
	PKC_inact_GAP_cplx' = ReactionFlux38-ReactionFlux39 : affects compound with ID S71
	PKC_act_GEF_cplx' = ReactionFlux40-ReactionFlux41 : affects compound with ID S72
	kenz_cplx' = ReactionFlux42-ReactionFlux43 : affects compound with ID S73
	kenz_cplx_1' = ReactionFlux44-ReactionFlux45 : affects compound with ID S74
	kenz_cplx_2' = ReactionFlux46-ReactionFlux47 : affects compound with ID S75
	kenz_cplx_3' = ReactionFlux48-ReactionFlux49 : affects compound with ID S76
	kenz_cplx_4' = ReactionFlux50-ReactionFlux51 : affects compound with ID S77
	PLC_Ca_cplx' = ReactionFlux52-ReactionFlux53 : affects compound with ID S78
	PLCb_Ca_Gq_cplx' = ReactionFlux54-ReactionFlux55 : affects compound with ID S79
	MAPK_p_p_cplx' = ReactionFlux56-ReactionFlux57 : affects compound with ID S80
	MAPK_p_p_feedback_cplx' = ReactionFlux58-ReactionFlux59 : affects compound with ID S81
	phosph_Sos_cplx' = ReactionFlux60-ReactionFlux61 : affects compound with ID S82
	MAPKKtyr_cplx' = ReactionFlux62-ReactionFlux63 : affects compound with ID S83
	MAPKKthr_cplx' = ReactionFlux64-ReactionFlux65 : affects compound with ID S84
	Raf_p_GTP_Ras_1_cplx' = ReactionFlux66-ReactionFlux67 : affects compound with ID S85
	Raf_p_GTP_Ras_2_cplx' = ReactionFlux68-ReactionFlux69 : affects compound with ID S86
	basal_GEF_activity_cplx' = ReactionFlux70-ReactionFlux71 : affects compound with ID S87
	GEF_p_act_Ras_cplx' = ReactionFlux72-ReactionFlux73 : affects compound with ID S88
	GAP_inact_Ras_cplx' = ReactionFlux74-ReactionFlux75 : affects compound with ID S89
	CaM_GEF_act_Ras_cplx' = ReactionFlux76-ReactionFlux77 : affects compound with ID S90
	Ca_PLC_g_phospho_cplx' = ReactionFlux78-ReactionFlux79 : affects compound with ID S91
	SHC_phospho_cplx' = ReactionFlux80-ReactionFlux81 : affects compound with ID S92
	Sos_Ras_GEF_cplx' = ReactionFlux82-ReactionFlux83 : affects compound with ID S93
	PLC_g_phospho_cplx' = ReactionFlux86-ReactionFlux87 : affects compound with ID S94
	MKP1_tyr_deph_cplx' = ReactionFlux88-ReactionFlux89 : affects compound with ID S95
	MKP1_thr_deph_cplx' = ReactionFlux90-ReactionFlux91 : affects compound with ID S96
	craf_dephospho_cplx' = ReactionFlux92-ReactionFlux93 : affects compound with ID S97
	MAPKK_dephospho_cplx' = ReactionFlux94-ReactionFlux95 : affects compound with ID S98
	MAPKK_dephospho_ser_cplx' = ReactionFlux96-ReactionFlux97 : affects compound with ID S99
	craf_p_p_dephospho_cplx' = ReactionFlux98-ReactionFlux99 : affects compound with ID S100
	deph_raf_ser259_cplx' = ReactionFlux100-ReactionFlux101 : affects compound with ID S101
}
PROCEDURE observables_func() {
	pERK1_2_ratio1 = (MAPK_p+MAPK_p_p+MAPK_p_p_cplx+MAPK_p_p_feedback_cplx) : Output ID Y0
	MAPK_out = MAPK : Output ID Y1
	MAPK_p_out = MAPK_p : Output ID Y2
	MAPK_p_p_out = MAPK_p_p : Output ID Y3
	MAPK_p_p_cplx_out = MAPK_p_p_cplx : Output ID Y4
	MAPK_p_p_feedback_cplx_out = MAPK_p_p_feedback_cplx : Output ID Y5
	pERK1_2_ratio2 = (MAPK_p+MAPK_p_p+MAPK_p_p_cplx+MAPK_p_p_feedback_cplx) : Output ID Y6
}
