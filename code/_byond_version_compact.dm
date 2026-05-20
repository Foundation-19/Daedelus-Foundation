// This file contains defines allowing targeting byond versions newer than the supported

//Update this whenever you need to take advantage of more recent byond features
#define MIN_COMPILER_VERSION 516
#define MIN_COMPILER_BUILD 1681
#if (DM_VERSION < MIN_COMPILER_VERSION || DM_BUILD < MIN_COMPILER_BUILD) && !defined(SPACEMAN_DMM)
#error Your version of BYOND is too out-of-date to compile this project. Go to https://secure.byond.com/download and update.
#error For a specific minimum version, check code/_byond_version_compact.dm
#endif

/savefile/byond_version = MIN_COMPILER_VERSION
