//
//  DetailExhibitViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DetailExhibitViewController.h"
#import "GlobalVariable.h"
#import "FMDatabase.h"
#import "SDImageCache.h"
#import "DebugUtil.h"
#import "Updater.h"

@interface DetailExhibitViewController ()

@end

@implementation DetailExhibitViewController
@synthesize _titleLabel;
@synthesize _timeLabel;
@synthesize _dtimeLabel;
@synthesize _placeLabel;
@synthesize _priceLabel;
@synthesize _pageLabel;
@synthesize _infoLabel;
@synthesize _imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    CHECK_NIL(self);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self set_infoLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) DetailDataSetup: (NSString*) title regionID:(int) region
{
    if (nil == title || 0 > region) {
        DLog(@"wrong parameter");
        assert(0);
    }
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [FMDatabase APPDateSQLConstraint];
    CHECK_NIL(dateSQL);
    //select * from expo where region = 28 and name = xxxxx and edate >= "2012-09-16"
    NSString* NSdetail = [[NSString alloc] initWithFormat:@"select * from %@ where %@ = %i and %@ = \"%@\" and %@",EXPO_TABLE_NAME, EXPO_REGION, region, EXPO_TITLE, title, dateSQL];
    FMResultSet *dbResult = [db executeQuery:NSdetail];
    CHECK_NIL(dbResult);
    NSString *NSurl = nil;
    //TODO: Maybe cannot find detail information when the day change.
    while ([dbResult next]) {
        _titleLabel.text = [dbResult stringForColumn:EXPO_TITLE];
        _timeLabel.text = [dbResult stringForColumn:EXPO_TIME];
        _dtimeLabel.text = [dbResult stringForColumn:EXPO_DETAIL_TIME];
        _priceLabel.text = [dbResult stringForColumn:EXPO_PRICE];
        _placeLabel.text = [dbResult stringForColumn:EXPO_PLACE];
        _pageLabel.text = [dbResult stringForColumn:EXPO_WEBURL];
        _infoLabel.text = [dbResult stringForColumn:EXPO_INFO];
        NSurl = [dbResult stringForColumn:EXPO_IMAGEURL];
    }
    if (nil == _pageLabel.text) {
        _pageLabel.text = @"沒有參考網頁";
    }
    if (nil == _titleLabel.text ||
        nil == _timeLabel.text  ||
        nil == _priceLabel.text ||
        nil == _placeLabel.text ||
        nil == _pageLabel.text  ||
        nil == _dtimeLabel.text ||
        nil == _infoLabel.text  ||
        nil == NSurl) {
        DLog(@"%@, %@, %@, %@, %@, %@, %@, %@", _titleLabel.text, _timeLabel.text, _priceLabel.text, _placeLabel.text, _pageLabel.text, _dtimeLabel.text, _infoLabel.text, NSurl)
        DLog(@"wrong data in the label");
        assert(0);
    }
    if ([self setImage:NSurl]) {
        DLog(@"Cannot set the image url");
        assert(0);
    }
    return FALSE;    
}

- (BOOL) setImage:(NSString *)NSImageURL
{
    if (nil == NSImageURL || nil == _imageView) {
        DLog(@"Error: wrong parameter setImageinProtocol");
        return TRUE;
    }
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    if (nil == manager) {
        DLog(@"Cannot get the manager");
        return TRUE;
    }
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:NSImageURL];
    if (nil == cachedImage) {
        [manager downloadWithURL:[NSURL URLWithString:NSImageURL] delegate:self];
        _imageView.image = [UIImage imageNamed:WAIT_PICTURE_PATH];
    } else {
        _imageView.image = cachedImage;
    }
    return FALSE;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    CHECK_NIL(_imageView);
    CHECK_NIL(image);
    _imageView.image = image;
    [_imageView setNeedsLayout];
}

@end
