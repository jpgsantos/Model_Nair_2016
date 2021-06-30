TITLE Inwardly rectifying potassium current

NEURON {
    THREADSAFE
    SUFFIX kir
    USEION k READ ek WRITE ik
    RANGE gbar, gk, ik
}

UNITS {
    (S) = (siemens)
    (mV) = (millivolt)
    (mA) = (milliamp)
}

PARAMETER {
    gbar = 0.0 (S/cm2) 
    q = 3
} 

ASSIGNED {
    v (mV)
    ek (mV)
    ik (mA/cm2)
    gk (S/cm2)
    minf
    mtau (ms)
}

STATE { m }

BREAKPOINT {
    SOLVE states METHOD cnexp
    gk = gbar*m
    ik = gk*(v-ek)
}

DERIVATIVE states {
    rates()
    m' = (minf-m)/mtau*q
}

INITIAL {
    rates()
    m = minf
}

PROCEDURE rates() {
    LOCAL alpha, beta, sum
    UNITSOFF
    minf = 1/(1+exp((v-(-102))/13))
    alpha = 0.1*exp((v-(-60))/(-14))
    beta = 0.27/(1+exp((v-(-31))/(-23)))
    sum = alpha+beta
    mtau = 1/sum
    UNITSON
}


COMMENT

Original data by Steephen (2009), rat, room temp.

Genesis implementation by Kai Du <kai.du@ki.se>, MScell v9.5.

NEURON implementation by Alexander Kozlov <akozlov@csc.kth.se>, smooth
fit of mtau.

ENDCOMMENT
