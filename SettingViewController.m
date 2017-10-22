//
//  SettingViewController.m
//  PixelScheduler
//
//  Created by Tashita Akira on 2014/11/11.
//  Copyright (c) 2014年 dao. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
@property (weak) IBOutlet NSTableView *eventTable;
@property (weak) IBOutlet NSSegmentedControl *barPos;
@property (weak) IBOutlet NSSegmentedControl *barWidth;
@property (weak) IBOutlet NSComboBox *eventUpdate;
@property (weak) IBOutlet NSButton *checkEnablePop;
@property (weak) IBOutlet NSButton *checkEnableOverwrite;



@property (nonatomic,strong) SettingValue *setting;
@property (nonatomic,strong) NSArray *cals;
@property (nonatomic) EventManager *eventManager;
@property(weak)id<AppDelegateDel> delegate;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    //[super viewDidLoad];

    _delegate = self.representedObject;
    self.eventManager = [[EventManager alloc] init];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(getSettingData)])
        _setting = [self.delegate getSettingData];
    
    if (self.eventManager.eventsAccessGranted) {
        _cals = [self.eventManager getAllEventCalendars];
    }
    
    [self initControll];
}

- (void)initControll
{
    self.title = @"setting";
    [_barPos setSelected:YES forSegment:[_setting.barPos integerValue]];
    [_barWidth setSelected:YES forSegment:[_setting.barWidth integerValue]];
    [_eventUpdate selectItemAtIndex:[_setting.upDate integerValue]];
    [_checkEnablePop setState:[_setting.enablePop integerValue]];
    [_checkEnableOverwrite setState:[_setting.enableOverWriteStatus integerValue]];
    
    [_eventTable setHeaderView:nil];
    [_eventTable setDataSource:self];
    _eventTable.enabled = NO;
    
    if (self.eventManager.eventsAccessGranted) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[_eventManager getSelectedCalendarPos]];
        [_eventTable selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    
    
    
}

-(void)viewDidDisappear{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(setSettingData:)])
        [self.delegate setSettingData:_setting];
    
}

- (IBAction)selectPos:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    
    _setting.barPos = [NSNumber numberWithInteger:[control selectedSegment]];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(setSettingData:)])
        [self.delegate setSettingData:_setting];
}
- (IBAction)selectBarWidth:(id)sender {
    NSSegmentedControl *control = (NSSegmentedControl *)sender;
    
    _setting.barWidth = [NSNumber numberWithInteger:[control selectedSegment]];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(setSettingData:)])
        [self.delegate setSettingData:_setting];
}

- (IBAction)selectUpdate:(id)sender {
    NSComboBox *control = (NSComboBox *)sender;
    
    _setting.upDate = [NSNumber numberWithInteger:[control indexOfSelectedItem]];
}
- (IBAction)checkPopEvent:(id)sender {
    NSButton *btn = (NSButton*)sender;
    
    _setting.enablePop = [NSNumber numberWithInteger:btn.state];
}
- (IBAction)checkOverwriteStatus:(id)sender {
    NSButton *btn = (NSButton*)sender;

    _setting.enableOverWriteStatus = [NSNumber numberWithInteger:btn.state];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{

    return _cals.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    
    EKCalendar *cal = _cals[rowIndex];
    
    return cal.title;
}

@end
