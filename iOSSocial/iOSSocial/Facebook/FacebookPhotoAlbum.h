//
//  FacebookPhotoAlbum.h
//  MadRaces
//
//  Created by Christopher White on 7/7/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"


@interface FacebookPhotoAlbum : NSObject <TTPhotoSource>

@property(nonatomic, readonly, retain)  NSString *albumID;
@property(nonatomic, readonly, retain)  NSString *name;
@property(nonatomic, readonly, retain)  NSString *description;
@property(nonatomic, readonly, assign)  NSInteger count;

- (id)initWithDictionary:(NSDictionary*)albumDictionary;

// Asynchronously load the photo albums of the user as an array of FacebookPhoto objects. Error will be nil on success.
// Possible reasons for error:
// 1. Unauthenticated local user
// 2. Communications failure
// 3. Invalid user identifier
- (void)loadPhotos;

@end
