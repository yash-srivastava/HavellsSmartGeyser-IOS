//
//  TimerViewController.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 19/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "TimerViewController.h"
#import "TCPClient.h"
#import "GeyserCommands.h"

@interface TimerViewController ()<TCPClientDelegate>
@property(strong,nonatomic) NSUserDefaults *userDefaults;
@end

@implementation TimerViewController

- (void) loadUI
{
    [_currentTimePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    self.timerLabel.text = [NSString stringWithFormat:@"%d min",(int)self.timerSlider.value];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d deg",(int)self.temperatureSlider.value];
    
    [self.onOffSwitch setOn:YES];
}

- (void) loadDelegate
{
    [[TCPClient sharedInstance] setTcpDelegate:self];    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUI];

    _userDefaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[GeyserCommands sharedInstance] setCurrentTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) showAlert:(NSString *) msg
{
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}
#pragma mark - TCPClient Delegate
- (void)connectionState:(NSString *)state
{
    [self showAlert:state];
    
}

- (void) currentTimeChanged:(NSString *) currTime
{
    self.currentTimeLabel.text = currTime;
}

#pragma mark - User Actions
- (IBAction)onOffSwitchClick:(id)sender {
    
    if([self.onOffSwitch isOn])
        if([[TCPClient sharedInstance] isConnected])
            [[GeyserCommands sharedInstance] toggleSwitch:1 duration:(unsigned int)30 temperature:(unsigned int)80];
        else [self showAlert:@"Connection not established"];
    else
        if([[TCPClient sharedInstance] isConnected])
            [[GeyserCommands sharedInstance] toggleSwitch:0 duration:(unsigned int)30 temperature:(unsigned int)80];
        else [self showAlert:@"Connection not established"];
    
    
}


- (IBAction)setTime:(id)sender {
    if([[TCPClient sharedInstance] isConnected])
        [[GeyserCommands sharedInstance] setCurrentTime];
    else [self showAlert:@"Connection not established"];
}

- (IBAction)timerValue:(id)sender {
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d min",(int)self.timerSlider.value];
}

- (IBAction)temperatureValue:(id)sender {
    
    self.temperatureLabel.text = [NSString stringWithFormat:@"%d deg",(int)self.temperatureSlider.value];
}
- (IBAction)saveChanges:(id)sender {
    if([[TCPClient sharedInstance] isConnected])
    [[GeyserCommands sharedInstance] toggleSwitch:1 duration:(unsigned int)self.timerSlider.value temperature:(unsigned int)self.temperatureSlider.value];
    else [self showAlert:@"Connection not established"];
}

- (IBAction)setTempAndTimer:(id)sender {
    if([[TCPClient sharedInstance] isConnected]){
        [[GeyserCommands sharedInstance] toggleSwitch:1 duration:(unsigned int)self.timerSlider.value temperature:(unsigned int)self.temperatureSlider.value];
        [self.onOffSwitch setOn:YES];
    }
    
    else [self showAlert:@"Connection not established"];
}


- (IBAction)unwindToGeyser:(UIStoryboardSegue *)unwindSegue
{
    //    NSLog(@"Coming from GREEN!");
}
@end
