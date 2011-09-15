//
//  iOSSServicesViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

typedef void(^ServicesViewControllerHandler)();

@interface iOSSServicesViewController : TTTableViewController <UITableViewDelegate> {
}

- (id)initWithServicesFilter:(NSArray*)filter;

- (void)refreshUI;

- (void)presentModallyFromViewController:(UIViewController*)vc 
                   withCompletionHandler:(ServicesViewControllerHandler)completionHandler;

@end
