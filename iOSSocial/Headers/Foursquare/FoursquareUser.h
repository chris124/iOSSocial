//
//  FoursquareUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialUser.h"
#import "iOSSocialConstants.h"


@interface FoursquareUser : NSObject <iOSSocialUserProtocol>

@property(nonatomic, readonly, retain)  NSString *userID;   // User identifier.
@property(nonatomic, readonly, retain)  NSString *alias;    // The user's alias
@property(nonatomic, readonly, retain)  NSString *firstName;            // The user's first name
@property(nonatomic, readonly, retain)  NSString *profilePictureURL;    // The user's last name

// Asynchronously load the users's photo. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

@end
