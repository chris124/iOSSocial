//
//  iOSSocialServiceOAuth1Provider.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialOAuth.h"

@interface iOSSocialServiceOAuth1Provider : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)assignOAuthParams:(NSDictionary*)params;

- (void)logout;

@end
