//
//  iOSSServiceTableViewCell.m
//  PhotoStream
//
//  Created by Christopher White on 8/4/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSServiceTableViewCell.h"
#import "iOSSocialLocalUser.h"
#import "iOSSocialServicesStore.h"

@interface iOSSServiceTableViewCell () {
    id<iOSSocialServiceProtocol> _service;
}

@end

@implementation iOSSServiceTableViewCell

@synthesize service=_service;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (id)cellForTableView:(UITableView *)tableView 
{
    NSString *cellID = [self cellIdentifier];
    UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[self alloc] initWithCellIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;    
}


- (id)initWithCellIdentifier:(NSString *)cellID 
{
    return [self initWithStyle:UITableViewCellStyleSubtitle 
               reuseIdentifier:cellID];
}

- (void)setService:(id<iOSSocialServiceProtocol>)theService
{
    _service = theService;

    UIImageView *logoImageView = (UIImageView*)[self viewWithTag:1];
    if (!logoImageView) {
        logoImageView = [[UIImageView alloc] initWithImage:self.service.logoImage];
        [logoImageView setTag:1];
        [logoImageView setFrame:CGRectMake(5.0f, 5.0f, 25.0f, 25.0f)];
        [self.contentView addSubview:logoImageView];
    }
    logoImageView.image = self.service.logoImage;
    
    UILabel *nameLabel = (UILabel*)[self viewWithTag:2];
    if (!nameLabel) {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(logoImageView.frame.origin.x+logoImageView.frame.size.width+10.0f, 5.0f, 150.0f, 15.0f)];
        [nameLabel setTag:2];
        nameLabel.font = [UIFont systemFontOfSize:10.0f];
        nameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLabel];
    }
    
    nameLabel.text = [NSString stringWithFormat:@"%@", self.service.name];
}

@end
