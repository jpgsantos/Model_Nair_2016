# -*- coding: utf-8 -*-
"""
Created on Fri Sep  1 16:36:50 2017

@author: daniel
"""

from neuron import h
import experiment as e
import parameters as p
import time
import random as rnd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import json

class Timing_Experiment(e.Experiment):
    
    def __init__(self, exptype, cell):
        super(Timing_Experiment, self).__init__()
        self.exptype = exptype
        self.cell = cell
            
        if (str(type(cell))).find('MSN') != -1:
            self.celltype = 'MSN'
        
    def insert_synapses(self, syntype, syn_loc = [], deterministic = 0, 
                        num_syns = p.distributed_input_size, add_spine = 0, on_spine = 0):
                
        if syntype == 'input_syn':
            syn_loc = []            
            for i in range(0, num_syns):
                syn_loc.append([rnd.randint(0, len(self.cell.dendlist)-1), rnd.uniform(0,1)])
            
            if deterministic == 1:
                spike_time = []
                for i in range(0, len(syn_loc)):
                    spike_time.append(rnd.uniform(p.distributed_input_start, p.distributed_input_end))
            
            counter = 0
            for loc in syn_loc:
                counter += 1
                syn = self.cell.insert_synapse('glutamate', self.cell.dendlist[loc[0]], loc[1], add_spine = add_spine, on_spine = on_spine)
                if deterministic == 1:                
                    self.add_input_generator(syn, syntype, deterministic = deterministic, numsyn = counter, start = spike_time[counter-1])
                else:
                    self.add_input_generator(syn, syntype, deterministic = deterministic, numsyn = counter)
        
        elif syntype == 'MSN':
            for dend in self.cell.dendlist:
                # Synapses according to Cheng et al. Experimental Neurobiology, 147:287-298 (1997)                
                unit_length = 20.0 # Values reported in units per 20 microns in the study
                [exc_mean, exc_sem, inh_mean, inh_sem] = self.synapse_distribution(self.celltype, dend)
                # Insert excitatory synapses in this section, 
                # This contains both an exponential and an NMDA synapse.                
                syntype = 'glutamate'
                if dend.nseg <= exc_mean:
                    freq_multiplier = exc_mean/dend.nseg
                    step = 1/dend.nseg
                    for i in range(0, dend.nseg):
                        pos = (i + (i+1))*step/2
                        self.helper_insert(syntype, pos, dend, freq_multiplier)
                else:                        
                    num_exc_syn = int(dend.L/unit_length * rnd.gauss(exc_mean,exc_sem))
                    freq_multiplier = 1.0                     
                    for i in range(0,num_exc_syn):
                        pos = rnd.uniform(0,1)
                        self.helper_insert(syntype, pos, dend, freq_multiplier)                        
                
                # Insert inhibitory synapses in this section                
                syntype = 'inhexpsyn'
                if dend.nseg <= inh_mean:
                    freq_multiplier = inh_mean/dend.nseg
                    step = 1/dend.nseg
                    for i in range(0, dend.nseg):
                        pos = (i + (i+1))*step/2
                        self.helper_insert(syntype, pos, dend, freq_multiplier)
                else:        
                    num_inh_syn = int(dend.L/unit_length * rnd.gauss(inh_mean,inh_sem))                     
                    freq_multiplier = 1.0                    
                    for i in range(0,num_inh_syn):
                        pos = rnd.uniform(0,1)
                        self.helper_insert(syntype, pos, dend, freq_multiplier)  
        
        elif syntype in ['plateau_cluster', 'glutamate_phos_sat']:
            if syntype == 'plateau_cluster':
                syntype = 'glutamate_ica_nmda'
            if deterministic == 0:
                if (type(syn_loc) == list):
                    for list_element in syn_loc:
                        if type(list_element) == list:
                            llim = list_element[1]; ulim = list_element[2];
                            loc = list_element[0]                        
                        else: # Now type(list_element) == int:
                            llim = 0.85; ulim = 1.0;
                            loc = list_element
                        for i in range(0, num_syns):
                            pos = rnd.uniform(llim, ulim)
                            syn = self.cell.insert_synapse(syntype, self.cell.dendlist[loc], pos, 
                                                           add_spine = add_spine, on_spine = on_spine)
                            self.add_input_generator(syn, syntype)
                            print(self.cell.dendlist[loc].name(), "%f" % (h.distance(llim, sec = self.cell.dendlist[loc])))
                
                elif (type(syn_loc) == dict):
                    for ind, loc in enumerate(syn_loc['loc']):
                        for i in range(0, num_syns):
                            syn = self.cell.insert_synapse(syntype, self.cell.dendlist[loc], 
                                                           syn_loc['pos'][ind], add_spine = add_spine, on_spine = on_spine)
                            self.add_input_generator(syn, syntype, 1.0 , start = syn_loc['start'][ind], 
                                                     end = syn_loc['end'][ind])
    
            elif deterministic == 1:
                if (type(syn_loc) == list):
                    for list_element in syn_loc: 
                        syn_step = 1.0/num_syns
                        for i in range(0, num_syns):
                            pos = p.cluster_end_pos - (p.cluster_end_pos - p.cluster_start_pos)*i*syn_step
                            syn = self.cell.insert_synapse(syntype, self.cell.dendlist[list_element], 
                                                           pos, add_spine = add_spine, on_spine = on_spine)
                            self.add_input_generator(syn, syntype, deterministic = deterministic, numsyn = i)

        elif syntype == 'glutamate_phos':
            syn = self.cell.insert_synapse('glutamate_phos', self.cell.spines[-1].head, 0.5)
            self.add_input_generator(syn, syntype, start = p.glutamate_phos_start, deterministic = 1, numsyn = 1)
                
    def add_input_generator(self, syn, syntype, freq_multiplier = 1, 
                            start = p.plateau_burst_start, end = p.plateau_burst_end, deterministic = 0, numsyn = 1):
        
        if deterministic == 1:
            if self.exptype =='equilibration':
                start = 1e7
            noise = 0
            start = start + numsyn*p.deterministic_interval
            number = p.num_deterministic_spikes
            interval = p.deterministic_interval
            weight = p.gAMPAmax_plateau
            
            if syntype in ['input_syn']:
                start = start
                weight = p.g_expsyn_max
            elif syntype in ['inhexpsyn_plateau']:
                weight = p.gGABAmax_plateau
                start = start + numsyn*2
                number = 3
                end = end    
            elif syntype in ['glutamate_phos']:
                start = p.glutamate_phos_start
                number = 1
                interval = 0
                weight = 1
            
        elif deterministic == 0:
            noise = 1
            if syntype in ['inhexpsyn']:
                start = 0;
                end = p.simtime
                number = (end-start) * p.irate * freq_multiplier
                interval = p.i_interval/freq_multiplier
                weight = p.g_inhexpsyn_max
                
            elif syntype in ['inhexpsyn_plateau']:
                start = p.inhibitory_burst_start
                end = p.inhibitory_burst_end
                number = (end-start) * p.inhibitory_syn_rate
                interval = p.inhibitory_syn_interval
                weight = p.gGABAmax_plateau

            elif syntype in ['expsyn_plateau', 'plateau_cluster', 
            'glutamate_phos_sat', 'glutamate_ica_nmda']:
                number = (end-start) * p.plateau_syn_rate
                interval = p.plateau_syn_interval              
                weight = 1.0
                if syntype in ['expsyn_plateau']:
                    weight = p.gAMPAmax_plateau
                elif syntype in ['plateau_cluster']:
                    weight = p.gNMDAmax_plateau
                    
            elif syntype in ['input_syn']:
                start = p.distributed_input_start
                end = p.distributed_input_end
                number = (end-start) * p.distributed_input_rate
                interval = p.distributed_input_interval
                weight = p.gAMPAmax
                
            elif syntype in ['expsyn','glutamate']:
                start = 0;
                end = p.simtime
                number = (end-start) * p.erate * freq_multiplier
                interval = p.e_interval/freq_multiplier
                weight = p.g_expsyn_max
                
        gen = h.NetStim(0.5, sec = self.presyn)
        gen.seed(int(time.time() + rnd.randint(1,10**7)))
        gen.start = start
        gen.noise = noise
        gen.number = number        
        gen.interval = interval
        
        nc = h.NetCon(gen, syn.obj)
        nc.delay = 0
        nc.weight[0] = weight
        
        if syntype in ['inhexpsyn']:
            self.istim.append(gen) 
            self.inc.append(nc)      

        elif syntype in ['inhexpsyn_plateau']:
            self.istim.append(gen) 
            self.inc.append(nc)      

        elif syntype in ['expsyn', 'plateau_cluster', 'input_syn', 
        'expsyn_plateau', 'glutamate', 'glutamate_ica_nmda', 'glutamate_phos', 'glutamate_phos_sat']:
            self.estim.append(gen)
            self.enc.append(nc)
        
        if syntype in ['glutamate_phos_sat']:        
            gen = h.NetStim(0.5, sec = self.presyn)
            gen.seed(int(time.time() + rnd.randint(1,10**7)))
            if self.exptype == 'equilibration':
                start = 1e7
            else:
                start = p.glutamate_phos_start    
            gen.start = start
            gen.noise = 0
            gen.number = 1        
            gen.interval = 1
            
            nc = h.NetCon(gen, syn.obj)
            nc.delay = 0
            nc.weight[0] = weight
            self.estim.append(gen)
            self.enc.append(nc)
            
    def set_up_recording(self, dend_record_list = [], record_step = p.record_step):
        self.dend_record_list = dend_record_list        
        self.vdlist = []
        self.tout = h.Vector()
        self.tout.record(h._ref_t, record_step)
        self.tv = h.Vector()
        self.tv.record(h._ref_t, p.record_step_v)
        self.cali = []
        self.cali_dend = []
        self.cai_nmda = []
        self.cai = []            
        self.vspine = []

        self.vs = []
        self.vs = h.Vector()
        self.vs.record(self.cell.somalist[0](0.5)._ref_v, p.record_step_v)
                                      
        if self.exptype == 'single_sec' or self.exptype == 'equilibration':
            self.species = []            
            indices = []
            for s in p.species_to_plot:
                indices.append(p.cascade_species.index(s))
            
            for i in range(0,len(p.species_to_plot)):
                self.species.append(h.Vector())
                if self.exptype == 'single_sec':    
                    cmd = 'self.cell.somalist[0](0.5)._ref_' + p.cascade_species[indices[i]] + '_Nair_2016'                                                
                elif self.exptype == 'equilibration':
                    cmd = 'self.cell.esyn[0].sec(0.5)._ref_' + p.cascade_species[indices[i]] + '_Nair_2016'                                                
                self.species[-1].record(eval(cmd), record_step)
            
        if self.exptype == 'record_ca':
            self.species = []
            self.integral = []
            self.dopamine = []
            indices = []
            for s in p.species_to_plot:
                indices.append(p.cascade_species.index(s))

            for d in dend_record_list:
                self.vdlist.append(h.Vector())
                self.vdlist[-1].record(self.cell.dendlist[d](p.pos)._ref_v, record_step)
                
                record_spinelist = [s for s in self.cell.spines if s.parent == self.cell.dendlist[d]]                                        
                spine = record_spinelist[-1]                    
                self.vspine.append(h.Vector())
                self.cai.append(h.Vector())
                self.cali.append(h.Vector())
                self.cai_nmda.append(h.Vector())
                self.cali_dend.append(h.Vector())
                self.vspine[-1].record(spine.head(0.5)._ref_v, record_step)                    
                self.cai[-1].record(spine.head(0.5)._ref_cai, record_step)
                self.cali[-1].record(spine.head(0.5)._ref_cali, record_step)
                self.cai_nmda[-1].record(spine.head(0.5)._ref_ca_nmdai, record_step)
                self.cali_dend[-1].record(self.cell.dendlist[d](p.pos)._ref_cali, record_step)
                
                self.dopamine.append(h.Vector())
                self.dopamine[-1].record(spine.head(0.5)._ref_DA_Nair_2016, record_step)
            
                for i in range(0,len(p.species_to_plot)):
                    self.species.append(h.Vector())
                    cmd = 'spine.head(0.5)._ref_' + p.cascade_species[indices[i]] + '_Nair_2016'                                                
                    self.species[-1].record(eval(cmd), record_step)
                            
            self.w_ampa = []
            
            for syn in self.cell.esyn:
                if (syn.type == 'glutamate_phos_sat'):
                    self.w_ampa.append(h.Vector())
                    self.w_ampa[-1].record(syn.obj._ref_w_ampa, record_step)
                    syn.ref_var_ampa = self.w_ampa[-1]
#                    self.integral.append(h.Vector())
#                    self.integral[-1].record(syn.obj._ref_integral, record_step)
#                    
    def plot_results(self):
#        sns.set(font_scale = 2.0)
        sns.set_style("whitegrid")                
        plt.style.use('ggplot')
                   
        if self.exptype == 'single_sec' or self.exptype == 'equilibration':
            species_10_elem = []
            for i in range(0,len(self.species)):
                species_10_elem.append(self.species[i].to_python()[0:10])
                species_10_elem[-1].insert(0, p.species_to_plot[i])
            from operator import itemgetter
            species_10_elem.sort(reverse = True, key = itemgetter(2))
            print(species_10_elem)
            for i in range(0,len(self.species)):
                print(self.species[i].to_python()[0:10], " = %s" % p.species_to_plot[i])
            for i in range(0,len(self.species)):
                print(species_10_elem[i][1:11], " = %s" % species_10_elem[i][0])
                
            figs = []    
            axes = []
            for i in range(0,len(p.species_to_plot)):
                figs.append(plt.figure())
                axes.append(figs[-1].add_subplot(111))
                axes[-1].set_ylabel(p.species_to_plot[i] + ' (nM)')
                axes[-1].set_xlabel('t')
                axes[-1].plot(self.tout, self.species[i])
            plt.show()

        if self.exptype == 'record_ca':
            fig_vs = plt.figure()
            ax_vs = fig_vs.add_subplot(111)
            ax_vs.set_ylabel('Vs')
            ax_vs.set_xlabel('t')
            ax_vs.plot(self.tv, self.vs)
            
            fig_DA = plt.figure()
            ax_DA = fig_DA.add_subplot(111)
            ax_DA.set_ylabel('DA (nM)')
            ax_DA.set_xlabel('t')
            for i in range(0,len(self.dopamine)):
                ax_DA.plot(self.tout, self.dopamine[i])

            fig_ampa_depol = plt.figure()
            ax_ampa_depol = fig_ampa_depol.add_subplot(111)
            ax_ampa_depol.set_ylabel('Vs')
            ax_ampa_depol.set_xlabel('t')
            vs = self.vs.to_python()
            start = int(p.glutamate_phos_start*p.nrn_dots_per_1ms)
            end = int((p.glutamate_phos_start+50)*p.nrn_dots_per_1ms)
            before_LTP = vs[start:end] 
#            start = int((p.glutamate_phos_start+p.glutamate_phos_interval)*p.nrn_dots_per_1ms)
#            end = int((p.glutamate_phos_start+p.glutamate_phos_interval+50)*p.nrn_dots_per_1ms)
#            after_LTP = vs[start:end]
#            t = np.linspace(0,50, len(vs[start:end]))
#            ax_ampa_depol.plot(t, before_LTP); plt.hold(True)
#            ax_ampa_depol.plot(t, after_LTP);
            
            fig_wampa = plt.figure(); 
            ax_wampa = fig_wampa.add_subplot(111);
            ax_wampa.set_ylabel('w / w0')
            ax_wampa.set_xlabel('t (ms)')
            plt.hold(True)
            for i in range(0,len(self.w_ampa)):
                ax_wampa.plot(self.tout, self.w_ampa[i]/p.gAMPAmax_plateau)

            fig_vd = plt.figure(); 
            ax_vd = fig_vd.add_subplot(111);
            ax_vd.set_ylabel('Vd')
            ax_vd.set_xlabel('t')
            plt.hold(True)
            for i in range(0,len(self.vdlist)):
                ax_vd.plot(self.tout, self.vdlist[i])
                    
            legend_list = []
            for i in self.dend_record_list:
                legend_list.append('dend[%d](%.2f) = %.2f um' % (i, p.pos, h.distance(p.pos, sec = self.cell.dendlist[i]) ))
                
            fig_cai_nmda = plt.figure(); 
            ax_cai_nmda = fig_cai_nmda.add_subplot(111);
            ax_cai_nmda.set_ylabel('[Ca]_NMDA')
            ax_cai_nmda.set_xlabel('t')
            plt.hold(True)
            for i in range(0,len(self.cai_nmda)):
                ax_cai_nmda.plot(self.tout, self.cai_nmda[i])

            if self.cell.spines != []:
                fig_vspine = plt.figure()
                ax_vspine = fig_vspine.add_subplot(111)
                ax_vspine.set_ylabel('Vspine')
                ax_vspine.set_xlabel('t')
                for v in self.vspine:
                    ax_vspine.plot(self.tout, v)
#            
            legend_list = []
            for i in self.dend_record_list:
                legend_list.append('dend[%d](%.2f) = %.2f um' % (i, p.pos,  h.distance(p.pos, sec = self.cell.dendlist[i]) ))
            
            ax_vd.legend(legend_list);  
            ax_cai_nmda.legend(legend_list);

            figs = []    
            axes = []
            for i in range(0,len(p.species_to_plot)):
                figs.append(plt.figure())
                axes.append(figs[-1].add_subplot(111))
                axes[-1].set_ylabel(p.species_to_plot[i] + ' (nM)')
                axes[-1].set_xlabel('t')
                axes[-1].plot(self.tout, self.species[i])
            
#            fig_integral = plt.figure(); 
#            ax_integral.set_ylabel('pSubstrate area')
#            ax_integral.set_xlabel('t')
#            plt.hold(True)
#            for i in range(0,len(self.integral)):
#                ax_integral.plot(self.tout, self.integral[i])
#            
            plt.show()
            return fig_vs, fig_vd, fig_cai_nmda

    def plot_helper(self, plot_what):
        self.synlist = self.get_synapse_list('adaptive_glutamate2')
        self.synlist.sort(key = lambda f: f.sec.name())

        xlabel = 't'
        if plot_what == 'wampa':
            yval = [s.ref_var_ampa for s in self.synlist]
            ylabel = 'wampa'
            yliml = p.LTD_factor*p.gAMPAmax_plateau
            ylimu = p.LTP_factor*p.gAMPAmax_plateau
        elif plot_what == 'wnmda':
            yval = [s.ref_var_nmda for s in self.synlist]
            ylabel = 'wnmda'
            yliml = p.LTD_factor*p.gNMDAmax_plateau
            ylimu = p.LTP_factor*p.gNMDAmax_plateau
        elif plot_what == 'ca_nmda':
            yval = self.cai_nmda_in_syns
            ylabel = 'ca_nmda'
        elif plot_what == 'cali':
            yval = self.cali_in_syns
            ylabel = 'cali'
        
        fig = []; axes = []; legend = []
        for i in range(0,len(self.synlist)):
            if i==0 or (self.synlist[i].sec.name() != self.synlist[i-1].sec.name()):                   
                fig.append(plt.figure())
                axes.append(fig[-1].add_subplot(111))
                plt.hold(True)
                axes[-1].set_xlabel(xlabel) 
                axes[-1].set_ylabel(ylabel)
                if plot_what == 'wampa' or plot_what == 'wnmda':
                    axes[-1].set_ylim(yliml, ylimu)
                    
                if not (i == 0):
                    axes[-2].legend(legend)
                    legend = []
            
            axes[-1].plot(self.tout, yval[i])
            
            string = '%s(%.2f) = %.2f um' % (self.synlist[i].sec.name(), self.synlist[i].pos,
                    h.distance(self.synlist[i].pos, sec = self.synlist[i].sec) )
            legend.append(string)
            
        return fig, axes
           
    def simulate(self, simtime = p.simtime, parallel = False):
        start = time.time()
        gmtime = time.gmtime(start)
        print("Starting simulation... %d:%d:%d" %(gmtime.tm_hour + 1, gmtime.tm_min, gmtime.tm_sec))
        
        if not parallel:        
            h.load_file("stdrun.hoc")
            h.init()
            h.tstop = simtime        
            p.simtime = simtime       
            fih1 = h.FInitializeHandler((self.seti_print_status))
            fih2 = h.FInitializeHandler((self.seti_steady_states))
            
            h.run()

        end = time.time()
        print("It took %.2f hours or %.4f seconds to simulate." % ((end-start)/3600 , (end-start)))

    def seti_steady_states(self, filename = p.steady_states_file):
        with open(filename, 'r', encoding = 'utf-8') as f:
            to_read = json.load(f)
            result = json.loads(to_read)
            steady_states = result['steady_states']
            for spine in self.cell.spines:
                for i in range(0,len(steady_states)):
                    cmd = 'spine.head(0.5).' + p.cascade_species[i] + '_Nair_2016' + '=' + str(steady_states[i])
                    exec(cmd)
                    
    def seti_print_status(self):
        update_points = np.arange(0, p.simtime, p.simtime/100. )
        for t in update_points:
            h.cvode.event(t, self.print_status)
    
    def print_status(self):
        print("At time t %f, total simtime %f." % (h.t, p.simtime))
        
    def calculate_aoc(self, vector):
        v = np.array(vector.to_python())
        return sum(v) - v[0]*(len(v))
        
    def get_synapse_list(self, syntype):
        synlist = []
        for syn in self.cell.esyn:
            if syn.type == syntype:
                synlist.append(syn)
        
        return synlist
        
    def insert_IClamp(self, sec, pos, num_clamps):
        self.iclamp = []
        for i in range(0,num_clamps):                   
            self.iclamp.append(h.IClamp(pos, sec=sec))
            self.iclamp[-1].amp = p.iclamp_amp 
            self.iclamp[-1].delay = p.iclamp_start + p.iclamp_delay + i*p.iclamp_periodic_delay
            self.iclamp[-1].dur = p.iclamp_dur