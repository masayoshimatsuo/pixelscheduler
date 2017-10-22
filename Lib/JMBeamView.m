//
//  JMBeamView.m
//  Timebox
//
//  Created by Andreas Katzian on 16/02/14.
//  Copyright (c) 2014 JadeMind. All rights reserved.
//

#import "JMBeamView.h"
#import "NSPopover+Message.h"

@interface JMBeamView()

@property (nonatomic, retain) NSColor *color;
@property (nonatomic)NSTrackingArea* trackingArea;
@property (nonatomic)EKEvent *evn;
@property (nonatomic)NSPopover *pop;
@property (nonatomic)BOOL       isPop;

@end


@implementation JMBeamView

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color
{
    self = [super initWithFrame:frameRect];
    _trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:[self bounds]
                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                    owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    self.color = color;
    return self;
}

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color eventCalender:(EKEvent *)event isPop:(BOOL)pop
{
    if(event)
        _evn = event;
    
    _isPop = pop;
    
    return [self initWithFrame:frameRect color:color];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRect:dirtyRect];

    [self.color setFill];
    [rectanglePath fill];
}

- (void)mouseEntered:(NSEvent *)theEvent{

    if(_pop == nil && _isPop){
        NSString *str = [NSString stringWithFormat:@"%@〜%@\n%@",[self dateToString:[_evn startDate] formatString:@"HH:mm"],[self dateToString:[_evn endDate] formatString:@"HH:mm"],_evn.title];
        
        _pop = [NSPopover showPopover:self.frame ofView:self.superview preferredEdge:NSMaxXEdge string:str
                             maxWidth:250.0f];
    }

}

- (void)mouseExited:(NSEvent *)theEvent{

    if(_pop){
        [_pop close];
        _pop = nil;
    }
}

- (NSString*)dateToString:(NSDate *)baseDate formatString:(NSString *)formatString
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];

    [inputDateFormatter setLocale:[NSLocale currentLocale]];
    [inputDateFormatter setDateFormat:formatString];
    NSString *str = [inputDateFormatter stringFromDate:baseDate];
    return str;
}
@end
