//
//  iOSSServicesViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@protocol iOSSocialLocalUserProtocol;

typedef void(^ServicesViewControllerHandler)();
typedef void(^ServiceConnectedHandler)(id<iOSSocialLocalUserProtocol> localUser);

@interface iOSSServicesViewController : TTTableViewController <UITableViewDelegate> {
}

- (id)initWithServicesFilter:(NSArray*)filter;

- (void)refreshUI;

- (void)presentModallyFromViewController:(UIViewController*)vc 
             withServiceConnectedHandler:(ServiceConnectedHandler)serviceConnectedHandler 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler;

@end
