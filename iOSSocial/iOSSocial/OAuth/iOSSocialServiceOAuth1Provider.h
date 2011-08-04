//
//  iOSSocialServiceOAuth1Provider.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^AuthorizationHandler)(NSDictionary *userInfo, NSError *error);

@interface iOSSocialServiceOAuth1Provider : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(AuthorizationHandler)completionHandler;

- (BOOL)isSessionValid;

- (NSString*)oAuthAccessToken;

- (void)logout;

@end
