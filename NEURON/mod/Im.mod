COMMENT
Mechanism taken from Doron et al., 2017
https://senselab.med.yale.edu/ModelDB/ShowModel.cshtml?model=231427&file=/reproduction/Im.mod#tabs-2

Reference :     Adams et al. 1982 - M-currents and other potassium currents in bullfrog sympathetic neurones

corrected rates using q10 = 2.3, target temperature 34, orginal 21

ENDCOMMENT

NEURON	{
	SUFFIX Im
	USEION k READ ek WRITE ik
	RANGE gImbar, gIm, ik
}

UNITS	{
	(S) = (siemens)
	(mV) = (millivolt)
	(mA) = (milliamp)
}

PARAMETER	{
	gImbar = 0.00001 (S/cm2) 
}

ASSIGNED	{
	v	(mV)
	ek	(mV)
	ik	(mA/cm2)
	gIm	(S/cm2)
	mInf
	mTau
	mAlpha
	mBeta
}

STATE	{ 
	m
}

BREAKPOINT	{
	SOLVE states METHOD cnexp
	gIm = gImbar*m
	ik = gIm*(v-ek)
}

DERIVATIVE states	{
	rates()
	m' = (mInf-m)/mTau
}

INITIAL{
	rates()
	m = mInf
}

PROCEDURE rates(){
  LOCAL qt
  qt = 2.3^((34-21)/10)

	UNITSOFF
		mAlpha = 3.3e-3*exp(2.5*0.04*(v - -35))
		mBeta = 3.3e-3*exp(-2.5*0.04*(v - -35))
		mInf = mAlpha/(mAlpha + mBeta)
		mTau = (1/(mAlpha + mBeta))/qt
	UNITSON
}
