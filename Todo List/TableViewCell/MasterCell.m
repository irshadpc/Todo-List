//
//  TodoList.h
//  Todo List
//
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "MasterCell.h"
#import "UIImage+iPhone5.h"

@implementation MasterCell
@synthesize titleLabel, textLabel, disclosureImageView, bgImageView;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if(selected) {
        UIImage* bg = [UIImage tallImageNamed:@"ipad-list-item-selected.png"];
        UIImage* disclosureImage = [UIImage tallImageNamed:@"ipad-arrow-selected.png"];
        
        [self.bgImageView setImage:bg];
        [self.disclosureImageView setImage:disclosureImage];
        
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.titleLabel setShadowOffset:CGSizeMake(0, -1)];
        
        
        [self.textLabel setTextColor:[UIColor whiteColor]];
        [self.textLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.textLabel setShadowOffset:CGSizeMake(0, -1)];
        
    } else {
        UIImage* bg = [UIImage tallImageNamed:@"ipad-list-element.png"];
        UIImage* disclosureImage = [UIImage tallImageNamed:@"ipad-arrow.png"];
        
        [self.bgImageView setImage:bg];
        [self.disclosureImageView setImage:disclosureImage];
        
        [self.titleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
        [self.titleLabel setShadowColor:[UIColor whiteColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
        
        
        [self.textLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
        [self.textLabel setShadowColor:[UIColor whiteColor]];
        [self.textLabel setShadowOffset:CGSizeMake(0, 1)];
    }

    
    [super setSelected:selected animated:animated];
}

@end
