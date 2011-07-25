//
//  iOSSUploadFileInfo.h
//  iOSSocial
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iOSSUploadFileInfo : NSObject

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, copy) NSString *contentType;
@property (nonatomic, copy) NSString *nameParam;
@property (nonatomic, copy) NSString *fileName;

@end
