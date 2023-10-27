//
//  SettingView.m
//  PixelScheduler
//
//  Created by ARTMIXTURE on 2015/01/31.
//  Copyright (c) 2015年 株式会社ARTMIXTURE. All rights reserved.
//

#import "SettingView.h"

@interface SettingView()

@property (weak) IBOutlet NSButton *checkEnablePop;
@property (weak) IBOutlet NSButton *checkEnableStartUp;
@property (weak) IBOutlet NSButton *checkEnableAllSpaces;
@property (weak) IBOutlet NSButton *btnBarPosLeft;
@property (weak) IBOutlet NSButton *btnBarPosBottom;
@property (weak) IBOutlet NSButton *btnBarPosRight;
@property (weak) IBOutlet NSButton *btnBarWidthMin;
@property (weak) IBOutlet NSButton *btnBarWidthNormal;
@property (weak) IBOutlet NSButton *btnBarWidthBig;
@property (weak) IBOutlet NSSegmentedControl *eventUpdate;

@property (nonatomic,copy) SettingValue *setting;
@property (nonatomic,strong) NSArray *cals;
@property (nonatomic) EventManager *eventManager;

@property (nonatomic,weak)id<AppDelegateDel> appDel;

@end


@implementation SettingView

-(void)setAppDel:(id<AppDelegateDel>)appDel
{
    
    _appDel = appDel;
    [self loadSettingData];
    
    self.eventManager = [[EventManager alloc] init];
    if (self.eventManager.eventsAccessGranted) {
        _cals = [self.eventManager getAllEventCalendars];
    }
    
    [self initControll];
}

- (void)initControll
{
    NSInteger posval = [_setting.barPos integerValue];
    if(posval == 0){
        _btnBarPosLeft.state = NSOnState;
    }else if(posval == 2){
        _btnBarPosBottom.state = NSOnState;
    }else if(posval == 3){
        _btnBarPosRight.state = NSOnState;
    }
    
    NSInteger widthval = [_setting.barWidth integerValue];
    if(widthval == 0){
        _btnBarWidthMin.state = NSOnState;
    }else if(widthval == 1){
        _btnBarWidthNormal.state = NSOnState;
    }else if(widthval == 2){
        _btnBarWidthBig.state = NSOnState;
    }
    
    [_eventUpdate setSelected:YES forSegment:[_setting.upDate integerValue]];
    [_checkEnablePop setState:[_setting.enablePop integerValue]];
    [_checkEnableAllSpaces setState:[_setting.enableAllSpaces integerValue]];
    [_checkEnableStartUp setState:[_setting.enableStartUp integerValue]];
}

- (IBAction)clickPos:(NSButton *)sender {
    _btnBarPosLeft.state = NSOffState;
    _btnBarPosRight.state = NSOffState;
    _btnBarPosBottom.state = NSOffState;
    
    sender.state = NSOnState;
    _setting.barPos = [NSNumber numberWithInteger:sender.tag];
    
    [self saveSettingData];
}

- (IBAction)clickWidth:(NSButton *)sender {
    _btnBarWidthMin.state = NSOffState;
    _btnBarWidthNormal.state = NSOffState;
    _btnBarWidthBig.state = NSOffState;
    
    sender.state = NSOnState;
    _setting.barWidth = [NSNumber numberWithInteger:sender.tag];
    
    [self saveSettingData];
}

- (IBAction)segUpdateTime:(NSSegmentedControl *)sender {
    NSInteger sel = [sender selectedSegment];
    
    _setting.upDate = [NSNumber numberWithInteger:sel];
    [self saveSettingData];
}

- (IBAction)checkPopEvent:(id)sender {
    NSButton *btn = (NSButton*)sender;
    
    _setting.enablePop = [NSNumber numberWithInteger:btn.state];
    [self saveSettingData];
}

- (IBAction)checkAutoStartUP:(id)sender {
    NSButton *btn = (NSButton*)sender;
    
    _setting.enableStartUp = [NSNumber numberWithInteger:btn.state];
    [self saveSettingData];
}

- (IBAction)checkAllSpaces:(id)sender {
    NSButton *btn = (NSButton*)sender;
    
    _setting.enableAllSpaces = [NSNumber numberWithInteger:btn.state];
    [self saveSettingData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    
    return _cals.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    
    EKCalendar *cal = _cals[rowIndex];
    
    return cal.title;
}

-(void)loadSettingData{
 
    if(_appDel && [_appDel respondsToSelector:@selector(getSettingData)])
        _setting = [_appDel getSettingData];
    
}

-(void)saveSettingData{
    
    if(_appDel && [_appDel respondsToSelector:@selector(setSettingData:)])
        [_appDel setSettingData:_setting];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
