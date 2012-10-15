//
//  MNMobileFunctions.m
//  MindNodeTouchCanvas
//
//  Created by Markus Müller on 15.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MNMobileFunctions.h"


CGPoint MNOffsetPoint(CGPoint point, CGFloat x, CGFloat y) {
	return CGPointMake(point.x + x, point.y + y);
}

CGRect MNRectFromPoints(CGPoint point1, CGPoint point2) {
	
	CGRect result = CGRectZero;
	if (point1.x < point2.x) {
		result.origin.x = point1.x;
		result.size.width = point2.x - point1.x;
	} else {
		result.origin.x = point2.x;
		result.size.width = point1.x - point2.x;
	}
	
	if (point1.y < point2.y) {
		result.origin.y = point1.y;
		result.size.height = point2.y - point1.y;
	} else {
		result.origin.y = point2.y;
		result.size.height = point1.y - point2.y;
	}
	
	return result;
}

void MNCGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, CGFloat radius) {
	// code based on Apple's QuartzDemo Sample
	
	// verify that your radius is no more than half the width and height of your rectangle
	CGFloat width = CGRectGetWidth(rect);
    if (radius > width/2.0) {
        radius = width/2.0;
	}
	
	CGFloat height = CGRectGetHeight(rect);
    if (radius > height/2.0) {
        radius = height/2.0; 
	}
		
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);

	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
}


#pragma mark -
#pragma mark CGColor

CGColorRef MNCGColorCreateGenericRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	const CGFloat components[] = {red, green, blue, alpha};
	CGColorRef colorRef = CGColorCreate(space, components);
	CGColorSpaceRelease(space);
	return colorRef;
}


CGColorRef MNCGColorCreateGenericGray(CGFloat gray, CGFloat alpha) {
	CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
	const CGFloat components[] = {gray, alpha};
	CGColorRef colorRef = CGColorCreate(space, components);
	CGColorSpaceRelease(space);
	return colorRef;
}

