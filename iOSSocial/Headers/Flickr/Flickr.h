//
//  Flickr.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iOSSocialServiceOAuth1Provider.h"
#import "iOSSocialServicesStore.h"

@interface Flickr : iOSSocialServiceOAuth1Provider <iOSSocialServiceProtocol>

+ (id)JSONFromData:(NSData*)data;

@end
