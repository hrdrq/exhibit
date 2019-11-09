//
//  MyFavoriteTestBehavior.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/13.
//
//

#import "MyFavoriteTestBehavior.h"

@interface MyFavoriteTestBehavior()

@property (strong, nonatomic) NSMutableArray* _elementArray;

@end

@implementation MyFavoriteTestBehavior
@synthesize _elementArray;

-(BOOL) ItemAdd: (ActivityRoughData*) roughData
{
    BOOL ret = TRUE;
    int isExist = -1;
    if (nil == _elementArray) {
        _elementArray = [[NSMutableArray alloc] init];
    }
    CHECK_NIL(_elementArray);
    if (-1 == (isExist = [self ItemIsExist:roughData])) {
        goto End;
    } else if (1 == isExist) {
        ret = FALSE;
        goto End;
    }
    [_elementArray addObject:roughData];
    ret = FALSE;
End:
    return ret;
}

-(BOOL) ItemRemove: (ActivityRoughData*) roughData
{
    CHECK_NIL(roughData);
    BOOL ret = TRUE;
    if (nil == roughData) {
        DLog(@"Error: wrong parameter");
        goto End;
    }
    if (nil == _elementArray) {
        ret = FALSE;
        goto End;
    }
    for (ActivityRoughData* item in _elementArray) {
        if (item == roughData || 0 == [roughData compare:item]) {
            [_elementArray removeObject:item];
            break;
        }
    }
    ret = FALSE;
End:
    return ret;
}

-(int) ItemIsExist: (ActivityRoughData*) roughData
{
    CHECK_NIL(roughData);
    int ret = -1;
    if (nil == roughData) {
        goto End;
    }
    if (nil == _elementArray) {
        ret = 0;
        goto End;
    }
    for (ActivityRoughData* item in _elementArray) {
        if (item == roughData || 0 == [roughData compare:item]) {
            ret = 1;
            goto End;
        }
    }
    ret = 0;
End:
    return ret;
}

-(BOOL) ItemRemoveAll
{
    if (nil == _elementArray) {
        return false;
    }
    [_elementArray removeAllObjects];
    return false;
}

-(NSMutableArray*) ItemSelect
{
    return [[NSMutableArray alloc] initWithArray: _elementArray];
}

+(id<MyFavoriteAbstractLayerProtocol>) DelegateToOther
{
    static MyFavoriteTestBehavior *behaviorManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        behaviorManager = [[MyFavoriteTestBehavior alloc] init];
    });
    CHECK_NIL(behaviorManager)
    return behaviorManager;
}

@end
