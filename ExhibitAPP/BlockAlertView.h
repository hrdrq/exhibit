//
//  BlockAlertView.h
//
//

#import <UIKit/UIKit.h>

@class BlockAlertView;

@protocol BlockAlertViewDelegate <NSObject>
@optional

- (void)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
//- (void)blockAlert:(BlockAlertView *)blockAlert buttonPressedAtIndex:(NSInteger)index;

@end

@protocol BlockAlertViewDataSource <NSObject>
@required

- (UITableViewCell *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

@optional

- (NSInteger)numberOfSectionsInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView; // default 1
- (NSString *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

@end

@interface BlockAlertView : UIView <UITableViewDelegate, UITableViewDataSource>{
@protected
    //UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setDestructiveButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block;
- (void)addUtilityButtonWithTitle:(NSString *)title fullWidth:(BOOL)fullWidth block:(void (^)())block;
- (void)addTableWithRowsNumberToShow:(NSInteger)number rowHeight:(CGFloat)height tag:(NSInteger)tag style:(UITableViewStyle)style data:(NSMutableArray*)data;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@property (nonatomic, strong) UIImage *backgroundImage;
//@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;
@property (nonatomic, assign) id <BlockAlertViewDelegate> delegate;
@property (nonatomic, assign) id <BlockAlertViewDataSource> dataSource;
@property (nonatomic, strong) UITableView *table;//will be the table added lastly
@property (nonatomic, strong) NSMutableArray *tableData;

@end
