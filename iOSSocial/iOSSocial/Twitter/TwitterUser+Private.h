//
//  TwitterUser+Private.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

@interface TwitterUser ()

@property(nonatomic, readwrite, retain) NSDictionary *userDictionary;
@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain)  NSString *profilePictureURL;    // The user's last name

@end
