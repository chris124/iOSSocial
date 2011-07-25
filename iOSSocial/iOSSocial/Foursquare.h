//
//  Foursquare.h
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^FoursquareAuthorizationHandler)(NSDictionary *userInfo, NSError *error);

@interface Foursquare : NSObject

// See InstagramConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(FoursquareAuthorizationHandler)completionHandler;

- (BOOL)isSessionValid;

- (void)logout;

+ (NSURL*)authorizeURL:(NSURL*)URL;

+ (id)JSONFromData:(NSData*)data;

@end
