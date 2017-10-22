//
//  EventManager.m
//  EventKitDemo
//
//  Created by Gabriel Theodoropoulos on 11/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "EventManager.h"


@interface EventManager()

@property (nonatomic, strong) NSMutableArray *arrCustomCalendarIdentifiers;

@end


@implementation EventManager


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Check if the access granted value for the events exists in the user defaults dictionary.
        if ([userDefaults valueForKey:@"eventkit_events_access_granted"] != nil) {
            // The value exists, so assign it to the property.
            self.eventsAccessGranted = [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            // Set the default value.
            self.eventsAccessGranted = NO;
        }
        
        
        // Load the selected calendar identifier.
        if ([userDefaults objectForKey:@"eventkit_selected_calendar"] != nil) {
            self.selectedCalendarIdentifier = [userDefaults objectForKey:@"eventkit_selected_calendar"];
        }
        else{
            self.selectedCalendarIdentifier = @"";
        }
    
        
        // Load the custom calendar identifiers (if exist).
        if ([userDefaults objectForKey:@"eventkit_cal_identifiers"] != nil) {
            self.arrCustomCalendarIdentifiers = [userDefaults objectForKey:@"eventkit_cal_identifiers"];
        }
        else{
            self.arrCustomCalendarIdentifiers = [[NSMutableArray alloc] init];
        }
    }
    return self;
}


#pragma mark - Setter method override

-(void)setEventsAccessGranted:(BOOL)eventsAccessGranted{
    _eventsAccessGranted = eventsAccessGranted;
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:eventsAccessGranted] forKey:@"eventkit_events_access_granted"];
}


-(void)setSelectedCalendarIdentifier:(NSString *)selectedCalendarIdentifier{
    _selectedCalendarIdentifier = selectedCalendarIdentifier;
    
    [[NSUserDefaults standardUserDefaults] setObject:selectedCalendarIdentifier forKey:@"eventkit_selected_calendar"];
}


#pragma mark - Private method implementation

-(NSArray *)getLocalEventCalendars{
    NSArray *allCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSMutableArray *localCalendars = [[NSMutableArray alloc] init];
    
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if (currentCalendar.type == EKCalendarTypeLocal) {
            [localCalendars addObject:currentCalendar];
        }
    }
    
    return (NSArray *)localCalendars;
}

-(NSArray *)getAllEventCalendars{
    return [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
}

-(void)saveCustomCalendarIdentifier:(NSString *)identifier{
    [self.arrCustomCalendarIdentifiers addObject:identifier];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.arrCustomCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];
}


-(BOOL)checkIfCalendarIsCustomWithIdentifier:(NSString *)identifier{
    BOOL isCustomCalendar = NO;
    
    for (int i=0; i<self.arrCustomCalendarIdentifiers.count; i++) {
        if ([[self.arrCustomCalendarIdentifiers objectAtIndex:i] isEqualToString:identifier]) {
            isCustomCalendar = YES;
            break;
        }
    }
    
    return isCustomCalendar;
}


-(void)removeCalendarIdentifier:(NSString *)identifier{
    [self.arrCustomCalendarIdentifiers removeObject:identifier];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.arrCustomCalendarIdentifiers forKey:@"eventkit_cal_identifiers"];
}


-(NSString *)getStringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    [dateFormatter setDateFormat:@"d MMM yyyy, HH:mm"];
    NSString *stringFromDate = [dateFormatter stringFromDate:date];
    return stringFromDate;
}

-(NSArray *)getEventsTodayCalendar
{
    EKCalendar *calendar = nil;
    if (self.selectedCalendarIdentifier != nil && self.selectedCalendarIdentifier.length > 0) {
        calendar = [self.eventStore calendarWithIdentifier:self.selectedCalendarIdentifier];
    }
    
    NSArray *calendarsArray = nil;
    if (calendar != nil) {
        calendarsArray = @[calendar];
    }
    
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay ;
    
    NSDateComponents *toDaycomps    = [cal components:flags fromDate:[NSDate date]];
    NSDateComponents *tomorrowcomps = [[NSDateComponents alloc] init];
    [tomorrowcomps setDay:1];
    
    NSDate *toDay = [cal dateFromComponents:toDaycomps];
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowcomps toDate:[NSDate date] options:flags];
    
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:toDay endDate:tomorrow calendars:calendarsArray];
    
    return [self getEventsCalendar:predicate];
}

-(NSInteger)getSelectedCalendarPos{
    NSInteger ret = 0;
    EKCalendar *calendar = [self.eventStore defaultCalendarForNewEvents];
    NSArray *allCalendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    for(int i=0;i<allCalendars.count;i++){
        EKCalendar *cal = allCalendars[i];

        if([cal.title isEqualToString:calendar.title]){
            ret = i;
            break;
        }
    }
    
    return ret;
}
-(NSArray *)getEventsOfSelectedCalendar{
    
    EKCalendar *calendar = nil;
    if (self.selectedCalendarIdentifier != nil && self.selectedCalendarIdentifier.length > 0) {
        calendar = [self.eventStore calendarWithIdentifier:self.selectedCalendarIdentifier];
    }
    
    NSArray *calendarsArray = nil;
    if (calendar != nil) {
        calendarsArray = @[calendar];
    }
    
    // Create a predicate value with start date a year before and end date a year after the current date.
    int yearSeconds = 365 * (60 * 60 * 24);
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:-yearSeconds] endDate:[NSDate dateWithTimeIntervalSinceNow:yearSeconds] calendars:calendarsArray];
    
    return [self getEventsCalendar:predicate];
}
-(NSArray *)getEventsCalendar:(NSPredicate*)predicate{
    
    // Get an array with all events.
    NSArray *eventsArray = [self.eventStore eventsMatchingPredicate:predicate];
    
    // Copy all objects one by one to a new mutable array, and make sure that the same event is not added twice.
    NSMutableArray *uniqueEventsArray = [[NSMutableArray alloc] init];
    for (int i=0; i<eventsArray.count; i++) {
        EKEvent *currentEvent = [eventsArray objectAtIndex:i];
        
        BOOL eventExists = NO;
        
        // Check if the current event has any recurring rules set. If not, no need to run the next loop.
        if (currentEvent.recurrenceRules != nil && currentEvent.recurrenceRules.count > 0) {
            for (int j=0; j<uniqueEventsArray.count; j++) {
                if ([[[uniqueEventsArray objectAtIndex:j] eventIdentifier] isEqualToString:currentEvent.eventIdentifier]) {
                    // The event already exists in the array.
                    eventExists = YES;
                    break;
                }
            }
        }
        
        // If the event does not exist to the new array, then add it now.
        if (!eventExists) {
            [uniqueEventsArray addObject:currentEvent];
        }
    }
    
    // Sort the array based on the start date.
    uniqueEventsArray = (NSMutableArray *)[uniqueEventsArray sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
    
    // Return that array.
    return (NSArray *)uniqueEventsArray;
}

-(void)deleteEventWithIdentifier:(NSString *)identifier{
    // Get the event that's about to be deleted.
    EKEvent *event = [self.eventStore eventWithIdentifier:identifier];
    
    // Delete it.
    NSError *error;
    if (![self.eventStore removeEvent:event span:EKSpanFutureEvents commit:YES error:&error]) {
        // Display the error description.
        NSLog(@"%@", [error localizedDescription]);
    }
}


@end
