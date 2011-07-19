//
//  NSUserDefaults+iOSSAdditions.m
//  iOSSocial
//
//  Created by Christopher White on 7/19/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "NSUserDefaults+iOSSAdditions.h"

NSString *const iOSSDefaultsKeyInstagramUserDictionary = @"ioss_instagramUserDictionary";

@implementation NSUserDefaults (iOSSAdditions)

- (NSDictionary *)ioss_instagramUserDictionary 
{ 
    return [self objectForKey:iOSSDefaultsKeyInstagramUserDictionary];
}

- (void)ioss_setInstagramUserDictionary:(NSDictionary *)username 
{ 
    [self setObject:username forKey:iOSSDefaultsKeyInstagramUserDictionary];
    [self synchronize];
}

@end
