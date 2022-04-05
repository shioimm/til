// Head First C P366

#include <stdio.h>
#include <p366_hfcal.h>

void display_calories(float weight, float distance, float coeff)
{
  printf("weight: %3.2f pound\n", weight);
  printf("distance: %3.2f mile\n", distance);
  printf("coeff: %3.2f calories\n", coeff * weight * distance);
}
