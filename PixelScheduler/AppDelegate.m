//
//  AppDelegate.m
//  PixelScheduler
//
//  Created by dao on 2014/11/06.
//  Copyright (c) 2014年 dao. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesWindowController.h"
#import "StartAtLoginController.h"
#import <ServiceManagement/ServiceManagement.h>
#import "PSEvent.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    [self deduplicateRunningInstances];
    
    self.eventManager = [[EventManager alloc] init];

    _setting = [self loadSettingData];
    
    if(_setting == nil){
        _setting = [self makeInitSettingData];
        [self saveSettingData:_setting];
    }
    
    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
    [self performSelector:@selector(loadCalendars) withObject:nil afterDelay:0.5];
    [self startTimer];
}

- (void)deduplicateRunningInstances {
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        [NSApp terminate:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
    [self saveSettingData:_setting];
    [self exitApp];

}

- (void) exitApp{
    
    if([_timer isValid])
        [_timer invalidate];
    
    if([_ticktimer isValid])
        [_ticktimer invalidate];
    
    if(self.timerBeam)
    {
        [self.timerBeam stop];
        self.timerBeam = nil;
    }
}
- (void) createStatus{
    
    if(_statusItem == nil){
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        _statusItem.title = @"";
        _statusItem.image = [NSImage imageNamed:@"menuicon16"];
        _statusItem.menu = _StatusBarMenu;
        _statusItem.highlightMode = YES;
    }
}
- (void) updateBar:(JMTimerBeamOrientations) orientation width:(NSInteger)width
{
    if(_timerBeam){
        NSArray *allevents = [self getPSEvents:_arrCalendars];
        [_timerBeam update:allevents];
    }
}

- (void) showTimerBeam:(JMTimerBeamOrientations) orientation width:(NSInteger)width  allSpaces:(BOOL)allSpaces
{
    [self createStatus];
    
    if(self.timerBeam)
    {
        [self.timerBeam stop];
        self.timerBeam = nil;
    }
    
    NSArray *allevents = [self getPSEvents:_arrCalendars];
    
    self.timerBeam = [[JMTimerBeam alloc] initWithDuration:5 * 60
                                               orientation:orientation
                                                 allSpaces: allSpaces
                                                 thickness:width
                                                     color:[NSColor clearColor]
                                                     event:allevents
                                                  delegate:self];
    [self.timerBeam start];
}

- (NSArray*)getPSEvents:(NSArray*)cals
{
    NSMutableArray *allevents = NSMutableArray.new;
    
    for(EKCalendar *cal in cals){
        
        NSArray *evns = [self.eventManager getEvents:cal];
        for(EKEvent *evn in evns){
            PSEvent *pe = PSEvent.new;
            pe.evn      = evn;
            pe.color    = cal.color;
            [allevents addObject:pe];
        }
    }
    
    return allevents;
}

- (IBAction)ClickUpdate:(id)sender {
    [self loadCalendars];
}

- (IBAction)ClickExit:(id)sender {
    [NSApp terminate:nil];
}

- (IBAction)ClickSetting:(id)sender {

    PreferencesWindowController *sharedController = [PreferencesWindowController sharedPreferencesWindowController:self];
    sharedController.apDel = self;
    
    [sharedController showWindow:self];
}

- (void)setSettingData:(SettingValue*)data{
    
    _setting = data.copy;
    [self exitApp];
    
    [self loadCalendars];
    
    [self saveSettingData:_setting];
}
- (SettingValue*)getSettingData{

    return _setting.copy;
}

-(void)requestAccessToEvents{
    [self.eventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (error == nil) {
            // Store the returned granted value.
            self.eventManager.eventsAccessGranted = granted;
        }
        else{
            // In case of error, just log its description to the debugger.
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)loadCalendars{
    if (self.eventManager.eventsAccessGranted) {
        _arrCalendars = [self.eventManager getAllEventCalendars];
    }
    if(_timerBeam){
        [self updateBar:[_setting getPos] width:[_setting getWidth]];
    }else{
        [self showTimerBeam:[_setting getPos] width:[_setting getWidth] allSpaces:[_setting.enableAllSpaces boolValue]];
    }
}

-(SettingValue*)makeInitSettingData{
    
    SettingValue *tmp = SettingValue.new;
    
    tmp.selCal = [NSNumber numberWithInt:0];
    tmp.barPos = [NSNumber numberWithInt:0];
    tmp.barWidth = [NSNumber numberWithInt:1];
    tmp.upDate = [NSNumber numberWithInt:0];
    tmp.enablePop = [NSNumber numberWithBool:YES];
    tmp.enableStartUp = [NSNumber numberWithBool:YES];
    
    return tmp;
}

-(SettingValue*)loadSettingData{
    
    SettingValue *tmp = nil;
    
    NSData* settingData = (NSData*)[[NSUserDefaults standardUserDefaults] objectForKey:@"settingData"];
    
    if(settingData != nil)
        tmp = [NSKeyedUnarchiver unarchiveObjectWithData:settingData];
    
    return tmp;
}
- (void)moveTick
{
    [self.timerBeam moveTickPos];
}
-(void)startTimer
{
    if([_timer isValid])
        [_timer invalidate];
    
    if([_ticktimer isValid])
        [_ticktimer invalidate];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:[_setting getTime] target:self selector:@selector(loadCalendars) userInfo:nil repeats:YES];
    
    self.ticktimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(moveTick) userInfo:nil repeats:YES];
}
-(BOOL)saveSettingData:(SettingValue*)data{
    
    BOOL ret = NO;
    
    if(data){
        [self startTimer];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSData* settingData = [NSKeyedArchiver archivedDataWithRootObject:data];
        [ud setObject:settingData forKey:@"settingData"];
        [ud synchronize];
        ret = YES;
        
        SMLoginItemSetEnabled((__bridge CFStringRef)@"jp.artmixture.PixelSchedulerHelper", data.enableStartUp.boolValue);
    }
    
    return ret;
    
}
@end
