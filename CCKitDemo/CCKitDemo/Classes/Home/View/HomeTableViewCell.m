//
//  HomeTableViewCell.m
//  CCKitDemo
//
//  Created by CC on 2018/12/28.
//  Copyright © 2018 CC. All rights reserved.
//

#import "HomeTableViewCell.h"

@implementation HomeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor whiteColor];

        self.textLabel.font = [UIFont systemFontOfSize:17];
        self.textLabel.textColor = [UIColor colorFromHexCode:@"1f2328"];

        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        self.detailTextLabel.textColor = [UIColor colorFromHexCode:@"b2b2b2"];
    }
    return self;
}

- (void)cc_cellWillDisplayWithModel:(id)cModel indexPath:(NSIndexPath *)cIndexPath
{
    self.cc_dataSources = cModel;
    self.cc_indexPath = cIndexPath;

    if ([cModel cellImage])
        self.imageView.image = [UIImage imageNamed:[cModel cellImage]];

    self.textLabel.text = [cModel cellText];
    self.detailTextLabel.text = [cModel cellDetailText];
}


@end
