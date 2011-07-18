//
//  Instagram.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^AuthorizationHandler)(NSDictionary *userInfo, NSError *error);

@interface Instagram : NSObject

// See InstagramConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(AuthorizationHandler)completionHandler;

- (BOOL)isSessionValid;

- (void)logout;

+ (NSURL*)authorizeURL:(NSURL*)URL;

@end
