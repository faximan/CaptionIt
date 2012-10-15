//
//  MNMobileFunctions.h
//  MindNodeTouchCanvas
//
//  Created by Markus Müller on 15.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
static const CGFloat MNKEYBOARD_PORTRAIT_HEIGHT = 216;
static const CGFloat MNKEYBOARD_LANDSCAPE_HEIGHT = 162;

CGPoint MNOffsetPoint(CGPoint point, CGFloat x, CGFloat y);
CGRect MNRectFromPoints(CGPoint point1, CGPoint point2);

void MNCGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat radius);


// CGColor
CGColorRef MNCGColorCreateGenericRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
CGColorRef MNCGColorCreateGenericGray(CGFloat gray, CGFloat alpha);