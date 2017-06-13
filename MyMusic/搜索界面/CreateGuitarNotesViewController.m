//
//  CreateGuitarNotesViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/6/7.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "CreateGuitarNotesViewController.h"
#import "NotesViewController.h"
#import "NotesModel.h"

@interface CreateGuitarNotesViewController ()<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@end

@implementation CreateGuitarNotesViewController {
    
    NotesModel *notesModel;
    UIPickerView *fretPicker;
    
    // 节拍
    int fretNum;
    int notePerFlat;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [NotesModel sharedInstance];
    
    // 初始化节拍数和音符种类，4/4拍
    fretNum = 4;
    notePerFlat = 4;
    
    // 节拍选择器
    fretPicker = [[UIPickerView alloc] init];
    [fretPicker setBackgroundColor:[UIColor grayColor]];
    fretPicker.delegate = self;
    
    // textField的delegate
    self.tfdGuitarNoteName.delegate = self;
    self.tfdFret.delegate = self;
    self.tfdSpeed.delegate = self;
    
    // textField相关设定
    self.tfdFret.text = [NSString stringWithFormat:@"%d/%d", fretNum, notePerFlat];
    self.tfdFret.inputView = fretPicker;
    self.tfdSpeed.keyboardType = UIKeyboardTypeNumberPad;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 【确定】按钮按下事件，按textField设定新建吉他谱并打开

 @param sender 【确定】按钮
 */
- (IBAction)btnOKClicked:(id)sender {
    
    // 新建空的吉他谱
    NSString *guitarNotesTitle = self.tfdGuitarNoteName.text;
    NSString *flat = self.tfdFret.text;
    NSString *speed = self.tfdSpeed.text;
    NSMutableDictionary *rootGuitarNotes = [[NSMutableDictionary alloc] init];
    [rootGuitarNotes setValue:guitarNotesTitle forKey:@"GuitarNotesName"];
    [rootGuitarNotes setValue:flat forKey:@"Flat"];
    [rootGuitarNotes setValue:speed forKey:@"Speed"];
    [rootGuitarNotes setValue:@1 forKey:@"BarNum"];
    NSMutableArray *barNoArray = [[NSMutableArray alloc] init];
    NSMutableArray *noteNoArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *noteDic = [[NSMutableDictionary alloc] init];
    [noteDic setValue:@"4" forKey:@"NoteType"];
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    NSMutableDictionary *note = [[NSMutableDictionary alloc] init];
    [note setValue:@-1 forKey:@"FretNo"];
    [note setValue:@"Normal" forKey:@"PlayType"];
    [note setValue:@-1 forKey:@"StringNo"];
    [notes addObject:note];
    [noteDic setValue:notes forKey:@"noteArray"];
    [noteNoArray addObject:noteDic];
    [barNoArray addObject:noteNoArray];
    [rootGuitarNotes setValue:barNoArray forKey:@"GuitarNotes"];
    
    // 将新建的空吉他谱存入temp文件夹
    [notesModel writeToTmpDirectory:rootGuitarNotes withGuitarNotesTitle:guitarNotesTitle];
    
    // 构建新建的空吉他谱界面
    NotesViewController *notesViewController = [[NotesViewController alloc] init];
    notesViewController.guitarNotesTitle = guitarNotesTitle;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:notesViewController];
    
    // 释放吉他谱新建界面，并打开空吉他谱界面
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.presentingViewController presentViewController:navi animated:YES completion:nil];
}


/**
 【取消】按钮按下事件，不保存新建的空吉他谱，并关闭新建吉他谱界面

 @param sender 【取消】按钮
 */
- (IBAction)btnCancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ---- TextField Delegate ----
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [fretPicker selectRow:fretNum inComponent:0 animated:YES];
    [fretPicker selectRow:notePerFlat inComponent:1 animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self.tfdFret resignFirstResponder];
}

#pragma mark ---- touch事件 ----
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.tfdFret resignFirstResponder];
    [self.tfdGuitarNoteName resignFirstResponder];
    [self.tfdSpeed resignFirstResponder];
}

#pragma mark ---- PickerView DataSource and Delegate ----
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 8;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%ld", row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        fretNum = (int)row;
    } else {
        notePerFlat = (int)row;
    }
    self.tfdFret.text = [NSString stringWithFormat:@"%d/%d", fretNum, notePerFlat];
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
