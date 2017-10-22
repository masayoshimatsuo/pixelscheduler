//
//  JMTimerBeam.m
//  Timebox
//
//  Created by Andreas Katzian on 15/02/14.
//  Copyright (c) 2014 JadeMind. All rights reserved.
//

#import "JMTimerBeam.h"
#import "JMBeamView.h"
#import "EventManager.h"
#import "AppDelegate.h"

@interface JMTimerBeam()

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) JMTimerBeamOrientations orientation;
@property (nonatomic, retain) NSColor *color;
@property (nonatomic, assign) NSInteger thickness;

@property (nonatomic, retain) NSScreen *beamScreen;
@property (nonatomic, retain) NSWindow *beamWindow;
@property (nonatomic, retain) JMBeamView *beamView;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic)NSArray *cal;
@property(weak)id<AppDelegateDel> delegate;
@property (nonatomic) SettingValue *setting;

@property (atomic, assign) BOOL running;
@property (nonatomic)NSArray *colorTable;

@end



@implementation JMTimerBeam

#pragma mark - Initializer methods

- (id) initWithDuration:(NSTimeInterval) duration
            orientation:(JMTimerBeamOrientations) orientation
              thickness:(NSInteger) thickness
                  color:(NSColor *) color
               calender:(NSArray *) data
                delegate:(id)delegate;
{
    if(data)
        _cal = data;
    
    if(delegate){
        _delegate = delegate;
        if(self.delegate && [self.delegate respondsToSelector:@selector(getSettingData)])
            _setting = [self.delegate getSettingData];
    }
    
    return [self initWithDuration:duration orientation:orientation thickness:thickness color:color];
}
- (id) initWithDuration:(NSTimeInterval) duration
            orientation:(JMTimerBeamOrientations) orientation
              thickness:(NSInteger) thickness
                  color:(NSColor*) color
{
    if(self = [super init])
    {
        _colorTable = [NSArray arrayWithObjects:[NSColor lightGrayColor],
                                                [NSColor whiteColor],
                                                [NSColor redColor],
                                                [NSColor greenColor],
                                                [NSColor blueColor],
                                                [NSColor cyanColor],
                                                [NSColor yellowColor],
                                                [NSColor orangeColor],
                                                [NSColor purpleColor],nil];
        // Store parameters
        self.duration = duration;
        self.orientation = orientation;
        self.color = color;
        self.thickness = thickness;

        // Set default values
        self.startTime = nil;
        self.running = NO;
        
        // Select the screen
        self.beamScreen = [[NSScreen screens] firstObject];
        
        // Get the initial rect
        NSRect beamWindowRect = [self beamWindowRect];
        
        // Create the beam window
        NSWindow *window = [[NSWindow alloc] initWithContentRect:beamWindowRect
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO
                                                          screen:self.beamScreen];
        
        window.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"background"]];
        window.alphaValue = 0.8f;
        [window setOpaque:NO];
        [window setLevel:NSStatusWindowLevel];
        [window setReleasedWhenClosed:NO];
        
        self.beamWindow = window;
        
        for(EKEvent *evn in _cal){
            
            NSRect beamRect = [self getEventViewFrameSize:evn];
            JMBeamView *view = [[JMBeamView alloc] initWithFrame:NSMakeRect(beamRect.origin.x, beamRect.origin.y, beamRect.size.width, beamRect.size.height) color:[self getEventColor] eventCalender:evn isPop:[_setting.enablePop boolValue]];
            
            [self.beamWindow.contentView addSubview:view];
            
        }
    }
    
    return self;
}
- (NSRect)getEventViewFrameSize:(EKEvent*)event
{
    NSRect ret = [self beamRectForProgress:1.f];
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
            ret.origin.x    += [self getEventPos:event];
            ret.size.height -= 1;
            ret.size.width  = [self getEventWidth:event];
            break;
        case JMTimerBeamOrientationTop:
            ret.origin.x    += [self getEventPos:event];
            ret.origin.y    += 1;
            ret.size.width  = [self getEventWidth:event];
            break;
        case JMTimerBeamOrientationLeft:
            ret.origin.y    += [self getEventPos:event];
            ret.size.width  -= 1;
            ret.size.height = [self getEventHeight:event];
            break;
        case JMTimerBeamOrientationRight:
            ret.origin.y    += [self getEventPos:event];
            ret.origin.x    += 1;
            ret.size.height = [self getEventHeight:event];
            break;
    }
    

    
    return ret;
}
- (NSColor*)getEventColor{
    return (NSColor*)[_colorTable objectAtIndex:(int)arc4random_uniform((u_int32_t)_colorTable.count)];
}

#pragma mark - Timer methods

- (void) start
{
    if(self.running == YES) return;
    
    // Show the beam window
    [self.beamWindow makeKeyAndOrderFront:NSApp];

    self.running = YES;
    self.startTime = [NSDate date];

}

- (void) stop
{
    if(self.running == NO) return;

    self.running = NO;
    self.startTime = nil;

    // Hide the window
    [self.beamWindow resignKeyWindow];
    [self.beamWindow close];
    self.beamWindow = nil;

    // Destroy the timer
    [self.timer invalidate];
}

- (void) update
{
    if(self.running == NO) return;
    
    // Calculate elapsed time
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startTime];
    
    if(elapsed >= self.duration)
    {
        // Stop the timer
        [self stop];
        
        // Notifiy the delegate

    }
    else
    {
        // Calculate progress of new beam rectangle and udpate the beam view
        CGFloat progress = (self.duration - elapsed) / self.duration;
        NSRect rect = [self beamRectForProgress:progress];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.beamView setFrame:rect];
            [self.beamView setNeedsDisplay:YES];
        });
        
    }
}


#pragma mark - Helper methods
- (CGFloat)getEventPos:(EKEvent*)evn{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ;
    NSDateComponents *toDaycomps    = [cal components:flags fromDate:[NSDate date]];
    NSDate *toDay = [cal dateFromComponents:toDaycomps];
    
    CGFloat ret = 0.0f;
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
        case JMTimerBeamOrientationTop:
        {
            ret = [self beamBaseLength] - (([self getSecHeight]*[evn.startDate timeIntervalSinceDate:toDay])+[self getEventHeight:evn]);
            break;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            ret = [self beamBaseLength] - (([self getSecWidth]*[evn.startDate timeIntervalSinceDate:toDay])+[self getEventWidth:evn]);
            break;
        }
    }
    
    return ret;
}
- (CGFloat)getEventHeight:(EKEvent*)evn{
    return [self getSecHeight]*[evn.endDate timeIntervalSinceDate:evn.startDate];
}
- (CGFloat)getHourHeight{
    return [self beamBaseLength] / 24.0;
}
- (CGFloat)getMinHeight{
    return [self getHourHeight] / 60.0;
}
- (CGFloat)getSecHeight{
    return [self getMinHeight] / 60.0;
}
- (CGFloat)getEventWidth:(EKEvent*)evn{
    return [self getSecWidth]*[evn.endDate timeIntervalSinceDate:evn.startDate];
}
- (CGFloat)getHourWidth{
    return [self beamBaseLength] / 24.0;
}
- (CGFloat)getMinWidth{
    return [self getHourWidth] / 60.0;
}
- (CGFloat)getSecWidth{
    return [self getMinWidth] / 60.0;
}
// Returns the basic length of the beam in pixels depending
// on the screen size
- (CGFloat) beamBaseLength
{
    NSSize screenSize = self.beamScreen.frame.size;
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
        case JMTimerBeamOrientationTop:
        {
            return screenSize.width;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            return screenSize.height;
        }
    }
}

// Returns the beam rectangle for given progress within the beam window
// depending on the screen size
- (NSRect) beamRectForProgress:(CGFloat) progress
{
    NSRect rect;
    NSSize screenSize = self.beamScreen.frame.size;

    // ensure progress between 0 and 1
    progress = fmin(1.f, progress);
    progress = fmax(0.f, progress);

    // Calculate length of beam
    CGFloat beamLength = [self beamBaseLength] * progress;
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
        case JMTimerBeamOrientationTop:
        {
            rect = NSMakeRect(screenSize.width - beamLength, 0, beamLength, self.thickness);
            break;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            rect = NSMakeRect(0, 0, self.thickness, beamLength);
            break;
        }
    }
    
    return rect;
}


// Returns the main frame rectangle for the beam window
- (NSRect) beamWindowRect
{
    NSRect rect;
    NSSize screenSize = self.beamScreen.frame.size;
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
        {
            rect = NSMakeRect(0, 0, screenSize.width, self.thickness);
            break;
        }
        case JMTimerBeamOrientationTop:
        {
            rect = NSMakeRect(0, screenSize.height - self.thickness, screenSize.width, self.thickness);
            break;
        }
        case JMTimerBeamOrientationLeft:
        {
            if([_setting.enableOverWriteStatus integerValue] == NSOnState){
                rect = NSMakeRect(0,0, self.thickness, screenSize.height);
            }else{
                rect = NSMakeRect(0,[self.beamScreen visibleFrame].size.height - (screenSize.height - 5), self.thickness, screenSize.height);
            }
            break;
        }
        case JMTimerBeamOrientationRight:
        {
            if([_setting.enableOverWriteStatus integerValue] == NSOnState){
                rect = NSMakeRect(screenSize.width - self.thickness, 0, self.thickness,  screenSize.height);
            }else{
                rect = NSMakeRect(screenSize.width - self.thickness,[self.beamScreen visibleFrame].size.height - (screenSize.height - 5), self.thickness, screenSize.height);
            }
            
            break;
        }
    }
    
    return rect;
}

- (void) setCalender:(NSArray*)data
{
    if(data)
        _cal = data;
    
    [self update];
}

@end
