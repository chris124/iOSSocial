//
//  UIApplication+iOSSNetworkActivity.m
//  iOSSocial
//
//  Created by Christopher White on 7/18/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "UIApplication+iOSSNetworkActivity.h"

static NSInteger ioss_networkActivityCount = 0;

@implementation UIApplication (iOSSNetworkActivity)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)ioss_networkActivityCount 
{ 
    @synchronized(self) {
        return ioss_networkActivityCount;
    }
}

- (void)ioss_refreshNetworkActivityIndicator 
{ 
    if (![NSThread isMainThread]) {
        SEL sel_refresh = @selector(ioss_refreshNetworkActivityIndicator); 
        [self performSelectorOnMainThread:sel_refresh 
                               withObject:nil 
                            waitUntilDone:NO];
        return;
    }

    BOOL active = (self.ioss_networkActivityCount > 0); 
    self.networkActivityIndicatorVisible = active;
}
    
- (void)ioss_pushNetworkActivity 
{ 
    @synchronized(self) {
        ioss_networkActivityCount++;
    }
    [self ioss_refreshNetworkActivityIndicator];
}

- (void)ioss_popNetworkActivity
{
    @synchronized(self) {
        if (ioss_networkActivityCount > 0) { 
            ioss_networkActivityCount--;
        } else { 
            ioss_networkActivityCount = 0; 
            NSLog(@"%s Unbalanced network activity: count already 0.", __PRETTY_FUNCTION__);
        }
    }
}

- (void)ioss_resetNetworkActivity
{
    ioss_networkActivityCount = 0;
    self.networkActivityIndicatorVisible = NO;
}

@end
