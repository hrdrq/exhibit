//
//  CustomSelectedBackgroundView.h
//
//  Created by Mike Akers on 11/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    CustomSelectedBackgroundViewPositionTop, 
    CustomSelectedBackgroundViewPositionMiddle, 
    CustomSelectedBackgroundViewPositionBottom,
    CustomSelectedBackgroundViewPositionSingle,
    CustomSelectedBackgroundViewPositionPlain
} CustomSelectedBackgroundViewPosition;

@interface CustomSelectedBackgroundView : UIView {
    UIColor *borderColor;
    UIColor *fillColor;
    CustomSelectedBackgroundViewPosition position;
}

@property(nonatomic, retain) UIColor *borderColor, *fillColor;
@property(nonatomic) CustomSelectedBackgroundViewPosition position;
@end