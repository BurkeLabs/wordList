//
//  wordListViewController.m
//  wordList
//
//  Created by Michelle Burke on 1/17/17.
//  Copyright © 2017 BurkeLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "WordList.h"
#import "wordListViewController.h"

@interface wordListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITableView *wordListTV;
@property (weak, nonatomic) IBOutlet UITextField *addWord;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property WordList *words;

@end

@implementation wordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    self.words = [WordList newWithMoc:delegate.managedObjectContext];
    
}

#pragma mark - IBActions
- (IBAction)onAddButtonPressed:(UIBarButtonItem *)sender {
    if ([self.addWord.text isEqual: @""]) {
        return;
    }
    [self.words addWord:self.addWord.text];
    self.addWord.text = @"";
    [self.addWord resignFirstResponder];
    [self.wordListTV reloadData];
}

- (IBAction)onSwipe:(UISwipeGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.wordListTV];
    NSIndexPath *indexPath = [self.wordListTV indexPathForRowAtPoint:point];

    [self.words rotateWordStateAtIndex:indexPath.row];
    [self.wordListTV reloadData];
}

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender {
    if (self.editing)
    {
        self.editing = false;
        [self.wordListTV setEditing:false animated:true];
        sender.style = UIBarButtonItemStylePlain;
        sender.title = @"Edit";
    } else {
        self.editing = true;
        [self.wordListTV setEditing:true animated:true];
        sender.title = @"Done";
    }
    [self.wordListTV reloadData];
}

#pragma mark - UITableView
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm Deletion?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            UITableViewCell *cell = [self.wordListTV cellForRowAtIndexPath:indexPath];
            NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            UITableViewCell *cell2 = [self.wordListTV cellForRowAtIndexPath:path];
            cell.textLabel.textColor = cell2.textLabel.textColor;
            [self.words removeAtIndex:indexPath.row];
            [self.wordListTV reloadData];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:delete];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    [self.words moveFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    [self.wordListTV reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.wordListTV cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor darkGrayColor];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Word *word = [self.words atIndex:indexPath.row];
    if (word) {
        UITableViewCell *cell = [self.wordListTV dequeueReusableCellWithIdentifier:@"word"];
        cell.textLabel.text = word.word;
        cell.detailTextLabel.text = [self wordTypeString:word];
        cell.textLabel.textColor = [self wordTypeColor:word];
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

-(NSString*)wordTypeString:(Word*)word {
    switch(word.type) {
        case WT_SIGN:
            return @"Signed words";
        case WT_SPEAK:
            return @"Words I can say";
        case WT_BOTH:
            return @"Words I can sign or say";
        default:
            return @"New word";
    }
}

-(UIColor*)wordTypeColor:(Word*)word {
    switch(word.type) {
        case WT_SIGN:
            return [UIColor darkGrayColor];
        case WT_SPEAK:
            return [UIColor blueColor];
        case WT_BOTH:
            return [UIColor greenColor];
        default:
            return [UIColor blackColor];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.words count];
}

@end
