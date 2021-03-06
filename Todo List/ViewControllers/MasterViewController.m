//
//  MasterViewController.m
//  Todo List
//
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"
#import "TodoList.h"
#import "UIImage+iPhone5.h"
#import "MasterCell.h"

@interface MasterViewController ()<UITextFieldDelegate> {
    __block NSMutableArray *_todoLists;
}
@end

@implementation MasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Lists";
    UIImage *navBarImage = [UIImage tallImageNamed:@"ipad-menubar-left.png"];
    
    [self.navigationController.navigationBar setBackgroundImage:navBarImage
                                                  forBarMetrics:UIBarMetricsDefault];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
    [self.view setBackgroundColor:bgColor];
    
    if([APUser currentUser] == nil) {
        UIStoryboard *storyBoardTemp = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        __weak LoginViewController *loginViewController = (LoginViewController *) [storyBoardTemp instantiateViewControllerWithIdentifier:@"login"];
        loginViewController.loginSuccessful = ^() {
            [self fetchTodoLists];
        };
        [self.navigationController pushViewController:loginViewController animated:YES];
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlRequestMade) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    textField.borderStyle = UITextBorderStyleLine;
    textField.placeholder = @"Create a new list";
    textField.delegate = self;
    self.tableView.tableHeaderView = textField;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionReceived) name:SessionReceivedNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) sessionReceived {
}

- (void) fetchTodoLists {
    APUser *currentUser = [APUser currentUser];
    
    NSString *query = [NSString stringWithFormat:@"articleid=%lld&label=todolists", currentUser.objectId.longLongValue];
    
    [APConnection searchForConnectionsWithRelationType:@"user_lists" withQueryString:query successHandler:^(NSDictionary *result) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            NSArray *connections = [result objectForKey:@"connections"];
            __block NSMutableArray *todoListIds;
            
            [connections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                NSDictionary * connection = (NSDictionary*) obj;
                if (todoListIds == nil) {
                    todoListIds = [NSMutableArray array];
                }
                [todoListIds addObject:[[connection objectForKey:@"__endpointb"] objectForKey:@"articleid"]];
            }];
            
            if (todoListIds != nil) {
                [APObject fetchObjectsWithObjectIds:todoListIds
                                         schemaName:@"todolists"
                                     successHandler:^(NSDictionary *result) {
                                         NSArray *todoLists = [result objectForKey:@"articles"];
                                         [todoLists enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                                             NSDictionary *taskDict = (NSDictionary*) obj;
                                             
                                             TodoList *todoList = [[TodoList alloc] init];
                                             todoList.text = [taskDict objectForKey:@"list_name"];
                                             todoList.completedAtDate = [taskDict objectForKey:@"completed_at"];
                                             todoList.objectId = [taskDict objectForKey:@"__id"];
                                             
                                             if (_todoLists == nil) {
                                                 _todoLists = [NSMutableArray array];
                                             }
                                             
                                             
                                             if (![_todoLists containsObject:todoList]) {
                                                 [_todoLists addObject:todoList];
                                             } else {
                                                 [_todoLists removeObject:todoList];
                                                 [_todoLists addObject:todoList];
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

#pragma mark UIRefreshControl method

- (void) refreshControlRequestMade {
    [self fetchTodoLists];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _todoLists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MasterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MasterCell" forIndexPath:indexPath];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    TodoList *todoList = _todoLists[indexPath.row];
    cell.titleLabel.text = todoList.text;
    cell.textLabel.text = [todoList.completedAtDate description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        TodoList *todoList = _todoLists[indexPath.row];
        
        APObject *object = [APObject objectWithSchemaName:@"todolists"];
        object.objectId = todoList.objectId;
        [object deleteObjectWithConnectingConnectionsSuccessHandler:^(){
            [_todoLists removeObject:todoList];
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
            });
        } failureHandler:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        TodoList *todoList = _todoLists[indexPath.row];
        
        DetailViewController *detailViewController = (DetailViewController*)[(UINavigationController*)[self.splitViewController.viewControllers lastObject] topViewController];
        [detailViewController setTodoList:todoList];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TodoList *todoList = _todoLists[indexPath.row];
        
        DetailViewController *detailViewController = [segue destinationViewController];
        [detailViewController setTodoList:todoList];
    }
}

#pragma mark UITextField delegate method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text != nil && [textField.text length] != 0) {

        APObject *todoList = [APObject objectWithSchemaName:@"todolists"];
        [todoList addPropertyWithKey:@"list_name" value:textField.text];
        [todoList saveObjectWithSuccessHandler:^(NSDictionary *result) {
            if (_todoLists == nil) {
                _todoLists = [NSMutableArray array];
            }
            
            TodoList *newList = [[TodoList alloc] init];
            newList.objectId = [[result objectForKey:@"article"] objectForKey:@"__id"];
            newList.text = textField.text;
            [_todoLists addObject:newList];

            textField.text = nil;
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.tableView reloadData];
            });
            
            APConnection *connection = [[APConnection alloc] initWithRelationType:@"user_lists"];
            connection.labelA = @"user";
            connection.articleAId = [[APUser currentUser] objectId];
            connection.labelB =@"todolists";
            connection.articleBId = newList.objectId;
            
            [connection create];
            
        } failureHandler:nil];
    }
    [textField resignFirstResponder];
    return YES;
}
@end
