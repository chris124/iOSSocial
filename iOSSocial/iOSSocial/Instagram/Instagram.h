//
//  Instagram.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialServiceOAuth2Provider.h"

@interface Instagram : iOSSocialServiceOAuth2Provider

+ (NSURL*)authorizeURL:(NSURL*)URL;

+ (id)JSONFromData:(NSData*)data;

@end
