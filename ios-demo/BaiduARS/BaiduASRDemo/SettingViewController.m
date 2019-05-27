//
//  SettingViewController.m
//  BaiduASRDemo
//
//  Created by Wu,Yunpeng(AI2B) on 2019/4/25.
//  Copyright © 2019 Cloud. All rights reserved.
//

#import "SettingViewController.h"
#import "ASRConfig.h"
#import "SettingViewCell.h"
#import "SettingViewCellModel.h"

@interface SettingViewController ()<UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, SettingViewCellDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView *modelPicker;
@property (nonatomic, weak) IBOutlet UITableView *settingTableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *pickerHeight;

@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic, strong) SettingViewCell *editingCell;


@end

@implementation SettingViewController

- (void)initData {
    ASRConfig *config = [ASRConfig config];
    
    NSMutableArray *settingsArray = [NSMutableArray array];
    
    SettingViewCellModel *settingModel = nil;
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"HostAddress:";
    settingModel.descrptionString = config.hostAddress;
    settingModel.valueString = config.hostAddress;
    [settingsArray addObject:settingModel];
    
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"Port:";
    settingModel.descrptionString = config.serverPort;
    settingModel.valueString = config.serverPort;
    [settingsArray addObject:settingModel];
    
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"模型类别:";
    settingModel.descrptionString = config.productDescription;
    settingModel.valueString = config.productId;
    settingModel.isTextFieldEditEnable = NO;
    [settingsArray addObject:settingModel];
    
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"音频采样率:";
    settingModel.descrptionString = config.sampleRate;
    settingModel.valueString = config.sampleRate;
    [settingsArray addObject:settingModel];
    
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"账户设置";
    settingModel.isShowTextField = NO;
    [settingsArray addObject:settingModel];
    
    settingModel = [SettingViewCellModel new];
    settingModel.title = @"reset";
    settingModel.titleColor = [UIColor redColor];
    settingModel.isShowTextField = NO;
    [settingsArray addObject:settingModel];
    
    self.settings = settingsArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initData];

    UIView *footer = [[UIView alloc] init];
    self.settingTableView.tableFooterView = footer;
}

- (void)cancelEdit {
    if (self.editingCell != nil && self.editingCell.textField.isFirstResponder) {
        [self.editingCell.textField resignFirstResponder];
    }
    self.pickerHeight.constant = 0.0;
}

- (NSString *)productDesWithIndex:(NSInteger)index {
    NSString *proDes = @"";
    ASRConfig *config = [ASRConfig config];

    if (index >= 0 && index <= config.productIDDataSource.count) {
        proDes = [config.productIDDataSource objectAtIndex:index];
    }
    return proDes;
}

- (IBAction)pickModel:(id)sender {
    ASRConfig *config = [ASRConfig config];
    NSString *product = config.productId;
    NSInteger index = [config.productIDArray indexOfObject:product];
    
    if (index >= 0 && index <= config.productIDDataSource.count) {
        [self.modelPicker selectRow:index inComponent:0 animated:NO];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)conform:(id)sender {
    [self cancelEdit];
    
    ASRConfig *config = [ASRConfig config];
    
    SettingViewCell *cell = nil;

    cell = [self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *address = cell.textField.text;
    cell = [self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *port = cell.textField.text;

    NSString *productID = [config.productIDArray objectAtIndex:[self.modelPicker selectedRowInComponent:0]];
    cell = [self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSString *sampleRate = cell.textField.text;
    
    config.hostAddress = address;
    config.serverPort = port;
    config.productId = productID;
    config.sampleRate = sampleRate;
    
    [config save];
    
    [self performSelector:@selector(back:) withObject:nil afterDelay:.5f];
}

- (IBAction)reset:(id)sender {
    [[ASRConfig config] reset];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"数据已恢复为原始设置，重启App生效！" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)settingViewCellBeginEdit:(SettingViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    self.editingCell = cell;
    self.pickerHeight.constant = 0.0;
}

#pragma mark- UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingViewCellModel *model = [self.settings objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingViewCell"];
    if (cell == nil) {
        cell = [SettingViewCell cellWithNib];
    }
    SettingViewCellModel *model = [self.settings objectAtIndex:indexPath.row];
    
    cell.title.text = model.title;
    cell.textField.text = model.descrptionString;
    cell.title.textColor = model.titleColor;
    cell.textField.hidden = !model.isShowTextField;
    cell.textField.userInteractionEnabled = model.isTextFieldEditEnable;
    cell.indexPath = indexPath;
    cell.cellDelegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"index - %ld", indexPath.row);
    if (self.editingCell != nil && self.editingCell.textField.isFirstResponder) {
        [self.editingCell.textField resignFirstResponder];
        return;
    }

    if (self.pickerHeight.constant == 220.0) {
        self.pickerHeight.constant = 0.0;
        return;
    }

    if (indexPath.row == 2) {
        [self pickModel:nil];
        self.pickerHeight.constant = 220.0;
    }
    
    if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"gotoLogin" sender:nil];
    }
    
    if (indexPath.row == 5) {
        [self reset:nil];
    }
}

#pragma mark- UIPickerViewDelegate UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    ASRConfig *config = [ASRConfig config];
    return config.productIDDataSource.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return self.view.frame.size.width;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    ASRConfig *config = [ASRConfig config];
    NSString *title = [config.productIDDataSource objectAtIndex:row];
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *proDes = [self productDesWithIndex:row];
    
    SettingViewCellModel *model = [self.settings objectAtIndex:2];
    model.descrptionString = proDes;
    
    SettingViewCell *cell = [self.settingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.textField.text = proDes;
//    [self.modelBtn setTitle:proDes forState:UIControlStateNormal];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end