# -*- coding: utf-8 -*-
"""
Created on Thu Aug 31 15:44:21 2017

@author: daniel
"""

import parameters as p
from neuron import h
from random import randint
import time
import sys

class Experiment(object):
    
    def __init__(self):
        self.inc = []; self.istim = [] 
        self.enc = []; self.estim = []
        self.recorder_nc = []; self.recorder_tvec = []
        self.ramp_enc = []; self.ramp_estim = []
        self.presyn = h.Section()
                
    def insert_synapses(self): 
        """Inserts synaptic input."""
        raise NotImplementedError("insert_synapses() is not implemented.")               
    
    def set_up_recording(self):
        """Sets up recording of cell properties."""
        raise NotImplementedError("set_up_recording() is not implemented.")
                        
    def simulate(self):
        """Runs the simulation."""
        raise NotImplementedError("simulate() is not implemented.")
         
    def plot_results(self):
        """Plots results for this experiment."""
        raise NotImplementedError("plot_results() is not implemented.")
        
    def add_input_generator(self, syn, syntype, freq_multiplier = 1.0):
        if syntype in ['expsyn', 'expsyn_hom']:
            self.estim.append(h.SpikeGenerator(0.5, sec = self.presyn))
            self.estim[-1].seed(int(time.time() + randint(1,10**7)))
            self.estim[-1].noise = 1
            self.estim[-1].fast_invl = p.e_interval/freq_multiplier
            self.estim[-1].slow_invl = 0
            
            self.enc.append(h.NetCon(self.estim[-1], syn.obj))
            self.enc[-1].delay = 0
            self.enc[-1].weight[0] = p.g_expsyn_max
        
        elif syntype in ['inhexpsyn']:
            self.istim.append(h.SpikeGenerator(0.5, sec = self.presyn)) 
            self.istim[-1].seed(int(time.time() + randint(1,10**7)))
            self.istim[-1].fast_invl = p.i_interval/freq_multiplier
            self.istim[-1].slow_invl = 0
            self.istim[-1].noise = 1

            self.inc.append(h.NetCon(self.istim[-1], syn.obj))      
            self.inc[-1].delay = 0
            self.inc[-1].weight[0] = p.g_inhexpsyn_max

    def synapse_distribution(self, celltype, dend):
        if celltype == 'MSN':
            # Synapses according to Cheng et al. Experimental Neurobiology, 147:287-298 (1997)                
            dist = h.distance(1, sec = dend)
            if dist <= 20:
                exc_mean = 7.7; exc_sem = 1.1;
                inh_mean = 1.71; inh_sem = 0.37;
            elif dist <= 40:
                exc_mean = 22.6; exc_sem = 1.5;
                inh_mean = 1.71; inh_sem = 0.37;
            elif dist <= 60:
                exc_mean = 32.1; exc_sem = 1.1;
                inh_mean = 1.71; inh_sem = 0.37;
            elif dist <= 80:
                exc_mean = 31.3; exc_sem = 1.0;
                inh_mean = 1.71; inh_sem = 0.37;
            elif dist <= 100:
                exc_mean = 32.5; exc_sem = 1.0;
                inh_mean = 1.71; inh_sem = 0.37;
            elif dist <= 120:
                exc_mean = 29.4; exc_sem = 0.8;
                inh_mean = 1.71; inh_sem = 0.37;
            else:
                exc_mean = 25.4; exc_sem = 0.8; # Not sure here!
                inh_mean = 1.71; inh_sem = 0.37;
                
        return [exc_mean, exc_sem, inh_mean, inh_sem]
        
    def helper_insert(self, syntype, pos, dend, freq_multiplier):  
        if syntype in ['expsyn','expsyn_hom']:
            syn1 = self.cell.insert_synapse(syntype, dend, pos)
            self.add_input_generator(syn1, syntype, freq_multiplier)
            syn2 = self.cell.insert_synapse('nmda', dend, pos)
            self.connect_input_generator(syn2, 'nmda', self.estim[-1])
        
        elif syntype in ['inhexpsyn', 'glutamate']:
            syn = self.cell.insert_synapse(syntype, dend, pos)
            self.add_input_generator(syn, syntype, freq_multiplier)
            
    def connect_input_generator(self, syn, syntype, gen):
        self.enc.append(h.NetCon(gen, syn.obj))
        self.enc[-1].delay = 0
        if syntype == 'expsyn':
            self.enc[-1].weight[0] = p.g_expsyn_max
        elif syntype == 'nmda_plateau':
            self.enc[-1].weight[0] = p.gNMDAmax_plateau
        elif syntype == 'nmda':
            self.enc[-1].weight[0] = p.gNMDAmax
        elif syntype == 'tmGlut':
            self.enc[-1].weight[0] = p.gAMPAmax
        elif syntype == 'glutamate':
            self.enc[-1].weight[0] = p.g_expsyn_max
        elif syntype == 'glutamate_plateau':
            self.enc[-1].weight[0] = p.gAMPAmax_plateau
        elif syntype in ['glutamate_mod', 'adaptive_glutamate', 'adaptive_glutamate_crude',
                         'glutamate_test', 'adaptive_glutamate_test', 'glutamate_ica_nmda',
                         'adaptive_glutamate2']:
            self.enc[-1].weight[0] = 1.0
        else:
            print("Synapse model not available in connect_input_genetrator().")
            sys.exit(-1)
                        
        # ADD THE REST OF THE SYNAPSE TYPES HERE !            

#        if 'nmda' in syn.hname():
#            self.enc[-1].weight[0] = 1          

    def event_recorder(self, source):
        self.recorder_nc.append(h.NetCon(source, None))
        self.recorder_tvec.append(h.Vector())
        self.recorder_nc[-1].record(self.recorder_tvec[-1])
        
    def spike_recorder(self, source, pos, threshold):
        """
        Input arguments:
        
        source - the section of a cell that is to be recorded
        pos - the position on the section (between 0 and 1)
        threshold - the value of the voltage above which signifies a spike has occured

        """
        self.recorder_nc.append(h.NetCon(source(pos)._ref_v, None, sec = source))
        self.recorder_nc[-1].threshold = threshold
            
        self.recorder_tvec.append(h.Vector())
        self.recorder_nc[-1].record(self.recorder_tvec[-1])
        