//
//  ViewController.h
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GeyserCommands.h"

@interface ViewController : UIViewController
@property(strong,atomic) GeyserCommands *commander;
@property (weak, nonatomic) IBOutlet UITextField *ssidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *geyserIpTextField;
- (IBAction)connectToGeyser:(id)sender;
- (IBAction)configStationMode:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *geyserIpButton;
@property (weak, nonatomic) IBOutlet UIButton *configStationModeButton;

@end

