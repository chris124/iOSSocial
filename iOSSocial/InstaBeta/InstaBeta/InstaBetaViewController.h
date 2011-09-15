//
//  InstaBetaViewController.h
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iOSSServicesViewController.h"

@interface InstaBetaViewController : UIViewController <iOSSServicesViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (IBAction)servicesButtonPressed:(id)sender;
- (IBAction)actionButtonPressed:(id)sender;
- (IBAction)anotheractionButtonPressed:(id)sender;

@end
