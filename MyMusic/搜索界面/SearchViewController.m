//
//  SearchView.m
//  MyMusic
//
//  Created by 孔令文 on 2017/4/10.
//  Copyright © 2017年 孔令文. All rights reserved.
//

#import "SearchViewController.h"
#import "NotesViewController.h"
#import "CreateGuitarNotesViewController.h"
#import "NotesModel.h"

@interface SearchViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation SearchViewController {
    
    NotesModel *notesModel;
    UITableView *notesTableView;
    NSString *dataFilePath;
    NSString *tmpFilePath;
    NSMutableArray *files;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    notesModel = [NotesModel sharedInstance];
    
    notesTableView = [[UITableView alloc] init];
    notesTableView.delegate = self;
    notesTableView.dataSource = self;
    [self.view addSubview:notesTableView];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dataFilePath = [[paths objectAtIndex:0] stringByAppendingString:@"/"];
    tmpFilePath = NSTemporaryDirectory();
    files = [self getGuitarNotesFiles];
}


/**
 获取document路径下所有吉他谱文件

 @return 吉他谱文件名
 */
-(NSMutableArray *)getGuitarNotesFiles {
    NSMutableArray *resultFiles = [[NSMutableArray alloc] init];
    NSMutableArray *guitarNotesFiles = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dataFilePath error:nil] mutableCopy];
    for (int i = 0; i < guitarNotesFiles.count; i++) {
        NSString *fileName = guitarNotesFiles[i];
        if (![fileName hasSuffix:@".plist"]) {
            [guitarNotesFiles removeObject:fileName];
            i--;
            continue;
        }
        [resultFiles addObject:[fileName componentsSeparatedByString:@"."][0]];
    }
    return resultFiles;
}

- (IBAction)test:(id)sender {
    NotesViewController *notesController = [[NotesViewController alloc] init];
    notesController.guitarNotesTitle = @"天空之城version4";
    [self presentViewController:notesController animated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    files = [self getGuitarNotesFiles];
    [notesTableView reloadData];
    [notesTableView setFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 200)];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return files.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    if (indexPath.row == files.count) {
        cell.textLabel.text = @"新建吉他谱";
    } else {
        cell.textLabel.text = files[indexPath.row];
    }
    return cell;
}

/*!
 * @brief 吉他谱单行高度
 * @discussion 返回吉他谱单行高度
 */
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == files.count) {
        CreateGuitarNotesViewController *createGuitarNotesViewController = [[CreateGuitarNotesViewController alloc] init];
        createGuitarNotesViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:createGuitarNotesViewController animated:YES completion:nil];
    } else {
        NSString *fileName = files[indexPath.row];
        NotesViewController *notesViewController = [[NotesViewController alloc] init];
        notesViewController.guitarNotesTitle = [fileName componentsSeparatedByString:@"."][0];
        NSString *from = [dataFilePath stringByAppendingString:fileName];
        NSString *to = [tmpFilePath stringByAppendingString:fileName];
        [notesModel copyFileFrom:from To:to];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:notesViewController];
        [self presentViewController:navi animated:YES completion:nil];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
