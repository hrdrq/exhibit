//
//  SearchViewController.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendar.h"


@interface SearchViewController : UIViewController< UISearchDisplayDelegate, UISearchBarDelegate, PMCalendarControllerDelegate, UIScrollViewDelegate>

+ (NSArray*) scopeItemPair;
@end
