//
//  iOSSUploadFileInfo.m
//  iOSSocial
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSUploadFileInfo.h"

@implementation iOSSUploadFileInfo

@synthesize localPath;
@synthesize contentType;
@synthesize nameParam;
@synthesize fileName;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)fileName 
{
    if (fileName == nil) {
        return [localPath lastPathComponent];
    }
    return fileName;
}

@end
