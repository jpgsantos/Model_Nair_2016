# -*- coding: utf-8 -*-
"""
Created on Thu Sep 19 14:18:11 2019

@author: daniel
"""
from neuron import h
import parameters as p

class Spine():
    """
    Spine class. Create a spine with neck and head.
    Based on Mattioni and Le Novere, (2013).
    https://senselab.med.yale.edu/ModelDB/ShowModel.cshtml?model=150284&file=/TimeScales-master/neuronControl/spine.py#tabs-2
    """
    
    def __init__(self, sec, id,         
                       neck_L = p.neck_L,      
                       neck_dia = p.neck_diam,
                       neck_Ra = p.neck_Ra,   
                       head_L = p.head_L,                          
                       head_dia = p.head_diam,    
                       head_Ra = p.head_Ra     ):
        """ Create a spine with geometry given by the arguments"""
        
        self.id         =   id
        self.neck       =   self.create_neck(neck_L, neck_dia, neck_Ra)
        self.head       =   self.create_head(self.neck, head_L, head_dia, head_Ra)
        self.parent     =   None # the parent section connected to the neck
        self.syn_on = 0 # Is there a synapse attached to the spine
        
    
    def create_neck(self, neck_L, neck_dia, Ra):
        """ Create a spine neck"""
        
        name_sec        =   self.id + "_neck"
        neck = h.Section(name = name_sec)
        neck.nseg       =   1
        neck.L          =   neck_L 
        neck.diam       =   neck_dia
        neck.Ra         =   Ra 
        neck.cm         =   1.0
        
        for mech in [   'pas',      \
                        'cav32',    \
                        'cav33',    \
                        'cadyn'     ]:
            neck.insert(mech)
        neck.g_pas      =   1.25e-5
        neck.e_pas      =   -85 
        
        return neck
    
        
    def create_head(self, neck, head_L, head_dia, Ra):
        """Create the head of the spine and populate it with channels"""
        
        name_sec        =   self.id + "_head"
        head = h.Section(name = name_sec)        
        head.nseg       =   1
        head.L          =   head_L
        head.diam       =   head_dia
        head.Ra         =   Ra
        head.cm         =   1.0
        
        for mech in [   'pas',      \
                        'kir',      \
                        'cat32',    \
                        'cat33',    \
                        'car',      \
                        'cal12',    \
                        'cal13',    \
                        'cadyn',    \
                        'caldyn',   \
                        'cadyn_nmda',
                        'Nair_2016']:

            head.insert(mech)
        
        head.g_pas      =   1.25e-5
        head.e_pas      =   -85
        
        head.taur_cadyn_nmda = p.taur_cadyn_nmda
        head.scale_cadyn_nmda = p.scale_cadyn_nmda
        head.cainf_cadyn_nmda = p.cainf_cadyn_nmda
        head.cainf_cadyn_nmda = p.cainit_cadyn_nmda
        
        head.connect(neck(1),0)
        
        return head
    
            
    def attach(self, parentSec, parentx, childx):
        """Attach a spine to a parentSec and store the parentSec into an attribute.
        Just an handy variation of the connect method"""
        self.neck.connect(parentSec, parentx, childx)
        self.parent = parentSec
        self.pos = parentx
