Nair_2016
=========

We replaced the custom function for CaMKII autophosphorylation with mass action kinetics.

![alt text](https://github.com/jpgsantos/Model_Nair_2016/files/6181811/Figure.2.pdf)

Simplified schematics of the use case model with relevant second messengers with calcium and dopamine as inputs and  phosphorylation of a generic CaMKII substrate (purple; top right) as the output. Species of the calcium cascade are blue, and species of  the dopamine cascade are red. Lines ending in arrows represent activation and lines ending in circles represent inhibition. Time courses  of the species with a beige background are later used in parameter estimation. Readjusted from Nair et al. (2016). (B) Schematics of the  bimolecular reactions used for CaMKII autophosphorylation with yellow circles depicting fully activated CaMKII bound to calmodulin  and calcium, and blue circles depicting phosphate groups. Six newly introduced parameters are shown on the reaction arrows with their 
ID’ h . (C) T g ( ) h (Δ ={-4,-3,-2,-1,0,1,2,3,4} corresponding to E0-E8) relative to  the calcium input (zero), and a single experiment without a dopamine input (E9) 

# Reactions chosen for parameter estimation and Global Sensitivity Analysis
We estimated six parameters for CaMKII autophosphorylation that govern the CaMKII complex formation in the cytosol and the postsynaptic density (PSD). 

* CaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> CaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* CaMKII_CaM_Ca4_CaMKII_CaM_Ca4 -> pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4 -> pCaMKII_CaM_Ca4 + pCaMKII_CaM_Ca4

* CaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd -> pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd -> pCaMKII_CaM_Ca4_psd + pCaMKII_CaM_Ca4_psd

# Tools to run the model

https://github.com/jpgsantos/Subcellular_workflow

# References

Nair, A.G., Bhalla, U.S., Kotaleski J.H. (2016). Role of DARPP-32 and ARPP-21 in the emergence of temporal constraints on striatal Calcium and Dopamine integration. PLoS Computational Biology, 1;12(9):e1005080. doi: 10.1371/journal.pcbi.1005080.[Figure 2.pdf](https://github.com/jpgsantos/Model_Nair_2016/files/6181810/Figure.2.pdf)
