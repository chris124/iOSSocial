//
//  InstaBetaViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InstaBetaViewController : UIViewController

- (IBAction)servicesButtonPressed:(id)sender;
- (IBAction)actionButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;

@end
