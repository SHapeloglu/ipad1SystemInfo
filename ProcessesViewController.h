#import <UIKit/UIKit.h>

@class SystemMetrics;

@interface ProcessesViewController : UITableViewController {
    SystemMetrics *_metrics;
    NSArray *_processes;
    NSTimer *_timer;
}

@end
