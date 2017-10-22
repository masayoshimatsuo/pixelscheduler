//
//  JMBeamView.h
//  Timebox
//
//  Created by Andreas Katzian on 16/02/14.
//  Copyright (c) 2014 JadeMind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventManager.h"
#import "JMTimerBeam.h"

#define STROKE_COLOR    ([NSColor colorWithCalibratedRed:(38/255.0f) green:(36/255.0f) blue:(36/255.0f) alpha:1.0])

#define POPBACK_COLOR_B ([NSColor colorWithCalibratedRed:(38/255.0f) green:(36/255.0f) blue:(36/255.0f) alpha:1.0])
#define POPBACK_COLOR_W ([NSColor colorWithCalibratedRed:(255/255.0f) green:(255/255.0f) blue:(255/255.0f) alpha:1.0])
#define TEXT_COLOR_B    ([NSColor colorWithCalibratedRed:(38/255.0f) green:(36/255.0f) blue:(36/255.0f) alpha:1.0])
#define TEXT_COLOR_W    ([NSColor colorWithCalibratedRed:(255/255.0f) green:(255/255.0f) blue:(255/255.0f) alpha:1.0])


@interface JMBeamView : NSView

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color;
- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color eventCalender:(EKEvent*)event orientation:(JMTimerBeamOrientations)ori isPop:(BOOL)pop;

@property (nonatomic)BOOL       isPop;


@end
