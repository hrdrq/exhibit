//
//  testSwitch.m
//  test
//
//  Created by eric on 12/10/25.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import "CustomUISwitch.h"

@interface CustomUISwitch ()

@property (nonatomic, assign) BOOL onValue;
@property (nonatomic, assign) CGFloat percentage; // Number between 0 and 1.0
@property (nonatomic, assign) BOOL touching;
@property (nonatomic, assign) BOOL moved;

@end

@implementation CustomUISwitch

@dynamic on;
@synthesize onValue = _onValue;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize thumbnailImageView = _thumbnailImageView;
@synthesize percentage = _percentage;
@synthesize touching = _touching;
@synthesize moved = _moved;
@synthesize onImageView = _onImageView;
@synthesize offImageView = _offImageView;

#pragma mark - Initialization

- (void) setPercentageForOn:(BOOL) on {
	_percentage = self.onValue ? 1.0 : 0.0;
}

- (void) setup {
    _backgroundImageView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_background.png"]];
    _backgroundImageView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, _backgroundImageView.frame.size.width, _backgroundImageView.frame.size.height);
    _thumbnailImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_thumb.png"]];
    _thumbnailImageView.frame = CGRectMake(0, (_backgroundImageView.frame.size.height - _thumbnailImageView.frame.size.height) / 2.0, _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.size.height);
    _onImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_on.png"]];
    _onImageView.frame = CGRectMake(self.bounds.origin.x+11, self.bounds.origin.y+5, _onImageView.frame.size.width, _onImageView.frame.size.height);
    _offImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_off.png"]];
    _offImageView.frame = CGRectMake(self.bounds.origin.x+57, self.bounds.origin.y+6, _offImageView.frame.size.width, _offImageView.frame.size.height);
    [self addSubview:_backgroundImageView];
    [self addSubview:_onImageView];
    [self addSubview:_offImageView];
    [self addSubview:_thumbnailImageView];
    
    self.backgroundColor = [UIColor clearColor];
    
	//self.onValue = YES;
	[self setPercentageForOn:YES];
}

- (id) init {
	self = [super init];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (id) initWithFrame:(CGRect) frame {
	self = [super initWithFrame:frame];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (BOOL) on {
	return self.onValue;
}

- (void) setOn:(BOOL) on {
	NSLog(@"enter on=%i", on);
	self.onValue = on;
	[self setPercentageForOn:on];
	[self setNeedsDisplay];
}

#pragma mark - Display

- (void) drawRect:(CGRect) rect {
	[super drawRect:rect];
	
	//[self.backgroundImage drawInRect:self.bounds];
    //[self.backgroundImage drawInRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.backgroundImage.size.width, self.backgroundImage.size.height)];
    
    //[self.onImage drawInRect:CGRectMake(self.bounds.origin.x+9, self.bounds.origin.y+9, self.onImage.size.width, self.onImage.size.height) blendMode:kCGBlendModeNormal alpha:self.percentage];
    
    _onImageView.alpha = self.percentage;
    //[self.offImage drawInRect:CGRectMake(self.bounds.origin.x+59, self.bounds.origin.y+9, self.offImage.size.width, self.offImage.size.height) blendMode:kCGBlendModeNormal alpha:1-self.percentage];
    
    _offImageView.alpha = 1-_percentage;
    
	CGFloat thumbnailMaxX = self.bounds.size.width - _thumbnailImageView.frame.size.width;
	if (thumbnailMaxX < 0.0) {
		thumbnailMaxX = 0.0;
	}
	
	CGFloat thumbnailX = _percentage * thumbnailMaxX;
	//CGFloat thumbnailY = (self.backgroundImage.frame.size.height - self.thumbnailImage.frame.size.height) / 2.0;
    
    //NSLog(@"touched %d",self.touching);
    
    if (!_touching) {
        [UIView animateWithDuration:0.2 animations:^{
            if (self.on) {
                _thumbnailImageView.frame = CGRectMake(thumbnailMaxX, _thumbnailImageView.frame.origin.y, _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.size.height);
                _onImageView.alpha = 1;
                _offImageView.alpha = 0;
            }else {
                _thumbnailImageView.frame = CGRectMake(0, _thumbnailImageView.frame.origin.y, _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.size.height);
                _onImageView.alpha = 0;
                _offImageView.alpha = 1;
            }
        }];
    }else {
	
	//[self.thumbnailImage drawInRect:CGRectMake(thumbnailX, thumbnailY, self.thumbnailImage.size.width, self.thumbnailImage.size.height)];
    _thumbnailImageView.frame = CGRectMake(thumbnailX, _thumbnailImageView.frame.origin.y, _thumbnailImageView.frame.size.width, _thumbnailImageView.frame.size.height);
    }
}

#pragma mark - Touch

- (void) handlePercentageForPoint:(CGPoint) point {
	CGFloat minX = _thumbnailImageView.frame.size.width / 2.0;
	CGFloat maxX = self.bounds.size.width - minX;
	
	if (point.x < minX) {
		_percentage = 0.0;
	} else if (point.x > maxX) {
		_percentage = 1.0;
	} else {
		_percentage = (point.x - minX) / (self.bounds.size.width - _thumbnailImageView.frame.size.width);
	}
}

- (void) touchesBegan:(NSSet*) touches withEvent:(UIEvent*) event {
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
	//NSLog(@"enter point=%@", NSStringFromCGPoint(touchPoint));
	if (CGRectContainsPoint(self.bounds, touchPoint)) {
		_touching = YES;
		_moved = NO;
		[self handlePercentageForPoint:touchPoint];
		[self setNeedsDisplay];
	}
}

- (void) touchesMoved:(NSSet*) touches withEvent:(UIEvent*) event {
	CGPoint touchPoint = [[touches anyObject] locationInView:self];
    //	DLog(@"enter point=%@", NSStringFromCGPoint(touchPoint));
	//CGRect boundary = CGRectMake(self.bounds.origin.x - 75.0, self.bounds.origin.y - 75.0, self.bounds.size.width + 150.0, self.bounds.size.height + 150.0);
	if (_touching) {
		//if (CGRectContainsPoint(boundary, touchPoint)) {
			_moved = YES;
			[self handlePercentageForPoint:touchPoint];
			[self setNeedsDisplay];
		//} else {
		//	self.touching = NO;
		//}
	} else {
        //		DLog(@"not-touching point=%@", NSStringFromCGPoint(touchPoint));
		//if (CGRectContainsPoint(boundary, touchPoint)) {
			_moved = YES;
			_touching = YES;
			[self handlePercentageForPoint:touchPoint];
			[self setNeedsDisplay];
		//}
	}
}

- (void) touchesCancelled:(NSSet*) touches withEvent:(UIEvent*) event {
	//CGPoint touchPoint = [[touches anyObject] locationInView:self];
	//NSLog(@"touchesCancelled enter point=%@", NSStringFromCGPoint(touchPoint));
	_touching = NO;
}

- (void) touchesEnded:(NSSet*) touches withEvent:(UIEvent*) event {
	//CGPoint touchPoint = [[touches anyObject] locationInView:self];
	//NSLog(@"touchesEnded enter point=%@", NSStringFromCGPoint(touchPoint));
	BOOL wasTouching = _touching;
	BOOL hadMoved = _moved;
	
	_touching = NO;
	_moved = NO;
	
	BOOL on;
	if (hadMoved) {
        
		on = _percentage >= 0.5;
        //NSLog(@"hadMoved on %d",on);
	} else {
        //NSLog(@"not hadMoved");
		on = ! _onValue;
	}
	BOOL valueChanged = _onValue != on;
	_onValue = on;
	
	//[self setPercentageForOn:on];
    
	[self setNeedsDisplay];
	//NSLog(@"wasTouching %d",wasTouching);
	if (wasTouching && valueChanged) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}
@end
