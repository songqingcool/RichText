//
//  ViewController.m
//  RichTextDemo
//
//  Created by SONGQG on 2018/3/8.
//  Copyright © 2018年 思源. All rights reserved.
//

#import "ViewController.h"
#import "RichTextCell.h"
#import "RichModel.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    [self loadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i< 10; i++) {
        RichModel *model = [[RichModel alloc] init];
        [array addObject:model];
    }
    [self.dataArray addObjectsFromArray:array];
    [self.tableView reloadData];
}

#pragma mark - 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RichModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.cellHeight == 0.0) {
        model.cellHeight = [RichTextCell cellHeightWithModel:model];
    }
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RichModel *model = [self.dataArray objectAtIndex:indexPath.row];
    RichTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RichTextCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSLog(@"进入详情页 %ld",indexPath.row);
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[RichTextCell class] forCellReuseIdentifier:@"RichTextCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
