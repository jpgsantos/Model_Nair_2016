TITLE Calcium dynamics for NMDA calcium pool

NEURON {
    SUFFIX cadyn_nmda
    USEION ca_nmda READ ica_nmda, ca_nmdai WRITE ca_nmdai VALENCE 2
    RANGE pump, cainf, taur, drive, scale, ca_init
}

UNITS {
    (molar) = (1/liter) 
    (mM) = (millimolar)
    (um) = (micron)
    (mA) = (milliamp)
    (msM) = (ms mM)
    FARADAY = (faraday) (coulomb)
}

PARAMETER {
    drive = 10000 (1)
    depth = 0.1 (um)
    cainf = 130e-6 (mM)
    taur = 100 (ms)
    kb = 96 : 200 in soma
    kt = 1e-4 (mM/ms)
    kd = 1e-4 (mM)
    pump = 0.02
    scale = 1
    ca_init = 28.2653e-6
}

STATE { ca_nmdai (mM) }

INITIAL { ca_nmdai = ca_init }

ASSIGNED {
    ica_nmda (mA/cm2)
    drive_channel (mM/ms)
    drive_pump (mM/ms)
}
    
BREAKPOINT {
    SOLVE state METHOD cnexp
}

DERIVATIVE state { 
    drive_channel = -scale*drive*ica_nmda/(2*FARADAY*depth*(1+kb))
    if (drive_channel <= 0.) { drive_channel = 0. }
    drive_pump = -kt*ca_nmdai/(ca_nmdai+kd)
    ca_nmdai' = (drive_channel+pump*drive_pump+(cainf-ca_nmdai)/taur)
}

COMMENT

Original model by Wolf (2005) and Destexhe (1992).

Ca shell parameters by Evans (2012), with kb but without pump.

NEURON implementation by Alexander Kozlov <akozlov@nada.kth.se>.

ENDCOMMENT
