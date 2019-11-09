//
//  ImageNumberBadgeView.h
//  ExhibitAPP
//
//  Created by eric on 12/10/27.
//
//

#import <UIKit/UIKit.h>

@interface ImageNumberBadgeView : UIView

@property (assign,nonatomic) NSUInteger value;
@property (nonatomic) BOOL hideWhenZero;
@property (strong,nonatomic) UIImage *backgroundImage;

@end
