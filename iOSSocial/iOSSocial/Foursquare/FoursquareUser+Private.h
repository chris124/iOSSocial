//
//  FoursquareUser+Private.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

@interface FoursquareUser ()

@property(nonatomic, readwrite, retain) NSDictionary *userDictionary;
@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain) NSString *firstName;
@property(nonatomic, readwrite, retain) NSString *profilePictureURL;
@property(nonatomic, copy)              FetchUserDataHandler fetchUserDataHandler;

@end
