//
//  EventManager.h
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface EventManager : NSObject

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) NSString *selectedCalendarIdentifier;
@property (nonatomic, strong) NSString *selectedEventIdentifier;
@property (nonatomic) BOOL eventsAccessGranted;


-(NSArray *)getLocalEventCalendars;
-(NSArray *)getAllEventCalendars;
-(NSInteger)getSelectedCalendarPos;
-(void)saveCustomCalendarIdentifier:(NSString *)identifier;
-(BOOL)checkIfCalendarIsCustomWithIdentifier:(NSString *)identifier;
-(void)removeCalendarIdentifier:(NSString *)identifier;
-(NSString *)getStringFromDate:(NSDate *)date;
-(NSArray *)getEventsOfSelectedCalendar;
-(NSArray *)getEventsTodayCalendar;
-(void)deleteEventWithIdentifier:(NSString *)identifier;

@end
