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

@end
