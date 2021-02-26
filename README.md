Nair_2016
=========

Model taken from Nair et all.
We replaced custom functions for CAMKII phosphorilation qith mass action equations

# Reactions chosen for parameter estimation and Global Sensitivity Analysis

* CaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> CaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* CaMKII_CaM_Ca4_CaMKII_CaM_Ca4 <=> pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4 <=> pCaMKII_CaM_Ca4 + pCaMKII_CaM_Ca4
* CaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd <=> pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd <=> pCaMKII_CaM_Ca4_psd + pCaMKII_CaM_Ca4_psd

# Tools to run the model

https://github.com/jpgsantos/Subcellular_workflow

# References

Nair, A.G., Bhalla, U.S., Kotaleski J.H. (2016). Role of DARPP-32 and ARPP-21 in the emergence of temporal constraints on striatal Calcium and Dopamine integration. PLoS Computational Biology, 1;12(9):e1005080. 