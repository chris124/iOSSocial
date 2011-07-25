//
//  FacebookFriendsViewController.h
//  MadRaces
//
//  Created by Christopher White on 7/5/11.
//  Copyright 2011 Betaworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookFriendsViewController : UITableViewController {
    NSArray *friends;
}

@property(nonatomic, copy) NSArray *friends;

@end
