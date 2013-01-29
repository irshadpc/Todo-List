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

@interface DetailViewController ()<UITextFieldDelegate> {
    __block NSMutableArray *_tasks;
}
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
    [self.view setBackgroundColor:bgColor];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlRequestMade) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    UIImage *backButton = [[UIImage tallImageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
}

- (void) refreshControlRequestMade {
    [self fetchTasks];
}

- (void) setTodoList:(TodoList *)todoList {
    _todoList = todoList;
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
            [APObject fetchObjectsWithObjectIds:taskIds
                                     schemaName:@"tasks"
                                 successHandler:^(NSDictionary *result) {
                                     NSArray *tasks = [result objectForKey:@"articles"];
                                     [tasks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                                         NSDictionary *taskDict = (NSDictionary*) obj;
                                         
                                         Task *task = [[Task alloc] init];
                                         task.text = [taskDict objectForKey:@"text"];
                                         task.completedAtDate = [APHelperMethods deserializeJsonDateString:[taskDict objectForKey:@"completed_at"]];
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
    return cell;
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
@end
