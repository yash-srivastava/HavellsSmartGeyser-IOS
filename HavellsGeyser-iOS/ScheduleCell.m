//
//  ScheduleCell.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 03/10/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "ScheduleCell.h"
#import "GeyserCommands.h"
#import "TCPClient.h"

@implementation ScheduleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)deleteSchedule:(id)sender {
    if([[TCPClient sharedInstance] isConnected]){
        
        int day;
        if([self.schedule.day isEqualToString:@"Mon"]) day = 1;
        else if([self.schedule.day isEqualToString:@"Tue"]) day = 2;
        else if([self.schedule.day isEqualToString:@"Wed"]) day = 3;
        else if([self.schedule.day isEqualToString:@"Thu"]) day = 4;
        else if([self.schedule.day isEqualToString:@"Fri"]) day = 5;
        else if([self.schedule.day isEqualToString:@"Sat"]) day = 6;
        else if([self.schedule.day isEqualToString:@"Sun"]) day = 7;
        
        [[GeyserCommands sharedInstance] deleteSchedule:day scheduleId:[self.schedule.scheduleId intValue]];
    }
    
    
}

@end
