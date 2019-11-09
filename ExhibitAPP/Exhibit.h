//
//  Exhibit.h
//  ExhibitAPP
//
//  Created by eric on 12/10/6.
//
//

#ifndef ExhibitAPP_Exhibit_h
#define ExhibitAPP_Exhibit_h

#import "CLLocationManagerSingleton.h"
#import "DebugUtil.h"
#import "GlobalVariable.h"
#import "NSDateHandler.h"

#import "Updater.h"
#import "FileHandler.h"
#import "NetworkHandler.h"

#import "FMDatabase.h"

#define THEME_COLOR [UIColor colorWithRed:189.0/255 green:170.0/255 blue:137.0/255 alpha:0.8]
#define THEME_COLOR_LIGHT [UIColor colorWithRed:248.0/255 green:241.0/255 blue:219.0/255 alpha:1]

//#define THEME_COLOR_DARK [UIColor colorWithRed:176.0/255 green:153.0/255 blue:124.0/255 alpha:1]

#define THEME_COLOR_DEEP_DARK [UIColor colorWithRed:81.0/255 green:72.0/255 blue:65.0/255 alpha:1]

#define THEME_COLOR_TABLE [UIColor colorWithRed:252.0/255 green:249.0/255 blue:241.0/255 alpha:1]


#define THEME_COLOR_WHITE [UIColor colorWithRed:0.985 green:0.956 blue:0.912 alpha:1.000]
#define THEME_COLOR_1 [UIColor colorWithRed:0.639 green:0.510 blue:0.357 alpha:1.000]
#define THEME_COLOR_2 [UIColor colorWithRed:0.795 green:0.694 blue:0.530 alpha:1.000]
#define THEME_COLOR_3 [UIColor colorWithRed:0.577 green:0.370 blue:0.240 alpha:1.000]
#define THEME_COLOR_4 [UIColor colorWithRed:0.716 green:0.565 blue:0.400 alpha:1.000]
#define THEME_COLOR_DARK [UIColor colorWithRed:0.343 green:0.264 blue:0.192 alpha:1.000]
#define THEME_COLOR_GREEN [UIColor colorWithRed:0.692 green:0.707 blue:0.298 alpha:1.000]
#define THEME_COLOR_RED [UIColor colorWithRed:0.869 green:0.413 blue:0.448 alpha:1.000]
#define THEME_COLOR_BADGE [UIColor colorWithRed:0.355 green:0.307 blue:0.271 alpha:1.000]

enum{
    filteringTypeCity,
    filteringTypeCategory
};

#define TAG_FILTERING_CITY 1
#define TAG_FILTERING_CATEGORY 2

#endif
