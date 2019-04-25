#ifdef DEBUGGER

#ifndef _DEBUG_H_
#define _DEBUG_H_

#include <string>

struct SBreakPoint
{
	bool8	Enabled;
	uint8	Bank;
	uint16	Address;
};

#define ENSURE_TRACE_OPEN(fp, file, mode) \
	if (!fp) \
	{ \
		std::string fn = S9xGetDirectory(LOG_DIR); \
		fn += SLASH_STR file; \
		fp = fopen(fn.c_str(), mode); \
	}

extern struct SBreakPoint	S9xBreakpoint[6];

void S9xDoDebug (void);
void S9xTrace (void);
void S9xSA1Trace (void);
void S9xTraceMessage (const char *);
void S9xTraceFormattedMessage (const char *, ...);
void S9xPrintHVPosition (char *);

#endif

#endif
