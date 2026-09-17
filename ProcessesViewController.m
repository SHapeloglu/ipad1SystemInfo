#import "ProcessesViewController.h"
#import "SystemMetrics.h"

@implementation ProcessesViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Processes";
        _metrics = [[SystemMetrics alloc] init];
        _processes = nil;
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                 target:self
                                 action:@selector(reloadProcesses)] autorelease];
    }
    return self;
}

- (void)reloadProcesses {
    NSArray *list = [_metrics processes];
    [_processes release];
    _processes = [list retain];
    self.title = [NSString stringWithFormat:@"Processes (%lu)", (unsigned long)[_processes count]];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadProcesses];
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                 target:self
                                               selector:@selector(reloadProcesses)
                                               userInfo:nil
                                                repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)[_processes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProcessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    }

    NSDictionary *process = [_processes objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = [process objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"PID: %@", [process objectForKey:@"pid"]];
    return cell;
}

- (void)dealloc {
    [_timer invalidate];
    [_processes release];
    [_metrics release];
    [super dealloc];
}

@end
