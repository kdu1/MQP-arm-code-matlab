//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// conjTrans.cpp
//
// Code generation for function 'conjTrans'
//

// Include files
#include "conjTrans.h"
#include "conjTrans_data.h"
#include "rt_nonfinite.h"

// Function Definitions
void conjTrans(const emlrtStack *, const real_T A[3], real_T ct[3])
{
  covrtLogFcn(&emlrtCoverageInstance, 0, 0);
  covrtLogBasicBlock(&emlrtCoverageInstance, 0, 0);
  ct[0] = A[0];
  ct[1] = A[1];
  ct[2] = A[2];
}

// End of code generation (conjTrans.cpp)
