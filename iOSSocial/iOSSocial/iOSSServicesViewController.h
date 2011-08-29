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

@protocol iOSSServiceProtocol;

@protocol iOSSServicesViewControllerDelegate <NSObject>

@optional

-(void)servicesViewController:(iOSSServicesViewController*)servicesController 
             didSelectService:(id<iOSSServiceProtocol>)service;

-(void)servicesViewControllerDidSelectDoneButton:(iOSSServicesViewController*)servicesController;

@end



@interface iOSSServicesViewController : TTTableViewController <UITableViewDelegate> {
    id _serviceControllerDelegate;
}

@property(nonatomic, retain)    id<iOSSServicesViewControllerDelegate> serviceControllerDelegate;

- (void)refreshUI;

@end
