//
//  ProfileViewController.m
//  Instagram-clone
//
//  Created by felipeccm on 7/9/21.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "Post.h"
#import "ProfileCollectionViewCell.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *arrayOfPosts;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // construct PFQuery
    PFQuery *postQuery = [Post query];
    [postQuery whereKey:@"author" equalTo:PFUser.currentUser];
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];
    postQuery.limit = 20;

    // fetch data asynchronously
    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<Post *> * _Nullable posts, NSError * _Nullable error) {
        if (posts) {
            
            // Use the new data to update the data source
            self.arrayOfPosts = [posts mutableCopy];
            
            // Reload the tableView now that there is new data
            [self.collectionView reloadData];
        }
        else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        
        [self.collectionView reloadData];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProfileCollectionViewCell"
                                                                            forIndexPath:indexPath];
    Post *post = self.arrayOfPosts[indexPath.item];
    cell.post = post;
    cell.postImageView.file = post.image;
    [cell.postImageView loadInBackground];
    return cell;
}
     
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPosts.count;
}

@end
