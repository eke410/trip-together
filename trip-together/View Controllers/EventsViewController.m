//
//  EventsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "EventsViewController.h"
#import "Event.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"

@interface EventsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *events;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:@"location", @"is_free", @"limit", nil];
    NSArray *values = [[NSArray alloc] initWithObjects:@"500+Memorial+Drive,+Cambridge,+MA,+US", @"true", @"20", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    [self queryEventsWithParams:params];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)queryEventsWithURLString:(NSString *)URLString {
    // get API Key from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *APIKey= [dict objectForKey: @"yelpAPIKey"];
    
    // set request URL and authentication value
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", APIKey];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    // make request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.events = [Event eventsWithArray:dataDictionary[@"events"]];
               [self.tableView reloadData];
           }
       }];
    [task resume];
}

- (void)queryEventsWithParams:(NSDictionary *)params {
    // make string for request params
    NSString *paramString = @"?";
    for (NSString *key in params) {
        NSString *newParamString = [NSString stringWithFormat:@"%@=%@&", key, [params objectForKey:key]];
        paramString = [paramString stringByAppendingString:newParamString];
    }
    paramString = [paramString substringToIndex:[paramString length]-1];
    
    // add param string to yelp event query string
    NSString *URLString = [@"https://api.yelp.com/v3/events" stringByAppendingString:paramString];
    [self queryEventsWithURLString:URLString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.events[indexPath.row];
    [cell refreshData];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EventDetailsViewController *eventDetailsViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Event *event = self.events[indexPath.row];
    eventDetailsViewController.event = event;
}


@end
