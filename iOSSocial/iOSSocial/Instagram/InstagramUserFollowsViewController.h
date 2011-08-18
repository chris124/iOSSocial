//
//  InstagramUserFollowsViewController.h
//  PhotoStream
//
//  Created by Christopher White on 8/8/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Three20/Three20.h"

@class InstagramUser;
typedef void(^SelectedUserHandler)(InstagramUser *user);

@interface InstagramUserFollowsViewController : TTTableViewController <UITableViewDelegate>

@property(nonatomic, copy)  SelectedUserHandler selectedUserHandler;

@end
