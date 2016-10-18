//
//  SchedulerViewController.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 21/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchedulerViewController : UIViewController
- (IBAction)dropDownClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIStackView *topLevelStackView;
@property (weak, nonatomic) IBOutlet UIView *topLevelView;
- (IBAction)tapAnyWhere:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *viewSchedulesButton;
- (void) refreshSchedules;
- (IBAction)viewSchedulesClick:(id)sender;
- (IBAction)saveClick:(id)sender;
- (IBAction)clearValues:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;

@end
