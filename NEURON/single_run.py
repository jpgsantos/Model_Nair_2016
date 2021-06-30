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
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# --- 1. Create a cell and other useful stuff

with open('D1_71bestFit_updRheob.pkl', 'rb') as f:
    model_sets  = pickle.load(f, encoding="latin1")

cell_ID = 70
variables = model_sets[cell_ID]['variables'] 
d1 = msn.MSN(variables = variables) 


# --- 2. Insert stimulation to cell

#independent_dends = [3, 5, 8, 12, 15, 22, 26, 35, 41, 47, 53, 57]
dend_record_list = [3]
plateau_cluster_list = [3]

ex = pe.Timing_Experiment('record_ca', d1)
              
ex.insert_synapses('glutamate_phos_sat', plateau_cluster_list, deterministic = 1, 
                   num_syns = 1, add_spine = 1)
ex.insert_IClamp(ex.cell.somalist[0], 0.5, p.num_iclamps)
ex.set_up_recording(dend_record_list)

start = int(p.glutamate_phos_start*p.nrn_dots_per_1ms)
end = int((p.glutamate_phos_start+50)*p.nrn_dots_per_1ms + 1)

#1. Only calcium input #
for spine in d1.spines:
    spine.head(0.5).Nair_2016.DA_max = 20
    spine.head(0.5).Nair_2016.DA_start = p.DA_start
ex.simulate()
onlyCa_soma = ex.vs.to_python()[start:end]
onlyCa_spine = ex.vspine[0].to_python()[start:end]

#2. Da before calcium #
for spine in d1.spines:
    spine.head(0.5).Nair_2016.DA_max = p.DA_max
    spine.head(0.5).Nair_2016.DA_start = p.plateau_burst_start - 1000

ex.simulate()
DaCa_soma = ex.vs.to_python()[start:end]
DaCa_spine = ex.vspine[0].to_python()[start:end]

#3. Da after calcium #
for spine in d1.spines:
    spine.head(0.5).Nair_2016.DA_max = p.DA_max
    spine.head(0.5).Nair_2016.DA_start = p.plateau_burst_start + 1000

ex.simulate()
CaDa_soma = ex.vs.to_python()[start:end]
CaDa_spine = ex.vspine[0].to_python()[start:end]

sns.set(font_scale = 2.0)
sns.set_style("ticks")
t = np.linspace(0,50, len(onlyCa_soma))
fig_soma_depol = plt.figure()
ax_soma_depol = fig_soma_depol.add_subplot(111)
ax_soma_depol.set_ylabel('Vs (mV)')
ax_soma_depol.set_xlabel('t (ms)')
ax_soma_depol.plot(t, onlyCa_soma); plt.hold(True)
ax_soma_depol.plot(t, DaCa_soma);
ax_soma_depol.plot(t, CaDa_soma);
ax_soma_depol.legend(['Ca', 'Da + Ca', 'Ca + Da'])
sns.despine()
fig_soma_depol.savefig("EPSP_soma.png", dpi = 300)
fig_spine_depol = plt.figure()
ax_spine_depol = fig_spine_depol.add_subplot(111)
ax_spine_depol.set_ylabel('Vspine (mV)')
ax_spine_depol.set_xlabel('t (ms)')
ax_spine_depol.plot(t, onlyCa_spine); plt.hold(True)
ax_spine_depol.plot(t, DaCa_spine);
ax_spine_depol.plot(t, CaDa_spine);
ax_spine_depol.legend(['Ca', 'Da + Ca', 'Ca + Da'])
sns.despine()
fig_spine_depol.savefig("EPSP_spine.png", dpi = 300)


start = int((p.plateau_burst_start-2000)*p.nrn_dots_per_1ms)
end = int((p.plateau_burst_start+4000)*p.nrn_dots_per_1ms)
num_datapoints = len(ex.dopamine[0].to_python()[start:end])
t_inputs = np.linspace((p.plateau_burst_start-2000)/1000, (p.plateau_burst_start+4000)/1000, num_datapoints)
#color = 'tab:red'

fig_inputs, ax_inputs1 = plt.subplots()
ax_inputs1.set_xlabel('time (s)')
ax_inputs1.set_ylabel('[Da] (nM)')
ax_inputs1.plot(t_inputs, ex.dopamine[0].to_python()[start:end])
ax_inputs1.legend(["Da"], loc = (0.7, 0.85))
ax_inputs1.tick_params(axis='y')

ax_inputs2 = ax_inputs1.twinx()  # instantiate a second axes that shares the same x-axis

color = (0.3333333333333333, 0.6588235294117647, 0.40784313725490196)
ax_inputs2.set_ylabel('[Ca] mM')  # we already handled the x-label with ax1
ax_inputs2.plot(t_inputs, ex.cai_nmda[0].to_python()[start:end], color = color)
ax_inputs2.legend(["Ca"], loc = (0.7, 0.75))
ax_inputs2.tick_params(axis='y')

fig_inputs.tight_layout()  # otherwise the right y-label is slightly clipped
fig_inputs.savefig("inputs.png", dpi = 300)

plt.show()

import pandas as pd
time = pd.DataFrame(t.tolist())
onlyCa_soma = pd.DataFrame(onlyCa_soma)
DaCa_soma = pd.DataFrame(DaCa_soma)
CaDa_soma = pd.DataFrame(CaDa_soma)

time.to_csv("time.csv")
onlyCa_soma.to_csv("onlyCa_soma.csv")
DaCa_soma.to_csv("DaCa_soma.csv")
CaDa_soma.to_csv("CaDa_soma.csv")

onlyCa_spine = pd.DataFrame(onlyCa_spine)
DaCa_spine = pd.DataFrame(DaCa_spine)
CaDa_spine = pd.DataFrame(CaDa_spine)

onlyCa_spine.to_csv("onlyCa_spine.csv")
DaCa_spine.to_csv("DaCa_spine.csv")
CaDa_spine.to_csv("CaDa_spine.csv")