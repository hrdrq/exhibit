//
//  SQLDefine.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/10/14.
//
//

#ifndef ExhibitAPP_SQLDefine_h
#define ExhibitAPP_SQLDefine_h

#define MY_FAVORITE_FILE @"MyFavorite.db"
#define MY_FAVORITE_TABLE_NAME @"MyFavorite"

#define DISTANCE_5KM 5.
#define DISTANCE_10KM 10.
#define DISTANCE_20KM 20.

#define EXPO_TITLE @"name"
#define EXPO_PRICE @"price"
#define EXPO_PLACE @"place"
#define EXPO_WEBURL @"page"
#define EXPO_IMAGEURL @"pic"
#define EXPO_TABLE_NAME @"expo"
#define EXPO_REGION @"region"
#define EXPO_LATITUDE @"latitude"
#define EXPO_LONGITUDE @"longitude"
#define EXPO_INFO @"info"
#define EXPO_EDATE @"edate"
#define EXPO_DATE_FORMATTER @"yyyy-MM-dd"
#define EXPO_CATEGORY @"category"

#define EXPO_START_DATE @"sdate"
#define EXPO_END_DATE @"edate"
#define EXPO_START_TIME @"stime"
#define EXPO_END_TIME @"etime"
#define EXPO_WEEK @"week"
#define EXPO_TELEPHONE @"tel"
#define EXPO_ADDRESS @"map"

enum ACTIVITY_TYPE {
    ALL_ACTIVITY = 0,
    START_ACTIVITY,
    NONSTART_ACTIVITY,
    ERROR_ACTIVITY,
};

enum DISTANCE_TYPE {
    MIN_DISTANCE = 0,
    DEFAULT_DISTANCE,
    MAX_DISTANCE,
};

#endif
