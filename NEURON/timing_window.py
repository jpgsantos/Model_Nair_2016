# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 17:48:41 2016

@author: daniel
"""

from neuron import h
import d1msn as msn
import timing_experiment as pe
import pickle
import parameters as p
import random as rnd
# --- 1. Create a cell and other useful stuff

with open('D1_71bestFit_updRheob.pkl', 'rb') as f:
    model_sets  = pickle.load(f, encoding="latin1")

cell_ID = 70
variables = model_sets[cell_ID]['variables'] 
d1 = msn.MSN(variables = variables) 
#d2 = msn.MSN(variables = variables) 
#d1.dendlist[57].diam = 1.15
print(d1.max_dist())

for sec in d1.dendlist:
    print(sec.name(), "%f, %f, %f, d = %.2f" % (h.distance(1.0, sec = sec), 
                                      h.distance(0, sec = sec), 
                                      h.distance(0.70, sec = sec) - h.distance(0.55, sec = sec),
                                      sec.diam))

for sec in d1.somalist:
    print(sec.name(), "%f, %f, %f, d = %.2f" % (h.distance(1, sec = sec), 
                                      h.distance(0, sec = sec), 
                                      h.distance(1, sec = sec) - h.distance(0, sec = sec),
                                      sec.diam))


# --- 2. Insert stimulation to cell

#independent_dends = [3, 5, 8, 12, 15, 22, 26, 35, 41, 47, 53, 57]
dend_record_list = [3]
plateau_cluster_list = [3]

ex = pe.Timing_Experiment('record_ca', d1)            
ex.insert_synapses('plateau_cluster', plateau_cluster_list, deterministic = 1, 
                   num_syns = p.plateau_cluster_size, add_spine = 1)
ex.insert_synapses('glutamate_phos', plateau_cluster_list, deterministic = 1)
ex.set_up_recording(dend_record_list)
    
w_ampa = []; vs_before_LTP = []; vs_after_LTP = []   
DA_start = [-4000, -3000, -2000, -1000, -0, 1000, 2000, 3000, 4000]
for d in DA_start:
    for spine in d1.spines:
        spine.head(0.5).timing_model.DA_max = p.DA_max
        spine.head(0.5).timing_model.DA_start = d + p.plateau_burst_start 

    ex.simulate()
    w_ampa.append(ex.w_ampa[0].to_python())
    start = int(p.glutamate_phos_start*p.nrn_dots_per_1ms)
    end = int((p.glutamate_phos_start+50)*p.nrn_dots_per_1ms)
    before_LTP = ex.vs.to_python()[start:end] 
    start = int((p.glutamate_phos_start+p.glutamate_phos_interval)*p.nrn_dots_per_1ms)
    end = int((p.glutamate_phos_start+p.glutamate_phos_interval+50)*p.nrn_dots_per_1ms)
    after_LTP = ex.vs.to_python()[start:end]
    vs_before_LTP.append(before_LTP)
    vs_after_LTP.append(after_LTP)

import matplotlib.pyplot as plt
import numpy as np
vs = ex.vs.to_python()
vs_ss = vs[len(vs)-1]  
vs_before_LTP = np.array(vs_before_LTP)
vs_after_LTP = np.array(vs_after_LTP)
max_before_LTP = (vs_before_LTP - vs_ss).max(axis = 1)
max_after_LTP = (vs_after_LTP - vs_ss).max(axis = 1)             

fig = plt.figure()
ax = fig.add_subplot(111)
ax.plot(DA_start, np.divide(max_after_LTP, max_before_LTP))
ax.set_xlabel('t_Ca - t_Da (ms)')
ax.set_ylabel('increase in somatic depolarization')
