# -*- coding: utf-8 -*-
"""
Created on Sun Aug 27 13:38:21 2017

@author: daniel
"""

from neuron import h
import parameters as p
import matplotlib.pyplot as plt
import numpy as np
import synapse as s
import spine as sp
import sys

class Neuron(object):
    """Generic neuron class."""
    def __init__(self):
        self.create_morphology()
        self.insert_channels()
        self.esyn = []
        self.isyn = []
        self.spines = []
        
    def create_morphology(self):
        """Create the cell morphology, including axial resistance and membrane capacitance."""
        raise NotImplementedError('"create_morphology() is not implemented."')
    
    def insert_channels(self):
        """Insert channels in the cell."""
        raise NotImplementedError("insert_channels() is not implemented.")
    
    def create_sectionlists(self):
        """Build subset lists. This defines 'all', but subclasses may
        want to define others. If overridden, call super() to include 'all'."""
        self.all = h.SectionList()
        self.all.wholetree(sec=self.soma)
    
    def connect2target(self, target, thresh=10):
        """Make a new NetCon with this cell's membrane
        potential at the soma as the source (i.e. the spike detector)
        onto the target passed in (i.e. a synapse on a cell).
        Subclasses may override with other spike detectors."""
        nc = h.NetCon(self.soma(1)._ref_v, target, sec = self.soma)
        nc.threshold = thresh
        return nc
            
    def insert_synapse(self, syntype, sec, pos, add_spine = 0, on_spine = 0):
        if add_spine and on_spine:
            print("Arguments add_spine and on_spine can't simultaneously be 1")
            sys.exit(-1)
            
        if add_spine:
            spine_name = 'spine_' + sec.name() + '(' + str(pos) + ')'
            self.spines.append(sp.Spine(sec, spine_name))
            self.spines[-1].attach(sec, pos, 0)
            self.spines[-1].syn_on = 1
            sec = self.spines[-1].head
            pos = 0.5
        
        if on_spine:
            empty_spines = [spine for spine in self.spines if (spine.parent == sec and spine.syn_on == 0)]
            if empty_spines == []:
                print("There are no empty spines on dendrite %s" % sec.name())
                sys.exit(-1)
            else:
                sec = empty_spines[0].head
                pos = 0.5
                empty_spines[0].syn_on = 1
            
        syn = s.Synapse()
        syn.type = syntype
        syn.sec = sec
        syn.pos = pos        
        
        if syntype in ['expsyn', 'expsyn_plateau']:
            syn.obj = h.ExpSyn(sec(pos))            
            syn.obj.tau = p.esyn_tau
            syn.obj.e = p.e_esyn
            self.esyn.append(syn)
            return syn       
        
        elif syntype == 'inhexpsyn' or syntype == 'inhexpsyn_plateau':
            syn.obj = h.InhExpSyn(sec(pos))
            if syntype == 'inhexpsyn':       
                syn.obj.tau = p.isyn_tau
            elif syntype == 'inhexpsyn_plateau':
                syn.obj.tau = p.isyn_plateau_tau
            self.isyn.append(syn)
            return self.isyn[-1]
    
            
        elif syntype == 'exp2syn':
            syn.obj = h.Exp2Syn(sec(pos))
            syn.obj.e = p.exp2syn['e']
            syn.obj.tau2 = p.exp2syn['tau2']
            syn.obj.tau1 = p.exp2syn['tau1']
            self.esyn.append(syn)
            return syn        

        elif syntype == 'glutamate' or syntype == 'glutamate_plateau':
            syn.obj = h.glutamate(sec(pos))
            syn.obj.mg = p.Mg
            syn.obj.eta = p.eta
            syn.obj.alpha = p.alpha
            syn.obj.tau1_nmda = p.nmda['tcon']
            syn.obj.tau2_nmda = p.nmda['tcoff']
            syn.obj.ratio = p.nmda['ratio']
            self.esyn.append(syn)
            return syn

        elif syntype in ['glutamate_ica_nmda'] :
            syn.obj = h.glutamate_ica_nmda(sec(pos))
            syn.obj.mg = p.Mg            
            syn.obj.eta = p.eta
            syn.obj.alpha = p.alpha
            syn.obj.tau1_nmda = p.nmda['tcon']
            syn.obj.tau2_nmda = p.nmda['tcoff']
            syn.obj.w_ampa = p.gAMPAmax_plateau
            syn.obj.w_nmda = p.gNMDAmax_plateau
            self.esyn.append(syn)
            return syn

        elif syntype in ['glutamate_phos_sat'] :
            syn.obj = h.glutamate_phos_sat(sec(pos))
            syn.obj.mg = p.Mg            
            syn.obj.eta = p.eta
            syn.obj.alpha = p.alpha
            syn.obj.tau1_nmda = p.nmda['tcon']
            syn.obj.tau2_nmda = p.nmda['tcoff']
            syn.obj.w_ampa0 = p.gAMPAmax_plateau
            syn.obj.w_nmda0 = p.gNMDAmax_plateau
            syn.obj.total_Substrate = p.total_Substrate
            h.setpointer(sec(pos)._ref_pSubstrate_Nair_2016, 'pSubstrate', syn.obj)
            self.esyn.append(syn)
            return syn
            
        elif syntype in ['glutamate_phos'] :
            syn.obj = h.glutamate_phos(sec(pos))
            syn.obj.mg = p.Mg            
            syn.obj.eta = p.eta
            syn.obj.alpha = p.alpha
            syn.obj.tau1_nmda = p.nmda['tcon']
            syn.obj.tau2_nmda = p.nmda['tcoff']
            syn.obj.w_ampa0 = p.gAMPAmax_phos
            syn.obj.w_nmda0 = p.gNMDAmax_phos
            syn.obj.total_Substrate = p.total_Substrate
            h.setpointer(sec(pos)._ref_pSubstrate_Nair_2016, 'pSubstrate', syn.obj)
            self.esyn.append(syn)
            return syn
            
    def max_dist(self, axon_excluding=True):
        if not hasattr(self, 'somalist'):
            raise NotImplementedError("create_sectionlists() is not implemented or attribute somalist not defined")
        
        h.distance(sec=self.somalist[0])
        dmax = 0
        for sec in self.all:
            if axon_excluding and sec.name().find('axon') == 0: 
                continue
            dmax = max(dmax, h.distance(1, sec=sec))
        return dmax
        
    def get_nsegs(self):
        """Returns the number of segments in the neuron model."""
        nsegs = 0
        for sec in self.all: 
            nsegs += sec.nseg
        return nsegs
        
    def set_nsegs(self):
        """Sets the number of segments in each section of the neuron model
        according to n = 2*int(L/40) + 1, where L is the length of the section."""
        for sec in self.all:
            sec.nseg = 2*int(sec.L/40.0)+1
        if hasattr(self, 'axonlist'):
            for sec in self.axonlist:
                sec.nseg = 2  # two segments in axon initial segment

    def total_dend_length(self):
        """Returns the total dendritic length."""
        total_length = 0             
        for dend in self.dendlist:
            total_length += dend.L
        return total_length
        
    def plot_weight_distribution(self, start = None, stop = None, step = None):
        if start == None:
            start = p.JE/10
        if stop == None:
            stop = p.JE*10
        if step == None:
            p.JE = 0.0001
        bins = np.arange(start, stop + step, step)
        weights = [e.obj.w for e in self.esyn if e.type in ['expsyn_hom', 'expsyn_hom_MSN'] ]
        plt.hist(weights, bins);
        plt.show()
        
    def scatter_plot_weights_locations(self):
        weights = [e.obj.w for e in self.esyn if e.type in ['expsyn_hom', 'expsyn_hom_MSN'] ]
        delta_weights = np.multiply(np.divide(weights, p.JE),100) 
        dists = [h.distance(e.pos , sec = e.sec) for e in self.esyn if e.type in ['expsyn_hom', 'expsyn_hom_MSN'] ]        
        plt.scatter(delta_weights, dists)
        ax = plt.gca(); 
        ax.set_xlabel('\% change'); ax.set_ylabel('distance');
        plt.show()
        return delta_weights
        
    def increase_dend_res(self, dend_list, mult):
        for d in dend_list:
            self.dendlist[d].nseg *= mult