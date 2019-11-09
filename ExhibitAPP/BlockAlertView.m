//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"

#define kBlockTypeButton @"blockTypeButton"
#define kBlockTypeUtilityButton @"blockTypeUtilityButton"
#define kBlockTypeTable @"blockTypeTable"

@implementation BlockAlertView

//@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize tableData = _tableData;
@synthesize table = _table;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockAlertView class])
    {
        background = [UIImage imageNamed:kAlertViewBackground];
        background = [background stretchableImageWithLeftCapWidth:0 topCapHeight:kAlertViewBackgroundCapHeight];
        titleFont = kAlertViewTitleFont;
        messageFont = kAlertViewMessageFont;
        buttonFont = kAlertViewButtonFont;
    }
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[BlockAlertView alloc] initWithTitle:title message:message];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message 
{
    UIWindow *parentView = [BlockBackground sharedInstance];
    CGRect frame = parentView.bounds;
    frame.origin.x = floorf((frame.size.width - background.size.width) * 0.5);
    frame.size.width = background.size.width;
    if ((self = [super initWithFrame:frame]))
    {
        
        
        //_view = [[UIView alloc] initWithFrame:frame];
        _blocks = [[NSMutableArray alloc] init];
        _height = kAlertViewBorder + 6;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];

            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width-kAlertViewBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kAlertViewTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = kAlertViewTitleShadowColor;
            labelView.shadowOffset = kAlertViewTitleShadowOffset;
            labelView.text = title;
            [self addSubview:labelView];
            
            _height += size.height + kAlertViewBorder;
        }
        
        if (message)
        {
            CGSize size = [message sizeWithFont:messageFont
                              constrainedToSize:CGSizeMake(frame.size.width-kAlertViewBorder*2, 1000)
                                  lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kAlertViewBorder, _height, frame.size.width-kAlertViewBorder*2, size.height)];
            labelView.font = messageFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kAlertViewMessageTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = kAlertViewMessageShadowColor;
            labelView.shadowOffset = kAlertViewMessageShadowOffset;
            labelView.text = message;
            [self addSubview:labelView];
            
            _height += size.height + kAlertViewBorder;
        }
        
        _vignetteBackground = NO;
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color fullWidth:(BOOL)fullWidth block:(void (^)())block
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        kBlockTypeButton,
                        block ? [block copy] : [NSNull null],
                        title,
                        color,
                        [NSNumber numberWithBool:fullWidth],
                        nil]];
}

- (void)addButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"gray" fullWidth:fullWidth block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"black" fullWidth:fullWidth block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" fullWidth:fullWidth block:block];
}

- (void)addTableWithRowsNumberToShow:(NSInteger)number rowHeight:(CGFloat)height tag:(NSInteger)tag style:(UITableViewStyle)style data:(NSMutableArray *)data
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        kBlockTypeTable,
                        [NSNumber numberWithInteger:number],
                        [NSNumber numberWithFloat:height],
                        [NSNumber numberWithInteger:tag],
                        [NSNumber numberWithInt:style],
                        nil]];
    _tableData = data;
}

- (void)addUtilityButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        kBlockTypeUtilityButton,
                        block ? [block copy] : [NSNull null],
                        title,
                        @"black",
                        [NSNumber numberWithBool:fullWidth],
                        nil]];}

- (void)show
{
    BOOL isSecondButton = NO;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < _blocks.count; i++)
    {
        NSArray *block = [_blocks objectAtIndex:i];
        NSString *type = [block objectAtIndex:0];
        
        if ([type isEqualToString:kBlockTypeButton] || [type isEqualToString:kBlockTypeUtilityButton])
        {
                        
            NSString *title = [block objectAtIndex:2];
            NSString *color = [block objectAtIndex:3];
            BOOL fullWidth = [[block objectAtIndex:4] boolValue];

            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button.png", color]];
            image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width+1)>>1 topCapHeight:0];
            
            CGFloat maxHalfWidth = floorf((self.bounds.size.width-kAlertViewBorder*3)*0.5);
            CGFloat width = self.bounds.size.width-kAlertViewBorder*2;
            CGFloat xOffset = kAlertViewBorder;
            if (isSecondButton)
            {
                width = maxHalfWidth;
                xOffset = width + kAlertViewBorder * 2;
                isSecondButton = NO;
            }
            else if (_blocks.count  == 1)
            {
                // In this case this is the ony button. We'll size according to the text
                CGSize size = [title sizeWithFont:buttonFont
                                      minFontSize:10
                                   actualFontSize:nil
                                         forWidth:self.bounds.size.width-kAlertViewBorder*2
                                    lineBreakMode:UILineBreakModeClip];
                
                size.width = MAX(size.width, 80);
                if (size.width + 2 * kAlertViewBorder < width)
                {
                    width = size.width + 2 * kAlertViewBorder;
                    xOffset = floorf((self.bounds.size.width - width) * 0.5);
                }
            }
            else if (i + 1 < _blocks.count && !fullWidth)
            {
                NSArray *block2 = [_blocks objectAtIndex:i+1];
                NSString *type2 = [block2 objectAtIndex:0];
                
                if ([type2 isEqualToString:kBlockTypeButton] || [type2 isEqualToString:kBlockTypeUtilityButton])
                {
                    BOOL fullWidth2 = [[block2 objectAtIndex:4] boolValue];
                    if (!fullWidth2)
                    {
                        // In this case there's another button.
                        // Let's check if they fit on the same line.
                        CGSize size = [title sizeWithFont:buttonFont
                                              minFontSize:10
                                           actualFontSize:nil
                                                 forWidth:self.bounds.size.width-kAlertViewBorder*2
                                            lineBreakMode:UILineBreakModeClip];
                        
                        if (size.width < maxHalfWidth - kAlertViewBorder)
                        {
                            // It might fit. Check the next Button
                            NSString *title2 = [block2 objectAtIndex:2];
                            size = [title2 sizeWithFont:buttonFont
                                            minFontSize:10
                                         actualFontSize:nil
                                               forWidth:self.bounds.size.width-kAlertViewBorder*2
                                          lineBreakMode:UILineBreakModeClip];
                            
                            if (size.width < maxHalfWidth - kAlertViewBorder)
                            {
                                // They'll fit!
                                isSecondButton = YES;  // For the next iteration
                                width = maxHalfWidth;
                            }
                        }

                    } 
                }
            }
            
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(xOffset, _height, width, kAlertButtonHeight);
            button.titleLabel.font = buttonFont;
            button.titleLabel.minimumFontSize = 10;
            button.titleLabel.textAlignment = UITextAlignmentCenter;
            button.titleLabel.shadowOffset = kAlertViewButtonShadowOffset;
            button.backgroundColor = [UIColor clearColor];
            button.tag = i+1;
            
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button setTitleColor:kAlertViewButtonTextColor forState:UIControlStateNormal];
            [button setTitleShadowColor:kAlertViewButtonShadowColor forState:UIControlStateNormal];
            [button setTitle:title forState:UIControlStateNormal];
            button.accessibilityLabel = title;
            

            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:button];
            
            if (!isSecondButton)
                _height += kAlertButtonHeight + kAlertViewBorder;
        }
        else if([type isEqualToString:kBlockTypeTable])
        {
            NSInteger rowsNumber = [[block objectAtIndex:1] integerValue];
            CGFloat rowHeight = [[block objectAtIndex:2] floatValue];
            CGFloat tableHeight = rowsNumber * rowHeight;
            NSInteger tableTag = [[block objectAtIndex:3] integerValue];
            UITableViewStyle tableStyle = [[block objectAtIndex:4] integerValue];
            CGFloat width = self.bounds.size.width-kAlertViewBorder*2;
            CGFloat xOffset = kAlertViewBorder;
            
            UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(xOffset, _height, width, tableHeight) style:tableStyle];
            table.rowHeight = rowHeight;
            table.tag = tableTag;
            table.delegate = self;
            table.dataSource = self;
            _table = table;
            
            [self addSubview:table];
            _height += tableHeight + kAlertViewBorder;
        }
            
            
        index++;
    }
    
    _height += 10;  // Margin for the shadow
    
    if (_height < background.size.height)
    {
        CGFloat offset = background.size.height - _height;
        _height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < _blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[self viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }

    CGRect frame = self.frame;
    frame.origin.y = - _height;
    frame.size.height = _height;
    self.frame = frame;
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:self.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [self insertSubview:modalBackground atIndex:0];
    
    if (_backgroundImage)
    {
        [BlockBackground sharedInstance].backgroundImage = _backgroundImage;
        _backgroundImage = nil;
    }
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:self];

    __block CGPoint center = self.center;
    center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + kAlertViewBounce;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         self.center = center;
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:0
                                          animations:^{
                                              center.y -= kAlertViewBounce;
                                              self.center = center;
                                          } 
                                          completion:nil];
                     }];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:1];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             CGPoint center = self.center;
                             center.y += 20;
                             self.center = center;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0.0 
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  CGRect frame = self.frame;
                                                  frame.origin.y = -frame.size.height;
                                                  self.frame = frame;
                                                  [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                                              } 
                                              completion:^(BOOL finished) {
                                                  [[BlockBackground sharedInstance] removeView:self];
                                                  //_view = nil;
                                              }];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:self];
        //_view = nil;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [sender tag] - 1;
    if ([[[_blocks objectAtIndex: buttonIndex] objectAtIndex:0] isEqualToString:kBlockTypeButton]) {
        [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }else if ([[[_blocks objectAtIndex: buttonIndex] objectAtIndex:0] isEqualToString:kBlockTypeUtilityButton]) {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:1];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    /* 若有須要
    if ([_delegate respondsToSelector:@selector(blockAlert:buttonPressedAtIndex:)]) {
        [_delegate blockAlert:self buttonPressedAtIndex:buttonIndex];
    }
     */
    
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([_delegate respondsToSelector:@selector(blockAlert:tableView:didSelectRowAtIndexPath:)])
		[_delegate blockAlert:self tableView:tableView didSelectRowAtIndexPath:indexPath];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [_dataSource blockAlert:self tableView:tableView	cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_dataSource blockAlert:self tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([_dataSource respondsToSelector:@selector(numberOfSectionsInBlockAlert:tableView:)])
		return [_dataSource numberOfSectionsInBlockAlert:self tableView:tableView];
    
	return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_dataSource blockAlert:self tableView:tableView titleForHeaderInSection:section];
}

@end
