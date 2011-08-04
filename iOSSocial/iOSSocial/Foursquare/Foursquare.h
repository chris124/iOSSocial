//
//  Foursquare.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialServiceOAuth2Provider.h"


@interface Foursquare : iOSSocialServiceOAuth2Provider

+ (NSURL*)authorizeURL:(NSURL*)URL;

+ (id)JSONFromData:(NSData*)data;

@end
