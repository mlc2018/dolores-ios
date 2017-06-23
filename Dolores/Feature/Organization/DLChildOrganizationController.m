//
// DLChildOrganizationController
// Artsy
//
//  Created by heath on 23/06/2017.
//  Copyright (c) 2014 http://artsy.net. All rights reserved.
//
#import "DLChildOrganizationController.h"
#import "DLRootContactCell.h"
#import "DLUserDetailController.h"

@interface DLChildOrganizationController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

#pragma mark - data
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, strong) RLMResults<RMDepartment *> *rootDepartments;
@property (nonatomic, strong) RMDepartment *department;

@end

@implementation DLChildOrganizationController

#pragma mark - init

- (instancetype)initWithDepartmentId:(NSString *)departmentId {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _departmentId = [departmentId copy];
        if ([NSString isEmpty:departmentId]) {
            _isRoot = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    if (self.isRoot) {
        self.navigationItem.title = @"组织架构";
    } else {
        self.navigationItem.title = self.department.departmentName;
    }

    [self setupView];
}

- (void)setupData {
    self.rootDepartments = [DLDBQueryHelper rootDepartments];
    if (!self.isRoot) {
        self.department = [RMDepartment objectForPrimaryKey:self.departmentId];
    }
}

- (void)setupView {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isRoot) {
        return self.rootDepartments.count;
    }
    return self.department.staffs.count + self.department.childrenDepartments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLRootContactCell *rootContactCell = [tableView dequeueReusableCellWithIdentifier:[DLRootContactCell identifier]];
    if (self.isRoot) {
        RMDepartment *department = self.rootDepartments[(NSUInteger) indexPath.row];
        [rootContactCell updateImage:[UIImage imageNamed:@"cmail_list_folder"] title:department.departmentName];
    } else {

        if (self.department.staffs.count > 0) {
            if (indexPath.row < self.department.staffs.count) {
                RMStaff *staff = self.department.staffs[indexPath.row];
                [rootContactCell.imgPlace sd_setImageWithURL:[NSURL URLWithString:[staff qiniuURLWithSize:CGSizeMake(40, 40)]] placeholderImage:[UIImage imageNamed:@"contact_icon_avatar_placeholder_round"]];
                rootContactCell.lblTitle.text = staff.realName;
            } else {
                RMDepartment *department1 = self.department.childrenDepartments[indexPath.row - self.department.staffs.count + 1];
                [rootContactCell updateImage:[UIImage imageNamed:@"cmail_list_folder"] title:department1.departmentName];
            }
        } else {
            RMDepartment *department1 = self.department.childrenDepartments[indexPath.row];
            [rootContactCell updateImage:[UIImage imageNamed:@"cmail_list_folder"] title:department1.departmentName];
        }

    }
    return rootContactCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isRoot) {
        RMDepartment *department1 = self.rootDepartments[indexPath.row];
        [self reviewChildDepartment:department1.departmentId];
    } else {

        if (self.department.staffs.count > 0) {
            if (indexPath.row < self.department.staffs.count) {
                RMStaff *staff = self.department.staffs[indexPath.row];
                DLUserDetailController *userDetailController = [[DLUserDetailController alloc] initWithUid:staff.uid];
                [self.navigationController pushViewController:userDetailController animated:YES];
            } else {
                RMDepartment *department1 = self.department.childrenDepartments[indexPath.row - self.department.staffs.count + 1];
                [self reviewChildDepartment:department1.departmentId];
            }
        } else {
            RMDepartment *department1 = self.department.childrenDepartments[indexPath.row];
            [self reviewChildDepartment:department1.departmentId];
        }

    }
}

- (void)reviewChildDepartment:(NSString *)departmentId {
    DLChildOrganizationController *childOrganizationController = [[DLChildOrganizationController alloc] initWithDepartmentId:departmentId];
    [self.navigationController pushViewController:childOrganizationController animated:YES];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];

        [DLRootContactCell registerIn:_tableView];

        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end