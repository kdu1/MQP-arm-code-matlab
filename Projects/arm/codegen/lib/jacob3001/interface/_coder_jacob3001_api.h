//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// _coder_jacob3001_api.h
//
// Code generation for function 'jacob3001'
//

#ifndef _CODER_JACOB3001_API_H
#define _CODER_JACOB3001_API_H

// Include files
#include "emlrt.h"
#include "mex.h"
#include "tmwtypes.h"
#include <algorithm>
#include <cstring>

// Variable Declarations
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

// Function Declarations
void jacob3001(real_T ja[3], real_T J[18]);

void jacob3001_api(const mxArray *prhs, const mxArray **plhs);

void jacob3001_atexit();

void jacob3001_initialize();

void jacob3001_terminate();

void jacob3001_xil_shutdown();

void jacob3001_xil_terminate();

#endif
// End of code generation (_coder_jacob3001_api.h)
