//
//  iOSSLog.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

void iOSDebug(const char *fileName, int lineNumber, NSString *fmt, ...);

#ifdef IOSSDEBUG 
#define iOSSLog(format...) iOSDebug(__FILE__, __LINE__, format) 
#else 
#define iOSSLog(format...) 
#endif
