COMMENT
Updated Exp2Syn synapse with Mg-blocked nmda channel.

Defaul values of parameters (time constants etc) set to match synaptic channels in 
striatal medium spiny neurons (Du et al., 2017; Chapman et al., 2003; Ding et al., 2008).

Robert . Lindroos @ ki . se

original comment:
________________
Two state kinetic scheme synapse described by rise time tau1,
and decay time constant tau2. The normalized peak condunductance is 1.
Decay time MUST be greater than rise time.

The solution of A->G->bath with rate constants 1/tau1 and 1/tau2 is
 A = a*exp(-t/tau1) and
 G = a*tau2/(tau2-tau1)*(-exp(-t/tau1) + exp(-t/tau2))
	where tau1 < tau2

If tau2-tau1 -> 0 then we have a alphasynapse.
and if tau1 -> 0 then we have just single exponential decay.

The factor is evaluated in the
initial block such that an event of weight 1 generates a
peak conductance of 1.

Because the solution is a sum of exponentials, the
coupled equations can be solved as a pair of independent equations
by the more efficient cnexp method.

ENDCOMMENT






NEURON {
	POINT_PROCESS glutamate_ica_nmda
	RANGE tau1_ampa, tau2_ampa, tau1_nmda, tau2_nmda
	RANGE erev_ampa, erev_nmda, g, i
	NONSPECIFIC_CURRENT i
	
	RANGE i_ampa, i_nmda, g_ampa, g_nmda, w_ampa, w_nmda, I, G, mg, q, alpha, eta
	USEION ca_nmda WRITE ica_nmda VALENCE 2
}


UNITS {
	(nA) = (nanoamp)
	(mV) = (millivolt)
	(uS) = (microsiemens)
}


PARAMETER {
	erev_ampa        = 0.0       (mV)
	erev_nmda        = 15.0       (mV)
	
	tau1_ampa   = 1.9       (ms)
    tau2_ampa   = 4.8       (ms)  : tau2 > tau1
    tau1_nmda   = 5.52      (ms)  : old value was 5.63
    tau2_nmda   = 231       (ms)  : tau2 > tau1
    
    mg          = 1         (mM)
    alpha       = 0.062
    eta 	= 18
    q           = 2
    w_ampa = 0.2e-3 (uS)
    w_nmda = 1e-3 (uS)
}


ASSIGNED {
	v (mV)
	i (nA)
	g (uS)
	factor_nmda
	factor_ampa
	i_ampa
	i_nmda
	g_ampa
	g_nmda
	block
	I
	G
        ica_nmda (nA)
}


STATE {
	A (uS)
	B (uS)
	C (uS)
	D (uS)
}



INITIAL {
	LOCAL tp
	if (tau1_nmda/tau2_nmda > .9999) {
		tau1_nmda = .9999*tau2_nmda
	}
	if (tau1_ampa/tau2_ampa > .9999) {
		tau1_ampa = .9999*tau2_ampa
	}
	
	: NMDA
	A           = 0
	B           = 0
	tp          = (tau1_nmda*tau2_nmda)/(tau2_nmda - tau1_nmda) * log(tau2_nmda/tau1_nmda)
	factor_nmda = -exp(-tp/tau1_nmda) + exp(-tp/tau2_nmda)
	factor_nmda = 1/factor_nmda
	
	: AMPA
	C           = 0
	D           = 0
	tp          = (tau1_ampa*tau2_ampa)/(tau2_ampa - tau1_ampa) * log(tau2_ampa/tau1_ampa)
	factor_ampa = -exp(-tp/tau1_ampa) + exp(-tp/tau2_ampa)
	factor_ampa = 1/factor_ampa
}




BREAKPOINT {
	SOLVE state METHOD cnexp
	
	: NMDA
	g_nmda = (B - A)*w_nmda
	block  = MgBlock()
	i_nmda = g_nmda * (v - erev_nmda) * block
	ica_nmda = i_nmda
	
	: AMPA
	g_ampa = (D - C)*w_ampa
	i_ampa = g_ampa * (v - erev_ampa)
	
	: total current
	G = g_ampa + g_nmda
	I = i_ampa 
    	i = I
}



DERIVATIVE state {
	A' = -A/tau1_nmda*q
	B' = -B/tau2_nmda*q
	C' = -C/tau1_ampa
	D' = -D/tau2_ampa
}



NET_RECEIVE(weight (uS)) {
	A = A + factor_nmda
	B = B + factor_nmda
	C = C + factor_ampa
	D = D + factor_ampa
}



FUNCTION MgBlock() {
    
    MgBlock = 1 / (1 + mg * eta * exp(-alpha * v)  )
    
}




