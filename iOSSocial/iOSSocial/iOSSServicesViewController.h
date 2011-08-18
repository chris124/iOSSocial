//
//  iOSSServicesViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/21/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Three20/Three20.h"

@class iOSSServicesViewController;
@class iOSSService;

@protocol iOSSServicesViewControllerDelegate <NSObject>

@optional

-(void)servicesViewController:(iOSSServicesViewController*)servicesController 
             didSelectService:(iOSSService*)service;

@end

@interface iOSSServicesViewController : TTTableViewController <UITableViewDelegate> {
    id _serviceControllerDelegate;
}

@property(nonatomic, retain)    id<iOSSServicesViewControllerDelegate> serviceControllerDelegate;

@end
