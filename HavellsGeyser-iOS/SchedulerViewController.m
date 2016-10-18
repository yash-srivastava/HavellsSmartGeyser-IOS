//
//  SchedulerViewController.m
//  HavellsGeyser-iOS
//
//  Created by Sivakumar  K R on 21/09/16.
//  Copyright © 2016 Sivakumar  K R. All rights reserved.
//
enum {
    cellStackOffset = 200,
    cellStackLabelOffset = 100,
    cellStackButtonOffset = 0,
};

#import "SchedulerViewController.h"
#import "GeyserCommands.h"
#import "TCPClient.h"
#import "ScheduleCell.h"
@interface SchedulerViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource, TCPClientDelegate>
@property(strong,atomic) UIDatePicker *timeCells;
@property(strong,atomic) UIPickerView *tempCells;
@property(strong,atomic) UIPickerView *durCells;
@property(strong,atomic) NSMutableArray *temperature;
@property(strong,atomic) NSMutableArray *duration;
@property(strong,atomic) NSMutableArray<Schedule *> *foundSchedules;
@property(strong,atomic) NSThread *saveThread;

@property(strong,atomic) UIAlertController *overlay;

@property(strong,nonatomic) NSCalendar *gregorian;
@property(strong,nonatomic) NSDateComponents *comps;

@property(strong,nonatomic) NSUserDefaults *userDefaults;

@end

@implementation SchedulerViewController

long currentTag = -1;
int schedulesArr[8][6];
#pragma mark - View methods
-(void) loadValues
{
    _temperature = [[NSMutableArray alloc] init];
    for(int i=10;i<=90;i++)
        [_temperature addObject:[NSString stringWithFormat:@"%d deg",i]];
    
    _duration = [[NSMutableArray alloc] init];
    [_duration addObject:[NSString stringWithFormat:@"%d min",1]];
    for(int i=2;i<=255;i++)
        [_duration addObject:[NSString stringWithFormat:@"%d mins",i]];
    
    _gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    _comps = [_gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    int weekday = [_comps weekday];
    
    //Clearing the schedulesArr
    memset(schedulesArr,0,sizeof schedulesArr);
    
    
    
}

-(void) loadDelegate
{
    [[TCPClient sharedInstance] setTcpDelegate:self];
    [[GeyserCommands sharedInstance] setCurrentTime];
    
    self.scheduleTableView.delegate = self;
    self.scheduleTableView.dataSource = self;
    
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self viewSchedulesClick:self];
}
- (void) loadUI
{
    _timeCells = [[UIDatePicker alloc] init];
    _timeCells.backgroundColor = [UIColor whiteColor];
    
    _tempCells = [[UIPickerView alloc] init];
    _tempCells.backgroundColor = [UIColor whiteColor];
    
    _durCells = [[UIPickerView alloc] init];
    _durCells.backgroundColor = [UIColor whiteColor];
    
    [_tempCells setDelegate:self];
    [_durCells setDelegate:self];
    [_timeCells setDatePickerMode:UIDatePickerModeTime];
    
    
    [self.timeCells addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.topLevelView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.topLevelView.layer.borderWidth = 1.0;
    
    self.viewSchedulesButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.viewSchedulesButton.layer.borderWidth = 1.0;
    self.viewSchedulesButton.layer.cornerRadius = self.viewSchedulesButton.frame.size.height/2;

    self.scheduleTableView.backgroundColor = [UIColor clearColor];
    self.scheduleTableView.backgroundView = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadUI];
    [self loadValues];
    
    [self.scheduleTableView registerNib:[UINib nibWithNibName:@"ScheduleCell" bundle:nil] forCellReuseIdentifier:@"schedulecell"];
    // Do any additional setup after loading the view.
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    
    _foundSchedules = [[NSMutableArray<Schedule *> alloc]init];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self loadDelegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_foundSchedules count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScheduleCell *cell = (ScheduleCell *)[tableView dequeueReusableCellWithIdentifier:@"schedulecell" forIndexPath:indexPath];
    
    
    if(cell == nil){
        NSArray *temp = [[NSBundle mainBundle] loadNibNamed:@"ScheduleCell" owner:self options:nil];
        cell = [temp objectAtIndex:0];
        
    }
    
    NSMutableArray *schedules = _foundSchedules;
    cell.schedule = [schedules objectAtIndex:indexPath.row];
    cell.dayLabel.text = cell.schedule.day;
    cell.timeLabel.text = cell.schedule.time;
    cell.durationLabel.text = cell.schedule.duration;
    cell.temperatureLabel.text = cell.schedule.temperature;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *schedules = _foundSchedules;
    Schedule * schedule = [schedules objectAtIndex:indexPath.row];
    NSLog(@"%@ %@ %@ %@ %@",schedule.day,schedule.scheduleId,schedule.time,schedule.duration,schedule.temperature);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}
#pragma mark - PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if([_tempCells isEqual:pickerView])
        return [_temperature count];
    else
        return [_duration count];
    
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //Hiding the pickerView separator
    [[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
    pickerView.showsSelectionIndicator = NO;
    
    
    UILabel *cellView = (UILabel *)view;
    if(cellView == nil){
        cellView = [UILabel new];
    }
    cellView.textAlignment = NSTextAlignmentCenter;
    cellView.textColor = [UIColor blackColor];
    if(UI_USER_INTERFACE_IDIOM() ==UIUserInterfaceIdiomPad)
        cellView.font = [UIFont boldSystemFontOfSize:17];
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        cellView.font = [UIFont boldSystemFontOfSize:12];
    
    if([_tempCells isEqual:pickerView])
        cellView.text = [_temperature objectAtIndex:row];
    else
        cellView.text = [_duration objectAtIndex:row];
    
    
    return cellView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    UILabel *currentLabel = (UILabel *)[self.view viewWithTag:pickerView.tag+cellStackLabelOffset];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if([_tempCells isEqual:pickerView])
        currentLabel.text = [NSString stringWithFormat:@"%@",[_temperature objectAtIndex:row]];
    else
        currentLabel.text = [NSString stringWithFormat:@"%@",[_duration objectAtIndex:row]];
    NSLog(@"%ld %ld",(long)component,(long)row);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dropDownClick:(id)sender {
    UIButton *clickedButton = (UIButton *) sender;
    
    long tag = [clickedButton tag];
    if(currentTag == tag){
        [_timeCells removeFromSuperview];
        [_tempCells removeFromSuperview];
        [_durCells removeFromSuperview];
        currentTag = -1;
        return;
    }
    currentTag = tag;
    
    UIStackView *clickedStackView = (UIStackView *)[self.view viewWithTag:tag+cellStackOffset];
    
    long clickedColTag;
    if(1<=tag && tag<=5) clickedColTag = 50;
    else if(6<=tag && tag<=10) clickedColTag = 100;
    else clickedColTag = 150;
    
    UIStackView *clickedColStackView = (UIStackView *)[self.view viewWithTag:clickedColTag];
    CGSize size = clickedStackView.frame.size;
    
    CGRect pos;
    pos.origin.y = _topLevelView.frame.origin.y + _topLevelStackView.frame.origin.y + clickedColStackView.frame.origin.y+ clickedStackView.frame.origin.y + size.height;
    pos.origin.x = _topLevelView.frame.origin.x + _topLevelStackView.frame.origin.x+ clickedColStackView.frame.origin.x + clickedStackView.frame.origin.x;
    pos.size.height = 10* size.height;
    pos.size.width = size.width;
    
    [_timeCells removeFromSuperview];
    [_tempCells removeFromSuperview];
    [_durCells removeFromSuperview];
    if(1<=tag && tag<=5){
        [_timeCells setTag:tag];
        
        [_timeCells setFrame:pos];
        [UIView transitionWithView:_timeCells duration:1.3
                           options:UIViewAnimationOptionCurveLinear //change to whatever animation you like
                        animations:^ { [self.view addSubview:_timeCells]; }
                        completion:nil];
        
        
    }else if(6<=tag && tag<=10){
        [_durCells setTag:tag];
        
        [_durCells setFrame:pos];
        [UIView transitionWithView:_durCells duration:1.3
                           options:UIViewAnimationOptionCurveLinear //change to whatever animation you like
                        animations:^ { [self.view addSubview:_durCells]; }
                        completion:nil];
    }else{
        [_tempCells setTag:tag];
        [_tempCells setFrame:pos];
        [UIView transitionWithView:_tempCells duration:1.3
                           options:UIViewAnimationOptionCurveLinear //change to whatever animation you like
                        animations:^ { [self.view addSubview:_tempCells]; }
                        completion:nil];
    }
    
}

- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    UILabel *currentLabel = (UILabel *)[self.view viewWithTag:datePicker.tag+cellStackLabelOffset];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:datePicker.date];
    
    currentLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)[components hour],(long)[components minute]];
}

-(void) showAlert:(NSString *) msg
{
    UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)tapAnyWhere:(id)sender {
    NSLog(@"wow");
    
    
    [UIView transitionWithView:_timeCells duration:1.3
                       options:UIViewAnimationOptionCurveEaseIn //change to whatever animation you like
                    animations:^ { [_timeCells removeFromSuperview]; }
                    completion:nil];
    
    [UIView transitionWithView:_tempCells duration:1.3
                       options:UIViewAnimationOptionCurveEaseIn //change to whatever animation you like
                    animations:^ { [_tempCells removeFromSuperview]; }
                    completion:nil];
    
    
    [UIView transitionWithView:_durCells duration:1.3
                       options:UIViewAnimationOptionCurveLinear //change to whatever animation you like
                    animations:^ { [_durCells removeFromSuperview]; }
                    completion:nil];
    
}
- (void) refreshSchedules
{
    [_foundSchedules removeAllObjects];
    for(int i=1;i<=7;i++){
        [[GeyserCommands sharedInstance] getSchedulue:i];
        sleep(1);
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        //Update UI in UI thread here
        [self.overlay dismissViewControllerAnimated:YES completion:^{
            [self.scheduleTableView reloadData];
        }];
        
    });
    
    memset(schedulesArr,0,sizeof schedulesArr);
    for (int i=0;i<[_foundSchedules count];i++) {
        int day;
        if([_foundSchedules[i].day isEqualToString:@"Mon"]) day = 1;
        else if([_foundSchedules[i].day isEqualToString:@"Tue"]) day = 2;
        else if([_foundSchedules[i].day isEqualToString:@"Wed"]) day = 3;
        else if([_foundSchedules[i].day isEqualToString:@"Thu"]) day = 4;
        else if([_foundSchedules[i].day isEqualToString:@"Fri"]) day = 5;
        else if([_foundSchedules[i].day isEqualToString:@"Sat"]) day = 6;
        else if([_foundSchedules[i].day isEqualToString:@"Sun"]) day = 7;
        schedulesArr[day][[_foundSchedules[i].scheduleId intValue]] = 1;
    }
}

-(void) saveSchedules
{
    bool flag = true;
    for(int i=1;i<=4;i++){
        
        
        UILabel *fromLabel = (UILabel *)[self.view viewWithTag:i+cellStackLabelOffset];
        UILabel *toLabel = (UILabel *)[self.view viewWithTag:i+5+cellStackLabelOffset];
        UILabel *tempLabel = (UILabel *)[self.view viewWithTag:i+10+cellStackLabelOffset];
        if([fromLabel.text isEqualToString:@"From:"] && [toLabel.text isEqualToString:@"Duration:"] && [tempLabel.text isEqualToString:@"Temp:"]) continue;
        if([toLabel.text isEqualToString:@"Duration:"]){
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Fields should be filled or remain empty to create a schedule successfully" waitUntilDone:YES];
            return;
        }
        if([fromLabel.text isEqualToString:@"From:"]){
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Fields should be filled or remain empty to create a schedule successfully" waitUntilDone:YES];
            return;
        }
        if([tempLabel.text isEqualToString:@"Temp:"]){
            [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Fields should be filled or remain empty to create a schedule successfully" waitUntilDone:YES];
            return;
        }
        
        if(![fromLabel.text isEqualToString:@"From:"] && ![toLabel.text isEqualToString:@"Duration:"] && ![tempLabel.text isEqualToString:@"Temp:"]){
            
            
            NSArray *fromTime = [fromLabel.text componentsSeparatedByString: @":"];
            NSArray *toDur = [toLabel.text componentsSeparatedByString: @" "];
            NSArray *tempTemp = [tempLabel.text componentsSeparatedByString: @" "];
            
            NSString *startTime = [NSString stringWithFormat:@"%02d%02d",[fromTime[0] intValue],[fromTime[1] intValue]];
            int durValue = [toDur[0] intValue];
            int tempValue = [tempTemp[0] intValue];
            switch(i){
                case 1:
                    if([[TCPClient sharedInstance] isConnected]){
                        
                        //Calculating the day
                        int day = (int)([_comps weekday])-1 == 0 ? 7 : (int)([_comps weekday])-1;
                        int scheduleId = 0;
                        
                        //Finding the available schedules
                        for(int i=1;i<=5;i++){
                            if(schedulesArr[day][i]==0){
                                scheduleId = i; break;
                            }
                        }
                        if(scheduleId == 0) scheduleId = 1;
                        
                        
                        [[GeyserCommands sharedInstance] addSchedulue:(int)(day) id:scheduleId startTime:startTime duration:durValue temperature:tempValue];
                        sleep(3);
                        
                        schedulesArr[day][scheduleId]=1;
                        
                    }
                    else {[self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Connection not established" waitUntilDone:YES];
                        flag = false;
                    }
                    break;
                case 2:
                    if([[TCPClient sharedInstance] isConnected]){
                        
                        for(int i=1;i<=7;i++){
                            int scheduleId = 0;
                            
                            //Finding the available schedules
                            for(int j=1;j<=5;j++){
                                if(schedulesArr[i][j] == 0){
                                    scheduleId = j; break;
                                }
                            }
                            if(scheduleId == 0) scheduleId = 1;
                            
                            //Adding the schedule for each day
                            [[GeyserCommands sharedInstance] addSchedulue:i id:scheduleId startTime:startTime duration:durValue temperature:tempValue];
                            sleep(2);
                            
                            schedulesArr[i][scheduleId]=1;
                            
                        }
                    }
                    else {[self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Connection not established" waitUntilDone:YES];
                        flag = false;
                    }
                    break;
                case 3:
                    if([[TCPClient sharedInstance] isConnected])
                        for(int i=1;i<=5;i++){
                            int scheduleId = 0;
                            
                            //Finding the available schedules
                            for(int j=1;j<=5;j++){
                                if(schedulesArr[i][j] == 0){
                                    scheduleId = j; break;
                                }
                            }
                            if(scheduleId == 0) scheduleId = 1;
                            
                            //Adding the schedule for each day
                            [[GeyserCommands sharedInstance] addSchedulue:i id:scheduleId startTime:startTime duration:durValue temperature:tempValue];
                            sleep(2);
                            
                            schedulesArr[i][scheduleId]=1;
                            
                        }
                    else{ [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Connection not established" waitUntilDone:YES];
                        flag = false;
                    }
                    break;
                case 4:
                    if([[TCPClient sharedInstance] isConnected])
                        for(int i=6;i<=7;i++){
                            int scheduleId = 0;
                            
                            //Finding the available schedules
                            for(int j=1;j<=5;j++){
                                if(schedulesArr[i][j] == 0){
                                    scheduleId = j; break;
                                }
                            }
                            if(scheduleId == 0) scheduleId = 1;
                            
                            //Adding the schedule for each day
                            [[GeyserCommands sharedInstance] addSchedulue:i id:scheduleId startTime:startTime duration:durValue temperature:tempValue];
                            sleep(2);
                            
                            schedulesArr[i][scheduleId]=1;
                            
                        }
                    else {
                        [self performSelectorOnMainThread:@selector(showAlert:) withObject:@"Connection not established" waitUntilDone:YES];
                        flag = false;
                    }
                    break;
                    
            }
        }
    }
    
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        //Update UI in UI thread here
        if(flag){
            [self showAlert:@"Svae successfull"];
            [self clearValues:self];
        }
        else
            [self showAlert:@"Svae failed. Please try again"];
        [self.overlay dismissViewControllerAnimated:YES completion:^{
            [self.scheduleTableView reloadData];
        }];
        
    });
}


- (IBAction)viewSchedulesClick:(id)sender {
    
    
    
    if(self.saveThread == nil || [self.saveThread isFinished] || [self.saveThread isCancelled]){
        
        
        _overlay = [UIAlertController alertControllerWithTitle:@"Please wait" message:@"Loading schedules..." preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_overlay animated:YES completion:nil];
        
        _saveThread = [[NSThread alloc] initWithTarget:self selector:@selector(refreshSchedules)object:nil];
        //Starting a new thread
        [self.saveThread start];
    }
    
    
}

- (IBAction)saveClick:(id)sender {
    
    
    if(self.saveThread == nil || [self.saveThread isFinished] || [self.saveThread isCancelled]){
        
        
        _overlay = [UIAlertController alertControllerWithTitle:@"Please wait" message:@"Saving schedules..." preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:_overlay animated:YES completion:nil];
        
        _saveThread = [[NSThread alloc] initWithTarget:self selector:@selector(saveSchedules)object:nil];
        //Starting a new thread
        [self.saveThread start];
    }
    
    
}

- (IBAction)clearValues:(id)sender {
    for(int i=1;i<=4;i++){
        UILabel *fromLabel = (UILabel *)[self.view viewWithTag:i+cellStackLabelOffset];
        UILabel *toLabel = (UILabel *)[self.view viewWithTag:i+5+cellStackLabelOffset];
        UILabel *tempLabel = (UILabel *)[self.view viewWithTag:i+10+cellStackLabelOffset];
        fromLabel.text = @"From:";
        toLabel.text = @"Duration:";
        tempLabel.text = @"Temp:";
    }
}

#pragma mark TCP delegate methods
- (void)connectionState:(NSString *)state
{
    [self showAlert:state];
    
}

- (void) schedulesUpdated:(Schedule *)schedule
{
    bool flag = true;
    for (int i=0;i<[_foundSchedules count];i++) {
        if([_foundSchedules[i].day isEqualToString:schedule.day] && [_foundSchedules[i].scheduleId isEqualToString:schedule.scheduleId]){
            _foundSchedules[i].duration = schedule.duration;
            _foundSchedules[i].time = schedule.time;
            _foundSchedules[i].temperature = schedule.temperature;
            flag = false; break;
        }
    }
    if(flag) [_foundSchedules addObject:schedule];
    [self.scheduleTableView reloadData];
}

- (void) scheduleDeleted
{
    
//    [_foundSchedules removeAllObjects];
    [self viewSchedulesClick:self];
    
}
@end
