//
//  UIApplication+iOSSNetworkActivity.h
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (iOSSNetworkActivity)

@property (nonatomic, assign, readonly) NSInteger ioss_networkActivityCount;

- (void)ioss_pushNetworkActivity;
- (void)ioss_popNetworkActivity; 
- (void)ioss_resetNetworkActivity;

@end
