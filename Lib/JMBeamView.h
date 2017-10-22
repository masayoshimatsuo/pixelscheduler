//
//  JMBeamView.h
//  Timebox
//
//  Created by Andreas Katzian on 16/02/14.
//  Copyright (c) 2014 JadeMind. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventManager.h"

@interface JMBeamView : NSView

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color;
- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color eventCalender:(EKEvent*)event isPop:(BOOL)pop;

@end
