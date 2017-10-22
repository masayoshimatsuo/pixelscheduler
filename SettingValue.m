//
//  SettingValue.m
//  PixelScheduler
//
//  Created by Tashita Akira on 2014/12/21.
//  Copyright (c) 2014年 dao. All rights reserved.
//

#import "SettingValue.h"

@implementation SettingValue

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_selCal forKey:@"selCal"];
    [coder encodeObject:_barPos forKey:@"barPos"];
    [coder encodeObject:_barWidth forKey:@"barWidth"];
    [coder encodeObject:_upDate forKey:@"upDate"];
    [coder encodeObject:_enablePop forKey:@"enablePop"];
    [coder encodeObject:_enableOverWriteStatus forKey:@"enableOverWriteStatus"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    
    _selCal = [decoder decodeObjectForKey:@"selCal"];
    _barPos = [decoder decodeObjectForKey:@"barPos"];

    _barWidth = [decoder decodeObjectForKey:@"barWidth"];
    _upDate = [decoder decodeObjectForKey:@"upDate"];
    
    _enablePop = [decoder decodeObjectForKey:@"enablePop"];
    _enableOverWriteStatus = [decoder decodeObjectForKey:@"enableOverWriteStatus"];
    
    return self;
}

-(NSTimeInterval)getTime{
    NSTimeInterval ret = 0;
    
    switch([_upDate integerValue]){
        case 0:
            ret = 60;
            break;
        case 1:
            ret = 60*5;
            break;
        case 2:
            ret = 60*15;
            break;
        case 3:
            ret = 60*30;
            break;
        case 4:
        default:
            break;
    }
    
    return ret;
}

-(NSInteger)getWidth{
    NSInteger ret = 5;
    
    switch([_barWidth integerValue]){
        case 0:
            ret = 3;
            break;
        case 1:
            ret = 5;
            break;
        case 2:
            ret = 10;
            break;
        default:
            break;
    }
    
    return ret;
}
-(JMTimerBeamOrientations)getPos{
    
    JMTimerBeamOrientations ret = JMTimerBeamOrientationLeft;
    
    switch([_barPos intValue]){
        case 0:
            ret = JMTimerBeamOrientationLeft;
            break;
        case 1:
            ret = JMTimerBeamOrientationTop;
            break;
        case 2:
            ret = JMTimerBeamOrientationBottom;
            break;
        case 3:
            ret = JMTimerBeamOrientationRight;
            break;
        default:
            break;
    }
    
    return ret;
}
@end
