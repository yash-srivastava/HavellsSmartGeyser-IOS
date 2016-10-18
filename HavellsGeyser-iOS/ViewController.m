//
//  ViewController.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 16/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//

#import "ViewController.h"
#import "TCPClient.h"
#import "GeyserCommands.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>

@interface ViewController ()<TCPClientDelegate>

@property(strong,nonatomic) NSUserDefaults *userDefaults;
@end

@implementation ViewController

-(void) loadUI
{
    _geyserIpButton.layer.borderWidth = .5f;
    _geyserIpButton.layer.borderColor = [UIColor blueColor].CGColor;
    _geyserIpButton.layer.cornerRadius = _geyserIpButton.frame.size.height/2;
    
    _configStationModeButton.layer.borderWidth = .5f;
    _configStationModeButton.layer.borderColor = [UIColor blueColor].CGColor;
    _configStationModeButton.layer.cornerRadius = _configStationModeButton.frame.size.height/2;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self loadUI];
    
    // Do any additional setup after loading the view, typically from a nib.
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [_userDefaults removeObjectForKey:@"Geyser"];
    [_userDefaults synchronize];
    
    NSMutableArray *schedules = [[NSMutableArray alloc]initWithCapacity:8];
    NSMutableArray *daySchedules = [[NSMutableArray alloc] initWithCapacity:6];
    
    for(int i=0;i<=5;i++) [daySchedules insertObject:@"0" atIndex:i];
    for(int i=0;i<=7;i++){
        [schedules insertObject:daySchedules atIndex:i];
    }
        
    NSMutableArray *storedSchedules = [_userDefaults valueForKey:@"Geyser"];
    if(storedSchedules == nil){
        [_userDefaults setObject:schedules forKey:@"Geyser"];
        [_userDefaults synchronize];
    }
    
//    
//    NSArray *array = [NEHotspotHelper supportedNetworkInterfaces];
//    
//    NEHotspotNetwork *connectedNetwork = [array lastObject];
//    
//    NSLog(@"supported Network Interface: %@", connectedNetwork);
//    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
//    [options setObject:@"Try Here" forKey:kNEHotspotHelperOptionDisplayName];
//    
//    BOOL returnType = [NEHotspotHelper registerWithOptions:options queue:dispatch_get_main_queue() handler: ^(NEHotspotHelperCommand * cmd) {
//        if(cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList ) {
//            
//            for (NEHotspotNetwork* network  in cmd.networkList) {
//                
//                if ([network.SSID isEqualToString:@"Internet"]){
//                    
//                    [network setConfidence:kNEHotspotHelperConfidenceHigh];
//                    NSLog(@"Confidance set to high for ssid:%@",network.SSID);
//                    
//                }
//                
//            }
//            
//        }
//        
//    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[TCPClient sharedInstance] setTcpDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connectToServer:(id)sender {
    
//    [_commander setWifiParams:_ssidTextField.text auth:4 encryption:3 passphrase:_passwordTextField.text];
    
//    [[TCPClient sharedInstance] connectToSocket];
}


#pragma mark - TCPClient Delegate methods
- (void)connectionState:(NSString *) state
{
    [self performSelectorOnMainThread:@selector(showAlert:) withObject:state waitUntilDone:YES];
//    [self pershowAlert:state];
//    if([[TCPClient sharedInstance] isConnected])
//        [[GeyserCommands sharedInstance] setCurrentTime];

}

-(void) showAlert:(NSString *) msg
{
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue
{
//    NSLog(@"Coming from GREEN!");
}
- (IBAction)connectToGeyser:(id)sender {
    if(![[TCPClient sharedInstance] isConnected])
        [[TCPClient sharedInstance] connectToSocket:self.geyserIpTextField.text];
}

- (IBAction)configStationMode:(id)sender {
        [[GeyserCommands sharedInstance] setWifiParams:_ssidTextField.text auth:4 encryption:3 passphrase:_passwordTextField.text];
    [self showAlert:@"Please wait for 30 sec as you will be disconnected from SoftAP. Connect to configured Wifi manually. Enter the geyserip and click connect GeyserIp"];
}
@end
