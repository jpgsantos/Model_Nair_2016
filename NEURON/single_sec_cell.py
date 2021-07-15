# -*- coding: utf-8 -*-
"""
Created on Thu Feb 20 16:48:48 2020

@author: daniel
"""
from neuron import h
import parameters as p
import matplotlib.pyplot as plt
import numpy as np
import neuron_cls as n

mod        = "./mod/"
params  = "./params_dMSN.json"
morphology = "./morphology/"

#h.load_file('stdlib.hoc')
#h.load_file('import3d.hoc')
#h.nrn_load_dll(mod + 'x86_64/.libs/libnrnmech.so')


class SingleSecCell(n.Neuron):
    
    def create_morphology(self):
        self.somalist = []
        self.somalist.append(h.Section())
        
    def insert_channels(self):
        self.somalist[0].insert('pas')
        self.somalist[0].insert('Nair_2016')
        self.somalist[0].insert('cadyn_nmda')
    
