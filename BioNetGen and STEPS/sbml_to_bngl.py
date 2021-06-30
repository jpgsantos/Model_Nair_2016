import pandas as pd
import numpy as np
import re
import libsbml
from libsbml import *
from decimal import Decimal

def transform(fxml, fbngl, transform_units=False, adapt_steps=False, converter='pysb'):
    is_sbml_model=False
    if converter=='plain':
        dsbml, mdl = read_sbml(fxml)
        if dsbml is None :
            return None, None
        is_sbml_model=True
        print('write plain bngl...')
        write_plain_bngl(dsbml, fbngl)
        print('done')
        
    elif converter=='pysb':
        import pysb
        from pysb.importers.sbml import sbml_translator
        fbngl = sbml_translator(fxml, output_file=fbngl, convention_file=None,
                                             naming_conventions=None,
                                    user_structures=None, molecule_id=False, 
                                    atomize=False, pathway_commons=False, verbose=False)   
    
    if bool(adapt_steps):
        default_steps = ['transform_names','transform_units','clamp_species']
        if ('list_of_steps' in adapt_steps.keys()):
            if ('all' in adapt_steps['list_of_steps'])==True:
                adapt_steps['list_of_steps'] = default_steps
        #else:
        #    adapt_steps.update({'list_of_steps': default_steps})
            
        
        # read bngl file
        with open(fbngl, 'r') as file:
            #data = file.read().replace('\n', '')
            sbngl = file.read()
        
        # find main sections
        sbngl2 = re.split('\n',sbngl)
        bngl_sections = ['parameters','compartments','molecule types','species','observables','functions','reaction rules']
        bngl_sections2 = pd.DataFrame(['parameters','compartments','molecule','species','observables','functions','reaction'])
        df_sections = pd.DataFrame(np.zeros((len(bngl_sections),2)),index=bngl_sections,columns=['begin','end']).astype(int)
        for i,s in enumerate(sbngl2): 
            s2=re.split('\W',s.strip())
            if len(s2)>1:
                if (bngl_sections2==s2[1]).any()[0]: # s contains section name
                    if (s2[0]=='begin'):
                        df_sections.loc[s2[1],s2[0]]=i+1
                    if (s2[0]=='end'):
                        df_sections.loc[s2[1],s2[0]]=i-1    
            
    
        #print(df_sections)  
        df_sbngl2 = pd.DataFrame(sbngl2)
        #sbngl2
        
        # read sbml if needed
        if is_sbml_model==False:
            #document = readSBML(fxml )
            #errors = document.getNumErrors()
            #print('number of errors in sbml: ',document.getNumErrors() )
            #mdl = document.getModel()
            dsbml, mdl = read_sbml(fxml)
            is_sbml_model=True
        
        
        if 'transform_names' in adapt_steps['list_of_steps']:
            # get list of all sbml elements, transform names if needed
            el=mdl.getListOfAllElements()
            #print(len(el))
            nel = el.getSize()
            el_id  = []
            el_nm =[]
            el_nm2 =[]
            ind_reac=0
            for i in range(0,nel):
                el_idi=el.get(i).getId()
                el_id = el_id + [el_idi]
                elni = el.get(i).getName()
                if (len(elni)==0)&(len(el_idi)>0):
                    ind=df_sbngl2.index[df_sbngl2[0].str.contains(el_idi)]
                    if len(ind)==1:
                        if (ind>=df_sections['begin']['reaction'])&(ind<=df_sections['end']['reaction']):
                            elni = 'reaction'+str(ind_reac)
                            ind_reac=ind_reac+1

                el_nm = el_nm + [elni]
                rex = re.compile('\*')
                elni2 = re.sub(rex,'_x_',elni)
                rex = re.compile('\s')
                elni2 = re.sub(rex,'_',elni2)
                el_nm2 = el_nm2 + [elni2]
            #print(nel)    
            df = pd.DataFrame({'name': el_nm,'name2': el_nm2, 'id' : el_id})

            # substitute incorrect names in bngl
            #
            sbngl2 = sbngl
            el_con = []
            for i in range(0,len(el_id)):
                rex = re.compile(el_id[i])
                if rex.search(sbngl2):
                    el_con = el_con  + [1]
                else:
                    el_con = el_con  + [0] 

                if len(el_nm[i])>0:
                     sbngl2 = re.sub(el_id[i], el_nm2[i], sbngl2)

            sbngl3 = re.split('\n',sbngl2)

            fbngl2 = re.split('\.bngl',fbngl)[0]+'_adapted.bngl'
            #print(fbngl2)
            #print(fbngl)
            with open(fbngl2, 'w') as file:
                #data = file.read().replace('\n', '')
                file.write(sbngl2 )

            # make a dataframe with aligned original and adapted bngl lines
            sbngl4 = re.split('\n',sbngl)
            dfbngl = pd.DataFrame({'transformed': sbngl3, 'original': sbngl4})  
            # make a dataframe with elements
            df = pd.DataFrame({'name': el_nm,'name2': el_nm2, 'is_in_bngl' : el_con, 'id' : el_id})
        else:
            sbngl4 = re.split('\n',sbngl)
            dfbngl = pd.DataFrame({'transformed': sbngl4, 'original': sbngl4})
            
        
        # adapt bngl
        #
        if 'transform_units' in adapt_steps['list_of_steps']:
            # modify input units if needed
            if 'input_units_table' in adapt_steps.keys():
                in_out_units = adapt_steps['in_out_units_table']
                dsbml = transform_input_units(dsbml, in_out_units)
            
            
            if ('output_mode' in adapt_steps.keys())==False:
                adapt_steps.update({'output_mode':'steps'})
                print("to select between steps and nfsim otput mode set adapt_steps['output_mode']='steps', otherwise steps output bngl file will be produced")

            # find units transformation factors
            dsbml = kinetic_rates_units_transform_factors(dsbml, input_mode='auto', factors=None)
            dsbml = substance_units_transform_factors(dsbml, input_mode='auto', factors=None)

        # modify bngl
        dfbngl = modify_bngl(dfbngl, dsbml, adapt_steps)
        
        print('save modified bngl file...')

        sbngl_alt2 = '\n'.join(dfbngl.loc[:,'transformed'])
        fbngl2 = re.split('\.bngl',fbngl)[0]+'_alternative.bngl'
        with open(fbngl2, 'w') as file:
            #data = file.read().replace('\n', '')
            file.write(sbngl_alt2 )

        print('done')     
        
    return fbngl, mdl    


def modify_bngl(dfbngl, dsbml, adapt_steps):

    #dsbml = {'compartments': cmps2,'parameters': pars2, 'functions': funs2, 'species': spes2, 'units': uns2, 'reactions': Ki }
    uns2 = dsbml['units']
    spes2 = dsbml['species']
    cmps2 = dsbml['compartments']
    pars2 = dsbml['parameters']
    funs2 = dsbml['functions']
    Ki = dsbml['reactions']

    # modify bngl file
    # modify : 
    #          compartment volume - to 1.0
    #          functions remove - / 6.022e23
    #          double sites - rename?
    #          k-rates parameters
    #          initial concentrations
    #          reactions 2D+3D - convert to absorbtion+1compartment chain
    #          fixed species -> to parameters
    #          if, and other functions? -- initial model level
    #          stimulation?
    #          time variable?
    # add:
    #         comp volume parameter
    #         kinetic rates transform parameters
    #         Na
    #         STEPS and NFsim switch?
    #         stimulation by clamped concentration defined by an expression?
    #         automatic rnf (stimulation file)
    #         automatic geometry json file?
    #         read diffusions?
       
    if 'transform_units' in adapt_steps['list_of_steps']:
        #modify species (by units factors)
        startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin species')][0]+1
        endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end species')][0]
        dfbngl_se = dfbngl.loc[startf:endf,:]
        ## spes3 : one to one correspondence with species section in bngl - !!!! - Should be found in a more stable way!!!
        #spes3 = spes2.loc[((spes2.loc[:,'init_c']>0)+(spes2.loc[:,'is_constant']) + (spes2.loc[:,'is_boundary_c'])>0),:]
        # spes3 - use id in comments?
        spes3 = spes2

        for i in range(len(spes3.index)):
            s_nm = spes3.iloc[i,:]['name']
            s_id = spes3.iloc[i,:]['id']
            s_init_c = spes3.iloc[i,:]['init_c']
            s_fac = spes3.iloc[i,:]['c_nm']

            #s_bngl = dfbngl_se.iloc[i]['transformed']
            ind_bngl = dfbngl_se.index[ dfbngl_se.loc[:,'original'].str.contains(s_id)]
            all_s_id_in_bngl = dfbngl_se.loc[ind_bngl,'original']
            for isp2 in ind_bngl:
                sp_bngl=parse_species_bngl(all_s_id_in_bngl[isp2])
                sp_bngl = re.split('\(',sp_bngl.loc[0,'species'])[0]

                #if s_id==sp_bngl.strip():
                if s_nm==sp_bngl.strip():    
                    ind_bngl = isp2
                    break

            s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
            s_bngl = re.split('\s+',s_bngl.strip())
            s_bngl_end = ''
            if len(s_bngl)>2:
                s_bngl_end = ' '.join(s_bngl[2:])
            #s_bngl2=re.split('\W+',s_bngl)
            #s_bngl2[1]=str(s_init_c)+'*'+s_fac
            dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+' '+ str(s_init_c)+'*'+s_fac+ ' # '+s_bngl_end
            #ind_bngl = dfbngl_se.index[ dfbngl_se.loc[:,'original'].str.contains(s_id)][0]


        #modify kinetic rates
        startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin parameters')][0]+1
        endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end parameters')][0]
        dfbngl_se = dfbngl.loc[startf:endf,:]

        for i in range(len(Ki.index)):
            k_nm = Ki.iloc[i,:]['name']
            k_id = Ki.iloc[i,:]['id']
            k_val = Ki.iloc[i,:]['value']
            k_fac = Ki.iloc[i,:]['k2k_nm_r']

            ind_bngl = dfbngl_se.index[ dfbngl_se.loc[:,'original'].str.contains(k_id)][0]
            s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
            s_bngl = re.split('\s+',s_bngl.strip())
            s_bngl_end = ''
            if len(s_bngl)>2:
                s_bngl_end = ' '.join(s_bngl[2:])
            #dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+' '+ s_bngl[1]+'*'+k_fac
            #dfbngl.loc[ind_bngl,'transformed'] = k_nm+' '+ str(k_val)+'*'+k_fac
            dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+'   '+ str(k_val)+'*'+k_fac + s_bngl_end

            if Ki.loc[i,'id_b']!=0: 
                k_nm = Ki.iloc[i,:]['name_b']
                k_id = Ki.iloc[i,:]['id_b']
                k_val = Ki.iloc[i,:]['value_b']
                k_fac = Ki.iloc[i,:]['k2k_nm_p']

                ind_bngl = dfbngl_se.index[ dfbngl_se.loc[:,'original'].str.contains(k_id)][0]
                s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
                s_bngl = re.split('\s+',s_bngl.strip())
                s_bngl_end = ''
                if len(s_bngl)>2:
                    s_bngl_end = ' '.join(s_bngl[2:])
                #dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+' '+ s_bngl[1]+'*'+k_fac
                #dfbngl.loc[ind_bngl,'transformed'] = k_nm+' '+ str(k_val)+'*'+k_fac
                dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+'   '+ str(k_val)+'*'+k_fac + s_bngl_end


    #   compartment volume - set to 1.0    
    startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin compartments')][0]+1
    endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end compartments')][0]
    dfbngl_se = dfbngl.loc[startf:endf,:]

    for i in range(len(cmps2.index)):
        k_nm = cmps2.iloc[i,:]['name']
        k_id = cmps2.iloc[i,:]['id']
        k_val = cmps2.iloc[i,:]['volume']

        ind_bngl = dfbngl_se.index[ dfbngl_se.loc[:,'original'].str.contains(k_id)][0]
        s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
        s_bngl = re.split('\s+',s_bngl.strip())
        #dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+' '+ s_bngl[1]+'*'+k_fac
        #dfbngl.loc[ind_bngl,'transformed'] = k_nm+' '+ str(k_val)+'*'+k_fac
        dfbngl.loc[ind_bngl,'transformed'] = s_bngl[0]+'   3   1.0' 


    #   functions remove : / 6.022e23
    startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin functions')][0]+1
    endf   = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end functions')][0]
    dfbngl_se = dfbngl.loc[startf:endf,:]
    for i in range(len(dfbngl_se.index)):
        ind_bngl = dfbngl_se.index[i]
        s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
        s_bngl = re.split('/ 6.022e23',s_bngl)
        s_bngl = ' '.join(s_bngl)
        s_bngl = re.split('\*  1.0',s_bngl)
        s_bngl = ' '.join(s_bngl)
        dfbngl.loc[ind_bngl,'transformed'] = s_bngl

    
    #   multisite reactions:
    #                  rename sites in molecules, species, rules
    #                  find all equations -> find their correspondences in sbml -> recover rates from sbml file                 
    #
    startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin molecule types')][0]+1
    endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end molecule types')][0]-1
    dfbngl_se = dfbngl.loc[startf:endf,:]
    Mu = []
    nmu=0
    for i in range(len(dfbngl_se.index)):
        ind_bngl = dfbngl_se.index[i]
        s_bngl = dfbngl_se.loc[ind_bngl,'transformed']
        s_bngl = re.split('[()]',s_bngl.strip())
        s_nm = s_bngl[0]
        s_bngl2 = re.split('\,',s_bngl[1].strip())
        s_bngl3 = pd.Series(s_bngl2) 
        multi = []
        multi2 = []
        for ii in range(len(s_bngl2)):
            if multi2.count(s_bngl2[ii])==0:
                mii = s_bngl3.isin([s_bngl2[ii]])
                if (mii.sum()>1):
                    multi2 = multi2 + [s_bngl2[ii]] 
                    multi  = multi  + [s_bngl3.index[mii].tolist()] 
        Mu = Mu + [multi2, multi]
        nmu = nmu+len(multi2)
        if nmu>0:
            print('Warning: repeated site names of molecules should be renamed : ',nmu)
        # find all instances of multisite molecule - modify sites names
        # modify kinetic rates -> what about other modifiers? - *2 etc? - check and repair?

    #   rewrite 2D+3D (all reactions with different compartments):  find 2d+3d. - do in model!
    #


    #  input equations? - boundary conditions?
    #
    #

    if 'transform_units' in adapt_steps['list_of_steps']:
        # add parameters - units factors
        #
        #modify species
        parplus = pd.DataFrame({'transformed':[],'original':[]})

        startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin parameters')][0]
        #dfbngl = pd.concat([dfbngl.loc[:startf,:], parplus,  dfbngl.loc[startf+1:,:]])
        #endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end parameters')][0]
        #dfbngl_se = dfbngl.iloc[startf:endf,:]
        # Na, v_Spine, Na_x_v_Spine
        Na = '1.0'
        if adapt_steps['output_mode']=='nfsim':
            Na = '6.022e23'
        parplus = parplus.append({'transformed':'Na '+Na+' # set Na to 6.022e23 for NFsim, or to 1.0 for STEPS','original':''},ignore_index=True)
        for c in cmps2['name']:
            parplus = parplus.append({'transformed': 'v_'+c+' 1.0 # set to 1.0 for STEPS or to volume in liters for NFsim','original': ''},ignore_index=True)

        for c in cmps2['name']:
            parplus = parplus.append({'transformed': 'Na_x_v_'+c+' Na*v_'+c,'original': ''},ignore_index=True)    

        # kinetic rates
        k2kset = list(set(Ki.loc[:,'k2k_nm_r']).union(set(Ki.loc[:,'k2k_nm_p'])))
        k2k = pd.concat([Ki.loc[:,['k2k_nm_r','k2k_ex_r']],
                         Ki.loc[:,['k2k_nm_p','k2k_ex_p']].rename(columns={'k2k_nm_p':'k2k_nm_r', 'k2k_ex_p':'k2k_ex_r'})])
        for i in range(len(k2kset)):
            k2ki = k2k.loc[k2k.loc[:,'k2k_nm_r'].isin([k2kset[i]]),'k2k_ex_r'].iloc[0]
            if k2ki is not None:
                parplus = parplus.append({'transformed': k2kset[i] + ' '+k2ki+' # transformation of kinetic rates units, final units should be descendants of mole/liter, second for STEPS and number of molecules, second for NFsim, CHECK IT','original': ''},ignore_index=True)

        # species    
        c2cset = list(set(spes2.loc[:,'c_nm']))
        for i in range(len(c2cset)):
            c2ci = spes2.loc[spes2.loc[:,'c_nm'].isin([c2cset[i]]),'c_ex'].iloc[0]
            if c2ci is not None:
                parplus = parplus.append({'transformed': c2cset[i] + ' '+c2ci+' # transformation of concentration units,final units should be descendants of mole/liter for STEPS and number of molecules for NFsim, CHECK IT','original': ''},ignore_index=True)


        #s_bngl = dfbngl_se.iloc[i]['transformed']
        #dfbngl.loc[dfbngl_se.index[i],'transformed'] = re.split('\s+',s_bngl.strip())[0]+' '+ str(s_init_c)+'*'+s_fac
        dfbngl = pd.concat([dfbngl.loc[:startf,:], parplus,  dfbngl.loc[startf+1:,:]])

    #   clamp species:  find $ spec.
    #                   remove spec. from rules
    #                   add spec. to parameter
    #                   add spec. parameter to reaction rate - make a function or use existed
    
    if 'clamp_species' in adapt_steps['list_of_steps']:
        print('clamp concentrations of specified species...')
        if 'clamp_species_list' in adapt_steps.keys():
            clamp_species = adapt_steps['clamp_species_list'] #True
        else: 
            clamp_species = []

        startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin reaction rules')][0]+1
        endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end reaction rules')][0]
        dfbngl_re = dfbngl.loc[startf:endf,:]
    
        #dfbngl_re.to_excel('dfbngl_re.xlsx') #ACHTUNG!!!

        startf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('begin species')][0]+1
        endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end species')][0]
        dfbngl_se = dfbngl.loc[startf:endf,:]
        is_clamped = dfbngl_se.loc[dfbngl_se.loc[:,'original'].str.contains('\$'),:]
        kk=0
        paradd = pd.DataFrame({'name':[], 'value':''})
        for i0 in is_clamped.index:
            # find species expression
            #s_clam = re.split('\s+',is_clamped.loc[i,'transformed'])
            df_spec=parse_species_bngl(is_clamped.loc[i0,'transformed'])

            paradd.loc[kk,'name'] = re.split('\W+',df_spec['species'][0])[0]+'_'+df_spec['compartment'][0]+'_parameter'
            paradd.loc[kk,'value'] = df_spec['init_c'][0]


            # find species in reactions
            clamped_in_reac = dfbngl_re.loc[dfbngl_re.loc[:,'original'].str.contains(df_spec.loc[0,'species']),:] 
            for ire in clamped_in_reac.index:
                # check species in a reaction            
                s_re = clamped_in_reac.loc[ire,'transformed'] 
                df_re0, df_re = parse_reaction_bngl(s_re)

                find_spec = ((df_re['compartment']==df_spec['compartment'][0])&(df_re['species']==df_spec['species'][0]))
                if find_spec.any():
                    r_exp = (find_spec&(df_re['side']=='r')).sum()
                    p_exp = (find_spec&(df_re['side']=='p')).sum()
                    #paradd.loc[kk,'name'] = re.split('\W+',df_spec['species'][0])[0]+'_'+df_spec['compartment'][0]+'_parameter'
                    #paradd.loc[kk,'value'] = df_spec['init_c'][0]

                    if (p_exp>0):
                        # remove from products!
                        is_clamped_p = df_re.index[find_spec&(df_re['side']=='p')]
                        if p_exp!=((df_re['side']=='p').sum()):
                            df_re = df_re.drop(index=is_clamped_p)
                        else:    
                            df_re.loc[is_clamped_p,'string'] = '0'

                        if df_re0['is_reversible'][0]:
                            # add to kinetic rate
                            #df_re0.loc[0,'kr'] = df_re0.loc[0,'kr'] + '*('+paradd.loc[kk,'name']+')^'+str(int(p_exp)) 
                            sss =  df_re0.loc[0,'kr']
                        
                            for iii in range(int(p_exp)):
                                sss = sss + '*('+paradd.loc[kk,'name']+')'
                            df_re0.loc[0,'kr'] = sss    

                    if r_exp>0:
                        # remove from reactants!
                        is_clamped_r = df_re.index[find_spec&(df_re['side']=='r')]
                        if r_exp!=((df_re['side']=='r').sum()):
                            df_re = df_re.drop(index=is_clamped_r)
                        else:  
                            df_re.loc[is_clamped_r,'string'] = '0'
                        # add to kinetic rate


                        #df_re0.loc[0,'kf'] = df_re0.loc[0,'kf'] + '*('+ paradd.loc[kk,'name']+')^'+str(int(r_exp)) 
                        sss =  df_re0.loc[0,'kf']
                        for iii in range(int(r_exp)):
                            sss = sss + '*('+paradd.loc[kk,'name']+')'
                        df_re0.loc[0,'kf'] = sss 
                    
                    
                #kk = kk+1

    #             if df_re0.loc[0,'name']=='reaction51':
    #                 kkk=kkk+1
    #                 if kkk==2:
    #                     blabla

                    dfbngl.loc[ire,'transformed'] = list_reaction_bngl(df_re0,df_re) #check!!!
            kk=kk+1
        # add to parameters
        endf = dfbngl.index[ dfbngl.loc[:,'original'].str.contains('end parameters')][0]
        parplus=pd.DataFrame({'original':'','transformed':[]})
        for i in paradd.index:
            parplus.loc[i,'transformed'] = paradd.loc[i,'name'] + ' ' + paradd.loc[i,'value']
            parplus.loc[i,'original'] = ''
        dfbngl = pd.concat([dfbngl.loc[:endf-1,:], parplus,  dfbngl.loc[endf:,:]]).reset_index() #check!!!
 

    return dfbngl


def getUnits(unsd):
    #unsd=mdl.getListOfUnitDefinitions()[4]
    uns0 = unsd.getListOfUnits()
    u2=[]
    u3=[]
    u4=[]
    u5=[]
    for ii in range(len(uns0)):
        u2=u2+[libsbml.UnitKind_toString(uns0[ii].getKind())]
        u3=u3+[uns0[ii].getScale()]
        u4=u4+[uns0[ii].getExponent()]
        u5=u5+[uns0[ii].getMultiplier()]
        
    uns1 = pd.DataFrame({'kind': u2, 'scale': u3, 'exponent': u4, 'mult': u5})    
    return uns1

import re

def combine_substance_units(substance_u,spatial_u):
    uns2 = pd.DataFrame({'kind': [substance_u.getKind(),spatial_u.getKind()],
                         'scale': [substance_u.getScale(),spatial_u.getScale()], 
                         'exponent': [substance_u.getExponent(),-spatial_u.getExponent()], 
                         'mult': [substance_u.getMultiplier(),spatial_u.getMultiplier()]})  ## or 1/(mult*1e3) ??????
            

    asp7 = (substance_u.getId()+'/'+spatial_u.getId()).replace('/','__')
    uns3 = pd.DataFrame({'id': [asp7], 'name': [asp7], 'units': [uns2],'unitdef': [[]]})
    
    return uns3 #asp3, asp5


def parse_SimBiology_substance_units(species,uns2):
    asp=species.getAnnotationString()

    regexp = re.compile('SimBiology')
    is_simbio=False
    asp5=''
    asp3=''
    if regexp.search(asp):
        is_simbio=True
        regexp1 = re.compile('Unit')
        if regexp1.search(asp):
            asp1 = re.split('Unit',asp)
            asp1 = re.split('\n',asp1[1])

            regexp3 = re.compile('Numerator')
            if regexp3.search(asp1[0]):
                asp2 = re.split('Numerator',asp1[0])
                asp2 = re.split('\"',asp2[1])
                asp3 = asp2[1]

            regexp4 = re.compile('Denominator')
            if regexp4.search(asp1[0]):
                asp4 = re.split('Denominator',asp1[0])
                asp4 = re.split('\"',asp4[1])
                asp5 = asp4[1]
                
        prefix = ['yotta','zetta','exa','peta','giga','mega','kilo','hecto','deca','deci','centi','milli','micro' ,'nano','pico','femto','atto','zepto','yocto']
        prefix2= ['Y',    'Z',    'E',  'P',   'G',   'M',   'K',   'H',     'D',  'd',   'c',    'm',    'u',    'n',    'p',   'f',    'a',   'z',    'y']
        mult =   10.0**np.arange(21,-25,-3)
        mult = np.concatenate([mult[0:7],[1e2, 1e1, 1e-1, 1e-2],mult[8:]])
        pref = pd.DataFrame({'prefix': prefix, 'prefix2': prefix2, 'mult': mult})

        #second= pd.DataFrame(['s','second'])
        meter = pd.DataFrame(['m','meter','metre'])
        liter = pd.DataFrame(['l','liter','litre'])
        mole  = pd.DataFrame(['mol','mole'])
        M     = pd.DataFrame(['M','mole/liter','mole/litre','molarity'])    

        matching = [s for s in pref['prefix'] if s in asp3]
        if len(matching)>0:
            substance=re.split(matching[0],asp3)
            mult1 = pref.loc[pref.loc[:,'prefix']==matching[0],'mult'].values[0]
        else: 
            substance=['',asp3]
            mult1 = 1e0

        no_denominator=False
        if (mole==substance[1]).any().values[0]:
            uns = pd.DataFrame({'kind': ['mole'], 'scale': [0.0], 'exponent': [1.0], 'mult': [1.0]}) 
        elif (M==substance[1]).any().values[0]:
            no_denominator==True
            uns = pd.DataFrame({'kind': ['mole','litre','dimensionless'], 'scale': [0.0,0.0,0.0], \
                                'exponent': [1.0,-1.0,1.0], 'mult': [1.0,1.0,mult1*1e0]})  ## or 1/(mult*1e3) ??????
        else:
            print("WARNING: unknown SimBiology substance unit, 'mole' units will be used by default ")
            print(substance[1],asp3,asp5,asp,asp1)
            uns = pd.DataFrame({'kind': ['mole'], 'scale': [0.0], 'exponent': [1.0], 'mult': [1.0]}) 


        if (no_denominator==False)&(asp5!=''):
            matching2 = [s for s in pref['prefix'] if s in asp5]
            if len(matching2)>0:
                substance2=re.split(matching2[0],asp5)
                mult2 = 1/pref.loc[pref.loc[:,'prefix']==matching2[0],'mult'].values[0]
            else: 
                substance2=['',asp5]
                mult2 = 1e0
            #ssubstunce2 = pd.Series(substance2[1])
            matching4 = [s for s in meter[0] if s in substance2[1]]
            matching5 = [s for s in liter[0] if s in substance2[1]]
            if len(matching4)>0: #(meter==substance2[1]).sum()==1: #any(meter==substance2[1]):
                mult2 = mult2*1.0e-3
            elif len(matching5)>0: #(liter==substance2[1]).sum()==1: #any(liter==substance2[1]):
                mult2 = mult2*1.0
            else:
                print("WARNING: unknown substance unit, 'mole/liter' units will be used by default")  
                mult2=1.0

            #uns2 = pd.DataFrame({'kind': ['metre','dimensionless'], 'scale': [0.0,0.0], \
            #                    'exponent': [-3.0,1.0], 'mult': [1.0,mult1*mult2]})  ## or 1/(mult*1e3) ??????
            uns2 = pd.DataFrame({'kind': ['litre'], 'scale': [0.0], 
                                'exponent': [-1.0], 'mult': [1.0]})  
            uns.loc[0,'mult'] = mult1*mult2*uns.loc[0,'mult']
            uns = pd.concat([uns,uns2])

        else:
            if (asp5!=''):
                print("WARNING: unknown SimBiology concentration unit, 'mole/liter' units will be used by default ")   
                uns = pd.DataFrame({'kind': ['mole','litre'], 'scale': [0.0,0.0], 
                                    'exponent': [1.0,-1.0],   'mult' : [1.0,1.0]})  
                
        if len(asp5)>0:
            asp6 = '/'+asp5
        asp7 = (asp3+asp6).replace('/','__')
        uns3 = pd.DataFrame({'id': [asp7], 'name': [asp3+asp6], 'units': [uns],'unitdef': [[]]})
        
    else:
        print("WARNING: unknown concentration units, 'mole/liter' units will be used by default")
        print(asp)
        print(species)
        
        uns = pd.DataFrame({'kind': ['mole','litre'], 'scale': [0.0,0.0], 
                            'exponent': [1.0,-1.0],   'mult':  [1.0,1.0]}) 
        uns3 = pd.DataFrame({'id': ['mole__litre'], 'name': ['mole/litre'], 'units': [uns],'unitdef': [[]]})

    return uns3 #asp3, asp5

def  transform_input_units(dsbml, input_units):
    
    return dsbml

def K_transform_2(k_u_f):
    fac_t_c = 0
    kinetic_basic_units = ['dimensionless','metre','meter','litre','liter','second','sec','mole','mol']
    for i in k_u_f.index:
        scale2 = k_u_f.loc[i,'scale']
        if (k_u_f.loc[i,'kind']=='metre')|(k_u_f.loc[i,'kind']=='meter'):
            scale2 = k_u_f.loc[i,'scale']+1
        
        fac_t_c = fac_t_c - (fexp(k_u_f.loc[i,'mult']) +scale2 )*k_u_f.loc[i,'exponent'] # ACHTUNG!!! check - if scale combines this way with exponent!!!
        if (k_u_f.loc[i,'kind'] in kinetic_basic_units)==False:
            print('WARNING : unknown kinetic rate units')   
    
                       
    return fac_t_c


def K_transform(k_u_f):
    units_c =['nanomolarity','micromolarity','millimolarity','molarity']
    # define time units transformation to seconds 
    if k_u_f.find('millisecond')>-1:
        fac_t=-3
    elif k_u_f.find('microsecond')>-1:
        fac_t=-6
    elif k_u_f.find('second')>-1:
        fac_t=0
    else:
        print('unknown time units in '+str(i)+' reaction kinetic rate')
        fac_t=0

    # define concentration units transformation to mole/liter 
    iuc=-1
    if   k_u_f.find('picomolarity')>-1:
        fac_c=-12
        iuc=0
    elif k_u_f.find('nanomolarity')>-1:
        iuc=1
        fac_c=-9    
    elif k_u_f.find('micromolarity')>-1:
        iuc=2
        fac_c=-6
    elif k_u_f.find('millimolarity')>-1:
        iuc=3
        fac_c=-3
    elif k_u_f.find('molarity')>-1:
        iuc=4
        fac_c=0    
    else:
        print('unknown concentration units in '+str(i)+' reaction kinetic rate?')
        fac_c=0

    # define order of reaction
    r_order=0
    if iuc>-1:
        is1=k_u_f.find(units_c[iuc]) +len(units_c[iuc])+1  
        if k_u_f[is1]=='^':
            if k_u_f[is1+1]=='-':
                r_order=-int(k_u_f[is1+2])
            else:
                r_order=int(k_u_f[is1+1])
        elif k_u_f[is1:is1+2]==')^':
            if k_u_f[is1+2]=='-':
                r_order=-int(k_u_f[is1+3])
            else:
                r_order=int(k_u_f[is1+2])
        else:
            r_order=1
                            
    return fac_t, fac_c, r_order 


def K2K_2(fac_t_c,rp_cmp,rp_exp):

#     if fac_t>=0:
#         fac_t2=str(int(fac_t))
#     else:    
#         fac_t2='m'+str(abs(int(fac_t)))
#     if fac_c>=0:
#         fac_c2=str(int(fac_c))
#     else:    
#         fac_c2='m'+str(abs(int(fac_c)))    
    if fac_t_c>=0:
        fac_tc2=str(int(fac_t_c))
    else:    
        fac_tc2='m'+str(abs(int(fac_t_c)))
    #k2k_nm = 'k2k_'+fac_t2+'_'+fac_c2+'_'
    k2k_nm = 'k2k_'+fac_tc2+'_'  #str(int(fac_t_c))+'_'
    k2k_ex = '1/1e'+str(int(fac_t_c)) #+'*'+'1/1e'+str(fac_c)
    for j in range(len(rp_cmp)):
        k2k_nm = k2k_nm + str(int(rp_exp[j]))+'x'+rp_cmp[j]+'_'
        sj=''
        jj=0
        if j==0:
            sj='-1'
            jj=-1
            
        #k2k_ex = k2k_ex +'*'+'1/(Na_x_v_'+rp_cmp[j]+')^('+str(rp_exp[j])+sj+')'
        
        sss =  k2k_ex 
        jj1 = int(rp_exp[j]+jj)
        for ii in range(abs(jj1)):
            if jj1>0:
                sss = sss + '*'+'1/(Na_x_v_'+rp_cmp[j]+')'
            else:
                sss = sss + '*'+'(Na_x_v_'+rp_cmp[j]+')'
        k2k_ex = sss
        
    return  k2k_nm, k2k_ex   

def K2K_(fac_t,fac_c,rp_cmp,rp_exp):

    if fac_t>=0:
        fac_t2=str(fac_t)
    else:    
        fac_t2='m'+str(abs(fac_t))
    if fac_c>=0:
        fac_c2=str(fac_c)
    else:    
        fac_c2='m'+str(abs(fac_c))    

    k2k_nm = 'k2k_'+fac_t2+'_'+fac_c2+'_'
    k2k_ex = '1/1e'+str(fac_t)+'*'+'1/1e'+str(fac_c)
    for j in range(len(rp_cmp)):
        k2k_nm = k2k_nm + str(rp_exp[j])+'x'+rp_cmp[j]+'_'
        sj=''
        if j==0:
            sj='-1'
        k2k_ex = k2k_ex +'*'+'1/(Na_x_v_'+rp_cmp[j]+')^('+str(rp_exp[j])+sj+')'
        
    return  k2k_nm, k2k_ex   


def kinetic_rates_units_transform_factors(dbngl, input_mode='auto', factors=None):
    uns2 = dbngl['units']
    Ki = dbngl['reactions']
    
    # transform K in bngl
    if input_mode=='manual':
        fac_t = factors['time']
        fac_c = factors['substance']
        
    #output='NFsim'
    #fac_c1=1e-9 # additional transformation of concentrations due to SBtab->MATLAB error
    # transform K in bngl

    Ki9=[]
    Ki11=[]
    for i in range(Ki.shape[0]):
        Ki10=[]
        Ki12=[]
        if input_mode == 'auto':
            # define volume of compartment  +                  
            # reactants_id -> compartments_id -> compartments volume variables  +
            # create units modifications coefficients
            k_u = Ki.loc[i,'unit']  # units of Kinetic rate i id

            #k_u_f = df['name'][df['id'].str.contains(k_u)].values[0] # expression for units of Kinetic rate i
            #fac_t, fac_c, r_order = K_transform(k_u_f) # time and substance factors , e.g. ms, nM etc
            k_u_f = uns2['units'][uns2['id']==k_u].values[0].reset_index(drop=True) #uns2['units'][uns2['id'].str.contains(k_u)].values[0] # expression for units of Kinetic rate i
            fac_t_c = K_transform_2(k_u_f) # time and substance factors , e.g. ms, nM etc

            rp = Ki.loc[i,'r_all']   # references to reactant species
            #rp_exp = Ki.loc[i,'r_exp']  # reactant species syochiometry
            #rp_cmp = Ki.loc[i,'r_cmp']  # volumes of reactants compartments
            rp_exp = Ki.loc[i,'r_exp_all']  # reactant species syochiometry
            rp_cmp = Ki.loc[i,'r_cmp_all']  # volumes of reactants compartments        
            #k2k_nm, k2k_ex = K2K_(fac_t,fac_c,rp_cmp,rp_exp)  # name and expression for 
            k2k_nm, k2k_ex = K2K_2(fac_t_c,rp_cmp,rp_exp)  # name and expression for 

            Ki10 = Ki10+[k2k_nm]
            Ki12 = Ki12+[k2k_ex]

            if Ki.loc[i,'id_b']!=0: 
                k_ub = Ki.loc[i,'unit_b']
                #k_u_fb = df['name'][df['id'].str.contains(k_ub)].values[0]
                #fac_tb, fac_cb, r_orderb = K_transform(k_u_fb)
                k_u_fb = uns2['units'][uns2['id']==k_ub].values[0].reset_index(drop=True) #uns2['units'][uns2['id'].str.contains(k_ub)].values[0] # expression for units of Kinetic rate i
                fac_t_cb = K_transform_2(k_u_fb) # time and substance factors , e.g. ms, nM etc

                rpb = Ki.loc[i,'p_all']
                #rp_expb = Ki.loc[i,'p_exp']
                #rp_cmpb = Ki.loc[i,'p_cmp']
                rp_expb = Ki.loc[i,'p_exp_all']  # product species syochiometry
                rp_cmpb = Ki.loc[i,'p_cmp_all']  # volumes of products compartments 
                #k2k_nmb, k2k_exb = K2K_(fac_tb,fac_cb,rp_cmpb,rp_expb)
                k2k_nmb, k2k_exb = K2K_2(fac_t_cb,rp_cmpb,rp_expb) 

                Ki10 = Ki10+[k2k_nmb]
                Ki12 = Ki12+[k2k_exb]

            Ki9=Ki9+[Ki10]
            Ki11=Ki11+[Ki12]

    Ki9  = pd.DataFrame(Ki9,columns=['k2k_nm_r','k2k_nm_p'])   
    Ki11 = pd.DataFrame(Ki11,columns=['k2k_ex_r','k2k_ex_p'])   

    Ki  = pd.concat([Ki,Ki9,Ki11],axis=1)                                                            
    dbngl['reactions']  = Ki  
    return dbngl

def C_transform_2(s_u_f):
    fac_c = 0
    concentration_basic_units = ['dimensionless','metre','meter','litre','liter','mole','mol','molarity']
    for i in s_u_f.index:
        scale2=s_u_f.loc[i,'scale'] 
        if (s_u_f.loc[i,'kind']=='metre')|(s_u_f.loc[i,'kind']=='meter'):
            scale2 = s_u_f.loc[i,'scale'] +1
        fac_c = fac_c + (fexp(s_u_f.loc[i,'mult']) +s_u_f.loc[i,'scale'] )*s_u_f.loc[i,'exponent'] # ACHTUNG!!! check - if scale combines this way with exponent and multiplier !!!
        if (s_u_f.loc[i,'kind'] in concentration_basic_units)==False:
            print('warning: unknown concentration units')
                       
    return fac_c

def C2C_(fac_c, c_cmp): #, init_c):

    if fac_c>=0:
        fac_c2=str(int(fac_c))
    else:    
        fac_c2='m'+str(abs(int(fac_c)))    

    c_nm = 'c2c_'+fac_c2+'_'+c_cmp
    #c_ex = str(init_c)+'*1e'+str(fac_c) +'*'+'(Navog_x_v_'+c_cmp+')'
    c_ex = '1e'+str(int(fac_c)) +'*'+'(Na_x_v_'+c_cmp+')'
        
    return  c_nm, c_ex   

def substance_units_transform_factors(dbngl, input_mode='auto', factors=None):
    uns2 = dbngl['units']
    spes2 = dbngl['species']
    
    if input_mode=='manual':        
        fac_c = factors['substance']
        #fac_c1=-9 # additional transformation of concentrations due to SBtab->MATLAB error
        
    S7 = []
    S8 = []
    for i in spes2.index:
        s_u = spes2.loc[i,'unit']  # units of Kinetic rate i id
        if any(uns2['id']==s_u):
            #fac_c = fac_c1  # should be fac_c = C_transform(s_u_f) if C units are valid
            if input_mode=='manual':
                fac_c = factors['substance']
            else:
                s_u_f = uns2['units'][uns2['id']==s_u].values[0].reset_index(drop=True)  # expression for units of Kinetic rate i
                fac_c = C_transform_2(s_u_f)
            
            rp_cmp = spes2.loc[i,'compartment_name']  # volumes of reactants compartments
            c_nm, c_ex = C2C_(fac_c,rp_cmp)  # name and expression for 
            
        else: 
            c_nm = 'c2c_none'
            c_ex = '1e0'    

        S7 = S7+[c_nm]
        S8 = S8+[c_ex]  

    S7  = pd.DataFrame(S7,columns=['c_nm'])   
    S8  = pd.DataFrame(S8,columns=['c_ex'])   
   
    spes2  = pd.concat([spes2,S7,S8],axis=1)                                    
    dbngl['species']  = spes2  
    return dbngl

def read_sbml(fxml):
    print('read document ...')
    document = readSBML(fxml )
    errors = document.getNumErrors()

    mdl = document.getModel()
    if document.getNumErrors()>0:
        print('errors at reading sbml file : ',document.getNumErrors(), ' errors were ancountered' )
        print(document)
        return  None, None #'stop reading document'
    
    print('read units ...')
    uns = mdl.getListOfUnitDefinitions() #.getListOfAllElements()
    u2=[]
    u3=[]
    u4=[]
    u5=[]
    for i in range(len(uns)):
        if type(uns[i]) is libsbml.UnitDefinition:
            u2 = u2 +[uns[i].getId()]
            u3 = u3 +[uns[i].getName()]
            u4 = u4 +[uns[i]]
            u5 = u5 +[getUnits(uns[i])]
    uns2 = pd.DataFrame({'id': u2, 'name': u3, 'units': u5,'unitdef': u4})
    
    print('read compartments ...')
    cmps = mdl.getListOfCompartments()
    cmpsids=[]
    cmpsus=[]
    cmpsnms  = []
    for i in range(len(cmps)):
        nm_cmp = cmps[i].getName()
        mid_cmp = cmps[i].getVolume()
        id_cmp = cmps[i].getId()

        cmpsids = cmpsids + [id_cmp]
        cmpsus = cmpsus + [mid_cmp]
        cmpsnms = cmpsnms + [nm_cmp]

    cmps2 = pd.DataFrame([cmpsids,cmpsus,cmpsnms],index=['id','volume','name']).T    
    #cmps2.head()
    
    print('read functions...')
    funs = mdl.getListOfFunctionDefinitions()
    
    funsids=[]
    funsus=[]
    funsnms  = []
    funsexps = []
    for i in range(len(funs)):
        nm_pars = funs[i].getName()
        nm_units = funs[i].getUnits()
        mid_pars = funs[i].getMetaId()
        id_pars = funs[i].getId()
        funsids = funsids + [id_pars]
        funsus = funsus + [nm_units]
        funsnms = funsnms + [nm_pars]
        funsexps = funsexps + [funs[i].getMath()]
        #rex = re.compile(nm_pars[i])
        #if rex.search(sbngl2):
        #    el_con = el_con  + [1]
        #else:
        #    el_con = el_con  + [0]
    funs2 = pd.DataFrame([funsids,funsus,funsnms,funsexps],index=['id','unit','name','expression']).T 

    #funs2.head() 
    
    print('read species...')
    spes = mdl.getListOfSpecies()
    spesids = []
    spesus  = []
    spesnms    = []
    spescmps   = []
    spescmps2  = []
    spescmps3  = []
    spescmps4  = []
    spescmps5  = []
    for i in range(len(spes)):
        nm_pars = spes[i].getName()

        #hasOnlySubstanceUnits="false" - search for units in annotations
        if spes[i].isSetHasOnlySubstanceUnits():
            
            if spes[i].getHasOnlySubstanceUnits():
                spa_uid = spes[i].getCompartment().getUnits()
                sub_uid = spes[i].getUnits()
                #print(spa_uid)
                #print(sub_uid)
                sub_u=uns2.loc[uns2.loc[:,'id']==sub_uid,:]
                spa_u=uns2.loc[uns2.loc[:,'id']==spa_uid,:]
                #print(spa_u)
                #print(sub_u)
                #uns3 = combine_substance_units(substance_u,spatial_u)
                sbu2 = sub_u.loc[sub_u.index[0],'units']
                spu2 = spa_u.loc[spa_u.index[0],'units']
                #print(spu2)
                uns4 = pd.DataFrame({ 'kind':     [sbu2.getKind(),      spu2.getKind()],
                                      'scale':    [sbu2.getScale(),     spu2.getScale()], 
                                      'exponent': [sbu2.getExponent(), -spu2.getExponent()], 
                                      'mult':     [sbu2.getMultiplier(),spu2.getMultiplier()] })  #### or 1/(mult*1e3) ??????
            

                asp7 = (substance_u.getId()+'/'+spatial_u.getId())
                uns3 = pd.DataFrame({'id': [asp7.replace('/','__')], 'name': [asp7], 'units': [uns4],'unitdef': [[]]})
                is_unit=uns3.loc[0,'id'] in uns2.loc[:,'id'].tolist()
            else:
                if spes[i].getUnits() in uns2.loc[:,'id'].tolist():
                    nm_units = spes[i].getUnits()
                    is_unit=True
                    
                else:
                    uns3 = parse_SimBiology_substance_units(spes[i],uns2)
                    is_unit=uns3.loc[0,'id'] in uns2.loc[:,'id']

            if is_unit==False:         
                for iu in uns2.index:
                    ui = uns2.loc[iu,'units']
                    if uns3.loc[0,'units'].equals(ui):
                        nm_units = uns2.loc[iu,'id']
                        is_unit=True
                        break
            if is_unit==False: 
                uns2 = pd.concat([uns2, uns3]).reset_index(drop=True)
                nm_units = uns3.loc[0,'id'] #spes[i].getUnits()
        else:    
            nm_units = spes[i].getUnits()

        mid_pars = spes[i].getMetaId()
        id_pars = spes[i].getId()
        spesids = spesids + [id_pars]
        spesus  = spesus + [nm_units]
        spesnms = spesnms + [nm_pars]
        spescmps = spescmps + [spes[i].getCompartment()]
        #cmp_name = cmps2.loc[cmps2.loc[:,'id'].isin([spes[i].getCompartment()]),'name'][0]
        cmp_name = cmps2.loc[cmps2.loc[:,'id'].isin([spes[i].getCompartment()]),'name'].iloc[0]
        spescmps2 = spescmps2 + [cmp_name]

        init_c = spes[i].getInitialConcentration()
        spescmps3 = spescmps3 + [init_c]   

        is_fixed = spes[i].getConstant()
        spescmps4 = spescmps4 + [is_fixed] 

        is_fixed2 = spes[i].getBoundaryCondition()
        spescmps5 = spescmps5 + [is_fixed2]

    spes2 = pd.DataFrame([spesids,spesus,spesnms,spescmps,spescmps2,spescmps3,spescmps4,spescmps5],index=['id','unit','name','compartment_id','compartment_name','init_c','is_constant','is_boundary_c']).T 

    #spes2.head()
    
    print('read parameters...')
    pars = mdl.getListOfParameters()
    parsids=[]
    parsus=[]
    parsnms  = []
    parsvs  = []
    for i in range(len(pars)):
        nm_pars = pars[i].getName()
        nm_units = pars[i].getUnits()
        mid_pars = pars[i].getMetaId()
        id_pars = pars[i].getId()
        parsids = parsids + [id_pars]
        parsus = parsus + [nm_units]
        parsnms = parsnms + [nm_pars]
        parsvs = parsvs + [pars[i].getValue()]
    pars2 = pd.DataFrame([parsids,parsus,parsnms,parsvs],index=['id','unit','name','value']).T   
    
    #print('read unit definitions...')
    #uns = mdl.getListOfUnitDefinitions().getListOfAllElements()
    #u2=[]
    #u3=[]
    #for i in range(len(uns)):
    #    if type(uns[i]) is libsbml.UnitDefinition:
    #        u2 = u2 +[uns[i].getId()]
    #        u3 = u3 +[uns[i].getName()]
    #uns2 = pd.DataFrame({'id': u2, 'name': u3})
        
    
    print('read reactions...')
    reacs = mdl.getListOfReactions()
    Ki = pd.DataFrame(np.zeros((len(reacs),10)),
                      columns = ['id','unit','name','value','ind','id_b','unit_b','name_b','value_b','ind_b'])
    sparsids = pd.Series(parsids)
    ij=0;
    Ki11=[]
    Ki3 = []
    Ki5 = []
    Ki7 = []
    Ki9 = []
    Ki32 = []
    Ki52 = []
    Ki72 = []
    Ki92 = []
    for i in range(len(reacs)):
        nm_reac = reacs[i].getName()
        mid_reac = reacs[i].getMetaId()
        id_reac = reacs[i].getId()

        fori=reacs[i].getKineticLaw().getFormula()
        lfi=re.split('\W+',fori)
        lfi2=pd.Series(re.split('\-',fori))
        is_in_fi = sparsids.isin(lfi)
        pari=sparsids.loc[is_in_fi]
        lj = is_in_fi.sum()
        Ki2=[]
        Ki4=[]
        Ki6=[]
        Ki8=[]
        Ki22=[]
        Ki42=[]
        Ki62=[]
        Ki82=[]
        for j in range(lj): #is_in_fi.any():
            ind_par_ri = is_in_fi.index[is_in_fi][j]
            Ki.iloc[i,0+5*j] = parsids[ind_par_ri]
            Ki.iloc[i,1+5*j] = parsus[ind_par_ri]
            Ki.iloc[i,2+5*j] = parsnms[ind_par_ri]
            Ki.iloc[i,3+5*j] = parsvs[ind_par_ri]
            Ki.iloc[i,4+5*j] = ind_par_ri

            i2=lfi2.index[lfi2.str.contains(parsids[ind_par_ri])][0]  # part of rate equation 
            pr_spec = spes2.loc[spes2.loc[:,'id'].isin(lfi) ,:] # all reactants and products
            rp = pr_spec.loc[pr_spec.loc[:,'id'].isin(re.split('\W+',lfi2.loc[i2])),'id'].tolist() # reactant associated with k[j]
            rp2 = pr_spec.loc[pr_spec.loc[:,'id'].isin(re.split('\W+',lfi2.loc[i2])),'compartment_name'].tolist()
            rp3 = pr_spec.loc[pr_spec.loc[:,'id'].isin(re.split('\W+',lfi2.loc[i2])),'name'].tolist() # reactant associated with k[j]

            Ki2 = Ki2 +[rp]
            Ki4 = Ki4 +[rp2]
            Ki6 = Ki6 +[[1]*len(rp)]  # stocheometry
            Ki8 = Ki8 +[rp3]        

        for j in range(2):
            rp5=[]
            rp4=[]
            rp32=[]
            rp22=[]
            if j==0:
                rp_ = reacs[i].getListOfReactants()
            else:
                rp_ = reacs[i].getListOfProducts()
            for subs in rp_:    
                rp5 = rp5 +[subs.species]
                rp4 = rp4 +[subs.stoichiometry]
                rp32 = rp32 + spes2.loc[spes2.loc[:,'id'].isin([subs.species]) ,'name'].tolist()
                rp22 = rp22 + spes2.loc[spes2.loc[:,'id'].isin([subs.species]) ,'compartment_name'].tolist()
            ##Ki.loc[i,4+j] = [rp]
            #rp32 = spes2.loc[spes2.loc[:,'id'].isin(rp5) ,'name'].tolist()
            #rp22 = spes2.loc[spes2.loc[:,'id'].isin(rp5) ,'compartment_name'].tolist()
            ##rp32 = pr_spec.loc[:,'name'].tolist()
            Ki22 = Ki22 +[rp5]
            Ki42 = Ki42 +[rp22]
            Ki62 = Ki62 +[rp4]  # stocheometry
            Ki82 = Ki82 +[rp32]

        Ki3=Ki3 + [Ki2]
        Ki5=Ki5 + [Ki4]
        Ki7=Ki7 + [Ki6]
        Ki9=Ki9 + [Ki8]

        Ki11=Ki11 + [reacs[i].getId()]

        Ki32=Ki32 + [Ki22]
        Ki52=Ki52 + [Ki42]
        Ki72=Ki72 + [Ki62]
        Ki92=Ki92 + [Ki82]
        #udl0 = reacs[i].getKineticLaw().getDerivedUnitDefinition()
        #udl=udl0.getListOfUnits() #getUnit(1)  #getListOfUnits()[1] #getFormula()
        #for u in udl:
            #print(u.getMultiplier(),u.getScale(),u.getKind(),u.getExponent())
        #print(udl0.getAnnotationString())

        #udl1 = reacs[i].getKineticLaw().getListOfParameters()
        ##udl=udl0.getListOfUnits() #getUnit(1)  #getListOfUnits()[1] #getFormula()
        #for u in udl1:
        #    print(u.getName(),u.getID())


        #print('\n')

    Ki11 = pd.DataFrame(Ki11,columns=['id_reac'])     

    Ki3 = pd.DataFrame(Ki3,columns=['r','p'])   
    Ki5 = pd.DataFrame(Ki5,columns=['r_cmp','p_cmp'])   
    Ki7 = pd.DataFrame(Ki7,columns=['r_exp','p_exp']) 
    Ki9 = pd.DataFrame(Ki9,columns=['r_nm','p_nm']) 

    Ki32 = pd.DataFrame(Ki32,columns=['r_all','p_all'])  
    Ki52 = pd.DataFrame(Ki52,columns=['r_cmp_all','p_cmp_all']) 
    Ki72 = pd.DataFrame(Ki72,columns=['r_exp_all','p_exp_all']) 
    Ki92 = pd.DataFrame(Ki92,columns=['r_nm_all','p_nm_all'])
    Ki  = pd.concat([Ki,Ki3,Ki5,Ki7,Ki9,Ki32,Ki52,Ki72,Ki92,Ki11],axis=1)


    #Ki.head()  
    dsbml = {'compartments': cmps2,'parameters': pars2, 'functions': funs2, 'species': spes2, 'units': uns2, 'reactions': Ki }                  
    return dsbml, mdl  



def fexp(number):
    (sign, digits, exponent) = Decimal(number).as_tuple()
    return len(digits) + exponent - 1

def fman(number):
    return Decimal(number).scaleb(-fexp(number)).normalize()


def conv_name(s):
    s2 = '_'.join(re.split('\W+',s))
    return s2   
    
def write_plain_bngl(dsbml, fbngl):
    uns2  = dsbml['units']                  
    pars2 = dsbml['parameters']
    cmps2 = dsbml['compartments']
    funs2 = dsbml['functions']
    spes2 = dsbml['species']
    Ki    = dsbml['reactions']    
     
    # write plain bngl
    sbngl_alt=['begin model']

    sbngl_alt=sbngl_alt+['begin parameters']
    for i in pars2.index:
        sbngl_alt=sbngl_alt+[conv_name(pars2.loc[i,'name'])+' '+str(pars2.loc[i,'value']) + '    # '+ str(pars2.loc[i,'id'])]
    sbngl_alt=sbngl_alt+['end parameters']

    sbngl_alt=sbngl_alt+['begin compartments']
    for i in cmps2.index:
        sbngl_alt=sbngl_alt+[conv_name(cmps2.loc[i,'name'])+' '+'3 1.0    '+'# '+cmps2.loc[i,'id'] +', v '+str(cmps2.loc[i,'volume'])]
    sbngl_alt=sbngl_alt+['end compartments']

    sbngl_alt=sbngl_alt+['begin molecule types']
    for i in spes2.index:
        sbngl_alt=sbngl_alt+[conv_name(spes2.loc[i,'name'])+'()'+'    # '+str(spes2.loc[i,'id']) ]
    sbngl_alt=sbngl_alt+['end molecule types']

    sbngl_alt=sbngl_alt+['begin species']
    for i in spes2.index:
        is_clamped=''
        if (spes2.loc[i,'is_constant']==True)|(spes2.loc[i,'is_boundary_c']==True):
            is_clamped='$'
        sbngl_alt=sbngl_alt+[is_clamped + conv_name(spes2.loc[i,'name'])+'()@'+conv_name(spes2.loc[i,'compartment_name'])+ 
                             ' '+str(spes2.loc[i,'init_c'])+'    # '+spes2.loc[i,'id']+
                             ', is_const '+str(spes2.loc[i,'is_constant'])+ 
                             ', is_boundary '+str(spes2.loc[i,'is_boundary_c']) ]
    sbngl_alt=sbngl_alt+['end species']

    sbngl_alt=sbngl_alt+['begin observables']
    for i in spes2.index:
        sbngl_alt=sbngl_alt+['Molecules ' +conv_name(spes2.loc[i,'name']) +' '+ '@'+conv_name(spes2.loc[i,'compartment_name'])+ ':' +conv_name(spes2.loc[i,'name'])+'()'+'    # '+str(spes2.loc[i,'id']) ]
    sbngl_alt=sbngl_alt+['end observables']

    sbngl_alt=sbngl_alt+['begin functions']
    for i in funs2.index:
        sbngl_alt=sbngl_alt+[conv_name(funs2.loc[i,'name'])+'() = '+funs2.loc[i,'expression']+'    # '+str(funs2.loc[i,'id']) ]
    sbngl_alt=sbngl_alt+['end functions']

    sbngl_alt=sbngl_alt+['begin reaction rules']
    for i in Ki.index:
        reaci = 'reaction'+str(i)+': '
        for j in range(len(Ki.loc[i,'r_nm_all'])):
            for jx in range(int(Ki.loc[i,'r_exp_all'][j])): 
                if (j>0)or(jx>0):
                    reaci = reaci +' + '   
                reaci = reaci + conv_name(Ki.loc[i,'r_nm_all'][j])+'()@'+conv_name(Ki.loc[i,'r_cmp_all'][j])

        is_rev = Ki.loc[i,'id_b']!=0
        if is_rev:
            reaci = reaci + ' <-> '
        else:
            reaci = reaci + ' -> '

        for j in range(len(Ki.loc[i,'p_nm_all'])):
            for jx in range(int(Ki.loc[i,'p_exp_all'][j])):
                if (j>0)or(jx>0):
                    reaci = reaci +' + '
                reaci = reaci + conv_name(Ki.loc[i,'p_nm_all'][j])+'()@'+conv_name(Ki.loc[i,'p_cmp_all'][j])    

        reaci = reaci +' '+ conv_name(Ki.loc[i,'name'])
        if is_rev:
            reaci = reaci + ', '+  conv_name(Ki.loc[i,'name_b'])  

        #sbngl_alt=sbngl_alt+[reaci+'    # '+str(reacs[i].getId()) ]
        sbngl_alt=sbngl_alt+[reaci+'    # '+Ki.loc[i,'id_reac'] ]
        
    sbngl_alt=sbngl_alt+['end reaction rules']

    sbngl_alt=sbngl_alt+['end model']

    sbngl_alt2 = '\n'.join(sbngl_alt)
    #fbngl2 = re.split('\.',fbngl)[0]+'_plane.bngl'
    with open(fbngl, 'w') as file:
        #data = file.read().replace('\n', '')
        file.write(sbngl_alt2 )
        

def parse_reaction_bngl(s_re):
    # parse a bngl reaction          
    df_re = pd.DataFrame({'side':'', 'string':'', 'species':'',
                          'name':'', 'compartment':'', 'sites':[]})
    df_re2 = pd.DataFrame({'kf':'', 'kr':'', 'name':[],
                          'comment':'','is_reversible':''})

    s_re1 = re.split('<->',s_re)
    is_rev=1
    df_re2.loc[0,'is_reversible'] = True
    if len(s_re1)==1:
        df_re2.loc[0,'is_reversible'] = False
        is_rev=0
        s_re1 = re.split('->',s_re)  
        
    s_re2 = re.split('\+',s_re1[0])  
    s_re3 = re.split('\:',re.split('\@',s_re2[0])[0])  
    s_re_name=''
    if len(s_re3)>1:
        s_re_name = s_re3[0].strip()
    df_re2.loc[0,'name']=s_re_name

    s_re2[0] = re.split(':', re.split(s_re_name,s_re2[0].strip())[1].strip() )[1].strip()  
    for i in range(len(s_re2)): 
        df_re.loc[i,'side']='r'
        df_re.loc[i,'string']=s_re2[i].strip()
        s_re3 = re.split('[\@\:]',s_re2[i].strip())
        if (len(s_re3)==3)&(s_re3[0]==''):
            df_re.loc[i,'compartment']=s_re3[1].strip()
            df_re.loc[i,'species']=s_re3[2].strip()
        elif (len(s_re3)==2)&(s_re3[0]!=''): 
            df_re.loc[i,'compartment']=s_re3[1].strip()
            df_re.loc[i,'species']=s_re3[0].strip()
        else:
            df_re.loc[i,'compartment']=''
            df_re.loc[i,'species']=s_re3[0].strip()

        s_re4 = re.split('[\(\)]',df_re.loc[i,'species'])
        df_re.loc[i,'name'] = s_re4[0] 
        if len(s_re4)>1:
            df_re.loc[i,'sites'] = re.split(',',s_re4[1])

    s_re2 = re.split('\+',s_re1[1]) 
    s_re3 = re.split('\#',s_re2[-1])
    s_re2[-1] = s_re3[0]
    s_re_comment=''
    if len(s_re3)>1:
        s_re_comment = s_re3[1].strip()
    df_re2.loc[0,'comment']=s_re_comment

    if is_rev==1:    
        s_re3 = re.split('\,',s_re2[-1].strip())
        s_re2[-1] = s_re3[0]   
        df_re2.loc[0,'kr']=s_re3[1].strip()

    s_re3 = re.split('\s+',s_re2[-1].strip())
    df_re2.loc[0,'kf']=s_re3[-1].strip()
    s_re2[-1]=re.split(df_re2.loc[0,'kf'],s_re2[-1].strip())[0]
    lr=len(df_re.index)
    for i in range(len(s_re2)): 
        df_re.loc[lr+i,'side']='p'
        df_re.loc[lr+i,'string']=s_re2[i].strip()
        s_re3 = re.split('[\@\:]',s_re2[i].strip())
        if (len(s_re3)==3)&(s_re3[0]==''):
            df_re.loc[lr+i,'compartment']=s_re3[1].strip()
            df_re.loc[lr+i,'species']=s_re3[2].strip()
        elif (len(s_re3)==2)&(s_re3[0]!=''): 
            df_re.loc[lr+i,'compartment']=s_re3[1].strip()
            df_re.loc[lr+i,'species']=s_re3[0].strip()
        else:
            df_re.loc[lr+i,'compartment']=''
            df_re.loc[lr+i,'species']=s_re3[0].strip()

        s_re4 = re.split('[\(\)]',df_re.loc[lr+i,'species'])
        df_re.loc[lr+i,'name'] = s_re4[0] 
        if len(s_re4)>1:
            df_re.loc[lr+i,'sites'] = re.split(',',s_re4[1])

    return  df_re2, df_re  


def parse_species_bngl(s_re):
        df_re = pd.DataFrame({'prefix':[], 'string':'', 'species':'', 'compartment':'','sites':'', 'init_c':'',
                          'comment':''})
        s_re1 = re.split('\#',s_re.strip())
        is_com=0
        if len(s_re1)>1:
            is_com=1
            df_re.loc[0,'comment']=s_re1[1]
        if (len(s_re1[0])>0):
            s_re2 = re.split('\s+',s_re1[0].strip())
            df_re.loc[0,'init_c']=s_re2[1]
            
            s_re3 = re.split('[0-9A-Za-z@\_]+',s_re2[0].strip())
            df_re.loc[0,'prefix']=s_re3[0]
            s_re2[0]=re.split('[\ '+s_re3[0]+']',s_re2[0].strip())[-1] 
           
            
            df_re.loc[0,'string']=s_re2[0].strip()
            s_re3 = re.split('[\@\:]',s_re2[0].strip())
            if (len(s_re3)==3)&(s_re3[0]==''):
                df_re.loc[0,'compartment']=s_re3[1].strip()
                df_re.loc[0,'species']=s_re3[2].strip()
            elif (len(s_re3)==2)&(s_re3[0]!=''): 
                df_re.loc[0,'compartment']=s_re3[1].strip()
                df_re.loc[0,'species']=s_re3[0].strip()
            else:
                df_re.loc[0,'compartment']=''
                df_re.loc[0,'species']=s_re3[0].strip()
        return df_re
    
def list_reaction_bngl(fd_re2,fd_re):
    #df_re = pd.DataFrame({'side':'', 'string':'', 'species':'',
    #                      'name':'', 'compartment':'', 'sites':[]})
    #df_re2 = pd.DataFrame({'kf':'', 'kr':'', 'name':'',
    #                      'comment':'','is_reversible':''})
    s_bngl = ''
    s_bngl = s_bngl + fd_re2.loc[0,'name']+': '
    #ind = df_re.index[df_re.loc[:,'side']=='r']
    ind = fd_re.index[fd_re.loc[:,'side']=='r']
    for i in range(len(ind)):
        s_plus = ''
        if i>0:
            s_plus = ' + '
        s_bngl = s_bngl + s_plus  + fd_re.loc[ind[i],'string'] #fd_re.loc[ind[i],'species'] + '@'+fd_re.loc[ind[i],'compartment'] #fd_re.loc[ind[i],'string']
    
    s_arr = ' -> '
    if fd_re2.loc[0,'is_reversible']:
        s_arr = ' <-> '
    s_bngl = s_bngl + s_arr 
    
    #ind = df_re.index[df_re.loc[:,'side']=='p']
    ind = fd_re.index[fd_re.loc[:,'side']=='p']
    for i in range(len(ind)):
        s_plus = ''
        if i>0:
            s_plus = ' + '
        s_bngl = s_bngl + s_plus  + fd_re.loc[ind[i],'string'] #fd_re.loc[ind[i],'species'] + '@'+fd_re.loc[ind[i],'compartment'] #fd_re.loc[ind[i],'string']
        
    s_bngl = s_bngl + ' ' + fd_re2.loc[0,'kf']
    if fd_re2.loc[0,'is_reversible']:
        s_bngl = s_bngl + ', '+ fd_re2.loc[0,'kr']
    
    if len(fd_re2.loc[0,'comment'])>0:
        s_bngl = s_bngl + '    #'+ fd_re2.loc[0,'comment']
    return s_bngl