//
//  UIButtonAboveTable.m
//  CustomButton
//
//  Created by eric on 12/10/3.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import "UIButtonAboveTable.h"
#import <QuartzCore/QuartzCore.h>
#import "Exhibit.h"

@interface CustomGradientLayer : CAGradientLayer

@end
@implementation CustomGradientLayer
- (void)drawInContext:(CGContextRef)theContext {

    CGContextSetRGBFillColor(theContext, 0.0, 0.0, 0.0, 1.0);//set color
#define CIRCLE_DIAMETER 13
    CGContextFillEllipseInRect(theContext, CGRectMake(self.bounds.size.width -CIRCLE_DIAMETER -5, self.bounds.size.height/2 - CIRCLE_DIAMETER/2, CIRCLE_DIAMETER, CIRCLE_DIAMETER));//draw circle
    
    CGContextSetLineWidth(theContext, 2.0);
    CGContextSetStrokeColorWithColor(theContext, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(theContext, self.bounds.size.width-CIRCLE_DIAMETER -5 +3, self.bounds.size.height/2 - CIRCLE_DIAMETER/2 +5);
    CGContextAddLineToPoint(theContext, self.bounds.size.width-CIRCLE_DIAMETER -5 +CIRCLE_DIAMETER/2, self.bounds.size.height/2 - CIRCLE_DIAMETER/2 +9);
    CGContextAddLineToPoint(theContext, self.bounds.size.width-CIRCLE_DIAMETER -5 +CIRCLE_DIAMETER -3, self.bounds.size.height/2 - CIRCLE_DIAMETER/2 +5);
    CGContextStrokePath(theContext);


}

@end

@interface UIButtonAboveTable()
{
    CustomGradientLayer* _gradientLayer;
}
@end

@implementation UIButtonAboveTable

@synthesize gradientStartColor;
@synthesize gradientEndColor;

-(void)awakeFromNib
{
    _gradientLayer = [[CustomGradientLayer alloc] init];
    _gradientLayer.bounds = self.bounds;
    
    _gradientLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [self.layer insertSublayer:_gradientLayer atIndex:0];
    [_gradientLayer setNeedsDisplay];
    //[_gradientLayer setDelegate:self];
    
    
    self.layer.borderWidth = 0.5;//2.0f;
    self.layer.borderColor = /*THEME_COLOR_DARK.CGColor;*/[UIColor colorWithRed:(CGFloat)226/255 green:(CGFloat)226/255 blue:(CGFloat)226/255 alpha:1].CGColor;
    
    self.gradientStartColor = /*THEME_COLOR_1;*/[UIColor colorWithRed:(CGFloat)245/255 green:(CGFloat)245/255 blue:(CGFloat)245/255 alpha:1];
    self.gradientEndColor = /*THEME_COLOR_2;*/[UIColor colorWithRed:(CGFloat)220/255 green:(CGFloat)220/255 blue:(CGFloat)220/255 alpha:1];
    
    [self setTitleColor:/*THEME_COLOR_DARK*/[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:/*THEME_COLOR_WHITE*/[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
    
}

- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

- (void)drawRect:(CGRect)rect
{
    if (self.state == UIControlStateNormal) {
        if (self.gradientStartColor && self.gradientEndColor) {
            [_gradientLayer setColors:
             [NSArray arrayWithObjects: (id)[self.gradientStartColor CGColor]
              , (id)[self.gradientEndColor CGColor], nil]];
        }
    }else{
        if (self.gradientStartColor && self.gradientEndColor) {
            [_gradientLayer setColors:
             [NSArray arrayWithObjects: (id)[self.gradientEndColor CGColor]
              , (id)[self.gradientStartColor CGColor], nil]];
        }
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGRect theRect = CGRectMake(0,0,20,20);
    //CGContextAddEllipseInRect(context, theRect);
    //CGContextDrawPath(context, kCGPathFillStroke);
    CGPoint point;
    point.x = self.bounds.origin.x + self.bounds.size.width/2;
    point.y = self.bounds.origin.y + self.bounds.size.height/2;
    [self drawCircleAtPoint:point withRadius:10 inContext:context];
    
    [super drawRect:rect];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self setNeedsDisplay];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}


@end
