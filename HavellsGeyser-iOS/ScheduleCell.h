//
//  ScheduleCell.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 03/10/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Schedule.h"

@interface ScheduleCell : UITableViewCell
@property (strong,atomic) Schedule * schedule;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;

@end
