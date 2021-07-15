# -*- coding: utf-8 -*-
"""
Created on Fri Jan 24 15:14:41 2020

@author: daniel
"""

from mpi4py import MPI 
import d1msn as msn
import timing_experiment as te
import numpy as np
import parameters as pp
import seaborn as sns
import pickle
import matplotlib.pyplot as plt
import json

def extend_list(l):
    res = []
    for el in l:
        res.extend(el)
    return res

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
nprocs = comm.Get_size()
print("Number of processes = %d" % nprocs)

if rank == 0:
    DA_start = [-4000, -3750, -3500, -3250, 
                -3000, -2750, -2500, -2250,
                -2000, -1750, -1500, -1250,
                -1000,  -750,  -500,  -250, 
                    0,   250,   500,   750,
                 1000,  1250,  1500,  1750, 
                 2000,  2250,  2500,  2750,                
                 3000,  3250,  3500,  3750, 4000]
    
    div, res = divmod(len(DA_start), nprocs)
    counts = [div + 1 if p < res else div for p in range(nprocs)]
    
    # determine the starting and ending indices of each sub-task
    starts = [sum(counts[:p]) for p in range(nprocs)]
    ends = [sum(counts[:p+1]) for p in range(nprocs)]
    DA_start = [DA_start[starts[p]:ends[p]] for p in range(nprocs)]
else:
    DA_start = None

DA_start = comm.scatter(DA_start, root=0)

with open('D1_71bestFit_updRheob.pkl', 'rb') as f:
    model_sets  = pickle.load(f, encoding="latin1")

cell_index = 70
variables = model_sets[cell_index]['variables'] 
cell = msn.MSN(variables = variables)

dend_record_list = [3]
plateau_cluster_list = [3]

ex = te.Timing_Experiment('record_ca', cell)            
ex.insert_synapses('glutamate_phos_sat', plateau_cluster_list, deterministic = 1, 
                   num_syns = 1, add_spine = 1)
ex.insert_IClamp(ex.cell.somalist[0], 0.5, pp.num_iclamps)
ex.set_up_recording(dend_record_list)
    
integral = []

if rank == 0:
    for spine in ex.cell.spines:
        spine.head(0.5).Nair_2016.DA_max = 0
        spine.head(0.5).Nair_2016.DA_start = 100 
        
    ex.simulate()
    integral0 = ex.calculate_aoc(ex.species[pp.species_to_plot.index('pSubstrate')])

for d in DA_start:
    for spine in ex.cell.spines:
        spine.head(0.5).Nair_2016.DA_max = pp.DA_max
        spine.head(0.5).Nair_2016.DA_start = d + pp.plateau_burst_start 

    ex.simulate()
    integral.append(ex.calculate_aoc(ex.species[pp.species_to_plot.index('pSubstrate')]))
    pSubstrate = ex.species[pp.species_to_plot.index('pSubstrate')]
    pSubstrate = pSubstrate.to_python()
    
DA_start = comm.gather(DA_start, root = 0)    
integral = comm.gather(integral, root = 0)
pSubstrate = comm.gather(pSubstrate, root = 0)
# 5. Calculate and plot results
if rank == 0:
    DA_start = extend_list(DA_start)
    print("DA_start:"); print(DA_start)
    integral = extend_list(integral)

    res_dict = {'DA_start':DA_start,
                'integral': integral,
                'integral0': integral0,
    }    
    to_save = json.dumps(res_dict)
    with open('timing_window_ca_iclamp.dat', 'w', encoding = 'utf-8') as f:
        json.dump(to_save, f)
    
    sns.set(font_scale = 1.5)
    sns.set_style("ticks")
    plt.rcParams["font.weight"] = "bold"
    plt.rcParams["axes.labelweight"] = "bold"
    
    integral = np.array(integral)

    fig_parea2 = plt.figure()
    ax_parea2 = fig_parea2.add_subplot(111)
    ax_parea2.plot(DA_start, np.array(integral)/integral0)
    ax_parea2.set_xlabel('t_Ca - t_Da (ms)')
    ax_parea2.set_ylabel('pSubstrate area')
    sns.despine()    
    plt.show()
    
