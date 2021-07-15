# -*- coding: utf-8 -*-
"""
Created on Mon Jun 21 12:10:34 2021

@author: daniel
"""
import timing_experiment as te
import json
import d1msn as msn
import parameters as p
import pickle

with open('D1_71bestFit_updRheob.pkl', 'rb') as f:
    model_sets  = pickle.load(f, encoding="latin1")

cell_ID = 70
variables = model_sets[cell_ID]['variables'] 
cell = msn.MSN(variables = variables) 
    
dend_record_list = [3]
plateau_cluster_list = [3]

ex = te.Timing_Experiment('equilibration', cell)
ex.insert_synapses('glutamate_phos_sat', plateau_cluster_list, deterministic = 1, 
                   num_syns = 1, add_spine = 1)
ex.cell.esyn[0].sec.DA_max_Nair_2016 = 0
ex.set_up_recording()
p.steady_states_file = 'steady_states_interim.dat'

simtime = 200e3
ex.simulate(simtime = simtime)
ex.plot_results()

steady_states = []
for sp in ex.species:
    steady_states.append(sp.to_python()[-1])

result = {'steady_states': steady_states}
to_save = json.dumps(result)
with open('steady_states.dat', 'w', encoding = 'utf-8') as f:
    json.dump(to_save, f)