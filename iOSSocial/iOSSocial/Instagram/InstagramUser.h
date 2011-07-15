//
//  InstagramUser.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^LoadPhotoHandler)(UIImage *photo, NSError *error);

@interface InstagramUser : NSObject

//cwnote: should alias be copied?
@property(nonatomic, readonly, retain)  NSString *userID;               // Invariant user identifier.
@property(nonatomic, readonly, retain)  NSString *alias;                // The user's alias
@property(nonatomic, readonly, retain)  NSString *firstName;            // The user's first name
@property(nonatomic, readonly, retain)  NSString *lastName;             // The user's last name
@property(nonatomic, readonly, retain)  NSString *profilePictureURL;    // The user's last name
@property(nonatomic, readonly, retain)  NSString *bio;                  // The user's biography
@property(nonatomic, readonly, retain)  NSString *website;              // The user's website
@property(nonatomic, readonly, assign)  NSInteger mediaCount;           // The user's total number of media
@property(nonatomic, readonly, assign)  NSInteger followsCount;         // The user's number of people they follow
@property(nonatomic, readonly, assign)  NSInteger followedByCount;      // The user's total number of followers
//@property(nonatomic, readonly)          BOOL isFriend;          // True if this user is a friend of the local user

- (id)initWithDictionary:(NSDictionary*)userDictionary;

// Asynchronously load the users's photo. Error will be nil on success.
// Possible reasons for error:
// 1. Communications failure
- (void)loadPhotoWithCompletionHandler:(LoadPhotoHandler)completionHandler;

@end
