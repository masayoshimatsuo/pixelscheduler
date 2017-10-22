//
//  AppDelegate.h
//  PixelScheduler
//
//  Created by 株式会社ARTMIXTURE on 2015/01/06.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JMTimerBeam.h"
#import "EventManager.h"
#import "SettingValue.h"

@class AppDelegate;

@protocol AppDelegateDel <NSObject>

@optional

- (void)setSettingData:(SettingValue*)data;
- (SettingValue*)getSettingData;

@end

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) EventManager *eventManager;
@property (nonatomic, strong) NSArray *arrCalendars;
@property (strong,nonatomic) NSStatusItem *statusItem;
@property (nonatomic,strong) JMTimerBeam *timerBeam;
@property (weak) IBOutlet NSMenu *StatusBarMenu;
@property (nonatomic, copy) SettingValue *setting;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *ticktimer;

@end