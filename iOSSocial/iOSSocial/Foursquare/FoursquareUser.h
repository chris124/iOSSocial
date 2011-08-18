//
//  FoursquareUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialUser.h"


@interface FoursquareUser : NSObject <iOSSUserProtocol>

@property(nonatomic, readonly, retain)  NSString *userID;   // User identifier.
@property(nonatomic, readonly, retain)  NSString *alias;    // The user's alias
@property(nonatomic, readonly, retain)  NSString *firstName;            // The user's first name
@property(nonatomic, readonly, retain)  NSString *profilePictureURL;    // The user's last name

@end
