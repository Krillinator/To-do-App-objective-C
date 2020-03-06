//
//  ViewController.m
//  TodoListAppLab
//
//  Created by Kristoffer on 2020-02-29.
//  Copyright © 2020 Kristoffer. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic) NSMutableArray *items;
@property (nonatomic) NSArray *categories;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Categories setup
    self.categories = @[@"Home", @"Work"];
    
    // Loading Saved State
    NSUserDefaults *itemUserDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedTodos = [itemUserDefaults objectForKey:@"itemList"];
    if (savedTodos != nil) {
        self.items = [savedTodos mutableCopy];
    } else {
        self.items = [NSMutableArray new];
    }
    [itemUserDefaults synchronize];
    
    /*
        self.items = @[@{@"name" : @"Go outside",            @"category" : @"Home"},
                       @{@"name" : @"Chill",                 @"category" : @"Home"},
                       @{@"name" : @"Die or something",      @"category" : @"Work"}].mutableCopy;
    */
    
    //reloadTableViewData
    
    self.navigationItem.title = @"To-do list";
    
    // Edit Button (top left)
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(toggleEditing:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
}

#pragma mark - Editing

// Edit button
- (void)toggleEditing:(UIBarButtonItem *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if (self.tableView.editing) {
        sender.title = @"Done";
        sender.style = UIBarButtonItemStyleDone;
    } else {
        sender.title = @"Edit";
        sender.style = UIBarButtonItemStylePlain;
    }
}

#pragma mark - Adding items

// Add through UIAlertController
- (void)addNewItem:(UIBarButtonItem * ) sender {
    UIAlertController * alert = [UIAlertController
                    alertControllerWithTitle:@"Add New to-do item"
                                     message:@"Do you wish to add a new item?"
                              preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesButton =
    [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
       // handle add, button code:
       UIAlertController * alertController = [UIAlertController
                          alertControllerWithTitle: @"Add item to your list"
                                           message: @"Please enter the name"
                          preferredStyle:UIAlertControllerStyleAlert];
         [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"What itme do you want to add?";
                textField.textColor = [UIColor blueColor];
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSArray * textfields = alertController.textFields;
            UITextField * namefield = textfields[0];
            
            NSLog(@"%@:",namefield.text); // LOG - REMOVE THIS LATER - MAYBE...
            
            // item attribuets
            NSDictionary *item = @{@"name" : namefield.text, @"category" : @"Home"};
            
                      // // // // // // // // //
                     // #### Adding item #### /
                    // // // // // // // // //
            // 1. Add object (item attributes above)
            // 2. Get int for items in list 'numHomeItems'
            // 3. Insert Rows 'numHomeItems' - 1? didn't work with +.
            [self.items addObject:item];
            NSInteger numHomeItems = [self numberOfItemsInCategory:@"Home"];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:numHomeItems - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Saving For user defaults
            NSUserDefaults *itemUserDefaults = [NSUserDefaults standardUserDefaults];
            [itemUserDefaults setValue:self.items forKey:@"itemList"];
            [itemUserDefaults synchronize];
              
            [self.tableView reloadData];
            
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
            }];
            UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                // Handle Cancel, button
                // LEAVE EMPTY FOR NO EFFECT
                }];
    [alert addAction:yesButton];
    [alert addAction:noButton];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Datasource helper methods

// Category items
- (NSArray *) itemsInCategory:(NSString *)targetCategory {
    NSPredicate *matchingPredicate = [NSPredicate predicateWithFormat:@"category == %@", targetCategory];
    NSArray *categoryItems = [self.items filteredArrayUsingPredicate:matchingPredicate];
    
    return categoryItems;
}

- (NSInteger)numberOfItemsInCategory:(NSString *)targetCategory {
    
    return [self itemsInCategory:targetCategory].count;
}

// Item at row:
- (NSDictionary *)itemAtIndexPath:(NSIndexPath *) indexPath {
    NSString *category = self.categories[indexPath.section];
    NSArray *categoryItems = [self itemsInCategory:category];
    NSDictionary *item = categoryItems[indexPath.row];
    
    return item;
}

// Item at (index):
- (NSInteger)itemIndexForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    NSInteger index = [self.items indexOfObjectIdenticalTo:item];
    
    return index;
}

// Get Remove at Index
-(void) removeItemAtIndexPath:(NSIndexPath *) indexPath {
    NSInteger index = [self itemIndexForIndexPath:indexPath];
    [self.items removeObjectAtIndex:index];
}

#pragma mark - Table view datasource

// Categories
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.categories.count;
}

// tableView Rows for items.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self numberOfItemsInCategory:self.categories[section]];
    }

// Setup
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ToDoItemRow";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *item = [self itemAtIndexPath:indexPath];
    
    cell.textLabel.text = item[@"name"];
    
    // Make check when scrolling to properly work
    if ([item[@"completed"] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.categories[section];
}

#pragma mark - Table view delegate

// Checkmark on click
- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger index = [self itemIndexForIndexPath:indexPath];
    
    NSMutableDictionary *item = [self.items[index] mutableCopy];
    BOOL completed = [item[@"completed"] boolValue];
    item[@"completed"] = @(!completed);
    
    self.items[index] = item;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = ([item[@"completed"] boolValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

// EDIT Button - delete button
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeItemAtIndexPath:indexPath];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        NSUserDefaults *itemUserDefaults = [NSUserDefaults standardUserDefaults];
        [itemUserDefaults setValue:self.items forKey:@"itemList"];
        [itemUserDefaults synchronize];
        
        [self.tableView reloadData];
    }
}

@end
