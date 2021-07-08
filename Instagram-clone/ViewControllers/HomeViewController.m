//
//  HomeViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/6/21.
//

#import "HomeViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "Post.h"
#import "FeedTableViewCell.h"
#import "DetailsViewController.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayOfPosts;
@property (assign, nonatomic) BOOL isMoreDataLoading;
@property (assign, nonatomic) long skip;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set tableview delegate and datasource
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Set skip value
    self.skip = 0;
    
    // Instantiate refreshControl
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    
    // Load in data
    [self beginRefresh:refreshControl];
}
- (IBAction)didTapLogOut:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
        SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        myDelegate.window.rootViewController = loginViewController;
        
    }];
}
- (IBAction)didTapCamera:(id)sender {
    [self performSegueWithIdentifier:@"toCamera" sender:nil];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {

    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            self.arrayOfPosts = [posts mutableCopy];
            self.skip = self.arrayOfPosts.count;
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        // Tell the refreshControl to stop spinning
         [refreshControl endRefreshing];
        
        // Refresh tableview
        [self.tableView  reloadData];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier  isEqual: @"toDetails"]){
        DetailsViewController *detailsViewController = [segue destinationViewController];
        FeedTableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        detailsViewController.post = self.arrayOfPosts[indexPath.row];
    
        tappedCell.highlighted = false;
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableViewCell"];
    Post *post = self.arrayOfPosts[indexPath.row];
    [self configureCell:cell withPost:post];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

- (void)configureCell:(FeedTableViewCell *)cell withPost: (Post *)post{
    // Configure labels
    cell.authorLabel.text = post.author.username;
    cell.captionLabel.text = post.caption;
    cell.likeLabel.text = [post.likeCount stringValue];

    // Configure image
    cell.postImageView.file = post.image;
    [cell.postImageView loadInBackground];
}

-(void)loadMoreData{
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;
    postQuery.skip = self.skip;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            // Update flag
            self.isMoreDataLoading = false;
            
            // Use the new data to update the data source
            [self.arrayOfPosts addObjectsFromArray:posts];
            
            // Increase skip number
            self.skip += posts.count;
            
            // Reload the tableView now that there is new data
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
//        // Tell the refreshControl to stop spinning
//         [refreshControl endRefreshing];
        
        // Refresh tableview
        [self.tableView  reloadData];
    }];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.tableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
            self.isMoreDataLoading = true;
            [self loadMoreData];
        }
    }
}

@end
