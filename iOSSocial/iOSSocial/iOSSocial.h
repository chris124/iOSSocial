//
//  iOSSocial.h
//  iOSSocial
//
//  Created by Christopher White on 7/15/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramUser.h"
#import "LocalInstagramUser.h"

void iOSDebug(const char *fileName, int lineNumber, NSString *fmt, ...);

#ifdef IOSSDEBUG 
#define iOSSLog(format...) iOSDebug(__FILE__, __LINE__, format) 
#else 
#define iOSSLog(format...) 
#endif