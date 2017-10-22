//
//  JMTimerBeam.h
//  Timebox
//
//  Created by Andreas Katzian on 15/02/14.
//  Copyright (c) 2014 JadeMind. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM (NSUInteger, JMTimerBeamOrientations) {
    JMTimerBeamOrientationTop,
    JMTimerBeamOrientationLeft,
    JMTimerBeamOrientationRight,
    JMTimerBeamOrientationBottom
}_JMTimerBeamOrientations;

@interface JMTimerBeam : NSObject


/// Init new timer beam with given duration, orientation, thichkness and color
- (id) initWithDuration:(NSTimeInterval) duration
            orientation:(JMTimerBeamOrientations) orientation
              thickness:(NSInteger) thickness
                  color:(NSColor*) color;

- (id) initWithDuration:(NSTimeInterval) duration
            orientation:(JMTimerBeamOrientations) orientation
              thickness:(NSInteger) thickness
                  color:(NSColor *) color
               event:(NSArray *) data
               delegate:(id)delegate;
/// Show the timer beam on screen and start the timer
- (void) start;

/// Dismiss the timer beam and stop the timer
- (void) stop;

- (void) update:(NSArray*)evns;

- (void) moveTickPos;

@end
