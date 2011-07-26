//
//  GTMOAuthAuthentication+Additions.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"

@interface GTMOAuthAuthenticationWithAdditions : GTMOAuthAuthentication

@property(nonatomic, readonly, retain)  NSString *userID;       // User identifier.
@property(nonatomic, readonly, retain)  NSString *username;     // The user's alias

@end
