//
//  MKMapVIew+MTLocation.h
//
//  Created by Matthias Tretter on 02.03.11.
//  Copyright (c) 2009-2012  Matthias Tretter, @myell0w. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCMapView.h"


@interface OCMapView (MTLocation)

// creates and initializes a MapView and adds it to superview
+ (id)mapViewInSuperview:(UIView *)superview;

// sizes to MapView so that it can be rotated using a transform without showing it's background
- (void)sizeToFitTrackingModeFollowWithHeading;

- (void)addGoogleBadge;
- (void)addGoogleBadgeAtPoint:(CGPoint)topLeftOfGoogleBadge;

- (void)addHeadingAngleView;
- (void)showHeadingAngleView;
- (void)hideHeadingAngleView;
- (void)moveHeadingAngleViewToCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)rotateToHeading:(CLHeading *)heading;
- (void)rotateToHeading:(CLHeading *)heading animated:(BOOL)animated;

- (void)resetHeadingRotation;
- (void)resetHeadingRotationAnimated:(BOOL)animated;

@end
