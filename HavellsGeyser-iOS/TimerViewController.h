//
//  TimerViewController.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 19/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *currentTimePicker;
@property (weak, nonatomic) IBOutlet UILabel *geyserNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UISlider *timerSlider;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

- (IBAction)onOffSwitchClick:(id)sender;

- (IBAction)setTime:(id)sender;
- (IBAction)timerValue:(id)sender;

- (IBAction)temperatureValue:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

- (IBAction)saveChanges:(id)sender;

- (IBAction)setTempAndTimer:(id)sender;
@end
