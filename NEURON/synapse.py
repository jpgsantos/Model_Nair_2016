# -*- coding: utf-8 -*-
"""
Created on Wed Jan 23 18:55:32 2019

@author: daniel
"""

class Synapse(object):
    """Generic synapse class."""
    def __init__(self):
        self.type = None
        self.sec = None
        self.pos = None
        self.obj = None
        self.source = None
        self.ref_var_ampa = None
        self.ref_var_nmda = None