//
//  CreateMyMusicListViewController.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/16.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "CreateMyMusicListViewController.h"
#import "ModelDataController.h"

@interface CreateMyMusicListViewController ()
@property (strong, nonatomic) IBOutlet UITextField *tfdMusicListTitle;

@end

@implementation CreateMyMusicListViewController

{
    ModelDataController *modelDataController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    modelDataController = [ModelDataController sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 * @brief [完成]按钮事件
 * @discussion 当歌单标题为空时，提示【歌单标题不能为空】，当歌单标题不为空时，关闭窗口，返回上层并刷新【我的歌单】
 */
- (IBAction)done:(id)sender {
    if ([self.tfdMusicListTitle.text isEqual: @""]) {
        
    } else {
        // 更新我的歌单数据
        [modelDataController addMyMusicList:self.tfdMusicListTitle.text];
        
        // 通知上层的masterTableView刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didMyMusicListChanged" object:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
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
