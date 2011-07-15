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

- (id)initWithClientID:(NSString*)ID 
          clientSecret:(NSString*)cs 
           redirectURI:(NSString*)uri
   andKeyChainItemName:(NSString*)kcin;

- (void)authorize:(NSArray *)permissions fromViewController:(UIViewController*)vc;

//- (void)authorize:(NSArray *)permissions
//         delegate:(id<FBSessionDelegate>)delegate;

- (BOOL)isSessionValid;

- (void)logout;

@end
