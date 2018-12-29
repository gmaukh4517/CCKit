//
//  CollectionViewCell.m
//  CCKitDemo
//
//  Created by CC on 2018/12/28.
//  Copyright © 2018 CC. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell ()

@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    self.clipsToBounds = YES;

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_textLabel = textLabel];
}

- (void)cc_cellWillDisplayWithModel:(id)cModel indexPath:(NSIndexPath *)cIndexPath
{
    TableViewCellEntity *entity = cModel;

    self.contentView.backgroundColor = cIndexPath.row % 2 ? [UIColor groupTableViewBackgroundColor] : [UIColor lightGrayColor];
    self.textLabel.text = entity.cellText;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.x = (self.contentView.width - self.textLabel.width) / 2;
    self.textLabel.y = (self.contentView.height - self.textLabel.height) / 2;
}

@end
