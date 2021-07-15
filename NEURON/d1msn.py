from neuron import h
from math import exp
import numpy as np
import json
import neuron_cls as n
import spine as sp
import parameters as p

mod        = "./mod/"
params  = "./params_dMSN.json"
morphology = "./morphology/"

h.load_file('stdlib.hoc')
h.load_file('import3d.hoc')
h.nrn_load_dll(mod + 'x86_64/.libs/libnrnmech.so')

#h.nrn_load_dll('/pdc/vol/neuron/7.4-py27/x86_64/.libs/libnrnmech.so')

# ======================= the MSN class ==================================================

class MSN(n.Neuron):
    def __init__(self, variables = None):
        self.create_morphology()
        self.insert_channels(variables)
        self.esyn = []
        self.isyn = []
        self.spines = []
        
    def create_morphology(self):    
        Import = h.Import3d_SWC_read()
        Import.input(morphology + 'MSN_morphology_D1.swc')
        imprt = h.Import3d_GUI(Import, 0)
        imprt.instantiate(None)
        h.define_shape()
        self.create_sectionlists()
        self.set_nsegs()
                
        h.celsius = 35
        self.v_init = -80
                   
    def insert_channels(self, variables = None):
        self.dendritic_channels =   [
                    "naf",      
                    "kaf",
                    "kas",
                    "kdr",
                    "kir",
                    "cal12",
                    "cal13",
                    "can",
                    "car",
                    "cav32",
                    "cav33",
                    "sk",
                    "bk"            ]
                
        self.somatic_channels = [
                    "naf",
                    "kaf",
                    "kas",
                    "kdr",
                    "kir",
                    "cal12",
                    "cal13",
                    "can",
                    "car",
                    "sk",
                    "bk"        ]
                    
        self.axonal_channels = [
                    "naf",
                    "kas",
                    "Im"        ]        

        # Load ion channel parameters
        with open(params) as file:
            par = json.load(file)
        
        for sec in self.somalist:
            for mech in self.somatic_channels+["cadyn", "caldyn"]:
                sec.insert(mech)
                
        for sec in self.axonlist:
            for mech in self.axonal_channels:
                sec.insert(mech)
                
        for sec in self.dendlist:
            for mech in self.dendritic_channels+["cadyn", "caldyn", "cadyn_nmda"]:
                sec.insert(mech)

        for sec in self.all:
            sec.Ra = 150
            sec.cm = 1.0
            sec.insert('pas')
            sec.g_pas = float(par['g_pas_all']['Value'])
            sec.e_pas = -70 # -73
            sec.ena = 50
            sec.ek = -85 # -90


        self.distribute_channels("soma", "gbar_naf",   0, 1, 0, 0, 0, float(par['gbar_naf_somatic']['Value']))
        self.distribute_channels("soma", "gbar_kaf",   0, 1, 0, 0, 0, float(par['gbar_kaf_somatic']['Value']))
        self.distribute_channels("soma", "gbar_kas",   0, 1, 0, 0, 0, float(par['gbar_kas_somatic']['Value']))
        self.distribute_channels("soma", "gbar_kdr",   0, 1, 0, 0, 0, float(par['gbar_kdr_somatic']['Value']))
        self.distribute_channels("soma", "gbar_bk",    0, 1, 0, 0, 0, float(par['gbar_bk_somatic' ]['Value']))
        self.distribute_channels("soma", "pbar_cal12", 0, 1, 0, 0, 0, 1.34e-5)
        self.distribute_channels("soma", "pbar_cal13", 0, 1, 0, 0, 0, 1.34e-6)
        self.distribute_channels("soma", "pbar_car",   0, 1, 0, 0, 0, 1.34e-4)
        self.distribute_channels("soma", "pbar_can",   0, 1, 0, 0, 0,    4e-5)
        
        self.distribute_channels("dend", "gbar_kdr",   0, 1, 0, 0, 0, float(par['gbar_kdr_basal']['Value']))
        self.distribute_channels("dend", "gbar_bk",    0, 1, 0, 0, 0, float(par['gbar_bk_basal' ]['Value']))
        self.distribute_channels("dend", "pbar_cal12", 0, 1, 0, 0, 0, 1e-5)
        self.distribute_channels("dend", "pbar_cal13", 0, 1, 0, 0, 0, 1e-6)
        self.distribute_channels("dend", "pbar_car",   0, 1, 0, 0, 0, 1e-4)
        
        self.distribute_channels("axon", "gbar_kas",   0, 1, 0, 0, 0,      float(par['gbar_kas_axonal']['Value']))
        self.distribute_channels("axon", "gbar_naf",   3, 1, 1.1, 30, 500, float(par['gbar_naf_axonal']['Value']))
        #self.distribute_channels("axon", "gbar_naf",   1, 1, 0.1, 30, -1, float(par['gbar_naf_axonal']['Value']))
        self.distribute_channels("axon", "gImbar_Im",   0, 1, 0, 0, 0, 1.0e-3)
        
        #(1 + 0.9/(1 + math.exp(({distance}-30.0)/-1.0) ))
        
        if variables:
            self.distribute_channels("dend", "gbar_naf", 1,   1.0-variables['naf'][1],  \
                                                              variables['naf'][1],      \
                                                              variables['naf'][2],      \
                                                              variables['naf'][3],      \
                                                              np.power(10,variables['naf'][0])*float(par['gbar_naf_basal']['Value']))
            self.distribute_channels("dend", "gbar_kaf", 1,   1.0,                      \
                                                              variables['kaf'][1],      \
                                                              variables['kaf'][2],      \
                                                              variables['kaf'][3],      \
                                                              np.power(10,variables['kaf'][0])*float(par['gbar_kaf_basal']['Value']))
            self.distribute_channels("dend", "gbar_kas", 1,   0.1,                      \
                                                              0.9,                      \
                                                              variables['kas'][1],      \
                                                              variables['kas'][2],      \
                                                              np.power(10,variables['kas'][0])*float(par['gbar_kas_basal']['Value']))
                                                              
            self.distribute_channels("dend", "gbar_kir", 0,   np.power(10,variables['kir'][0]), 0, 0, 0,    float(par['gbar_kir_basal'  ]['Value']))
            self.distribute_channels("soma", "gbar_kir", 0,   np.power(10,variables['kir'][0]), 0, 0, 0,    float(par['gbar_kir_somatic']['Value']))
            self.distribute_channels("dend", "gbar_sk",  0,   np.power(10,variables['sk' ][0]), 0, 0, 0,    float(par['gbar_sk_basal'   ]['Value']))
            self.distribute_channels("soma", "gbar_sk",  0,   np.power(10,variables['sk' ][0]), 0, 0, 0,    float(par['gbar_sk_somatic' ]['Value']))
            
            self.distribute_channels("dend", "pbar_can",   1, 1.0-variables['can'][1],  \
                                                              variables['can'][1],      \
                                                              variables['can'][2],      \
                                                              variables['can'][3],      \
                                                              np.power(10,variables['can'][0]))
            self.distribute_channels("dend", "pbar_cav32", 1, 0,                        \
                                                              1,                        \
                                                              variables['c32'][1],      \
                                                              variables['c32'][2],      \
                                                              np.power(10,variables['c32'][0]))
            self.distribute_channels("dend", "pbar_cav33", 1, 0,                        \
                                                              1,                        \
                                                              variables['c33'][1],      \
                                                              variables['c33'][2],      \
                                                              np.power(10,variables['c33'][0]))
        else:
            self.distribute_channels("dend", "gbar_naf", 1, 0.1, 0.9,   60.0,   10.0, float(par['gbar_naf_basal']['Value']))
            self.distribute_channels("dend", "gbar_kaf", 1,   1, 0.5,  120.0,  -30.0, float(par['gbar_kaf_basal']['Value']))
            #self.distribute_channels("dend", "gbar_kaf", 0, 1, 0, 0, 0, float(par['gbar_kaf_basal']['Value']))
            self.distribute_channels("dend", "gbar_kas", 2,   1, 9.0,  0.0, -5.0, float(par['gbar_kas_basal']['Value']))
            self.distribute_channels("dend", "gbar_kir", 0, 1, 0, 0, 0, float(par['gbar_kir_basal']['Value']))
            self.distribute_channels("soma", "gbar_kir", 0, 1, 0, 0, 0, float(par['gbar_kir_somatic']['Value']))
            self.distribute_channels("dend", "gbar_sk",  0, 1, 0, 0, 0, float(par['gbar_sk_basal']['Value']))
            self.distribute_channels("soma", "gbar_sk",  0, 1, 0, 0, 0, float(par['gbar_sk_basal']['Value']))
            self.distribute_channels("dend", "pbar_can", 0, 1, 0, 0, 0, 1e-7)
            self.distribute_channels("dend", "pbar_cav32", 1, 0, 1.0, 120.0, -30.0, 1e-7)
            self.distribute_channels("dend", "pbar_cav33", 1, 0, 1.0, 120.0, -30.0, 1e-8)         
         
      
    def create_sectionlists(self):
        self.all = []
        self.somalist = [] 
        self.nsomasec = 0                
        self.axonlist = [] 
        self.dendlist = [] 
        
        for sec in h.allsec():
            self.all.append(sec) # needs to be a keyword argument when used with h.SectionList()
            if sec.name().find('soma') >= 0:
                self.somalist.append(sec)
                self.nsomasec += 1
            if sec.name().find('axon') >= 0:
                self.axonlist.append(sec)
            if sec.name().find('dend') >= 0:
                self.dendlist.append(sec)
        
    def distribute_channels(self, as1, as2, d3, a4, a5, a6, a7, g8):
        h.distance(sec=self.somalist[0])
        for sec in self.all:
            if sec.name().find(as1) >= 0:
                for seg in sec:
                    dist = h.distance(seg.x, sec=sec)
                    val = self.calculate_distribution(d3, dist, a4, a5, a6, a7, g8)
                    cmd = 'seg.%s = %g' % (as2, val)
                    exec(cmd)

    def calculate_distribution(self, d3, dist, a4, a5, a6, a7, g8):
        # d3 is the distribution type:
        #     0 linear, 1 sigmoid, 2 exponential
        #     3 step for absolute distance (in microns)
        # dist is the somatic distance
        # a4-a7 are distribution parameters 
        # g8 is the maximal conductance
        if   d3 == 0: 
            value = a4 + a5*dist
        elif d3 == 1: 
            value = a4 + a5/(1 + exp((dist-a6)/a7) )
        elif d3 == 2: 
            value = a4 + a5*exp((dist-a6)/a7)
        elif d3 == 3:
            if (dist > a6) and (dist < a7):
                value = a4
            else:
                value = a5
                
        if value < 0:
            value = 0
            
        value = value*g8
        return value

    def get_dendrites(self, distance_to_soma = 80):
        distal_ind = []; proximal_ind = []; middle_ind = [];
        
        for ind, dend in enumerate(self.dendlist):
            if h.distance(0, sec = dend) >= distance_to_soma:
                distal_ind.append(ind)
            elif h.distance(1, sec = dend) <= distance_to_soma:
                proximal_ind.append(ind)
            else:
                middle_ind.append(ind)
                
        return distal_ind, proximal_ind, middle_ind

    
    def insert_spines(self, section_list, start_pos, end_pos, num_spines = 20):
        spine_step = 1.0/num_spines
        for sec in section_list:
            for i in range(0, num_spines):
                pos = end_pos - (end_pos - start_pos)*i*spine_step
                spine_name = 'spine_' + self.dendlist[sec].name() + '(' + str(pos) + ')'
                s = sp.Spine(self.dendlist[sec], spine_name)
                self.spines.append(s)            
                self.spines[-1].attach(self.dendlist[sec], pos, 0)                    
