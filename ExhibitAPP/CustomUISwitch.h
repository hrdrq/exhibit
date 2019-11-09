//
//  testSwitch.h
//  test
//
//  Created by eric on 12/10/25.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUISwitch : UIControl

@property (nonatomic, assign) BOOL on;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UIImageView* onImageView;
@property (nonatomic, strong) UIImageView* offImageView;

@end
