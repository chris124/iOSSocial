//
//  Instagram.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^InstagramAuthorizationHandler)(NSDictionary *userInfo, NSError *error);

@interface Instagram : NSObject

// See InstagramConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(InstagramAuthorizationHandler)completionHandler;

- (BOOL)isSessionValid;

- (NSString*)oAuthAccessToken;

- (void)logout;

+ (NSURL*)authorizeURL:(NSURL*)URL;

+ (id)JSONFromData:(NSData*)data;

@end
