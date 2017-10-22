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
@property (nonatomic) JMTimerBeamOrientations orientation;

@end


@implementation JMBeamView

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color
{
    self = [super initWithFrame:frameRect];
    _trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:self.bounds
                                    options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways
                                    owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    self.color = color;
    return self;
}

- (id) initWithFrame:(NSRect)frameRect color:(NSColor*) color eventCalender:(EKEvent *)event orientation:(JMTimerBeamOrientations)ori isPop:(BOOL)pop
{
    if(event)
        _evn = event;
    
    _orientation = ori;
    _isPop = pop;
    
    return [self initWithFrame:frameRect color:color];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRect:dirtyRect];

    [self.color setFill];
    [rectanglePath fill];
    
    CGContextRef context = (CGContextRef)NSGraphicsContext.currentContext.graphicsPort;
    
    CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
    CGContextSetLineWidth(context, 1.0);
    
    switch (_orientation) {
        case JMTimerBeamOrientationBottom:
        case JMTimerBeamOrientationTop:
        {
            break;
        }
        case JMTimerBeamOrientationLeft:
        case JMTimerBeamOrientationRight:
        {
            
            CGContextMoveToPoint(context, dirtyRect.origin.x, dirtyRect.origin.y);
            CGContextAddLineToPoint(context, dirtyRect.size.width, 0);
            CGContextMoveToPoint(context, dirtyRect.origin.x, dirtyRect.size.height);
            CGContextAddLineToPoint(context, dirtyRect.size.width, dirtyRect.size.height);
            break;
        }
    }

    CGContextStrokePath(context);
}

- (void)mouseEntered:(NSEvent *)theEvent{

    NSString *str;

    if(_isPop && _pop == nil){
        str = [NSString stringWithFormat:@"%@〜%@\n%@",[self dateToString:[_evn startDate] formatString:@"HH:mm"],[self dateToString:[_evn endDate] formatString:@"HH:mm"],_evn.title];
        _pop = [NSPopover showPopover:self.frame ofView:self.superview preferredEdge:NSMaxXEdge string:str
                          stringColor:TEXT_COLOR_B backgroundColor:POPBACK_COLOR_W maxWidth:250.0f];
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
