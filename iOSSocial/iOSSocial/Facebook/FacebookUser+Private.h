//
//  FacebookUser+Private.h
//  iOSSocial
//
//  Created by Christopher White on 9/29/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

@interface FacebookUser ()

@property(nonatomic, readwrite, retain) NSDictionary *userDictionary;
@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain) NSString *firstName;
@property(nonatomic, readwrite, retain) NSString *lastName;
@property(nonatomic, readwrite, retain) NSString *email;
@property(nonatomic, readwrite, retain) NSString *profilePictureURL;
@property(nonatomic, copy)              FetchUserDataHandler fetchUserDataHandler;
@property(nonatomic, readwrite, retain) Facebook *facebook;

@end

