Nair_2016
=========

As a use case to illustrate the workflow we have chosen a previously developed pathway model of the emergence of the eligibility trace observed in reinforcement learning in striatal direct pathway medium spiny neurons (MSN) that carry the D1 receptor (Nair et al. 2016). In this model, a synapse that receives excitatory input which leads to an increase in calcium concentration is potentiated only when the signal is followed by a reinforcing dopamine input. Fig. 1a represents a simplified model scheme illustrating these two signaling cascades, one starts with calcium as the input and the other one with dopamine. In simulation experiments the inputs are represented as a calcium train and a dopamine transient. The first cascade (species in blue) features the calcium-dependent activation of Ca2+/calmodulin-dependent protein kinase II (CaMKII) and the subsequent phosphorylation of a generic CaMKII substrate which serves as a proxy for long term potentiation (LTP) and is the main output of the model. The second cascade (species in red) represents a G-protein dependent cascade following the dopamine input and resulting in the phosphorylation of the striatal dopamine- and cAMP-regulated phosphoprotein, 32 kDa (DARPP-32) that turns into an inhibitor of protein phosphatase 1 (PP1) which  can dephosphorylate both CaMKII and its substrate. The phosphorylation of the substrate is maximal when two constraints are met. First, the time window between the calcium and dopamine inputs has to be short, corresponding to the input-interval constraint which is mediated by DARPP-32 via PP1 inhibition. Second, intracellular calcium elevation has to be followed by the dopamine input, corresponding to the input-order constraint that is mediated by another phosphoprotein, the cyclic AMP-regulated phosphoprotein, 21 kDa (ARPP-21), thanks to its ability to sequester calcium/calmodulin if dopamine arrives first.

In the originally published model, CaMKII is autophosphorylated in two compartments, both the cytosol and the post synaptic density (PSD), with a custom-written MATLAB rate function that was calculated based on the probability of two neighboring subunits being fully activated as described in Li et al. (2012). To make it possible to run the model in different software we replace the rate equation of autophosphorylation with a similar set of reactions in both compartments so that the model would only contain bimolecular reactions. The reactions represent a simplified version of the autophosphorylation reactions in Pepke et al. (2010), where in our case only the fully activated CaMKII (four Ca2+ molecules bound) can be phosphorylated. The same set of reactions is used in both compartments and the schematics is available in Fig. 1b along with the required six new parameters. We used our parameter estimation software to find and constrain parameters that preserved the behavior of the model. We used simulated data from the original model with different timings of the dopamine input relative to the calcium input (Fig. 1c) to obtain a comprehensive picture of its behavior which we want the updated model to reproduce.

![Figure 1](https://github.com/jpgsantos/Model_Nair_2016/blob/kadripajo-patch-1/files/Model%20schematics.png "Figure 1")

Figure 1. (A) Simplified schematics of the use case model with relevant second messengers, with calcium and dopamine as inputs, and  phosphorylation of a generic CaMKII substrate (purple; top right) as the output. Species of the calcium cascade are blue, and species of the dopamine cascade are red. Lines ending in arrows represent activation and lines ending in circles represent inhibition. Time courses  of the species with a beige background are later used in parameter estimation. Readjusted from Nair et al. (2016). (B) Schematics of the  bimolecular reactions used for CaMKII autophosphorylation with yellow circles depicting fully activated CaMKII bound to calmodulin  and calcium, and blue circles depicting phosphate groups. Six newly introduced parameters are shown on the reaction arrows with their ID’s in the updated model. (C) Timing (in seconds) of the dopamine input (Δt ={-4,-3,-2,-1,0,1,2,3,4} corresponding to E0-E8) relative to  the calcium input (zero), and a single experiment without a dopamine input (E9).

# Reactions chosen for parameter estimation and Global Sensitivity Analysis

Four reactions representing autophosphorylation in one compartment. The reactions represent the formation of a complex with two CaMKII monomers and a catalytic step in which one monomer phosphorylates the other.

Reactions in cytosol:
* CaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> CaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* CaMKII_CaM_Ca4_CaMKII_CaM_Ca4 -> pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4 + CaMKII_CaM_Ca4 <=> pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4
* pCaMKII_CaM_Ca4_CaMKII_CaM_Ca4 -> pCaMKII_CaM_Ca4 + pCaMKII_CaM_Ca4

Reactions in PSD:
* CaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* CaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd -> pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd + CaMKII_CaM_Ca4_psd <=> pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd
* pCaMKII_CaM_Ca4_psd_CaMKII_CaM_Ca4_psd -> pCaMKII_CaM_Ca4_psd + pCaMKII_CaM_Ca4_psd

# Tools to run the model

The scripts that reproduce figures in the Subcellular Workflow repository https://github.com/jpgsantos/Subcellular_workflow

# References

Li, L., Stefan, M.I.,. Le Novere, N. (2012). Calcium input frequency, duration and amplitude differentially modulate the relative activation of
calcineurin and CaMKII. PLoS One, 7:e43810.

Nair, A.G., Bhalla, U.S., Kotaleski J.H. (2016). Role of DARPP-32 and ARPP-21 in the emergence of temporal constraints on striatal Calcium and Dopamine integration. PLoS Computational Biology, 1;12(9):e1005080. doi: 10.1371/journal.pcbi.1005080.

Pepke, S., Kinzer-Ursem, T., Mihalas, S., Kennedy, M.B. (2010). A dynamic model of interactions of Ca2+, calmodulin, and catalytic subunits
of Ca2+/calmodulin-dependent protein kinase II. PLoS Computational Biology, 12;6(2):e1000675.
