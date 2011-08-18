//
//  InstagramUserFollowsViewController.m
//  PhotoStream
//
//  Created by Christopher White on 8/8/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstagramUserFollowsViewController.h"
#import "IGUserFollowsDataSource.h"
#import "InstagramUser.h"

@implementation InstagramUserFollowsViewController

@synthesize selectedUserHandler;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.dataSource = [[IGUserFollowsDataSource alloc] init];
        self.variableHeightRows = YES;
    }
    
    return self;
}

#pragma mark - Table view delegate

- (id<UITableViewDelegate>)createDelegate
{
    return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    InstagramUser *user = [self.dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    
    if (self.selectedUserHandler) {
        self.selectedUserHandler(user);
        //cwnote: when to null this out?
        //self.selectedUserHandler = nil;
    }
    
    //call block to sell other object that a user was selected
    //didSelectUserWithCompletionHandler?
    //keep that row highlighted? how to do that?
}

@end
