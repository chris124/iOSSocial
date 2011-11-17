/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "iOSSLog.h"

void iOSDebug(const char *fileName, int lineNumber, NSString *fmt, ...) 
{ 
    va_list args;
    va_start(args, fmt);
    
    static NSDateFormatter *debugFormatter = nil; 
    if (debugFormatter == nil) {
        debugFormatter = [[NSDateFormatter alloc] init]; 
        [debugFormatter setDateFormat:@"yyyyMMdd.HH:mm:ss"];
    }
    
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:args]; 
    NSString *filePath = [[NSString alloc] initWithUTF8String:fileName]; 
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date] 
                                                         dateStyle:kCFDateFormatterFullStyle 
                                                         timeStyle:kCFDateFormatterFullStyle];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary]; 
    NSString *appName = [info objectForKey:(NSString *)kCFBundleNameKey]; 
    fprintf(stdout, "%s %s[%s:%d] %s\n", 
            [timestamp UTF8String], 
            [appName UTF8String], 
            [[filePath lastPathComponent] UTF8String], 
            lineNumber, 
            [msg UTF8String]);
    
    va_end(args);
}
