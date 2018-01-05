//
//  HistoryVC.m
//  Quantle
//
//  Created by Olga Saukh on 5/05/17.
//  Copyright (c) 2017 chatterboxbit.com. All rights reserved.
//
//  Quantle is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Quantle is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Quantle.  If not, see <http://www.gnu.org/licenses/>.
//

#import "HistoryVC.h"
#import "StatisticsVC.h"
#import "AppDelegate.h"
#import "TalkData.h"

@interface HistoryVC ()
@end

@implementation HistoryVC

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the table
    return [self.appDelegate.historyEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // Set background of cell
    cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    // Set background if cell selected
    UIView *cellSelColorView = [[UIView alloc] init];
    cellSelColorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    cell.selectedBackgroundView = cellSelColorView;
    
    // Set all information of the cell
    if (indexPath.row >= [self.appDelegate.historyEntries count]) {
        NSLog(@"ERROR: Table requires access to non-existing element in history array");
        return cell;
    }
    
    TalkData *talk = (self.appDelegate.historyEntries)[indexPath.row];
    cell.textLabel.text = talk.speakerName;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'  'HH':'mm':'ss"];
    NSString *dateString = [dateFormatter stringFromDate: talk.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
                            talk.eventName, dateString];
    
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(16, 5, 32, 32)];
    imgView.backgroundColor=[UIColor clearColor];
    [imgView.layer setCornerRadius:8.0f];
    [imgView.layer setMasksToBounds:YES];
    [imgView setImage:[UIImage imageWithData:talk.speakerPicture]];
    #define MY_CUSTOM_TAG 1234
    imgView.tag = MY_CUSTOM_TAG;
    [[cell.contentView viewWithTag:MY_CUSTOM_TAG]removeFromSuperview];
    [cell.contentView addSubview:imgView];
    
    return cell;
}

// Prepare for segue to map view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [[self tableView] indexPathForSelectedRow];
    TalkData *t = self.appDelegate.historyEntries[indexPath.row];
    
    [segue.destinationViewController initData:(int)indexPath.row talk:t];
}

// delete row on swipe
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Delete talk entry");
    // tell the table view you're going to make an update
    [self.tableView beginUpdates];
    // Delete the row from the data source
    [self.appDelegate.historyEntries removeObjectAtIndex:(int)indexPath.row];
    [self.appDelegate saveHistory];
    // tell the table view to delete the row
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    // tell the table view that you're done
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

@end
