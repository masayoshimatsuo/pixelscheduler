//
//  TickView.m
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/02/01.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import "TickView.h"

#define STROKE_COLOR    ([NSColor colorWithCalibratedRed:(38/255.0f) green:(36/255.0f) blue:(36/255.0f) alpha:1.0])

@implementation TickView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;
    
    switch(_pos){
        case 0://left
            CGContextMoveToPoint(context, 0, 0);
            CGContextAddLineToPoint(context, 5, 5);
            CGContextAddLineToPoint(context, 0, 10);
            CGContextAddLineToPoint(context, 0, 0);
            break;
        case 1://right
            CGContextMoveToPoint(context, 10, 0);
            CGContextAddLineToPoint(context, 5, 5);
            CGContextAddLineToPoint(context, 10, 10);
            CGContextAddLineToPoint(context, 10, 0);
            break;
        case 2://top
            CGContextMoveToPoint(context, 10, 10);
            CGContextAddLineToPoint(context, 5, 5);
            CGContextAddLineToPoint(context, 0, 10);
            CGContextAddLineToPoint(context, 10, 10);
            break;
        case 3://btm
            CGContextMoveToPoint(context, 0, 0);
            CGContextAddLineToPoint(context, 5, 5);
            CGContextAddLineToPoint(context, 10, 0);
            CGContextAddLineToPoint(context, 0, 0);
            break;
    }
    
    CGContextSetFillColorWithColor(context, STROKE_COLOR.CGColor);
    CGContextFillPath(context);
}

@end
