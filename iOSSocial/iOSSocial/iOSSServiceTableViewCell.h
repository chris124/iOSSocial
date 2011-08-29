//
//  iOSSServiceTableViewCell.h
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "PRPSmartTableViewCell.h"

@protocol iOSSocialServiceProtocol;
@interface iOSSServiceTableViewCell : PRPSmartTableViewCell

@property(nonatomic, retain)   id<iOSSocialServiceProtocol> service;

@end
