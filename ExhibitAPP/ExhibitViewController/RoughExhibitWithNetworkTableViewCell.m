//
//  RoughExhibitWithNetworkTableViewCell.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoughExhibitWithNetworkTableViewCell.h"
#import "SDImageCache.h"
#import "Exhibit.h"

@implementation RoughExhibitWithNetworkTableViewCell

@synthesize _nameLabel;
@synthesize _dateLabel;
@synthesize _imageUIView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (nil == self) {
        DLog(@"cannot allocate the memory");
        assert(0);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Procotol

- (BOOL) setNameLabelinProctocol: (NSString*) NSName
{
    if (nil == NSName || nil == _nameLabel) {
        DLog(@"Wrong parameter");
        return TRUE;
    }
    _nameLabel.text = NSName;

    return FALSE;
}

- (BOOL) setDateLableinProctocol:(NSString *) NSdate
{
    if (nil == NSdate || nil == _dateLabel) {
        DLog(@"Wrong parameter");
        return TRUE;
    }
    NSString *date = [[NSString alloc] initWithFormat:@"%@", NSdate];
    if (nil == date) {
        DLog(@"cannot get the date");
        return TRUE;
    }
    _dateLabel.text = date;

    return FALSE;
}

- (BOOL) setImageinProctocol:(NSString *)NSImageURL
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    if (nil == NSImageURL || nil == manager || 
        nil == _imageUIView) {
        DLog(@"wrong parameter");
        return TRUE;
    }
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:NSImageURL];
    if (nil == cachedImage) {
        [manager downloadWithURL:[NSURL URLWithString:NSImageURL] delegate:self];
        _imageUIView.image = [UIImage imageNamed:WAIT_PICTURE_PATH];
    } else {
        _imageUIView.image = cachedImage;
    }
    return FALSE;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    if (nil == image) {
        DLog(@"wrong parameter");
        assert(0);
    }
    self.imageView.image = image;
    [self setNeedsLayout];
}


@end
