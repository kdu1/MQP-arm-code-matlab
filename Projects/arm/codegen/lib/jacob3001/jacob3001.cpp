//
// Academic License - for use in teaching, academic research, and meeting
// course requirements at degree granting institutions only.  Not for
// government, commercial, or other organizational use.
//
// jacob3001.cpp
//
// Code generation for function 'jacob3001'
//

// Include files
#include "jacob3001.h"
#include <cmath>

// Function Definitions
void jacob3001(const double ja[3], double J[18])
{
  double J_tmp;
  double J_tmp_tmp;
  double b_J_tmp;
  double b_J_tmp_tmp;
  double c_J_tmp;
  double c_J_tmp_tmp;
  double d_J_tmp;
  double d_J_tmp_tmp;
  double e_J_tmp;
  double e_J_tmp_tmp;
  double f_J_tmp;
  double g_J_tmp;
  double h_J_tmp;
  //  calculates 6x3 manipulator Jacobian from 3x1 array of joint
  //  angles
  //  hardcoded Jacobian calculation
  J_tmp_tmp = 3.1415926535897931 * (ja[1] - 90.0) / 180.0;
  J_tmp = std::sin(J_tmp_tmp);
  J_tmp_tmp = std::cos(J_tmp_tmp);
  b_J_tmp_tmp = 3.1415926535897931 * (ja[2] + 90.0) / 180.0;
  b_J_tmp = std::sin(b_J_tmp_tmp);
  c_J_tmp = std::cos(b_J_tmp_tmp);
  b_J_tmp_tmp = 3.1415926535897931 * ja[0] / 180.0;
  c_J_tmp_tmp = std::sin(b_J_tmp_tmp);
  b_J_tmp_tmp = std::cos(b_J_tmp_tmp);
  d_J_tmp_tmp = 15.707963267948966 * c_J_tmp_tmp;
  d_J_tmp = d_J_tmp_tmp * J_tmp_tmp;
  e_J_tmp = 15.707963267948966 * c_J_tmp_tmp * J_tmp;
  J[0] = (e_J_tmp * b_J_tmp / 9.0 - d_J_tmp * c_J_tmp / 9.0) - d_J_tmp / 9.0;
  f_J_tmp = 15.707963267948966 * b_J_tmp_tmp;
  e_J_tmp_tmp = f_J_tmp * J_tmp_tmp;
  g_J_tmp = e_J_tmp_tmp * b_J_tmp;
  f_J_tmp = f_J_tmp * c_J_tmp * J_tmp / 9.0;
  h_J_tmp = 15.707963267948966 * b_J_tmp_tmp * J_tmp;
  J[6] = (-h_J_tmp / 9.0 - g_J_tmp / 9.0) - f_J_tmp;
  J[12] = -g_J_tmp / 9.0 - f_J_tmp;
  J[1] = (e_J_tmp_tmp / 9.0 + e_J_tmp_tmp * c_J_tmp / 9.0) -
         h_J_tmp * b_J_tmp / 9.0;
  d_J_tmp *= b_J_tmp;
  f_J_tmp = d_J_tmp_tmp * c_J_tmp * J_tmp / 9.0;
  J[7] = (-e_J_tmp / 9.0 - d_J_tmp / 9.0) - f_J_tmp;
  J[13] = -d_J_tmp / 9.0 - f_J_tmp;
  J[2] = 0.0;
  J_tmp = 15.707963267948966 * J_tmp * b_J_tmp / 9.0 -
          15.707963267948966 * J_tmp_tmp * c_J_tmp / 9.0;
  J[8] = J_tmp - 15.707963267948966 * J_tmp_tmp / 9.0;
  J[14] = J_tmp;
  J[3] = 0.0;
  J[9] = -c_J_tmp_tmp;
  J[15] = -c_J_tmp_tmp;
  J[4] = 0.0;
  J[10] = b_J_tmp_tmp;
  J[16] = b_J_tmp_tmp;
  J[5] = 1.0;
  J[11] = 0.0;
  J[17] = 0.0;
}

// End of code generation (jacob3001.cpp)
