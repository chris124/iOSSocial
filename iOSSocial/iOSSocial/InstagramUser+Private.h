//
//  InstagramUser+Private.h
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

@interface InstagramUser ()

@property(nonatomic, readwrite, retain) NSString *userID;
@property(nonatomic, readwrite, retain) NSString *alias;
@property(nonatomic, readwrite, retain) NSString *firstName;
@property(nonatomic, readwrite, retain) NSString *lastName;
@property(nonatomic, readwrite, retain) NSString *profilePictureURL;
@property(nonatomic, readwrite, retain) NSString *bio;
@property(nonatomic, readwrite, retain) NSString *website;
@property(nonatomic, readwrite, assign) NSInteger mediaCount;
@property(nonatomic, readwrite, assign) NSInteger followsCount;
@property(nonatomic, readwrite, assign) NSInteger followedByCount;
@property (nonatomic, copy)             LoadPhotoHandler loadPhotoHandler;

@end
