: this model is built-in to neuron with suffix gaba
: Schaefer et al. 2003

COMMENT
modified from epsp Hay et al (2006)

ENDCOMMENT
					       
INDEPENDENT {t FROM 0 TO 1 WITH 1 (ms)}

NEURON {
	POINT_PROCESS gaba
	RANGE onset, tau, gmax, Erev, i
	NONSPECIFIC_CURRENT i
}
UNITS {
	(nA)   = (nanoamp)
	(mV)   = (millivolt)
	(umho) = (micromho)
}

PARAMETER {
	onset = 200  (ms)    : activation time
	tau   = 5.0  (ms)    : decay time constant
	gmax  = 2e-3 (uS)    : maximum conductance        
	Erev  =-60   (mV)    : reversal potential
	v	         (mV)
}

ASSIGNED { i (nA) }


BREAKPOINT {

    i = gmax * g(t) * (v - Erev)
}


FUNCTION g(x) {	
    
    LOCAL a, e			
	
	if (x < onset) {
		g = 0
	}else{
	    a    = 1 - (x - onset) / tau
        e    = exp(a)
        g    = (x - onset) / tau * e
        
	}
}
