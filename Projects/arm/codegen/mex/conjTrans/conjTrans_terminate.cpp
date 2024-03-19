//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// conjTrans_terminate.cpp
//
// Code generation for function 'conjTrans_terminate'
//

// Include files
#include "conjTrans_terminate.h"
#include "_coder_conjTrans_mex.h"
#include "conjTrans_data.h"
#include "rt_nonfinite.h"

// Function Definitions
void conjTrans_atexit()
{
  emlrtStack st{
      nullptr, // site
      nullptr, // tls
      nullptr  // prev
  };
  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  // Free instance data
  covrtFreeInstanceData(&emlrtCoverageInstance);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  emlrtExitTimeCleanup(&emlrtContextGlobal);
}

void conjTrans_terminate()
{
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

// End of code generation (conjTrans_terminate.cpp)
