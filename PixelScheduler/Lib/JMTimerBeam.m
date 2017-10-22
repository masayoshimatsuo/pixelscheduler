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
#import "TickView.h"
#import "BackView.h"
#import "PSEvent.h"

#define TICKSIZE        10
#define MAINBAROFFSET   1

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

@property (nonatomic) NSArray *evn;
@property (nonatomic) NSMutableArray *evnViews;
@property(weak)id<AppDelegateDel> delegate;
@property (nonatomic) SettingValue *setting;

@property (atomic, assign) BOOL running;
@property (nonatomic)TickView *tick;
@property (nonatomic)BackView *back;

@end



@implementation JMTimerBeam

#pragma mark - Initializer methods

- (id) initWithDuration:(NSTimeInterval) duration
            orientation:(JMTimerBeamOrientations) orientation
              thickness:(NSInteger) thickness
                  color:(NSColor *) color
               event:(NSArray *) data
                delegate:(id)delegate;
{
    if(data)
        _evn = data;
    
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
        // Store parameters
        self.duration = duration;
        self.orientation = orientation;
        self.color = color;
        self.thickness = thickness;
        
        // Set default values
        self.startTime = nil;
        self.running = NO;
        
        _evnViews = NSMutableArray.new;
        
        // Select the screen
        self.beamScreen = [[NSScreen screens] firstObject];
        
        // Get the initial rect
        NSRect beamWindowRect = [self beamWindowRect];
        
        _back = [[BackView alloc] initWithFrame:[self getBackPos]];
        
        // Create the beam window
        NSWindow *window = [[NSWindow alloc] initWithContentRect:beamWindowRect
                                                       styleMask:NSBorderlessWindowMask
                                                         backing:NSBackingStoreBuffered
                                                           defer:NO
                                                          screen:self.beamScreen];
        
        window.backgroundColor = self.color;
        window.alphaValue = 1.0f;
        [window setOpaque:NO];
        [window setLevel:NSStatusWindowLevel];
        [window setReleasedWhenClosed:NO];
        
        self.beamWindow = window;
        
        
        [self setEvns:_evn];
        
        _tick = [[TickView alloc] initWithFrame:[self getTickPos]];
        [self setTickData];
        [self.beamWindow.contentView addSubview:_tick];
        
        [self getTimePos];
    }
    
    return self;
}
- (NSString *)getAllDayText:(NSArray *)evns;
{
    NSString *ret = @"";
    
    for(PSEvent *psevn in evns){
        
        if(psevn.evn.allDay)
            ret = [ret stringByAppendingFormat:@"%@\n\n",[self getEventInfo:psevn.evn]];
    }
    
    if([ret hasSuffix:@"\n\n"])
        ret = [ret substringToIndex:ret.length - 2];
    
    return ret;
}
- (NSString *)getEventInfo:(EKEvent *)evn
{
    return [NSString stringWithFormat:@"%@〜%@\n%@",[self dateToString:[evn startDate] formatString:@"HH:mm"],[self dateToString:[evn endDate] formatString:@"HH:mm"],evn.title];
}
- (NSString*)dateToString:(NSDate *)baseDate formatString:(NSString *)formatString
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    
    [inputDateFormatter setLocale:[NSLocale currentLocale]];
    [inputDateFormatter setDateFormat:formatString];
    NSString *str = [inputDateFormatter stringFromDate:baseDate];
    return str;
}
- (NSRect)getEventViewFrameSize:(EKEvent*)event
{
    NSRect ret = [self beamRectForProgress:1.f];
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
            ret.origin.x    += [self getEventPos:event];
            ret.origin.y    -= (TICKSIZE + MAINBAROFFSET) - 1;
            ret.size.width  = [self getEventWidth:event];
            break;
        case JMTimerBeamOrientationTop:
            ret.origin.x    += [self getEventPos:event];
            ret.origin.y    += TICKSIZE;
            ret.size.width  = [self getEventWidth:event];
            break;
        case JMTimerBeamOrientationLeft:
            ret.origin.y    += [self getEventPos:event];
            ret.size.width  -= TICKSIZE  + MAINBAROFFSET;
            ret.size.height = [self getEventHeight:event];
            break;
        case JMTimerBeamOrientationRight:
            ret.origin.y    += [self getEventPos:event];
            ret.origin.x    += TICKSIZE  + MAINBAROFFSET;
            ret.size.height = [self getEventHeight:event];
            break;
    }
    

    
    return ret;
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

- (void) setEvns:(NSArray*)evns
{
    [_evnViews removeAllObjects];
    
    _back.popInfo = [self getAllDayText:evns];
    [self.beamWindow.contentView addSubview:_back];
    
    for(PSEvent *psevn in evns){

        if(!psevn.evn.allDay){
            NSRect beamRect = [self getEventViewFrameSize:psevn.evn];
            
            JMBeamView *view = [[JMBeamView alloc] initWithFrame:NSMakeRect(beamRect.origin.x, beamRect.origin.y, beamRect.size.width, beamRect.size.height) color:psevn.color eventCalender:psevn.evn orientation:_orientation isPop:[_setting.enablePop boolValue]];
            [self.beamWindow.contentView addSubview:view];
            [_evnViews addObject:view];
        }
    }
}

- (void) update:(NSArray*)evns
{
    for(JMBeamView *v in _evnViews){
        [v removeFromSuperview];
    }
    [_back removeFromSuperview];
    [self setEvns:evns];
    [_beamWindow update];
}

#pragma mark - Helper methods
- (void)setTickData
{
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
            _tick.pos = 3;
            _back.pos = 270;
            break;
        case JMTimerBeamOrientationTop:
            _tick.pos = 2;
            _back.pos = 90;
            break;
        case JMTimerBeamOrientationLeft:
            _tick.pos = 0;
            _back.pos = 180;
            break;
        case JMTimerBeamOrientationRight:
            _tick.pos = 1;
            _back.pos = 0;
            break;
    }
}
- (void)moveTickPos{
    if(_tick){
        _tick.frame = [self getTickPos];
    }
}
- (NSRect)getTickPos
{
    NSRect ret;
    NSRect bmr = [self beamWindowRect];
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
            ret = NSMakeRect([self getTimePos],bmr.size.height - TICKSIZE, TICKSIZE, TICKSIZE);
            break;
        case JMTimerBeamOrientationTop:
            ret = NSMakeRect([self getTimePos],0, TICKSIZE, TICKSIZE);
            break;
        case JMTimerBeamOrientationLeft:
            ret = NSMakeRect(bmr.size.width - TICKSIZE, [self getTimePos], TICKSIZE, TICKSIZE);
            break;
        case JMTimerBeamOrientationRight:
            ret = NSMakeRect(1, [self getTimePos], TICKSIZE, TICKSIZE);
            break;
        
    }
    
    return ret;
}
- (CGFloat)getTimePos
{
    CGFloat ret = 0.0f;
    NSRect bmr = [self beamWindowRect];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *nowDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *nowDate = [dateFormatter dateFromString:nowDateStr];
    
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
        case JMTimerBeamOrientationTop:
        {
            ret = ([self getSecWidth] * [[NSDate date] timeIntervalSinceDate:nowDate]);
            ret -= (TICKSIZE / 2);
            
            if(( ret + (TICKSIZE / 2)) > bmr.size.width)
                ret = 0;
            break;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            CGFloat h = ([self.beamScreen visibleFrame].size.height + [self.beamScreen visibleFrame].origin.y);
            ret = h - ([self getSecHeight] * [[NSDate date] timeIntervalSinceDate:nowDate]);
            ret -= (TICKSIZE / 2);
            
            CGFloat over  = (bmr.size.height - ret);
            CGFloat menuh = (bmr.size.height - h);

            if(over < menuh + TICKSIZE){
                ret = h - TICKSIZE;
            }

            break;
        }
    }

    
    return ret;
}
- (NSRect)getBackPos
{
    NSRect ret;
    //NSRect bmr = [self beamWindowRect];
    NSRect bmr = [self beamRectForProgress:1.f];
    switch (self.orientation)
    {
        case JMTimerBeamOrientationBottom:
            ret = NSMakeRect(0, bmr.origin.y - (TICKSIZE - 1), bmr.size.width, bmr.size.height);
            break;
        case JMTimerBeamOrientationTop:
            ret = NSMakeRect(0, bmr.origin.y + TICKSIZE, bmr.size.width, bmr.size.height);
            break;
        case JMTimerBeamOrientationLeft:
            ret = NSMakeRect(0, bmr.origin.y, bmr.size.width - TICKSIZE, bmr.size.height);
            break;
        case JMTimerBeamOrientationRight:
            ret = NSMakeRect(TICKSIZE, bmr.origin.y, bmr.size.width - TICKSIZE, bmr.size.height);
            break;
            
    }
    
    return ret;
}

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
            ret = (([self getSecWidth]*[evn.startDate timeIntervalSinceDate:toDay])+[self getEventHeight:evn]) - [self getEventWidth:evn];
            break;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            ret = [self beamBaseLength] - (([self getSecHeight]*[evn.startDate timeIntervalSinceDate:toDay])+[self getEventWidth:evn]);
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
            return screenSize.height - [self getMenuBarHeight];
        }
    }
}
- (CGFloat) getMenuBarHeight{

    NSSize screenSize = self.beamScreen.frame.size;

    return screenSize.height - ([self.beamScreen visibleFrame].size.height + [self.beamScreen visibleFrame].origin.y);
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
            rect = NSMakeRect(0,0, self.thickness, screenSize.height - [self getMenuBarHeight]);
            break;
        }
        case JMTimerBeamOrientationRight:
        {
            rect = NSMakeRect(screenSize.width - self.thickness, 0, self.thickness,  screenSize.height - [self getMenuBarHeight]);
            break;
        }
    }
    
    return rect;
}

@end
