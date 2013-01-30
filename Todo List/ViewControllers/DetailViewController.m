//
//  DetailViewController.m
//  Todo List
//
//  Created by Nikhil Prasad on 28/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "TodoList.h"
#import "Task.h"
#import "MasterCell.h"
#import "UIImage+iPhone5.h"

@interface DetailViewController ()<UITextFieldDelegate, UISplitViewControllerDelegate> {
    __block NSMutableArray *_tasks;
}
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *navBarImage = [UIImage tallImageNamed:@"ipad-menubar-right.png"];
    
    [self.navigationController.navigationBar setBackgroundImage:navBarImage
                                                  forBarMetrics:UIBarMetricsDefault];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
    [self.view setBackgroundColor:bgColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlRequestMade) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIImage *backButton = [[UIImage tallImageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    textField.borderStyle = UITextBorderStyleLine;
    textField.placeholder = @"Create a new task";
    textField.delegate = self;
    self.tableView.tableHeaderView = textField;
}

- (void) refreshControlRequestMade {
    [self fetchTasks];
}

- (void) setTodoList:(TodoList *)todoList {
    _todoList = todoList;
    
    self.title = _todoList.text;
    _tasks = nil;
    [self.tableView reloadData];
    [self fetchTasks];
}

- (void) fetchTasks {
    NSString *query = [NSString stringWithFormat:@"articleid=%lld&label=tasks", self.todoList.objectId.longLongValue];
    
    [APConnection searchForConnectionsWithRelationType:@"list_items" withQueryString:query successHandler:^(NSDictionary *result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSArray *connections = [result objectForKey:@"connections"];
            __block NSMutableArray *taskIds;
            
            [connections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSDictionary * connection = (NSDictionary*) obj;
                if (taskIds == nil) {
                    taskIds = [NSMutableArray array];
                }
                [taskIds addObject:[[connection objectForKey:@"__endpointb"] objectForKey:@"articleid"]];
            }];
            
            if (taskIds != nil) {
                [APObject fetchObjectsWithObjectIds:taskIds
                                         schemaName:@"tasks"
                                     successHandler:^(NSDictionary *result) {
                                         NSArray *tasks = [result objectForKey:@"articles"];
                                         [tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                                             NSDictionary *taskDict = (NSDictionary*) obj;
                                             
                                             Task *task = [[Task alloc] init];
                                             task.text = [taskDict objectForKey:@"text"];
                                             task.completedAtDate = [taskDict objectForKey:@"completed_at"];
                                             task.objectId = [taskDict objectForKey:@"__id"];
                                             
                                             if (_tasks == nil) {
                                                 _tasks = [NSMutableArray array];
                                             }
                                             
                                             
                                             if (![_tasks containsObject:task]) {
                                                 [_tasks addObject:task];
                                             } else {
                                                 [_tasks removeObject:task];
                                                 [_tasks addObject:task];
                                             }
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^(){
                                                 [self.tableView reloadData];
                                                 [self.refreshControl endRefreshing];
                                             });
                                         }];
                                     } failureHandler:nil];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.refreshControl endRefreshing];
                });
            }
        });
    } failureHandler:^(APError *error) {
        NSLog(@"%@", error.description);
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MasterCell"];
    
    [cell setSelectionStyle:UITableViewCellEditingStyleNone];
    Task *task = [_tasks objectAtIndex:indexPath.row];
    cell.titleLabel.text = task.text;
    cell.textLabel.text = [task.completedAtDate description];
    
    if (task.completedAtDate != nil) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        Task *task = _tasks[indexPath.row];
        
        APObject *object = [APObject objectWithSchemaName:@"tasks"];
        object.objectId = task.objectId;
        [object deleteObjectWithConnectingConnectionsSuccessHandler:^(){
            [_tasks removeObject:task];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
            });
        } failureHandler:nil];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Task *task = _tasks[indexPath.row];
    APObject *taskObject = [APObject objectWithSchemaName:@"tasks"];
    taskObject.objectId = task.objectId;
    
    if (tableViewCell.accessoryType == UITableViewCellAccessoryNone) {
        [tableViewCell setAccessoryType:UITableViewCellAccessoryCheckmark];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *completedAt = [dateFormatter stringFromDate:[NSDate date]];
        [taskObject addPropertyWithKey:@"completed_at" value:completedAt];
        task.completedAtDate = completedAt;
    } else {
        [tableViewCell setAccessoryType:UITableViewCellAccessoryNone];
        
        [taskObject addPropertyWithKey:@"completed_at" value:[NSNull null]];
        task.completedAtDate = nil;
    }
    [taskObject updateObjectWithSuccessHandler:^(){
        [self.tableView reloadData];
    } failureHandler:nil];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

#pragma mark UITextField delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    __block UITextField *tField = textField;
    if (textField.text != nil && textField.text.length != 0) {
        __block APObject *task = [APObject objectWithSchemaName:@"tasks"];
        [task addPropertyWithKey:@"text" value:textField.text];
        [task saveObjectWithSuccessHandler:^(NSDictionary *result) {
            APConnection *listItemConnection = [APConnection connectionWithRelationType:@"list_items"];
            [listItemConnection createConnectionWithObjectAId:_todoList.objectId
                                                    objectBId:task.objectId
                                                    labelA:@"TodoLists"
                                                    labelB:@"Tasks"
                                                    successHandler:^(){
                                                        NSLog(@"Created a new list item");
                                                        
                                                        Task *t = [[Task alloc] init];
                                                        t.text = tField.text;
                                                        t.objectId = task.objectId;
                                                        
                                                        if (_tasks == nil) {
                                                            _tasks = [NSMutableArray array];
                                                        }
                                                        [_tasks addObject:t];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^(){
                                                            [self.tableView reloadData];
                                                        });
                                                        tField.text = nil;
                                                    } failureHandler:^(APError *error) {
                                                        NSLog(@"%@", error.description);
                                                    }];
        } failureHandler:nil];
    }
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return NO;
}
@end
