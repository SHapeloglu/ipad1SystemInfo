#import "OverviewViewController.h"
#import "SystemMetrics.h"

@implementation OverviewViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"SystemInfo";
        _metrics = [[SystemMetrics alloc] init];
        _sections = nil;
    }
    return self;
}

- (NSDictionary *)sectionWithTitle:(NSString *)title rows:(NSArray *)rows {
    return [NSDictionary dictionaryWithObjectsAndKeys:title, @"title", rows, @"rows", nil];
}

- (void)reloadSnapshot {
    NSArray *newSections = [NSArray arrayWithObjects:
        [self sectionWithTitle:@"General" rows:[_metrics generalRows]],
        [self sectionWithTitle:@"CPU" rows:[_metrics cpuRows]],
        [self sectionWithTitle:@"Memory" rows:[_metrics memoryRows]],
        [self sectionWithTitle:@"Storage" rows:[_metrics storageRows]],
        [self sectionWithTitle:@"Network" rows:[_metrics networkRows]],
        [self sectionWithTitle:@"Bluetooth" rows:[_metrics bluetoothRows]],
        [self sectionWithTitle:@"Battery" rows:[_metrics batteryRows]],
        nil];

    [_sections release];
    _sections = [newSections retain];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadSnapshot];
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(reloadSnapshot)
                                               userInfo:nil
                                                repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (NSInteger)[_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *sectionInfo = [_sections objectAtIndex:(NSUInteger)section];
    return (NSInteger)[[sectionInfo objectForKey:@"rows"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[_sections objectAtIndex:(NSUInteger)section] objectForKey:@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MetricCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
    }

    NSDictionary *sectionInfo = [_sections objectAtIndex:(NSUInteger)indexPath.section];
    NSArray *rows = [sectionInfo objectForKey:@"rows"];
    NSDictionary *row = [rows objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = [row objectForKey:@"title"];
    cell.detailTextLabel.text = [row objectForKey:@"value"];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_timer invalidate];
    [_sections release];
    [_metrics release];
    [super dealloc];
}

@end
