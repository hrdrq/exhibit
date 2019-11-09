//
//  RoughExhibitWithoutNetworkTableViewCell.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoughExhibitWithoutNetworkTableViewCell.h"
#import "Exhibit.h"


@implementation RoughExhibitWithoutNetworkTableViewCell
@synthesize nameLabel;
@synthesize dateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (nil == self) {
        DLog(@"No memory allocate");
        assert(0);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Procotol

- (BOOL) setNameLabelinProctocol: (NSString*) NSName
{
    if (nil == NSName || nil == self.nameLabel) {
        DLog(@"Wrong parameter");
        return TRUE;
    }
    self.nameLabel.text = NSName;
    return FALSE;
}

- (BOOL) setDateLableinProctocol:(NSString *) NSdate
{
    if (nil == NSdate || nil == self.dateLabel) {
        DLog(@"wrong parameter")
        return TRUE;
    }

    NSString *date = [[NSString alloc] initWithFormat:@"%@", NSdate];
    if (nil == date) {
        DLog(@"cannot allocate the memory");
        return TRUE;
    }
    self.dateLabel.text = date;
    
    return TRUE;
}

- (BOOL) setImageinProctocol:(NSString *)NSImageURI
{
    if (nil == NSImageURI) {
        DLog(@"Wrong parameter");
        return TRUE;
    }
    return FALSE;
}

@end
