//
//  ImageNumberBadgeView.m
//  ExhibitAPP
//
//  Created by eric on 12/10/27.
//
//

#import "ImageNumberBadgeView.h"

#define FONT [UIFont systemFontOfSize:15]

@interface ImageNumberBadgeView()
@property (strong,nonatomic) UIImageView *backgroundImageView;
@property (strong,nonatomic) UILabel *label;

@end

@implementation ImageNumberBadgeView
@synthesize value = _value;
@synthesize hideWhenZero = _hideWhenZero;
@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _backgroundImage = [[UIImage imageNamed:@"imageNumberBadge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 14)];
        _backgroundImageView = [[UIImageView alloc]initWithImage:_backgroundImage];
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = FONT;
        _label.textColor = [UIColor whiteColor];
        [_backgroundImageView addSubview:_label];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString* numberString = [NSString stringWithFormat:@"%d",self.value];

	CGSize numberSize = [numberString sizeWithFont:FONT];
    
    _backgroundImageView.frame = CGRectMake((self.bounds.size.width-(28+numberSize.width))/2, 0, 28+numberSize.width, 28);
    _label.frame = CGRectMake(14, 4, numberSize.width, numberSize.height);
    
    _label.text = numberString;

    [self addSubview:_backgroundImageView];
}


- (void)setValue:(NSUInteger)inValue
{
	_value = inValue;
    
    if (self.hideWhenZero == YES && _value == 0)
    {
        self.hidden = YES;
    }
    else
    {
        self.hidden = NO;
    }
	
	[self setNeedsDisplay];
}

@end
