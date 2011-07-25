//
//  FoursquareUser.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FetchFoursquareUserDataHandler)(NSError *error);

@interface FoursquareUser : NSObject

@property(nonatomic, readonly, retain)  NSString *userID;   // User identifier.
@property(nonatomic, readonly, retain)  NSString *alias;    // The user's alias

@end
