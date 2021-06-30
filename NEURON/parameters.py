# -*- coding: utf-8 -*-
"""
Created on Tue Oct 25 20:39:04 2016

@author: daniel
"""
#from math import sqrt
results_directory = './results'

#-----------------------------------------------------------#
#      1. General recording and simulation parameters       #
#-----------------------------------------------------------#
step = 20.0
record_step = 0.1
record_step_v = 0.1
g_record_step = 0.1

nrn_dots_per_1ms = 1/record_step
time_to_avg_over = 20 # in seconds

simtime = 20000
num_trials = 20
NUMBER_OF_PROCESSES = 7
steady_states_file = 'steady_states.dat'
#-----------------------------------#
#      2. Synaptic parameters       #
#-----------------------------------#
esyn_tau = 6
isyn_tau = 6
isyn_tau_plateau = 87
e_esyn = 0
e_gaba = -60
erate = 0.5
irate = 0.5
pos = 0.5

# NMDA parameters
Mg = 1.4 # 1.0
alpha = 0.099 # 0.062
eta = 1.0/18 # 1.0/3.57

g_ramp_max = 0.000255
nmda_ampa_ratio = 1
gAMPAmax = 0.1e-3
gNMDAmax = gAMPAmax*nmda_ampa_ratio
gGABAmax = 1.5e-3
g_expsyn_max =  0.2e-3
g_inhexpsyn_max = gGABAmax
 
gAMPAmax_plateau = 0.5e-3 
gNMDAmax_plateau = 1.5e-3 
gGABAmax_plateau = 0.0015*1
nmda_ampa_ratio = gNMDAmax_plateau/gAMPAmax_plateau
ratio_glutamate_syn = 1.0

gAMPAmax_pf = 0.05e-3
gNMDAmax_pf = 1.5e-3 

gAMPAmax_phos = 1.0e-3
gNMDAmax_phos = 0.5e-3
total_Substrate = 3000 

glu_thresh1 = 0.5
glu_thresh2 = 0.5

tNMDAon = 2.76
tNMDAoff = 115.5

taur_cadyn_nmda = 230.83
scale_cadyn_nmda = 0.083
cainf_cadyn_nmda = 130e-6
cainit_cadyn_nmda = 28.2653e-6

iclamp_amp = 1.85
iclamp_delay = 5
iclamp_periodic_delay = 100
iclamp_dur = 15
num_iclamps = 10
iclamp_start = 4000

tau1_exp2syn = 0.1
tau2_exp2syn = 2.0

v_thresh = -50
glu_thresh = 0.06
#-----------------------------------------#
#      3. Synaptic input parameters       #
#-----------------------------------------#

plateau_syn_rate = 10
plateau_burst_start = 4000
plateau_burst_end = 5030
plateau_cluster_size = 10
cluster_start_pos = 0.5
cluster_end_pos = 0.5

glutamate_phos_start = 12000
DA_start = 1000
DA_max = 1480

inhibitory_syn_rate = 85.0
inhibitory_burst_start = 100
inhibitory_burst_end = 160
inhibitory_cluster_size = 1

distributed_input_rate = 1000.0/40
distributed_input_start = 300
distributed_input_end = 500
distributed_input_size = 30

deterministic_interval = 100
num_deterministic_spikes = 10

e_interval = 1.0/erate*(10**3)
i_interval = 1.0/irate*(10**3)
plateau_syn_interval = 1.0/plateau_syn_rate*(10**3)
distributed_input_interval = 1.0/distributed_input_rate*(10**3)
inhibitory_syn_interval = 1.0/inhibitory_syn_rate*(10**3)

#--------------------------------#
#      4. Spine parameters       #
#--------------------------------#
head_L = 0.5
head_diam = 0.5
neck_L = 0.5
neck_diam = 0.12
neck_Ra = 1130.0
head_Ra = 150

#-----------------------------------------------------------#
#      5. XOR problem and adaptive synapse parameters       #
#-----------------------------------------------------------#

event_times = [200, 500, 900]

save_weights_file = 'syn_weights.dat'
load_weights_file = 'syn_weights.dat'
training_set_size = 20
training_input_length = 30
first_training_input_start = 1000
time_to_reward = 100 - training_input_length
reward_length = 20
session_length = 500

low_rate = 0.001
high_rate = 50
LTP_factor = 1.5
LTD_factor = 0.5
LTD_factor_NMDA = 0.5
thresh_LTP = 0.04#0.13
thresh_LTD = 0.002#0.001
l_thresh_LTP = 40
l_thresh_LTD = 40
learning_rate_w = 0.05

xor_input_size = 10
input_dends = [3, 12, 22, 26, 35, 57] #[3, 5, 8, 12, 15, 22, 26, 35, 41, 47, 53, 57]
pf_input_dends = [12, 22, 26, 35]
p_conn = 0.35
p_group = 0.5

low_interval = 1.0/low_rate*(10**3)
high_interval = 1.0/high_rate*(10**3)

#simtime = first_training_input_start + training_set_size*session_length
#simtime = first_training_input_start + training_set_size*(training_input_length+
#            time_to_reward + reward_length)

#----------------------------------#
#      6. Plotting parameters      #
#----------------------------------#

#-----------------------------------#
#      6.1. For XOR experiment      #
#-----------------------------------#

#-------------------------------------------------------#
#      7. Miscellaneous and parameter dictionaries      #
#-------------------------------------------------------#

dends_per_plot = 3


params = {
        'erate' : erate,
        'irate' : irate,
        'e_esyn' : e_esyn,
        'g_expsyn_max' : g_expsyn_max,
        'g_inhexpsyn_max' : g_inhexpsyn_max,
        'erate' : erate,
        'irate' : irate,
        'esyn_tau' : esyn_tau,
        'isyn_tau' : isyn_tau,
        'e_interval' : e_interval,
        'i_interval' : i_interval
}

par = {
        'gbar_naf_somatic': 9.0,
        'gbar_naf_axonal': 9.0
       }

       
nmda = {
        'gNMDAmax': gNMDAmax ,
        'gNMDAmax_plateau': gNMDAmax_plateau,
        'tcon': tNMDAon,
        'tcoff': tNMDAoff,
        'ratio': ratio_glutamate_syn
       }       
       
exp2syn = {
        'e': e_esyn ,
        'tau1': tau1_exp2syn ,
        'tau2': tau2_exp2syn
       }

#----------------------------------------------#
#      6. What to record       #
#----------------------------------------------#

species_to_plot = ['PKA', 'cAMP', 'pSubstrate', 'CaMKII', 'pCaMKII', 
                   'AC5_GaolfGTP','ATP', 'PP2B', 'PP2B_CaM_Ca2', 
                   'CaM_Ca2', 'CaM_Ca4', 'PP1', 'AMP', 'B56PP2A',
                   'B72PP2A_Ca', 'B56PP2A', 'D32', 'ARPP21', 'B72PP2A']
species_to_plot = ['PKA', 'cAMP', 'pSubstrate', 'CaMKII', 'pCaMKII', 'Ca', 'DA']
species_to_plot = ['pSubstrate']            
cascade_species = [
     'AC5', 
 	'AC5_ATP', 
	'AC5_Ca',
	'AC5_Ca_ATP', 
	'AC5_Ca_GaolfGTP', 
	'AC5_Ca_GaolfGTP_ATP', 
	'AC5_GaolfGTP', 
	'AC5_GaolfGTP_ATP', 
	'AMP', 
	'ATP', 
	'B56PP2A', 
	'B56PP2A_D32p75', 
	'B56PP2A_pARPP21', 
	'B56PP2Ap', 
	'B56PP2Ap_D32p75', 
	'B56PP2Ap_pARPP21', 
	'B72PP2A', 
	'B72PP2A_D32p34', 
	'B72PP2A_D32p75', 
	'B72PP2A_pARPP21', 
	'B72PP2A_Ca_D32p34', 
	'B72PP2A_Ca_D32p75', 
	'B72PP2A_Ca', 
	'B72PP2A_Ca_pARPP21', 
	'Ca', 
	'CaM', 
	'CaM_Ca2',
	'CaM_Ca4', 
	'CaM_Ca4_pARPP21', 
	'CaMKII', 
	'CaMKII_CaM_Ca4', 
	'CaMKII_CaM',
	'CaMKII_CaM_Ca2', 
	'CaMKII_CaM_Ca2_psd', 
	'CaMKII_CaM_psd', 
	'CaMKII_CaM_Ca4_psd', 
	'CaMKII_psd', 
	'cAMP',
	'Substrate', 
	'CDK5', 
	'CDK5_D32', 
	'D1R', 
	'D1R_DA', 
	'D1R_Golf_DA', 
	'D1R_Golf', 
	'D32p34', 
	'D32p75', 
	'DA',
	'D32',
	'GaolfGDP', 
	'GaolfGTP', 
	'Gbgolf', 
	'Golf', 
	'pCaMKII', 
	'pCaMKII_CaM_Ca4', 
	'pCaMKII_CaM', 
	'pCaMKII_CaM_Ca2', 
	'pCaMKII_CaM_Ca2_psd', 
	'pCaMKII_CaM_psd', 
	'pCaMKII_CaM_Ca4_psd', 
	'pCaMKII_psd', 
	'pSubstrate', 
	'PDE4',
	'PDE4_cAMP', 
	'PDE10r', 
	'PDE10r_cAMP', 
	'PDE10c', 
	'PDE10c_cAMP', 
	'PKA', 
	'PKAc', 
	'PKAc_B56PP2A',
	'PKAc_D32', 
	'PKAc_ARPP21', 
	'PKA_Ca2MP',
	'PKA_Ca4MP', 
	'PKAc_D32p75', 
	'PKAreg',
	'PP1', 
	'PP1_pCaMKII_psd', 
	'PP1_pSubstrate', 
	'PP1_D32p34', 
	'CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd', 
	'pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd', 
	'CaMKII_CaM_Ca4_CaMKII_CaM_Ca4', 
	'pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4', 
	'PP2B', 
	'PP2Bc',
	'PP2Bc_D32p34',
	'PP2B_CaM', 
	'PP2B_CaM_Ca2', 
	'pARPP21', 
	'ARPP21', 
	'pCaMKII_psd_Substrate',
	'pCaMKII_CaM_psd_Substrate', 
	'pCaMKII_CaM_Ca2_psd_Substrate', 
	'pCaMKII_CaM_Ca4_psd_Substrate',
	'CaMKII_CaM_psd_Substrate', 
	'CaMKII_CaM_Ca2_psd_Substrate', 
	'CaMKII_CaM_Ca4_psd_Substrate']
#species_to_plot  = cascade_species 