//
//  SVViewController.m
//  SVPullToRefreshDemo
//
//  Created by Sam Vermette on 23.04.12.
//  Copyright (c) 2012 Home. All rights reserved.
//

#import "SVViewController.h"
#import "SVPullToRefresh.h"

@interface SVViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation SVViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDataSource];
    
    __weak SVViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [_tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
        
    // setup infinite scrolling
    [_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[tableView triggerPullToRefresh];
}

#pragma mark - Actions

- (void)setupDataSource {
    self.dataSource = [NSMutableArray array];
    for(int i=0; i<5; i++)
        [self.dataSource addObject:[NSDate dateWithTimeIntervalSinceNow:-(i*90)]];
}

- (void)insertRowAtTop {

    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [_tableView beginUpdates];
        [_dataSource insertObject:[NSDate date] atIndex:0];
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        [_tableView endUpdates];

        [_tableView.pullToRefreshView stopAnimating];
    });
}


- (void)insertRowAtBottom {

    int64_t delayInSeconds = 1.0;

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (self.dataSource.count < 15) {
            
            //Method 1, to add items ****
            [_tableView beginUpdates];
            // add items to data source
            [_dataSource addObject:[_dataSource.lastObject dateByAddingTimeInterval:-90]];
            // insert rows to table directly with animation
            [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [_tableView endUpdates];
            //Method 1 end
            
            //Method 2, to add items ***
            // add items to data source and reload the tableview
//            [_dataSource addObject:[_dataSource.lastObject dateByAddingTimeInterval:-90]];
//            [_tableView reloadData];
            //Method 2 end

        }
        
        //stop the scrolling icon
        [_tableView.infiniteScrollingView stopAnimating];
    });
}
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    
    NSDate *date = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    return cell;
}

@end
