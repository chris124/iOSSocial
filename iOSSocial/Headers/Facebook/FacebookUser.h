//
//  FacebookUser.h
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialUser.h"
#import "iOSSocialConstants.h"

@class UIImage;
//typedef void(^LoadPhotoHandler)(UIImage *photo, NSError *error);

@interface FacebookUser : NSObject <iOSSocialUserProtocol>

//cwnote: should alias be copied?
@property(nonatomic, readonly, retain)  NSString *userID;       // Invariant user identifier.
@property(nonatomic, readonly, retain)  NSString *alias;        // The user's alias
@property(nonatomic, readonly, retain)  NSString *firstName;    // The user's first name
@property(nonatomic, readonly, retain)  NSString *lastName;     // The user's last name
@property(nonatomic, readonly, retain)  NSString *email;     // The user's last name
@property(nonatomic, readonly)          BOOL isFriend;          // True if this user is a friend of the local user

- (id)initWithDictionary:(NSDictionary*)userDictionary;

// Asynchronously load the player's photo. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

@end

// Notification will be posted whenever the user details changes. The object of the notification will be the user.
//extern NSString *UserDidChangeNotificationName;
