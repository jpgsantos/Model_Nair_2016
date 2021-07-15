TITLE Fast transient sodium current

NEURON {
    THREADSAFE
    SUFFIX naf
    USEION na READ ena WRITE ina
    RANGE gbar, gna, ina, mVhalf, hVhalf, mSlope, hSlope, taum, tauh, taun
}

UNITS {
    (S) = (siemens)
    (mV) = (millivolt)
    (mA) = (milliamp)
}

PARAMETER {
    gbar = 0.0 (S/cm2) 
    q = 1.8
    mVhalf     = -25.0 (mV)
    hVhalf     = -62.0 (mV)
    mSlope     =  -9.2 (mV)
    hSlope     =   6.0 (mV)
    taum       =   0.09 (ms)
    taun       =   0.34 (ms)
    tauh       =   0.34 (ms)
} 

ASSIGNED {
    v (mV)
    ena (mV)
    ina (mA/cm2)
    gna (S/cm2)
    minf
    mtau (ms)
    hinf
    htau (ms)
}

STATE { m h }

BREAKPOINT {
    SOLVE states METHOD cnexp
    gna = gbar*m*m*m*h
    ina = gna*(v-ena)
}

DERIVATIVE states {
    rates()
    m' = (minf-m)/mtau*q
    h' = (hinf-h)/htau*q
}

INITIAL {
    rates()
    m = minf
    h = hinf
}

PROCEDURE rates() {
    UNITSOFF
    minf = 1 / (1 + exp( (v-mVhalf) / mSlope ) )
    hinf = 1 / (1 + exp( (v-hVhalf) / hSlope ) )
    
    mtau = 0.38 + 1/( 0.6*exp((v-(-58.0))/8.0) + 1.8*exp((v-(-58.0))/(-35.0))  )
    
    if (v < - 60) {
        htau = 3.4 + 0.015*v
    }else{
        htau = 0.56 + 1.1/(1+exp((v-(-48))/15.0)) + 1.2/(1+exp((v-(-48))/4.0))
    }
        
    :mtau = 0.13 +1/(0.6*exp((v-(-58))/taum)+1.8*exp((v-(-58))/(taun)))
    :htau = 0.14 +1.2/(1+exp((v-(-32))/tauh))
    UNITSON
}


COMMENT

TODO:
update kintetics of inactivation gate below -60 mV, from linear to sigmoidal?
--------------------------------------------------------------------------------------

Original data by Ogata (1990), guinea pig, 22 C.

Genesis implementation by Kai Du <kai.du@ki.se>, MScell v9.5.

NEURON implementation by Alexander Kozlov <akozlov@csc.kth.se>, smooth
fit of mtau and htau. 

Updates by Robert Lindroos
channel kinetics updated so that natural instead of base 10 logarithm is used for 
values in Ogata 1990. This also reduces the AHP and spike frequency.
The revision of Ogata 1990, was done following a scanning of m and h gate parameters
that reduced the AHP magnitude.

Q factor of 1.8 used. Based on 
"The effect of temperature on Na currents in rat myelinated nerve fibres"
-> Q10 between 40 and 20 C 1.8-2.1
lowest value chousen since spiking is still intact and this make the cell fire slightly slower

ENDCOMMENT
