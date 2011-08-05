//
//  iOSSServiceTableViewCell.h
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "PRPSmartTableViewCell.h"

@class iOSSService;
@interface iOSSServiceTableViewCell : PRPSmartTableViewCell

@property(nonatomic, retain)    iOSSService *service;

@end
