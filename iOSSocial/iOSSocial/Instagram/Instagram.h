//
//  Instagram.h
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Instagram : NSObject

// See InstagramConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc;

//- (void)authorize:(NSArray *)permissions
//         delegate:(id<FBSessionDelegate>)delegate;

- (BOOL)isSessionValid;

- (void)logout;

@end
