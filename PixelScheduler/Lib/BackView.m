//
//  BackView.m
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/02/06.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import "BackView.h"
#import "NSPopover+Message.h"
#import "JMBeamView.h"

@interface BackView()

@property (nonatomic)NSTrackingArea* trackingArea;
@property (nonatomic)NSPopover *pop;

@end

@implementation BackView

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    _trackingArea = [[NSTrackingArea alloc]
                     initWithRect:self.bounds
                     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                     owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];

    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSColor *startingColor;
    NSColor *endingColor;
    NSGradient* aGradient;
    startingColor = [self colorFromRGB:38 g:36 b:36];
    endingColor   = [self colorFromRGB:41 g:39 b:39];
    aGradient = [[NSGradient alloc]
                 initWithStartingColor:startingColor
                 endingColor:endingColor];
    NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:0 yRadius:0];
    
    [aGradient drawInBezierPath:bezierPath angle:_pos];

}

- (NSColor *)colorFromRGB:(int)r g:(int)g b:(int)b
{
    return [NSColor colorWithCalibratedRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1.0];
}

- (void)mouseEntered:(NSEvent *)theEvent{
    
    if(_popInfo.length > 0){
        _pop = [NSPopover showPopover:self.frame ofView:self.superview preferredEdge:NSMaxXEdge string:_popInfo
                              stringColor:TEXT_COLOR_B backgroundColor:POPBACK_COLOR_W maxWidth:250.0f];
    }
    
}

- (void)mouseExited:(NSEvent *)theEvent{
    
    if(_pop){
        [_pop close];
        _pop = nil;
    }
}


@end
