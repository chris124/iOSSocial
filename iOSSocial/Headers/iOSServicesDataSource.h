//
//  iOSServicesDataSource.h
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface iOSServicesDataSource : NSObject <UITableViewDataSource> {
}

@property(nonatomic, retain)    NSString *message;
@property(nonatomic, assign)    BOOL displayDoneButton;

- (id)initWithServicesFilter:(NSArray*)filter;

@end
