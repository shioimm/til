/* RNA Transcription from https://exercism.io */

#include "rna_transcription.h"
#include <string.h>
#include <stdlib.h>

char *to_rna(const char *dna)
{
  char *rna = malloc(sizeof(char) * strlen(dna));

  for (int i = 0; dna[i] != '\0'; i++) {
    switch(dna[i]) {
      case 'G':
        rna[i] = 'C';
        break;
      case 'C':
        rna[i] = 'G';
        break;
      case 'T':
        rna[i] = 'A';
        break;
      case 'A':
        rna[i] = 'U';
        break;
      default:
        return NULL;
    }
  }

  return rna;
}
