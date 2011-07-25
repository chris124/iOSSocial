//
//  NSUserDefaults+iOSSAdditions.h
//  iOSSocial
//
//  Created by Christopher White on 7/19/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (iOSSAdditions)

@property (assign, getter=ioss_instagramUserDictionary, setter=ioss_setInstagramUserDictionary:) NSDictionary *ioss_instagramUserDictionary;

@property (assign, getter=ioss_twitterUserDictionary, setter=ioss_setTwitterUserDictionary:) NSDictionary *ioss_twitterUserDictionary;

@property (assign, getter=ioss_foursquareUserDictionary, setter=ioss_setFoursquareUserDictionary:) NSDictionary *ioss_foursquareUserDictionary;

@end
