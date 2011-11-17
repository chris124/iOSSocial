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
